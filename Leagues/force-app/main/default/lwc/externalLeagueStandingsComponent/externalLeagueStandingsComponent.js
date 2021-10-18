import { LightningElement, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import STYLES from '@salesforce/resourceUrl/LeagueStandingsStyles';

import getTeams from '@salesforce/apex/LeagueSeasonStandingsController.getTeams';

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

export default class ExternalLeagueStandingsComponent extends LightningElement {
    @api showTeamLogos;
    @api leagueSeasonId;
    isLoading = true;
    isCssLoaded = false;
    error;

    get cardTitle() {
        return `League Standings`;
    }

    wiredTeamsResult;
    teams = [];
    
    get cols() {
        return this.showTeamLogos ? COLS : COLS_NO_LOGOS;
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