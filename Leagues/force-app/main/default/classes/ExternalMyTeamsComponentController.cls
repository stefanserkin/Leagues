public with sharing class ExternalMyTeamsComponentController {
    
    @AuraEnabled(cacheable=true)
    public static List<Team__c> getMyTeams(String accountId){

        return [SELECT Id, Name, League_Season__c, League_Season__r.Name, 
                       League_Season__r.End_Date__c, League_Season__r.Start_Date__c,
                       League_Name__c, Wins__c, Losses__c, Ties__c
                  FROM Team__c
                 WHERE Id IN (SELECT Team__c 
                                FROM Player__c 
                               WHERE Contact__r.AccountId = :accountId)
                  WITH SECURITY_ENFORCED
                 ORDER BY League_Season__r.Start_Date__c DESC];
        
    }
}
