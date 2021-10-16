@isTest
public class LeaguesTestDataFactory {

    private static Map<String, Id> mapDevNamesToRecTypeIds;

    public static List<League_Season__c> createLeagueSeasons(
        String sport,
        String teamRankingsType,
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
                lstLeagueSeasons.add(
                    new League_Season__c(
                        League__c = league.Id, 
                        Team_Rankings_Type__c = teamRankingsType, 
                        Start_Date__c = Date.today().addDays(-30).addYears(-i), 
                        End_Date__c = Date.today().addDays(30).addYears(-i)
                    )
                );
            }
        }
        insert lstLeagueSeasons;
        return lstLeagueSeasons;
    }

    public static List<League_Season__c> createLeagueSeasons(
        String sport,
        String teamRankingsType,
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
                lstLeagueSeasons.add(
                    new League_Season__c(
                        League__c = league.Id, 
                        Team_Rankings_Type__c = teamRankingsType, 
                        Start_Date__c = Date.today().addDays(-30).addYears(-i), 
                        End_Date__c = Date.today().addDays(30).addYears(-i)
                    )
                );
            }
        }
        insert lstLeagueSeasons;
        return lstLeagueSeasons;
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

    public static Id getSeasonGameRecordTypeId(String developerName) {
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
