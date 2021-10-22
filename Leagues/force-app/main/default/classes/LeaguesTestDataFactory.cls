@isTest
public class LeaguesTestDataFactory {

    private static Map<String, Id> mapDevNamesToRecTypeIds;

    public static List<League_Season__c> createLeagueSeasons(
        String sport,
        String leagueRankingType,
        Integer numLeagues, 
        Integer numLeagueSeasons
    ) {
        List<League__c> lstLeagues = new List<League__c>();
        for (Integer i = 0; i < numLeagues; i++) {
            lstLeagues.add(new League__c(Name = 'Test League ' + String.valueOf(i), Sport__c = sport));
        }
        insert lstLeagues;
        List<League_Season__c> lstLeagueSeasons = new List<League_Season__c>();
        for (League__c league : lstLeagues) {
            for (Integer i = 0; i < numLeagueSeasons; i++) {
                League_Season__c ls = new League_Season__c();
                ls.League__c = league.Id;
                ls.League_Ranking_Type__c = leagueRankingType;
                ls.Start_Date__c = Date.today().addDays(-30).addYears(-i);
                ls.End_Date__c = Date.today().addDays(30).addYears(-i);
                if (leagueRankingType == 'Points System') {
                    System.debug('Should be adding config');
                    Standings_Configuration__c sc = createConfig();
                    ls.Standings_Configuration__c = sc.Id;
                }
                lstLeagueSeasons.add(ls);
            }
        }
        insert lstLeagueSeasons;
        return lstLeagueSeasons;
    }

    public static List<League_Season__c> createLeagueSeasons(
        String sport,
        String leagueRankingType,
        Integer numLeagues, 
        Integer numLeagueSeasons,
        Decimal minAge, 
        Decimal maxAge
    ) {
        List<League__c> lstLeagues = new List<League__c>();
        for (Integer i = 0; i < numLeagues; i++) {
            lstLeagues.add(new League__c(Name = 'Test League ' + String.valueOf(i), Sport__c = sport, Minimum_Age__c = minAge, Maximum_Age__c = maxAge));
        }
        insert lstLeagues;
        List<League_Season__c> lstLeagueSeasons = new List<League_Season__c>();
        for (League__c league : lstLeagues) {
            for (Integer i = 0; i < numLeagueSeasons; i++) {
                League_Season__c ls = new League_Season__c();
                ls.League__c = league.Id;
                ls.League_Ranking_Type__c = leagueRankingType;
                ls.Start_Date__c = Date.today().addDays(-30).addYears(-i);
                ls.End_Date__c = Date.today().addDays(30).addYears(-i);
                if (leagueRankingType == 'Points System') {
                    System.debug('Should be adding config');
                    Standings_Configuration__c sc = createConfig();
                    ls.Standings_Configuration__c = sc.Id;
                }
                lstLeagueSeasons.add(ls);
            }
        }
        insert lstLeagueSeasons;
        return lstLeagueSeasons;
    }

    private static Standings_Configuration__c createConfig() {
        Standings_Configuration__c sc = new Standings_Configuration__c();
        sc.Points_Per_Win__c  = 3;
        sc.Points_Per_Loss__c = 0;
        sc.Points_Per_Tie__c  = 1;
        insert sc;
        return sc;
    }

    public static List<Team__c> createTeams(
        List<League_Season__c> lstLeagueSeasons, 
        Integer numTeamsPerSeason
    ) {
        List<Team__c> lstTeams = new List<Team__c>();
        for (League_Season__c ls : lstLeagueSeasons) {
            for (Integer i = 0; i < numTeamsPerSeason; i++) {
                lstTeams.add(
                    new Team__c(Name='Test Team' + String.valueOf(i), League_Season__c = ls.Id)
                );
            }
        }
        insert lstTeams;
        return lstTeams;
    }

    public static Id getLeagueGameRecordTypeId(String developerName) {
        if (mapDevNamesToRecTypeIds != null) {
            return mapDevNamesToRecTypeIds.get(developerName);
        }

        mapDevNamesToRecTypeIds = new Map<String, Id>();
        List<RecordType> lstRecordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'League_Game__c' LIMIT 10000];
        for (RecordType rt : lstRecordTypes) {
            mapDevNamesToRecTypeIds.put(rt.DeveloperName, rt.Id);
        }
        return mapDevNamesToRecTypeIds.get(developerName);
    }
    
}