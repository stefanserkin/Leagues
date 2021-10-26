import { LightningElement, api } from 'lwc';

export default class ExternalLeagueSeasonRecordPageStandings extends LightningElement {
    @api showTeamLogos;
    @api recordId;
}