import { LightningElement,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import searchRecords from '@salesforce/apex/SYN_XiaflexPharmacyLookupSearchCls.searchRecordsForLocator';
import xiaflex_googleMap from "@salesforce/resourceUrl/xiaflex_googleMap";
import xiaflex_locationPin from "@salesforce/resourceUrl/xiaflex_locationPin";
import xiaflex_iconSearch from "@salesforce/resourceUrl/xiaflex_iconSearch";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Xiaflex_Locator extends LightningElement {
    googleMap = xiaflex_googleMap;
    locationPin = xiaflex_locationPin;
    iconSearch = xiaflex_iconSearch;
    partipantType;
    @track selectedType;
    @track address = '';
    @track radius = '10';
    @track showResults = false;
    noRecordMessage ='';
    showError = false;
    @track paramMapMarkers = [];
    @track locations = [];
    showHCS = false;
    showHCP = false;

    connectedCallback() {
        try {
            loadStyle(this, customHomeStyles);
        } catch (error) {
            console.log('error>>',error);
        }

    }

    get typeOptions() {
        return [
            { label: 'Prescribers', value: '1' },
            { label: 'Pharmacies', value: '2' }
        ];
    }

    get radiusOptions() {
        return [
            { label: '5 miles', value: '5' },
            { label: '10 miles', value: '10' },
            { label: '15 miles', value: '15' },
            { label: '20 miles', value: '20' },
            { label: '50 miles', value: '50' },
            { label: '100 miles', value: '100' }
        ];
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
    }

    handleAddressChange(event) {
        this.address = event.target.value;
    }

    handleRadiusChange(event) {
        this.radius = event.target.value;
    }

    handleSearch() {
        this.locations = [];
        this.showResults = false;
        this.showError = false;
        this.paramMapMarkers = [];
        if(!this.showHCP && !this.showHCS) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select participant type',
                    variant: 'error',
                })
            );
        } else {
            searchRecords({ inputValue: this.address, participantType: this.participantType, programType : 'REMS' })
                .then(result => {
                    this.showResults = true;
                    this.paramMapMarkers = [];
                    this.locations = [];
                    var location = [];
                    var records = JSON.parse(JSON.stringify(result));
                    if(records.length == 0) {
                        this.showError = true;
                        this.showResults = false;
                        this.noRecordMessage ='No Accounts available for selected search criteria';
                    }
                    else {
                            for(let i=0; i<records.length; i++){
                                if(this.participantType == 'HealthcareSetting'){    
                                    let addressLine1 = records[i].US_WSREMS__Address_Line_1__c;
                                    let addressLine2 = records[i].US_WSREMS__Address_Line_2__c;
                                    let address = '';
                                    if (addressLine1 != null && addressLine1 != undefined && addressLine1.length > 0) {
                                        address += addressLine1;
                                    }
                                    if (addressLine2 != null && addressLine2 != undefined && addressLine2.length > 0) {
                                        address += ' ' + addressLine2;
                                    }
                                    location.push(
                                        {
                                            id:records[i].Id,
                                            name:records[i].Name,
                                            address:address,
                                            city:records[i].US_WSREMS__City__c,
                                            state:records[i].US_WSREMS__State__c,
                                            zip:records[i].US_WSREMS__Zip__c,
                                            phone : records[i].Phone,
                                            miles : ''
                                        }
                                    );
                                } else if(this.participantType == 'Prescribing'){
                                    let addressLine1 = records[i].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c;
                                    let addressLine2 = records[i].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c;
                                    let address = '';
                                    if (addressLine1 != null && addressLine1 != undefined && addressLine1.length > 0) {
                                        address += addressLine1;
                                    }
                                    if (addressLine2 != null && addressLine2 != undefined && addressLine2.length > 0) {
                                        address += ' ' + addressLine2;
                                    }
                                    location.push(
                                        {
                                            id: records[i].US_WSREMS__Prescriber__r.Id,
                                            name: records[i].US_WSREMS__Prescriber__r.Name,
                                            address: address,
                                            city: records[i].US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c,
                                            state: records[i].US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c,
                                            zip: records[i].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c,
                                            phone: records[i].US_WSREMS__Prescriber__r.Phone,
                                            miles: ''
                                        }
                                    );
                                }
                            }
                            records = this.sortData('Name','asc',records);
                            location = this.sortData('name','asc',location);
                            this.updateMapMarkers(location);
                            this.locations = [...location];
                        }
                })
                .catch(error => {
                    console.error('Error fetching records:', error);
                });
        }
    }

    handleChangeRadio(event) {
        this.participantType = event.target.value;
        this.showHCP = false;
        this.showHCS = false; 
        this.showResults = false;
        if(this.participantType == 'Prescribing'){
            this.showHCP = true;
        }
        else if(this.participantType == 'HealthcareSetting'){
            this.showHCS = true; 
        }
    }

    updateMapMarkers(records) {
        var mapMarkers = [];
        this.paramMapMarkers = [];
        for (let obj of records) {
            mapMarkers.push(
                {
                    location: {
                        PostalCode: obj.zip,
                        City: obj.city,
                        State: obj.state
                    },
                    title: obj.name,
                    icon: 'standard:account',
                    value: obj.id
                }
            );
        }
        this.paramMapMarkers = mapMarkers;
    }

    sortData(sortColumnName, sortedDirection, records) {       

        // check reverse direction
        let isReverse = sortedDirection === 'asc' ? 1 : -1;

        // sort the data
        records = JSON.parse(JSON.stringify(records)).sort((a, b) => {
            a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : ''; // Handle null values
            b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';

            return a > b ? 1 * isReverse : -1 * isReverse;
        });;

        return records;
    }
}