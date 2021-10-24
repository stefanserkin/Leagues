@isTest
public class LeaguesParseFlowInput_Test {
    
    @isTest
    static void testParseFlowInput() {
        String inputString = 'Salt;Peanuts;Metsies';
        List<LeaguesParseFlowInput.ParseResult> resultList;

        Test.startTest();
        LeaguesParseFlowInput.ParseRequest request;
        request = new LeaguesParseFlowInput.ParseRequest();
        request.input = inputString;

        resultList = LeaguesParseFlowInput.getSeparatedValues(
            new List<LeaguesParseFlowInput.ParseRequest>{ request }
        );
        Test.stopTest();

        Set<String> resultSet = new Set<String>(resultList.get(0).output);

        System.assert(resultSet.contains('Salt'), 'Did not find Salt');
        System.assert(resultSet.contains('Peanuts'), 'Did not find Peanuts');
        System.assert(resultSet.contains('Metsies'), 'Did not find Mets');

    }

}
