public with sharing class PlayerHandler {

    private static Map<Id, Map<Decimal, String>> mapTeamsToTakenNumbers;
    
    public static void handleTriggerEvent(
        List<Player__c> lstPlayersInTrigger,
        Boolean isBefore, Boolean isInsert, Boolean isUpdate
    ) {
        if (isBefore) {
            handleBefore(lstPlayersInTrigger);
        }
    }

    private static void handleBefore(List<Player__c> lstPlayersInTrigger) {
        loadTeamPlayerCache();
        for (Player__c player : lstPlayersInTrigger) {
            Boolean numberIsTaken = false;
            Boolean numberIsDuplicate = false;
            if (player.Uniform_Number__c != null) {
                numberIsTaken = isDuplicateNumberForTeam(player.Uniform_Number__c, player.Team__c);
            }
            if (numberIsTaken) {
                Integer uniNumber = player.Uniform_Number__c.intValue();
                String matchingPlayerName = mapTeamsToTakenNumbers.get(player.Team__c)?.get(player.Uniform_Number__c);
                if (matchingPlayerName != player.Player_Name__c) {
                    numberIsDuplicate = true;
                }
                if (numberIsDuplicate) {
                    String eMessage = matchingPlayerName + ' has already been assigned number ' + uniNumber + '.';
                    eMessage += '\n' + ' Please choose a different number or change ' + matchingPlayerName + '\'s number before saving.';
                    player.addError(eMessage);
                }
            }
        }
    }

    private static Boolean isDuplicateNumberForTeam(Decimal uniNumber, Id teamId) {
        Boolean numberIsDuplicate = false;
        if (mapTeamsToTakenNumbers.get(teamId) != null) {
            numberIsDuplicate = mapTeamsToTakenNumbers.get(teamId)?.containsKey(uniNumber);

        }
        return numberIsDuplicate;
    }

    private static void loadTeamPlayerCache() {
        if (mapTeamsToTakenNumbers != null) {
            return;
        }

        mapTeamsToTakenNumbers = new Map<Id, Map<Decimal, String>>();
        List<Team__c> lstTeamsWithUnis = [
            SELECT Id,
                   (SELECT Id, Uniform_Number__c, Player_Name__c FROM Players__r)
              FROM Team__c 
             WHERE League_Season__r.End_Date__c >= TODAY
              WITH SECURITY_ENFORCED
        ];
        for (Team__c tm : lstTeamsWithUnis) {
            Map<Decimal, String> innerMap = new Map<Decimal, String>();
            for (Player__c tmPlayer : tm.Players__r) {
                Decimal uniNumber = tmPlayer.Uniform_Number__c;
                String playerName = tmPlayer.Player_Name__c;
                innerMap.put(uniNumber, playerName);                
            }
            mapTeamsToTakenNumbers.put(
                tm.Id,
                innerMap
            );
        }
    }

}