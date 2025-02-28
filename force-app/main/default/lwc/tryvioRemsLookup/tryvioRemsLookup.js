import { LightningElement,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconLookup from '@salesforce/resourceUrl/tryvioIconLookup';
import tryvioIconLocation from '@salesforce/resourceUrl/tryvioIconLocation';
import tryvioIconSortAsc from '@salesforce/resourceUrl/tryvioIconSortAsc';
import searchRecords from '@salesforce/apex/TryvioLookupSearchCls.searchRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TryvioRemsLookup extends LightningElement {
    @track records = [];
    inputVal ='';
    noRecordMessage ='';
    showError = false;
    showTable = false;
    visibileContacts;
    participantType='';
    showHCS = false;
    showHCP = false;
    @track showPagination =false;
    iconLookup = tryvioIconLookup;
    iconLocation = tryvioIconLocation;
    iconSortAsc = tryvioIconSortAsc;
    isAsc = false;
    isDsc = false;
    sortedDirection = 'asc';
    sortedColumn;
    
    connectedCallback() {
        loadStyle(this, customStyles);
    }
    handleChangeRadio(event) {
        this.showHCS = false;
        this.showHCP = false;
        this.showTable = false;
        this.participantType = event.target.value;
        if(this.participantType == 'Prescribers'){
            this.showHCP = true;
        }
        else if(this.participantType == 'Pharmacies'){
            this.showHCS = true; 
        }
    }
    handleSearch() {
        console.log(this.inputVal ,'  ', this.participantType);
        this.showTable = false;
        this.records = [];
        if(!this.showHCP && !this.showHCS) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select participant type',
                    variant: 'error',
                })
            );
        } else {
            searchRecords({ inputValue: this.inputVal, participantType: this.participantType,searchType : 'Lookup' })
                .then(result => {
                    this.showError = false;
                    this.showTable = true;
                    this.records = [];
                    this.records = JSON.parse(JSON.stringify(result));
                    console.log('test'+ JSON.stringify(result));
                    if(this.records.length == 0) {
                        this.showError = true;
                        this.showTable = false;
                        this.noRecordMessage ='No Accounts available for selected search criteria';
                    }
                    else {
                        if(this.participantType == 'Pharmacies'){
                            for(let i=0; i<this.records.length; i++){
                                this.records[i].recType = this.records[i].RecordType.Name=='Inpatient Pharmacy' ? 'Inpatient' : 'Outpatient';
                            }
                            this.records = this.sortData('Name',this.records);
                        }
                        console.log('result'+ JSON.stringify(this.records));
                        this.showPagination = true;
                    }
                })
                .catch(error => {
                    console.error('Error fetching records:', error);
                });
        }
    }
    handleChange(event) {
        this.inputVal = event.target.value;
    }
    updateRecords(event){
        this.visibileContacts = [];
        this.visibileContacts=[...event.detail.records]
        console.log('------',JSON.stringify(this.visibileContacts));
    }

    sortData(sortColumnName, records) {
        // check previous column and direction
        if (this.sortedColumn === sortColumnName) {
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        } 
        else {
            this.sortedDirection = 'asc';
        }

        // check arrow direction
        if (this.sortedDirection === 'asc') {
            this.isAsc = true;
            this.isDsc = false;
        } 
        else {
            this.isAsc = false;
            this.isDsc = true;
        }

        // check reverse direction
        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

        this.sortedColumn = sortColumnName;

        // sort the data
        records = JSON.parse(JSON.stringify(records)).sort((a, b) => {
            a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : ''; // Handle null values
            b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';

            return a > b ? 1 * isReverse : -1 * isReverse;
        });;

        return records;
    }
}