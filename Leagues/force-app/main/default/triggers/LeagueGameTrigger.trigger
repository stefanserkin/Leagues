trigger LeagueGameTrigger on League_Game__c (before insert, before update) {
    LeagueGameHandler.handleTriggerEvent(Trigger.new, Trigger.isBefore, Trigger.isInsert, Trigger.isUpdate);
}