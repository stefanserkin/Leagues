public with sharing class CreatePlayerPositions {

    @InvocableMethod(label='Get Player Positions' description='Get player positions from semicolon-separated string' category='Leagues')
    public static List<Output> getPlayerPositions(List<Input> lstInput) {
        Id playerId = lstInput.get(0).playerId;
        String strOfPositions = lstInput.get(0).strOfPositions;
        String[] lstOfPositions = strOfPositions.split(';');
        List<Player_Position__c> lstPlayerPositions = new List<Player_Position__c>();
        for (String position : lstOfPositions) {
            lstPlayerPositions.add(
                new Player_Position__c(
                    Player__c = playerId,
                    Position__c = position
                )
            );
        }
        Output output = new Output();
        output.lstPPs = lstPlayerPositions;
        List<Output> outputList = new List<Output>();
        outputList.add(output);
        return outputList;
    }

    public class Input {
        @InvocableVariable(label='Player ID' required=true)
        public Id playerId;
        @InvocableVariable(label='List of Positions' required=true)
        public String strOfPositions;
    }

    public class Output {
        @InvocableVariable
        public List<Player_Position__c> lstPPs;
    }
}
