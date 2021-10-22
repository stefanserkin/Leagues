public with sharing class LeagueSeasonStandingsController {

    @AuraEnabled(cacheable=true)
    public static List<Team__c> getTeams(String recordId, String leagueRankingType){
        String strOrderBy;
        switch on leagueRankingType {
            when 'Points System' {
                strOrderBy = 'Points__c DESC';
            }
            when 'Winning Percentage' {
                strOrderBy = 'Winning_Percentage__c DESC';
            }
            when else {
                strOrderBy = 'Name ASC';
            }
        }
        String strQuery = 'SELECT Id, Name, Wins__c, Losses__c, Ties__c, Winning_Percentage__c, Points__c, Games_Played__c, League_Name__c, Team_Logo_URL__c';
        strQuery += ' FROM Team__c WHERE League_Season__c = :recordId WITH SECURITY_ENFORCED';
        strQuery += ' ORDER BY ' + strOrderBy;
        strQuery += ' LIMIT 10000';
        String strQueryEsc = String.escapeSingleQuotes(strQuery);
        List<Team__c> sortedTeams = Database.query(strQueryEsc);
        return sortedTeams;
    }

    @AuraEnabled(cacheable=true)
    public static List<League_Season__c> getLeagueSeasons(String sport){
        return [SELECT Id, Name, Start_Date__c, End_Date__c, League_Name__c, League_Ranking_Type__c
                  FROM League_Season__c 
                 WHERE Sport__c = :sport
                  WITH SECURITY_ENFORCED 
                 ORDER BY Start_Date__c DESC
                 LIMIT 10000];
    }
    
}