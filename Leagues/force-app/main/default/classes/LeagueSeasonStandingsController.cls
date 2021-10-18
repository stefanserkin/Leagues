public with sharing class LeagueSeasonStandingsController {

    @AuraEnabled(cacheable=true)
    public static List<Team__c> getTeams(String recordId){
        // TODO - ADD ARGUMENT FOR RANKING TYPE TO DYNAMICALLY SORT QUERY RESULTS
        return [SELECT Id, Name, Wins__c, Losses__c, Ties__c, 
                       Winning_Percentage__c, Points__c, Games_Played__c, 
                       League_Name__c, Team_Logo_URL__c
                  FROM Team__c 
                 WHERE League_Season__c = :recordId 
                  WITH SECURITY_ENFORCED 
                 ORDER BY Points__c DESC
                 LIMIT 10000];
    }

    @AuraEnabled(cacheable=true)
    public static List<League_Season__c> getLeagueSeasons(String sport){
        // TODO - ADD ARGUMENT FOR RANKING TYPE TO DYNAMICALLY SORT QUERY RESULTS
        return [SELECT Id, Name, Start_Date__c, End_Date__c, League_Name__c
                  FROM League_Season__c 
                 WHERE Sport__c = :sport
                  WITH SECURITY_ENFORCED 
                 ORDER BY Start_Date__c DESC
                 LIMIT 10000];
    }
    
}