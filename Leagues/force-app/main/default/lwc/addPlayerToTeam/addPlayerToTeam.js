import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import { getObjectInfo} from 'lightning/uiObjectInfoApi';
import SPORT_FIELD from '@salesforce/schema/Team__c.Sport__c';
import PLAYER_OBJECT from '@salesforce/schema/Player__c';
import RECORD_TYPE_ID_FIELD from '@salesforce/schema/Player__c.RecordTypeId';
import UNIFORM_NUMBER_FIELD from '@salesforce/schema/Player__c.Uniform_Number__c';
import CONTACT_FIELD from '@salesforce/schema/Player__c.Contact__c';
import TEAM_ID_FIELD from '@salesforce/schema/Player__c.Team__c';

export default class AddPlayerToTeam extends LightningElement {
    @api recordId;
    isLoading = false;
    isFormEntry = false;

    sport;
    
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [SPORT_FIELD]
    }) wireContact({
        error,
        data
    }) {
        if (error) {
            this.error = error ; 
        } else if (data) {
            this.sport = data.fields.Sport__c.value;
        }
    }
    
    @wire(getObjectInfo, { objectApiName: PLAYER_OBJECT })
    playerObjectInfo;

    get playerRecordTypeId() {
        const rtis = this.playerObjectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === this.sport);
    }

    handleOpenForm() {
        this.isFormEntry = true;
    }

    handleCloseForm() {
        this.isFormEntry = false;
    }

    fields = ["Name","Email","Birthdate"];
    displayFields = 'Name, Email, Birthdate';
    selectedContact;
    uniformNumber;
    playerId;

    player;

    handleLookup(event){
        this.playerId = undefined;
        this.selectedContact = event.detail.data.recordId;
    }

    handleUniformNumberChange(event) {
        this.playerId = undefined;
        this.uniformNumber = event.target.value;
    }

    handleCreatePlayer() {
        this.isLoading = true;
        const fields = {};
        fields[UNIFORM_NUMBER_FIELD.fieldApiName] = this.uniformNumber;
        fields[CONTACT_FIELD.fieldApiName] = this.selectedContact;
        fields[TEAM_ID_FIELD.fieldApiName] = this.recordId;
        fields[RECORD_TYPE_ID_FIELD.fieldApiName] = this.playerRecordTypeId;
        const recordInput = { apiName: PLAYER_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then((player) => {
                this.playerId = player.Id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Player added to roster',
                        variant: 'success'
                    })
                );
                this.isLoading = false;
                this.isFormEntry = false;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
                this.isLoading = false;
                this.isFormEntry = false;
            });
    }
}