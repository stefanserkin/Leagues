trigger PlayerPositionTrigger on Player_Position__c (after insert, after update, after delete) {
    if (Trigger.isDelete) {
        PlayerPositionHandler.handleTriggerEvent(
            Trigger.old, 
            Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete
        );
    } else if (Trigger.isInsert || Trigger.isUpdate) {
        PlayerPositionHandler.handleTriggerEvent(
            Trigger.new, 
            Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete
        );
    }
}