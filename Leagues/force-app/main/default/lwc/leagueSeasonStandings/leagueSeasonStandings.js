import { LightningElement, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getRecord } from 'lightning/uiRecordApi';
import STYLES from '@salesforce/resourceUrl/LeagueStandingsStyles';
import getTeams from '@salesforce/apex/LeagueSeasonStandingsController.getTeams';

import LEAGUE_NAME_FIELD from '@salesforce/schema/League_Season__c.League_Name__c';
import START_DATE_FIELD from '@salesforce/schema/League_Season__c.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/League_Season__c.End_Date__c';

const COLS = [
    { label: '', fieldName: 'teamLogo', type: 'image', initialWidth: 32 },
    { label: 'Team', fieldName: 'teamUrl', type: 'url', 
        typeAttributes: {
            label: { fieldName: 'teamName' }
        }, 
        sortable: true
    },
    { label: 'Games Played', fieldName: 'Games_Played__c', type: 'number' },
    { label: 'Wins', fieldName: 'Wins__c', type: 'number' },
    { label: 'Losses', fieldName: 'Losses__c', type: 'number' },
    { label: 'Ties', fieldName: 'Ties__c', type: 'number' },
    { label: 'Points', fieldName: 'Points__c', type: 'number',
        cellAttributes: {
            class: { fieldName:'pointsColumnColor' },
            alignment: 'center'
        }
    }
];

const COLS_NO_LOGOS = [
    { label: 'Team', fieldName: 'teamUrl', type: 'url', 
        typeAttributes: {
            label: { fieldName: 'teamName' }
        }, 
        sortable: true
    },
    { label: 'Games Played', fieldName: 'Games_Played__c', type: 'number' },
    { label: 'Wins', fieldName: 'Wins__c', type: 'number' },
    { label: 'Losses', fieldName: 'Losses__c', type: 'number' },
    { label: 'Ties', fieldName: 'Ties__c', type: 'number' },
    { label: 'Points', fieldName: 'Points__c', type: 'number',
        cellAttributes: {
            class: { fieldName:'pointsColumnColor' },
            alignment: 'center'
        }
    }
];

export default class LeagueSeasonStandings extends LightningElement {
    @api showTeamLogos;
    @api leagueSeasonId;
    isLoading = true;
    isCssLoaded = false;
    error;

    get cardTitle() {
        return `${this.leagueName} Standings`;
    }
    get leagueDateRange() {
        return `${this.leagueStartDate} - ${this.leagueEndDate}`;
    }

    wiredTeamsResult;
    teams = [];
    
    get cols() {
        return this.showTeamLogos ? COLS : COLS_NO_LOGOS;
    }

    leagueName;
    leagueStartDate;
    leagueEndDate;

    @wire(getRecord, {
        recordId: '$leagueSeasonId',
        fields: [LEAGUE_NAME_FIELD, START_DATE_FIELD, END_DATE_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error; 
        } else if (data) {
            this.leagueName = data.fields.League_Name__c.value;
            this.leagueStartDate = data.fields.Start_Date__c.value;
            this.leagueEndDate = data.fields.End_Date__c.value;
        }
    }

    @wire(getTeams, { recordId : '$leagueSeasonId' })
    wiredTeams(result) {
        this.wiredTeamsResult = result;
        const { data, error } = result;
        if (error) {
            this.teams = undefined;
            this.error = error;
            console.error(error);
            this.isLoading = false;
        } else if (data) {
            let teamUrl;
            let teamLogo;
            let parsedTeamsData = JSON.parse(JSON.stringify(result.data));
            parsedTeamsData = parsedTeamsData.map(row => {
                teamUrl = `/${row.Id}`;
                if (row.Team_Logo_URL__c) {
                    teamLogo = row.Team_Logo_URL__c;
                } else {
                    teamLogo = 'https://asphaltgreen--leagues--c.documentforce.com/servlet/servlet.ImageServer?id=01503000000I3SK&oid=00D030000008pAs&lastMod=1634498460000';
                }
                return {...row, 
                    'teamName':row.Name,
                    'teamUrl':teamUrl,
                    'pointsColumnColor':'datatable-shading',
                    'teamLogo':teamLogo
                }
            });

            this.teams = parsedTeamsData;
            this.error = undefined;
            console.table(parsedTeamsData);
            this.isLoading = false;
        }
    }

    renderedCallback() {
        if (this.isCssLoaded) return;
        this.isCssLoaded = true;
        loadStyle(this, STYLES).then(()=> {
            console.log('loaded styles successfully');
        }).catch(error=>{
            console.error('unable to load files');
        });
    }    
}