import { LightningElement,track,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import xiaflex_IconLocation from "@salesforce/resourceUrl/xiaflex_IconLocation";
import xiaflex_bgLtGrey from "@salesforce/resourceUrl/xiaflex_bgLtGrey";
import xiaflex_IconSortAcc from "@salesforce/resourceUrl/xiaflex_IconSortAcc";
import xiaflex_iconSearch from "@salesforce/resourceUrl/xiaflex_iconSearch";
import searchRecords from '@salesforce/apex/SYN_XiaflexPharmacyLookupSearchCls.searchRecords';
import searchHCPRecords from '@salesforce/apex/SYN_XiaflexPharmacyLookupSearchCls.searchHCPRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Xiaflex_LookupScreen extends LightningElement{
    @track records = [];
    @track name = '';
    @track inputVal ='';
    @track ShippingPostalCode = '';
    @track NPINumber = '';
    @track ShippingState = [];
    @track prescriber_records = [];
    @track selectedState;
    @track noRecordMessage ='';
    @track showError = false;
    @track showTable = false;
    @track participantType;
    isHCP = false;
    isHCS = false;
    visibileContacts;
    @track showPagination =false;
    sortIcon = 'utility:arrowup';
   
    iconLocation = xiaflex_IconLocation;
    iconSortAsc = xiaflex_IconSortAcc;
    iconSearch = xiaflex_iconSearch;
    bgLtGrey = xiaflex_bgLtGrey;
    locatorUrl;


    connectedCallback() {
        try {
            loadStyle(this, customHomeStyles); 
            let currentUrl = window.location.href;
            this.locatorUrl = currentUrl.substring(0, currentUrl.indexOf('s/'))+'s/locator';
            
        } catch (error) {
            console.log('error>>',error);
        }
        const departments = ['','AK','AL','AR','AS','AZ','CA','CO','CT','DC','DE','FL','GA','GU','HI','IA','ID','IL','IN','KS','KY','LA','MA','MD','ME','MI','MN','MO','MP','MS','MT','NC','ND','NE','NH','NJ','NM','NV','NY','OH','OK','OR','PA','PR','RI','SC','SD','TN','TX','UT','VA','VI','VT','WA','WI','WV','WY'];// Your list of departments
        this.ShippingState = this.generateOptions(departments);
    }
    generateOptions(options) {
        return options.map(option => ({
            label: option.charAt(0).toUpperCase() + option.slice(1),
            value: option.toLowerCase()
        }));
    }
    handleSearchKeyword() {
        this.records = [];
        this.prescriber_records = [];
        this.visibileContacts = [];
        this.showTable = false;
        if(!this.isHCP && !this.isHCS) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select participant type',
                    variant: 'error',
                })
            );
        } else if (this.participantType == 'Prescribing') {
            searchHCPRecords({ searchKeyWord: this.inputVal, programName : 'XIAFLEX', programType : 'REMS' })
                .then(result => {
                    this.showError = false;
                    this.showTable = true;
                    this.prescriber_records = result.map((obj) => {
                        return {
                            ...obj,
                            addressLine1: (obj.US_WSREMS__Health_Care_Setting__r && obj.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c != null && obj.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c != undefined) ? obj.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c : '',
                            addressLine2: (obj.US_WSREMS__Health_Care_Setting__r && obj.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c != null && obj.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c != undefined) ? obj.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c : '',
                            city: obj.US_WSREMS__Health_Care_Setting__r ? obj.US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c : '',
                            state: obj.US_WSREMS__Health_Care_Setting__r ? obj.US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c : '',
                            zip: obj.US_WSREMS__Health_Care_Setting__r ? obj.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c : ''
                        };
                    });
                    if (this.prescriber_records.length == 0) {
                        this.showError = true;
                        this.showTable = false;
                        this.noRecordMessage = 'No Accounts available for selected search criteria';
                    } else {
                        this.showPagination = true;
                    }
                })
                .catch(error => {
                    console.error('Error fetching records:', error);
                });
        }  else {
        searchRecords({ inputValue: this.inputVal, participantType: this.participantType,searchType : 'Lookup', programType : 'REMS' })
            .then(result => {
                this.showError = false;
                this.showTable = true;
                this.records = [...result];
                if(this.records.length == 0) {
                    this.showError = true;
                    this.showTable = false;
                    this.noRecordMessage ='No Accounts available for selected search criteria';
                }
                else {
                    this.showPagination = true;
                }
            })
            .catch(error => {
                console.error('Error fetching records:', error);
            });
        }
    }
    handleChange(event) {
        
        const label = event.target.label;
        this.inputVal = event.target.value;
    }


    handleChangeRadio(event) {
        const value = event.target.value;
        this.showTable = false;
        switch(value) {
            case 'Prescribing':
             this.participantType = event.target.value;
             this.isHCP = true;
             this.isHCS = false;
             this.name=null;
             this.selectedState=null;
             this.NPINumber=null;
             this.ShippingPostalCode=null;
             break;
            case 'Healthcare':
              this.participantType = event.target.value;
                this.isHCP = false;
                this.isHCS = true;
                this.name=null;
             this.selectedState=null;
             this.NPINumber=null;
             this.ShippingPostalCode=null;
              break;
              default:
        }
    }

    sortData() {
        // check previous column and direction
        this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        this.sortIcon = this.sortIcon === 'utility:arrowup'?'utility:arrowdown':'utility:arrowup';
        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
        let sortColumnName='';
        if (this.isHCP) {
            sortColumnName = 'LastName';
        } else if(this.isHCS){
            sortColumnName = 'Name';
        }

        // sort the data
        this.visibileContacts = JSON.parse(JSON.stringify(this.visibileContacts)).sort((a, b) => {
            a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : ''; // Handle null values
            b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';

            return a > b ? 1 * isReverse : -1 * isReverse;
        });;
    }

    updateRecords(event){
        this.visibileContacts = [];
        this.visibileContacts=[...event.detail.records]
    }
}