public with sharing class LeaguesParseFlowInput {
    
    @InvocableMethod(label='Parse multi select values' description='Takes a string of semicolon-separated values and returns a list of strings' category='Leagues')
    public static List<ParseResult> getSeparatedValues(List<ParseRequest> request) {
        String strInput = request.get(0).input;
        String[] lstValues = strInput.split(';');

        ParseResult result = new ParseResult();
        result.output = lstValues;
        List<ParseResult> resultList = new List<ParseResult>();
        resultList.add(result);
        return resultList;
    }

    public class ParseRequest {

        @InvocableVariable(required=true)
        public String input;
    
    }
    
    public class ParseResult {
    
        @InvocableVariable
        public List<String> output;
    
    }

}
