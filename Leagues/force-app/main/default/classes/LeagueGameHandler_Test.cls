@isTest
public class LeagueGameHandler_Test {
    
    @isTest
    static void testSetDefaults() {
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

        League_Game__c gameRefreshed = [SELECT Id, Name, Status__c, Home_Team__r.Name, Away_Team__r.Name, Game_Time__c FROM League_Game__c WHERE Id = :game.Id LIMIT 1];
        
        String strGameTime     = gameRefreshed.Game_Time__c.format('MM/dd/yyyy HH:mm:ss', 'America/New_York');
        String strExpectedName = gameRefreshed.Away_Team__r.Name + ' at ' + gameRefreshed.Home_Team__r.Name + ' - ' + strGameTime;
        System.assertEquals(strExpectedName, gameRefreshed.Name, 'Unexpected name for season game');

        String strExpectedStatus = 'Upcoming';
        System.assertEquals(strExpectedStatus, gameRefreshed.Status__c, 'Unexpected status for season game');
    }

    @isTest
    static void testSetResultsPendingStatus() {
        List<League_Season__c> lstLeagueSeasons = LeaguesTestDataFactory.createLeagueSeasons('Soccer', 'Unranked', 1, 1);
        List<Team__c> lstTeams = LeaguesTestDataFactory.createTeams(lstLeagueSeasons, 2);

        League_Game__c game = new League_Game__c(
            RecordTypeId = LeaguesTestDataFactory.getLeagueGameRecordTypeId('Soccer'),
            Home_Team__c = lstTeams[0].Id,
            Away_Team__c = lstTeams[1].Id,
            Game_Time__c = Datetime.now().addDays(-1)
        );

        Test.startTest();
        insert game;
        Test.stopTest();

        League_Game__c gameRefreshed = [SELECT Id, Name, Status__c, Home_Team__r.Name, Away_Team__r.Name, Game_Time__c FROM League_Game__c WHERE Id = :game.Id LIMIT 1];

        String strExpectedStatus = 'Results Pending';
        System.assertEquals(strExpectedStatus, gameRefreshed.Status__c, 'Unexpected status for season game');
    }

    @isTest
    static void testOverrideDefaults() {
        List<League_Season__c> lstLeagueSeasons = LeaguesTestDataFactory.createLeagueSeasons('Soccer', 'Unranked', 1, 1);
        List<Team__c> lstTeams = LeaguesTestDataFactory.createTeams(lstLeagueSeasons, 2);

        League_Game__c game = new League_Game__c(
            RecordTypeId = LeaguesTestDataFactory.getLeagueGameRecordTypeId('Soccer'),
            Home_Team__c = lstTeams[0].Id,
            Away_Team__c = lstTeams[1].Id,
            Game_Time__c = Datetime.now().addDays(-1),
            Name         = 'Test Override Name',
            Status__c    = 'Complete'
        );

        Test.startTest();
        insert game;
        Test.stopTest();

        League_Game__c gameRefreshed = [SELECT Id, Name, Status__c, Home_Team__r.Name, Away_Team__r.Name, Game_Time__c FROM League_Game__c WHERE Id = :game.Id LIMIT 1];
        
        String strExpectedName = 'Test Override Name';
        System.assertEquals(strExpectedName, gameRefreshed.Name, 'Unexpected name for season game');
        
        String strExpectedStatus = 'Complete';
        System.assertEquals(strExpectedStatus, gameRefreshed.Status__c, 'Unexpected status for season game');
    }

    @isTest
    static void testPointsSystemConfig() {
        List<League_Season__c> lstLeagueSeasons = LeaguesTestDataFactory.createLeagueSeasons('Soccer', 'Points System', 1, 1);
        List<Team__c> lstTeams = LeaguesTestDataFactory.createTeams(lstLeagueSeasons, 2);

        League_Game__c game = new League_Game__c(
            RecordTypeId = LeaguesTestDataFactory.getLeagueGameRecordTypeId('Soccer'),
            Home_Team__c = lstTeams[0].Id,
            Away_Team__c = lstTeams[1].Id,
            Game_Time__c = Datetime.now().addDays(-1)
        );
        insert game;

        game.Home_Score__c = 1;
        game.Away_Score__c = 0;
        game.Status__c     = 'Complete';

        Test.startTest();
        update game;
        Test.stopTest();

        League_Game__c gameRefreshed = [SELECT Id, Name, League_Season__c, Status__c, Home_Team__r.Points__c, Away_Team__r.Points__c FROM League_Game__c WHERE Id = :game.Id LIMIT 1];
        String leagueSeasonId = gameRefreshed.League_Season__c;
        League_Season__c seasonRefreshed = [SELECT Id, Standings_Configuration__r.Points_Per_Win__c FROM League_Season__c WHERE Id = :leagueSeasonId LIMIT 1];

        Decimal strExpectedPoints = seasonRefreshed.Standings_Configuration__r.Points_Per_Win__c;
        System.assertEquals(strExpectedPoints, gameRefreshed.Home_Team__r.Points__c, 'Unexpected points for season game');
    }

}
