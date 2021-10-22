trigger LeaguesExperienceUserTrigger on User (after insert) {

    List<PermissionSet> lstPSsToAssign = [SELECT Id FROM PermissionSet WHERE Name = 'Leagues_Experience_User' OR Name = 'External_Events_Calendar_Read_Only' LIMIT 2];
    Map<Id, Profile> mapExternalProfiles = new Map<Id, Profile>([
        SELECT Id FROM Profile WHERE Name LIKE '%Community%'
    ]);

    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();

    for (User u : Trigger.new) {
        if (mapExternalProfiles.containsKey(u.ProfileId)) {
            for (Integer i = 0; i < lstPSsToAssign.size(); i++) {
                psaList.add(
                    new PermissionSetAssignment(
                        AssigneeId = u.Id,
                        PermissionSetId = lstPSsToAssign[i].Id
                    )
                );
            }
        }
    }

    insert psaList;

}