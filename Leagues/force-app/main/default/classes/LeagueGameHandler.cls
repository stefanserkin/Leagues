public with sharing class LeagueGameHandler {

    private static Map<Id, Team__c> mapTeamCache;
    private static Map<Id, League_Season__c> mapSeasonsWithConfigCache;

    public static void handleTriggerEvent(
        List<League_Game__c> lstGamesInTrigger,
        Map<Id, League_Game__c> mapOldGamesInTrigger,
        Boolean isBefore, Boolean isAfter,
        Boolean isInsert, Boolean isUpdate
    ){
        if (isBefore) {
            processBefore(lstGamesInTrigger);
        } else if (isAfter) {
            processAfter(lstGamesInTrigger, mapOldGamesInTrigger);
        }
    }

    private static void processBefore(List<League_Game__c> lstGamesInTrigger) {
        for (League_Game__c game : lstGamesInTrigger) {
            if (String.isBlank(game.Name)) {
                game.Name = getSeasonGameName(game);
            }
            if (String.isBlank(game.Status__c)) {
                game.Status__c = getStatus(game);
            }
            if (game.League_Season__c == null) {
                System.debug('League season id is ' + getLeagueSeasonId(game.Home_Team__c));
                game.League_Season__c = getLeagueSeasonId(game.Home_Team__c);
            }
        }
    }

    private static void processAfter(
        List<League_Game__c> lstGamesInTrigger,
        Map<Id, League_Game__c> mapOldGamesInTrigger
    ) {
        Set<Id> setTeamIds = new Set<Id>();
        for (League_Game__c game : lstGamesInTrigger) {
            League_Game__c oldGame;
            // If game is not complete, move along
            if (game.Status__c != 'Complete') {
                continue;
            }
            // If isInsert, update teams
            if (mapOldGamesInTrigger == null) {
                setTeamIds.add(game.Home_Team__c);
                setTeamIds.add(game.Away_Team__c);
            } else {
                // If not, get old game to check against
                oldGame = mapOldGamesInTrigger.get(game.Id);
                // If there is any reason to update team totals, add to list
                if (
                    oldGame == null ||
                    (game.Status__c == 'Complete' && oldGame.Status__c != 'Complete') ||
                    game.Game_Result__c != oldGame.Game_Result__c
                ) {
                    setTeamIds.add(game.Home_Team__c);
                    setTeamIds.add(game.Away_Team__c);
                }
            }
        }
        if (!setTeamIds.isEmpty()) {
            recalcTeamRecords(setTeamIds);
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
        String strName = '';
        // If teams have already been queried, return team name for id
        if (mapTeamCache != null) {
            strName = mapTeamCache.get(teamId).Name;
            return strName;
        }
        // Otherwise, load map and return team name for id
        mapTeamCache = new Map<Id, Team__c>([
            SELECT Id, Name, League_Season__c
              FROM Team__c
             LIMIT 10000
        ]);
        strName = mapTeamCache.get(teamId)?.Name;
        return strName;
    }

    private static String getStatus(League_Game__c game) {
        String strStatus = '';
        if (game.Game_Time__c != null && game.Game_Time__c >= Datetime.now()) {
            strStatus = 'Upcoming';
        } else if (game.Game_Time__c != null && game.Game_Time__c < Datetime.now()) {
            strStatus = 'Results Pending';
        }
        return strStatus;
    }

    private static String getLeagueSeasonId(Id teamId) {
        String strSeasonId = '';
        if (mapTeamCache != null) {
            strSeasonId = mapTeamCache.get(teamId).League_Season__c;
            return strSeasonId;
        }
        // Otherwise, load map and return team name for id
        mapTeamCache = new Map<Id, Team__c>([
            SELECT Id, Name, League_Season__c
              FROM Team__c
             LIMIT 10000
        ]);
        strSeasonId = mapTeamCache.get(teamId).League_Season__c;
        return strSeasonId;
    }

    private static void recalcTeamRecords(Set<Id> setTeamIds) {
        List<Team__c> lstTeamsToUpdate = new List<Team__c>();

        // Get teams with both home and away games
        List<Team__c> lstTeams = [
            SELECT Id, Wins__c, Losses__c, Ties__c, League_Ranking_Type__c, League_Season__c, 
                   (SELECT Id, Home_Team__c, Home_Score__c, Away_Team__c, Away_Score__c
                      FROM Home_Games__r
                     WHERE Status__c = 'Complete'),
                   (SELECT Id, Home_Team__c, Home_Score__c, Away_Team__c, Away_Score__c
                      FROM Away_Games__r
                     WHERE Status__c = 'Complete')
              FROM Team__c 
             WHERE Id IN :setTeamIds 
              WITH SECURITY_ENFORCED
             LIMIT 10000
        ];

        for (Team__c tm : lstTeams) {
            Boolean hasPointsSystem = false;
            Decimal totalPoints     = 0;
            Decimal pointsPerWin    = 0;
            Decimal pointsPerLoss   = 0;
            Decimal pointsPerTie    = 0;

            Integer countWins   = 0;
            Integer countLosses = 0;
            Integer countTies   = 0;

            if (tm.League_Ranking_Type__c == 'Points System') {
                League_Season__c seasonWithConfig = getSeasonWithConfig(tm.League_Season__c);
                hasPointsSystem = true;
                pointsPerWin    = seasonWithConfig.Standings_Configuration__r.Points_Per_Win__c;
                pointsPerLoss   = seasonWithConfig.Standings_Configuration__r.Points_Per_Loss__c;
                pointsPerTie    = seasonWithConfig.Standings_Configuration__r.Points_Per_Tie__c;
            }

            for (League_Game__c lg : tm.Home_Games__r) {
                if (lg.Home_Score__c == lg.Away_Score__c) {
                    countTies++;
                    if (hasPointsSystem) {
                        totalPoints += pointsPerTie;
                    }
                } else if (lg.Home_Score__c > lg.Away_Score__c) {
                    countWins++;
                    if (hasPointsSystem) {
                        totalPoints += pointsPerWin;
                    }
                } else {
                    countLosses++;
                    if (hasPointsSystem) {
                        totalPoints += pointsPerLoss;
                    }
                }
            }

            for (League_Game__c lg : tm.Away_Games__r) {
                if (lg.Home_Score__c == lg.Away_Score__c) {
                    countTies++;
                    if (hasPointsSystem) {
                        totalPoints += pointsPerTie;
                    }
                } else if (lg.Home_Score__c < lg.Away_Score__c) {
                    countWins++;
                    if (hasPointsSystem) {
                        totalPoints += pointsPerWin;
                    }
                } else {
                    countLosses++;
                    if (hasPointsSystem) {
                        totalPoints += pointsPerLoss;
                    }
                }
            }

            tm.Wins__c   = countWins;
            tm.Losses__c = countlosses;
            tm.Ties__c   = countTies;
            tm.Points__c = totalPoints.intValue();
            lstTeamsToUpdate.add(tm);
            
        }

        if (!lstTeamsToUpdate.isEmpty()) {
            update lstTeamsToUpdate;
        }

    }

    private static League_Season__c getSeasonWithConfig(
        Id leagueSeasonId
    ) {
        League_Season__c ls = new League_Season__c();
        if (mapSeasonsWithConfigCache != null) {
            ls = mapSeasonsWithConfigCache.get(leagueSeasonId);
        } else {
            mapSeasonsWithConfigCache = new Map<Id, League_Season__c>([
                SELECT Id, 
                       Standings_Configuration__r.Points_Per_Win__c, 
                       Standings_Configuration__r.Points_Per_Loss__c, 
                       Standings_Configuration__r.Points_Per_Tie__c 
                  FROM League_Season__c
                  WITH SECURITY_ENFORCED
                 LIMIT 10000
            ]);
            ls = mapSeasonsWithConfigCache.get(leagueSeasonId);
        }
        return ls;
    }

}
