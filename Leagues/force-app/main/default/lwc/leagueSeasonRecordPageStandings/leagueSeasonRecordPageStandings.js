import { LightningElement, api } from 'lwc';

export default class LeagueSeasonRecordPageStandings extends LightningElement {
    @api showTeamLogos;
    @api recordId;
}