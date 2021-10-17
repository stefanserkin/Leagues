trigger LeagueGameTrigger on League_Game__c (before insert, before update, after insert, after update) {

    LeagueGameHandler.handleTriggerEvent(
        Trigger.new, 
        Trigger.oldMap,
        Trigger.isBefore, 
        Trigger.isAfter, 
        Trigger.isInsert, 
        Trigger.isUpdate
    );

}