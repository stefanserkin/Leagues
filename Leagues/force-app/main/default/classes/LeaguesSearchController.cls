public with sharing class LeaguesSearchController {

    @AuraEnabled
    public static List<sObject> search(String objectName, List<String> fields, String searchTerm){
        String searchKeyword = searchTerm + '*';
        String returningQuery = '';
        returningQuery = objectName + ' ( Id, ' + String.join(fields, ',') + ')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING ' + returningQuery + ' LIMIT 20';
        List<List<sObject>> searchRecords = Search.Query(query);
        return searchRecords.get(0);
    }

}
