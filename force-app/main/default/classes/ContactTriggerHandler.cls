public with sharing class ContactTriggerHandler {
    public static void afterInsert(List<Contact> newList) {
        handleAccountContactRoleCreation(newList, null);
    }
    
    public static void afterUpdate(List<Contact> newList, Map<Id, Contact> oldMap) {
        handleAccountContactRoleCreation(newList, oldMap);
    }

    private static void handleAccountContactRoleCreation(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<Id> accountIdsToCheck = new Set<Id>();
        Set<Id> existingRoleRecordsForAccounts = new Set<Id>();
        List<AccountContactRole> accountContactRoleRecordsToInsert = new List<AccountContactRole>();
 
        for(Contact con : newList) {
            if((oldMap == null && con.AccountId != null) ||
                (oldMap != null && con.AccountId != oldMap.get(con.Id).AccountId && con.AccountId != null)) {
                
                // Adding the account ids to the set for which we have to check if an AccountContactRole record already exists
                accountIdsToCheck.add(con.AccountId);
            }
        }

        for(AccountContactRole acRole : [SELECT Id, AccountId from AccountContactRole WHERE AccountId IN :accountIdsToCheck]) {
            // Adding the accounts ids to the set for which there already exists an AccountContactRole record
            existingRoleRecordsForAccounts.add(acRole.AccountId);
        }

        // clearing out the accountIdsToCheck set because we don't these values anymore and we'll use this set 
        // to hold the accounts ids for which we created a new AccountContactRole record
        accountIdsToCheck.clear();

        for(Contact con : newList) {
            if((oldMap == null && con.AccountId != null) ||
                (oldMap != null && con.AccountId != oldMap.get(con.Id).AccountId && con.AccountId != null)) {
                // checking if there already exists an AccountContactRole record for this account or if we created
                // a new AccountContactRole record for this account
                if(!accountIdsToCheck.contains(con.AccountId) && !existingRoleRecordsForAccounts.contains(con.AccountId)) {
                    AccountContactRole acRole = new AccountContactRole();
                    acRole.AccountId = con.AccountId;
                    acRole.ContactId = con.Id;
                    acRole.IsPrimary = true;
                    acRole.Role = 'Billing';
                    accountContactRoleRecordsToInsert.add(acRole);
                    accountIdsToCheck.add(con.AccountId);
                }
            }
        }

        if(!accountContactRoleRecordsToInsert.isEmpty()) {
            insert accountContactRoleRecordsToInsert;
        }
    }
}
