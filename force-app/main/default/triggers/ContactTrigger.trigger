trigger ContactTrigger on Contact (after insert, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            ContactTriggerHandler.afterInsert(trigger.new);
        }
        
        if(Trigger.isUpdate) {
            ContactTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
        }
    }
}