public with sharing class LeagueGameEventSync {
    
    private static Id ccCalEventRecTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName()
        .get('CC_Calendar_Event').getRecordTypeId();

    public static void syncEventsToGames(
        List<League_Game__c> lstGames,
        Map<Id, League_Game__c> mapOldGames,
        Map<Id, Team__c> mapTeams,
        String triggerDmlContext
    ) {
        switch on triggerDmlContext {
            when 'isInsert' {
                createEventsForGames(lstGames);
            }
            when 'isUpdate' {
                updateEventsForGames(lstGames, mapOldGames, mapTeams);
            }
            when 'isDelete' {
                deleteEventsForGames(lstGames);
            }
        }
    }

    private static void createEventsForGames(List<League_Game__c> lstGames) {
        List<Event> lstEvents = new List<Event>();
        for (League_Game__c lg : lstGames) {
            String strSubject = getEventSubjectFromGame(lg);
            String lgUrl = '/s/league-game/' + lg.Id + '/';

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
                    Subject = strSubject,
                    WhatId = lg.League_Season__c,
                    League_Game_ID__c = lg.Id,
                    cccalendar__Event_URL_Text__c = 'Game Details',
                    cccalendar__Event_URL__c = lgUrl,
                    Location = lg.Venue_Name_and_Address__c
                )
            );
        }
        insert lstEvents;
    }

    private static void updateEventsForGames(
        List<League_Game__c> lstGames,
        Map<Id, League_Game__c> mapOldGames,
        Map<Id, Team__c> mapTeams
    ) {
        Set<Id> eventGameIds = new Set<Id>();
        for(League_Game__c game : lstGames) {
            League_Game__c oldGame = mapOldGames.get(game.Id);
            if (
                game.Game_Time__c != oldGame.Game_Time__c || 
                game.Status__c != oldGame.Status__c ||
                game.Game_Result__c != oldGame.Game_Result__c ||
                game.Venue__c != oldGame.Venue__c
            ) {
                eventGameIds.add(game.Id);
            }
        }

        if (eventGameIds.isEmpty()) {
            return;
        }

        List<Event> lstEvents = [
            SELECT Id, Subject, StartDateTime, EndDateTime, League_Game_ID__c 
              FROM Event 
             WHERE League_Game_ID__c IN :eventGameIds 
              WITH SECURITY_ENFORCED
        ];

        Map<Id, Event> mapEvents = new Map<Id, Event>();
        for (Event event : lstEvents) {
            mapEvents.put(event.League_Game_ID__c, event);
        }

        List<Event> lstEventsToUpdate = new List<Event>();
        for (League_Game__c lg : lstGames) {
            String strSubject = getEventSubjectFromGame(lg);

            Event ev = mapEvents.get(lg.Id);
            ev.StartDateTime = lg.Game_Time__c;
            ev.EndDateTime   = lg.End_Time__c;
            ev.Subject       = strSubject;
            ev.Location      = lg.Venue_Name_and_Address__c;
            lstEventsToUpdate.add(ev);
        }
        update lstEventsToUpdate;

    }

    private static void deleteEventsForGames(List<League_Game__c> lstGames) {
        System.debug(':::: entered delete events method');
        Set<Id> setGameIds = new Set<Id>();
        for (League_Game__c lg : lstGames) {
            setGameIds.add(lg.Id);
        }
        List<Event> lstEventsToDelete = [SELECT Id FROM Event WHERE League_Game_ID__c IN :setGameIds WITH SECURITY_ENFORCED];
        System.debug(':::: lstEventsToDelete has ' + lstEventsToDelete.size() + ' records');
        if (!lstEventsToDelete.isEmpty()) {
            delete lstEventsToDelete;
        }
    }

    private static String getEventSubjectFromGame(League_Game__c game) {
        String strSubject = LeagueGameHandler.getSeasonGameName(game, false);
        if (game.Status__c == 'Complete') {
            strSubject += ' (' + game.Game_Result__c + ')';
        } else if (game.Status__c == 'Cancelled' || game.Status__c == 'Postponed') {
            strSubject += ' (' + game.Status__c + ')';
        }
        return strSubject;
    }

}
