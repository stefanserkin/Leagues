public with sharing class PlayerPositionHandler {

    public static void handleTriggerEvent(
        List<Player_Position__c> lstPPsInTrigger,
        Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete
    ) {
        if (isAfter) {
            concatenatePositionNames(lstPPsInTrigger);
        }
    }

    private static void concatenatePositionNames(
        List<Player_Position__c> lstPPsInTrigger
    ) {
        Set<Id> setPlayerIds = new Set<Id>();
        for (Player_Position__c pp : lstPPsInTrigger) {
            setPlayerIds.add(pp.Player__c);
        }
        List<Player__c> lstPlayersWithPositions = getPlayersWithPositions(setPlayerIds);

        for (Player__c pl : lstPlayersWithPositions) {
            String strPositions = '';
            Boolean isFirstItem = true;
            for (Player_Position__c pp : pl.Player_Positions__r) {
                if (!isFirstItem) {
                    strPositions += '; ';
                }
                strPositions += pp.Position__r.Abbreviation__c;
                if (isFirstItem) {
                    isFirstItem = false;
                }
            }
            pl.Positions__c = strPositions;
        }
        update lstPlayersWithPositions;
        
    }

    private static List<Player__c> getPlayersWithPositions(
        Set<Id> setPlayerIds
    ) {
        return [SELECT Id, Positions__c,
                       (SELECT Id, Position__r.Abbreviation__c FROM Player_Positions__r) 
                  FROM Player__c 
                 WHERE Id IN :setPlayerIds
                  WITH SECURITY_ENFORCED
                 LIMIT 10000];
    }
    

}