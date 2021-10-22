public with sharing class LeagueSeasonCloner {

    private static Map<Id, Team__c> mapOldIdToNewTeam = new Map<Id, Team__c>();

    @InvocableMethod(label='Clone League Seasons' description='Clone League Season. Optionally clone related teams and players, as well' category='Leagues')
    public static List<Result> cloneLeagueSeasons(List<Request> requestList) {
        Boolean cloneTeams      = requestList.get(0).cloneTeams;
        Boolean clonePlayers    = requestList.get(0).clonePlayers;
        Integer yearsToAdd      = requestList.get(0)?.yearsToAdd;
        Id leagueSeasonId       = requestList.get(0).leagueSeasonId;
        Boolean overrideName    = requestList.get(0).overrideName;
        String leagueSeasonName = requestList.get(0)?.leagueSeasonName;
        Boolean graduateTeams   = requestList.get(0).graduateTeams;
        Id leagueId             = requestList.get(0)?.leagueId;

        League_Season__c originalSeason = [
            SELECT Id, Name, Start_Date__c, End_Date__c, League__c, League_Ranking_Type__c, 
                   Length_of_Games__c, Standings_Configuration__c, League__r.Name
              FROM League_Season__c 
             WHERE Id = :leagueSeasonId
              WITH SECURITY_ENFORCED
             LIMIT 1
        ];

        League_Season__c newSeason = originalSeason.clone(false, true, false, false);
        if (yearsToAdd != null && yearsToAdd != 0) {
            newSeason.Start_Date__c = newSeason.Start_Date__c.addYears(yearsToAdd);
            newSeason.End_Date__c   = newSeason.End_Date__c.addYears(yearsToAdd);
            newSeason.Name = overrideName && leagueSeasonName != null ? 
                leagueSeasonName : 
                autoNameLeagueSeason(
                    newSeason, 
                    originalSeason.League__r.Name
                );
            if (graduateTeams && leagueId != null) {
                newSeason.League__c = leagueId;
            }
        }
        insert newSeason;

        List<Team__c> lstOriginalTeams = [
            SELECT Id, Name, League_Season__c, Team_Logo_URL__c,
                   (SELECT Id, Name, Contact__c, Team__c, Uniform_Number__c from Players__r)
              FROM Team__c
             WHERE League_Season__c = :originalSeason.Id
             LIMIT 10000
        ];

        if (cloneTeams) {
            List<Team__c> newTeams = getClonedTeams(lstOriginalTeams, newSeason.Id);
            if (!newTeams.isEmpty()) {
                insert newTeams;
            }
            if (clonePlayers && !newTeams.isEmpty()) {
                List<Player__c> newPlayers = getClonedPlayers(lstOriginalTeams);
                if (!newPlayers.isEmpty()) {
                    insert newPlayers;
                }
            }
        }

        Result result = new Result();
        result.clonedLeagueSeason = newSeason;
        List<Result> resultList = new List<Result>();
        resultList.add(result);
        return resultList;

    }

    private static String autoNameLeagueSeason(League_Season__c leagueSeason, String leagueName) {
        String startYear = String.valueOf( leagueSeason.Start_Date__c.year() );
        String endYear   = String.valueOf( leagueSeason.End_Date__c.year() );
        String leagueSeasonName = leagueName + ' ' + startYear;
        if (startYear != endYear) {
            leagueSeasonName += '-' + endYear;
        }
        return leagueSeasonName;
    }

    private static List<Team__c> getClonedTeams(List<Team__c> lstOriginalTeams, Id newSeasonId) {
        List<Team__c> lstClonedTeams = new List<Team__c>();
        for (Team__c tm : lstOriginalTeams) {
            Team__c clonedTeam = tm.clone(false, true, false, false);
            clonedTeam.League_Season__c = newSeasonId;
            mapOldIdToNewTeam.put(tm.Id, clonedTeam);
            lstClonedTeams.add(clonedTeam);
        }
        return lstClonedTeams;
    }

    private static List<Player__c> getClonedPlayers(List<Team__c> lstOriginalTeams) {
        List<Player__c> lstClonedPlayers = new List<Player__c>();
        for (Team__c tm : lstOriginalTeams) {
            for (Player__c player : tm.Players__r) {
                Player__c clonedPlayer = player.clone(false, true, false, false);
                clonedPlayer.Team__c = mapOldIdToNewTeam.get(tm.Id).Id;
                lstClonedPlayers.add(clonedPlayer);
            }
        }
        return lstClonedPlayers;
    }
    
    public class Request {
        @InvocableVariable(label='League Season ID' required=true)
        public Id leagueSeasonId;

        @InvocableVariable(label='Clone Teams')
        public Boolean cloneTeams;

        @InvocableVariable(label='Clone Players')
        public Boolean clonePlayers;

        @InvocableVariable(label='Add Years' description='Enter negative number to subtract years')
        public Integer yearsToAdd;

        @InvocableVariable(label='Override Name')
        public Boolean overrideName;

        @InvocableVariable(label='League Season Name')
        public String leagueSeasonName;

        @InvocableVariable(label='Graduate Teams')
        public Boolean graduateTeams;

        @InvocableVariable(label='League ID')
        public Id leagueId;
    }

    public class Result {
        @InvocableVariable(label='Cloned League Season')
        public League_Season__c clonedLeagueSeason;
    }

}