trigger PlayerPositionTrigger on Player_Position__c (after insert, after update, after delete) {
    PlayerPositionHandler.handleTriggerEvent(
        Trigger.new, 
        Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete
    );
}