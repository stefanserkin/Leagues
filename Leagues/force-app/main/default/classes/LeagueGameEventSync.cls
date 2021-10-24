public with sharing class LeagueGameEventSync {
    
    private static Id ccCalEventRecTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName()
        .get('CC_Calendar_Event').getRecordTypeId();

    public static void syncEventsToGames(
        List<League_Game__c> lstGames,
        Map<Id, League_Game__c> mapOldGames,
        String triggerDmlContext
    ) {
        switch on triggerDmlContext {
            when 'isInsert' {
                createEventsForGames(lstGames);
            }
            when 'isUpdate' {
                updateEventsForGames(lstGames, mapOldGames);
            }
            when 'isDelete' {
                deleteEventsForGames(lstGames);
            }
        }
    }

    private static void createEventsForGames(List<League_Game__c> lstGames) {
        List<Event> lstEvents = new List<Event>();
        for (League_Game__c lg : lstGames) {
            lstEvents.add(
                new Event(
                    ActivityDate = Date.newInstance(
                        lg.Game_Time__c.year(), lg.Game_Time__c.month(), lg.Game_Time__c.day()
                    ),
                    ActivityDateTime = lg.Game_Time__c,
                    cccalendar__Calendar_Background_Color__c = 'Blue',
                    cccalendar__Calendar_Border_Color__c = 'Blue',
                    cccalendar__Calendar_Rendering__c = 'Normal',
                    cccalendar__Calendar_Text_Color__c = 'White',
                    cccalendar__Display_Events_Local_Timezone__c = false,
                    cccalendar__Event_Icon_Name__c = 'utility:date_time',
                    cccalendar__Local_Timezone__c = 'America/New_York',
                    DurationInMinutes = lg.Duration_In_Minutes__c.intValue(),
                    EndDateTime = lg.End_Time__c,
                    EventSubtype = 'Event',
                    IsPrivate = false,
                    IsVisibleInSelfService = true,
                    RecordTypeId = ccCalEventRecTypeId,
                    ShowAs = 'Busy',
                    StartDateTime = lg.Game_Time__c,
                    Subject = lg.Name,
                    WhatId = lg.Public_Calendar_ID__c,
                    League_Game_ID__c = lg.Id
                )
            );
        }
        insert lstEvents;
    }

    private static void updateEventsForGames(
        List<League_Game__c> lstGames,
        Map<Id, League_Game__c> mapOldGames
    ) {
        Set<Id> eventGameIds = new Set<Id>();
        for(League_Game__c lg : lstGames) {
            if (lg.Game_Time__c != mapOldGames.get(lg.Id).Game_Time__c) {
                eventGameIds.add(lg.Id);
            }
        }

        if (!eventGameIds.isEmpty()) {
            return;
        }

        Map<Id, League_Game__c> mapLeagueGames = new Map<Id, League_Game__c>();
        for (League_Game__c game : lstGames) {
            mapLeagueGames.put(game.Id, game);
        }

        List<Event> lstEvents = [
            SELECT Id, Subject, StartDateTime, EndDateTime, League_Game_ID__c 
              FROM Event 
             WHERE League_Game_ID__c IN :eventGameIds 
              WITH SECURITY_ENFORCED
        ];
        
        if (lstEvents != null && !lstEvents.isEmpty()) {
            for (Event ev : lstEvents) {
                League_Game__c matchingGame = mapLeagueGames.get(ev.League_Game_ID__c);
                ev.StartDateTime = matchingGame.Game_Time__c;
                ev.EndDateTime   = matchingGame.End_Time__c;
                ev.Subject       = matchingGame.Name;
            }
        }
        update lstEvents;
    }

    private static void deleteEventsForGames(List<League_Game__c> lstGames) {
        Set<Id> setGameIds = new Set<Id>();
        for (League_Game__c lg : lstGames) {
            setGameIds.add(lg.Id);
        }
        List<Event> lstEventsToDelete = [SELECT Id FROM Event WHERE League_Game_ID__c IN :setGameIds WITH SECURITY_ENFORCED];
        if (!lstEventsToDelete.isEmpty()) {
            delete lstEventsToDelete;
        }
    }

}
