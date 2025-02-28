import { LightningElement, track,wire } from 'lwc';
import getCerifiedPharmacies from '@salesforce/apex/SYN_PiaSkyPharmacyLookupSearchCls.getCerifiedPharmacies';
export default class PiaSky_PharmacyLookup extends LightningElement {
    @track records = [];
    @track noRecordMessage ='';
    @track showError = false;
    @track showPagination =false;
    @track visibleContacts=[];
     @track sortDirection = 'utility:arrowdown';
    @track sortedBy = 'Name'; // Initial sorting column
    @track sortedDirection = 'asc'; // Initial sorting direction
    sortIcon = 'utility:arrowup';

    @wire(getCerifiedPharmacies,{sortedDirection: '$sortedDirection'})
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.records = data;
            if(this.records.length == 0) {
                this.showError = true;
                this.noRecordMessage ='No Accounts available for selected search criteria';
            }else{
                this.showPagination = true;
            }
        } else if (error) {
        }
    }
    updateRecords(event){
        this.visibileContacts = [];
        this.visibleContacts=[...event.detail.records]
    }
    sortByColumn(event) {
        const clickedColumn = event.target.dataset.title; // Extract the column header text
        if (this.sortedBy === clickedColumn) {
              
            // Toggle sorting direction if the same column header is clicked again
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
            this.sortIcon = this.sortIcon === 'utility:arrowup'?'utility:arrowdown':'utility:arrowup';


        }
    }
    
}