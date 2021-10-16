@isTest
public class LeagueGameHandler_Test {
    
    @isTest
    static void testSetName() {
        List<League_Season__c> lstLeagueSeasons = LeaguesTestDataFactory.createLeagueSeasons('Soccer', 'Unranked', 1, 1);
        List<Team__c> lstTeams = LeaguesTestDataFactory.createTeams(lstLeagueSeasons, 2);

        League_Game__c game = new League_Game__c(
            RecordTypeId = LeaguesTestDataFactory.getLeagueGameRecordTypeId('Soccer'),
            Home_Team__c = lstTeams[0].Id,
            Away_Team__c = lstTeams[1].Id,
            Game_Time__c = Datetime.now().addDays(1)
        );

        Test.startTest();
        insert game;
        Test.stopTest();

        League_Game__c gameRefreshed = [SELECT Id, Name, Home_Team__r.Name, Away_Team__r.Name, Game_Time__c FROM League_Game__c WHERE Id = :game.Id LIMIT 1];
        String strGameTime     = gameRefreshed.Game_Time__c.format('MM/dd/yyyy HH:mm:ss', 'America/New_York');
        String strExpectedName = gameRefreshed.Away_Team__r.Name + ' at ' + gameRefreshed.Home_Team__r.Name + ' - ' + strGameTime;
        System.assertEquals(strExpectedName, gameRefreshed.Name, 'Unexpected name for season game');
    }
}
