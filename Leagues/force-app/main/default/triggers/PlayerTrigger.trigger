trigger PlayerTrigger on Player__c (before insert, before update) {

    PlayerHandler.handleTriggerEvent(Trigger.new, Trigger.isBefore, Trigger.isInsert, Trigger.isAfter);

}