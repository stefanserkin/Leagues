import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getMyTeams from '@salesforce/apex/ExternalMyTeamsComponentController.getMyTeams';
import USER_ID from '@salesforce/user/Id';
import CONTACTID_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNTID_FIELD from '@salesforce/schema/User.AccountId';

const COLS = [
    { label: 'Team Name', fieldName: 'Name', type: 'text'},
    { label: 'League Season', fieldName: 'lsUrl', type: 'url', typeAttributes: {
        label: { fieldName: 'leagueSeasonName' }
        }
    },

    { label: 'Wins', fieldName: 'Wins__c', type: 'number', initialWidth: 120 },
    { label: 'Losses', fieldName: 'Losses__c', type: 'number', initialWidth: 120 },
    { label: 'Ties', fieldName: 'Ties__c', type: 'number', initialWidth: 120 },
    {  
        type: 'button',
        initialWidth: 180, 
        typeAttributes: {
            label: 'Go to Team Page'
        }
    }
];

export default class ExternalMyTeamsComponent extends NavigationMixin(LightningElement) {
    cardTitle = `My Household's Teams`
    isLoading = true;
    error;

    contactId;
    accountId;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACTID_FIELD, ACCOUNTID_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error; 
        } else if (data) {
            this.contactId = data.fields.ContactId.value;
            this.accountId = data.fields.AccountId.value;
        }
    }

    cols = COLS;
    wiredTeamsList;
    teamsList = [];
    teamsPerPage = [];
    // Navigation
    page = 1;
    pageSize = 10;
    startingRecord = 1;
    endingRecord = 0;
    totalRecordCount = 0;
    totalPages = 0;

    // Pagination methods
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordsPerPage(this.page);
        }
    }

    nextHandler() {
        if((this.page < this.totalPages) && this.page !== this.totalPages){
            this.page = this.page + 1;
            this.displayRecordsPerPage(this.page);            
        }
    }

    displayRecordsPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord; 

        this.teamsPerPage = this.teamsList.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    } 

    @wire(getMyTeams, { accountId: '$accountId' }) 
    teamList(result) {
        this.wiredTeamsList = result;
        if (result.data) {
            console.table(result.data);

            this.teamsList = result.data.map(item=>{
                let url = '/s/team/' + item.Id + '/';
                let leagueSeasonName = item.League_Season__r.Name;
                let lsUrl = '/s/league-season/' + item.League_Season__c + '/';
                return {...item,
                    "teamUrl":url,
                    "lsUrl":lsUrl,
                    "leagueSeasonName":leagueSeasonName
                }
            });

            this.totalRecordCount = result.data.length;
            this.totalPages = Math.ceil(this.totalRecordCount / this.pageSize);
            this.teamsPerPage = this.teamsList.slice(0, this.pageSize);
            this.endingRecord = this.pageSize;
            this.isLoading = false;
            this.error = undefined;
        } else if (result.error) {
            console.error(result.error);
            this.error = result.error;
            this.teamsList = [];
        }
    }

    handleRowAction(event) {
        const rowId = event.detail.row.Id;
        console.log(`rowId is ${rowId}`)
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rowId,
                objectApiName: 'Team__c',
                actionName: 'view'
            }
        });
    }

}