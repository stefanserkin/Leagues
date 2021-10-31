import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import simulateSeason from '@salesforce/apex/SeasonSimulatorController.simulateSeason';

import LS_NAME_FIELD from '@salesforce/schema/League_Season__c.Name';

export default class SeasonSimulator extends LightningElement {
    @api recordId;
    cardTitle = `Simulate ${this.leagueSeasonName}`;
    leagueSeasonName = '';
    simulationResult = '';
    simulationComplete = false;

    isLoading = true;
    error;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [LS_NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error; 
        } else if (data) {
            this.leagueSeasonName = data.fields.Name.value;
            this.isLoading = false;
        }
    }

    runSimulation() {
        this.isLoading = true;
        simulateSeason({recordId : this.recordId})
            .then((result) => {
                const seasonResult = result;
                this.simulationResult = result;
                const toastEvent = new ShowToastEvent({
                    title: 'Simulation Complete',
                    message: 'Refresh the page to see results.',
                    variant: 'Success'
                });
                this.dispatchEvent(toastEvent);
                this.simulationComplete = true;
                this.isLoading = false;
            })
            .catch(error =>{
                this.error = error;
                this.isLoading = false;
                window.console.log('Unable to create the records due to ' + JSON.stringify(this.error));
            });
    }
}