import LightningDatatable from 'lightning/datatable';
import tableImageControl from './tableImageControl.html';

export default class LeagueSeasonDatatable extends LightningDatatable {
    static customTypes = {
        image: {
            template: tableImageControl
        }
    };
}