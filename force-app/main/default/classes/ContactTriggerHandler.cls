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
                accountIdsToCheck.add(con.AccountId);
            }
        }

        for(AccountContactRole acRole : [SELECT Id, AccountId from AccountContactRole WHERE AccountId IN :accountIdsToCheck]) {
            existingRoleRecordsForAccounts.add(acRole.AccountId);
        }

        accountIdsToCheck.clear();

        for(Contact con : newList) {
            if((oldMap == null && con.AccountId != null) ||
                (oldMap != null && con.AccountId != oldMap.get(con.Id).AccountId && con.AccountId != null)) {
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
