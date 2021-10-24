trigger LeagueGameTrigger on League_Game__c (
    before insert, after insert, before update, after update, before delete
) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            LeagueGameHandler.handleTriggerEvent(
                Trigger.new, null, 
                Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete
            );
        } else if (Trigger.isDelete) {
            LeagueGameHandler.handleTriggerEvent(
                Trigger.old, null, 
                Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete
            );
        }
    }
    else if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        LeagueGameHandler.handleTriggerEvent(
            Trigger.new, Trigger.oldMap, 
            Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete
        );
    }

}