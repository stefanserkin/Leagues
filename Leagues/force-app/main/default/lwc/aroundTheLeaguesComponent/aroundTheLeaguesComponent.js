import { LightningElement, api, wire } from 'lwc';
import getLeagueSeasons from '@salesforce/apex/LeagueSeasonStandingsController.getLeagueSeasons';

export default class AroundTheLeaguesComponent extends LightningElement {
    @api showTeamLogos;
    isLoading = true;

    // SCANNING LOCATIONS
    wiredLeagueSeasonsResult;
    leagueSeasons = [];

    leagueSeasonOptions = [];
    leagueSeasonsChoice = '';
    selectedLeagueSeason = '';
    selectedLeagueSeasonName = '';

    sport;

    handleActive(event) {
        console.log(event.target.value);
        this.sport = event.target.value;
    }

    @wire(getLeagueSeasons, { sport : '$sport'})
    wiredLeagueSeasons(result) {
        this.wiredLeagueSeasonsResult = result;
        const { data, error } = result;
        if (data) {
            this.leagueSeasons = data;
            console.table(this.leagueSeasons);
            
            for (let i = 0; i < data.length; i++) {
                let leagueSeasonNameLabel = data[i].League_Name__c + ' (' + data[i].Start_Date__c + ' - ' + data[i].End_Date__c + ')';
                this.leagueSeasonOptions = [...this.leagueSeasonOptions, {value: data[i].Id, label: leagueSeasonNameLabel} ];
            }
            
            this.error = undefined;
            this.isLoading = false;
        } else if (error) {
            this.leagueSeasons = undefined;
            this.error = error;
            this.isLoading = false;
        }
    }

    get leagueSeasonOptionValues() {
        return this.leagueSeasonOptions;
    }

    // HANDLE COMBOBOX CHANGE
    handleLeagueSeasonChange(event) {
        const selectedOption = event.detail.value;
        this.selectedLeagueSeason = selectedOption;
    }

    // COMBOBOX VALUE
    get selectedLeagueSeasonValue() {
        return this.selectedLeagueSeason;
    }

}