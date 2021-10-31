public with sharing class SeasonSimulatorController {
    
    @AuraEnabled
    public static string simulateSeason(String recordId){
        System.debug('entered runsimulation with record id ' + recordId);
        String result = '';
        List<Team__c> teams = [SELECT Id, Name FROM Team__c WHERE League_Season__c = :recordId WITH SECURITY_ENFORCED LIMIT 1000];
        Team__c astros = new Team__c();
        Team__c braves = new Team__c();
        for (Team__c team : teams) {
            if (team.Name == 'Houston Astros') {
                astros = team;
            } else if (team.Name == 'Atlanta Braves') {
                braves = team;
            }
        }

        Datetime gameTime1 = Datetime.newInstance(2021, 10, 26, 20, 9, 0);
        Datetime gameTime2 = Datetime.newInstance(2021, 10, 27, 20, 9, 0);
        Datetime gameTime3 = Datetime.newInstance(2021, 10, 29, 20, 9, 0);
        Datetime gameTime4 = Datetime.newInstance(2021, 10, 30, 20, 9, 0);
        Map<Integer, Datetime> mapGameTimes = new Map<Integer, Datetime>();
        mapGameTimes.put(1, gameTime1);
        mapGameTimes.put(2, gameTime2);
        mapGameTimes.put(3, gameTime3);
        mapGameTimes.put(4, gameTime4);

        List<League_Game__c> gamesToInsert = new List<League_Game__c>();
        for (Integer i = 1; i <= 4; i++) {
            League_Game__c game = new League_Game__c();
            if (i < 3) {
                game.Away_Team__c = braves.Id;
                game.Home_Team__c = astros.Id;
                game.Away_Score__c = 0;
                game.Home_Score__c = 100;
                game.Venue__c = 'a3d030000004yJXAAY';
            } else {
                game.Home_Team__c = braves.Id;
                game.Away_Team__c = astros.Id;
                game.Home_Score__c = 0;
                game.Away_Score__c = 100;
                game.Venue__c = 'a3d030000004yJcAAI';
            }
            game.League_Season__c = recordId;
            game.Status__c = 'Complete';
            game.Game_Time__c = mapGameTimes.get(i);
            gamesToInsert.add(game);
        }
        insert gamesToInsert;
        result = 'Astros win in 4!';
        return result;
    }
}
