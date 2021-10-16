public with sharing class LeagueGameHandler {

    private static Map<Id, Team__c> mapTeamCache;

    public static void handleTriggerEvent(
        List<League_Game__c> lstGamesInTrigger,
        Boolean isBefore,
        Boolean isInsert, 
        Boolean isUpdate
    ){
        if (isBefore) {
            processBefore(lstGamesInTrigger);
        }
    }

    private static void processBefore(List<League_Game__c> lstGamesInTrigger) {
        for (League_Game__c game : lstGamesInTrigger) {
            if (String.isBlank(game.Name)) {
                game.Name = getSeasonGameName(game);
            }
        }
    }

    private static String getSeasonGameName(League_Game__c game) {
        String strHomeTeamName = getTeamName(game.Home_Team__c);
        String strAwayTeamName = getTeamName(game.Away_Team__c);
        String strGameTime     = game.Game_Time__c.format('MM/dd/yyyy HH:mm:ss', 'America/New_York');
        String strGameName     = strAwayTeamName + ' at ' + strHomeTeamName + ' - ' + strGameTime;
        return strGameName;
    }

    private static String getTeamName(Id teamId) {
        // If teams have already been queried, return team name for id
        if (mapTeamCache != null) {
            return mapTeamCache.get(teamId).Name;
        }
        // Otherwise, load map and return team name for id
        mapTeamCache = new Map<Id, Team__c>([
            SELECT Id, Name
              FROM Team__c
             LIMIT 10000
        ]);
        return mapTeamCache.get(teamId).Name;
    }


    
}
