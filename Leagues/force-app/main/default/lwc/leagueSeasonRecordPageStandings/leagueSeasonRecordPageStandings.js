import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class LeagueSeasonRecordPageStandings extends NavigationMixin(LightningElement) {
    @api showTeamLogos;
    @api recordId;

    handleTeamCreation() {
        const defaultValues = encodeDefaultFieldValues({
            League_Season__c: this.recordId
        });

        console.log(defaultValues);

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Team__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }
}