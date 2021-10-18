@isTest
public class LeagueSeasonStandingsController_Test {
    
    @isTest
    static void testGetTeams() {
        List<League_Season__c> lstLeagueSeasons = LeaguesTestDataFactory.createLeagueSeasons('Soccer', 'Unranked', 1, 1);
        List<Team__c> lstTeams = LeaguesTestDataFactory.createTeams(lstLeagueSeasons, 2);
        Test.startTest();
        List<Team__c> lstTeamsReturned = LeagueSeasonStandingsController.getTeams(lstLeagueSeasons[0].Id);
        Test.stopTest();
        System.assertEquals(2, lstTeamsReturned.size(), 'Did not return expected 2 teams');
    }

}
