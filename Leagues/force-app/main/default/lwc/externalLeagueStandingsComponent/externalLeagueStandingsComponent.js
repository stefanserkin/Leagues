import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getLeagueSeasons from '@salesforce/apex/LeagueSeasonStandingsController.getLeagueSeasons';

export default class ExternalLeagueStandingsComponent extends NavigationMixin(LightningElement) {
    @api showTeamLogos;
    @api sport;
    isLoading = false;

    get cardTitle() {
        return `League Standings`;
    }

    wiredLeagueSeasonsResult;
    leagueSeasons = [];

    leagueSeasonOptions = [];
    leagueSeasonsChoice = '';
    selectedLeagueSeason = '';
    selectedLeagueSeasonName = '';

    @wire(getLeagueSeasons, { sport : '$sport'})
    wiredLeagueSeasons(result) {
        this.isLoading = true;
        this.wiredLeagueSeasonsResult = result;
        const { data, error } = result;
        if (data) {
            this.leagueSeasons = data;
            
            for (let i = 0; i < data.length; i++) {
                // let leagueSeasonNameLabel = data[i].League_Name__c + ' (' + data[i].Start_Date__c + ' - ' + data[i].End_Date__c + ')';
                let leagueSeasonNameLabel = data[i].Name;
                this.leagueSeasonOptions = [...this.leagueSeasonOptions, {value: data[i].Id, label: leagueSeasonNameLabel} ];
            }
            
            this.error = undefined;

            refreshApex(this.wiredLeagueSeasonsResult);
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

    handleGoToSeason() {
        const leagueSeasonId = this.selectedLeagueSeason;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: leagueSeasonId,
                objectApiName: 'League_Season__c',
                actionName: 'view'
            }
        });

    }

}