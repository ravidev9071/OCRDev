import { LightningElement,track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import customStylesPiasky from '@salesforce/resourceUrl/piasky_customSecure';
import customStylesAveed from '@salesforce/resourceUrl/aveed_customcss';
import customStylesMaci from '@salesforce/resourceUrl/MacitentanAssets';
import searchRecords from '@salesforce/apex/MapLocatorSearchController.searchRecords';
import tryvioIconLocator from '@salesforce/resourceUrl/tryvioIconLocator';
import tryvioMapIconLocator from '@salesforce/resourceUrl/tryvioiconlocationpin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RemsLocator extends LightningElement {
    iconLocator = tryvioIconLocator;
    mapLocationIcon = tryvioMapIconLocator;
    partipantType;
    @api programName;
    @api serviceMaps;
    @track selectedType;
    @track address = '';
    @track radius = '5';
    @track showResults = false;
    @track tryvioBanner = false;
    noRecordMessage ='';
    showError = false;
    @track paramMapMarkers = [];
    @track locations = [];
    showHCS = false;
    showHCP = false;

    get typeOptions() {
        return [
            { label: 'Prescribers', value: '1' },
            { label: 'Pharmacies', value: '2' }
        ];
    }

    get radiusOptions() {
        return [
            { label: '5', value: '5' },
            { label: '10', value: '10' },
            { label: '15', value: '15' },
            { label: '20', value: '20' },
            { label: '50', value: '50' },
            { label: '60', value: '60' },
            { label: '70', value: '70' },
            { label: '100', value: '100' },
            { label: '150', value: '150' },
            { label: '200', value: '200' }
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
        this.showResults = true;
    }
    handleSearch() {
        console.log(this.address ,'  ', this.participantType);
        console.log(this.radius );

        this.records = [];
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
            searchRecords({ inputValue: this.address, participantType: this.participantType,searchType : 'Locator' , radius: this.radius, appProgramName: this.programName})
                .then(result => {
                    this.showResults = true;
                    this.paramMapMarkers = [];
                    this.locations = [];
                    var locations = [];
                    var records = JSON.parse(JSON.stringify(result));
                    console.log('test'+ JSON.stringify(result));
                    if(records.length == 0) {
                        this.showError = true;
                        this.showResults = false;
                        this.noRecordMessage ='No Accounts available for selected search criteria';
                    }
                    else {
                            for(let i=0; i<records.length; i++){
                                if(this.participantType == 'Pharmacies'){
                                    records[i].recType = records[i].Account__r.RecordType.Name=='Inpatient Pharmacy' ? 'Inpatient' : 'Outpatient';
                                    locations.push(
                                        {
                                            id:records[i].Id,
                                            name:records[i].Account__r.Name,
                                            address:records[i].Account__r.US_WSREMS__Address_Line_1__c,
                                            city:records[i].Account__r.US_WSREMS__City__c,
                                            state:records[i].Account__r.US_WSREMS__State__c,
                                            zip:records[i].Account__r.US_WSREMS__Zip__c,
                                            phone : '',
                                            miles : records[i].miles.toFixed(1),
                                            directionsUrl : 'https://www.google.com/maps/dir//'+records[i].Account__r.US_WSREMS__Address_Line_1__c+'.'+records[i].Account__r.US_WSREMS__City__c+','+records[i].Account__r.US_WSREMS__State__c+','+records[i].Account__r.US_WSREMS__Zip__c
                                        }
                                    );
                                } else if(this.participantType == 'Prescribers'){
                                    locations.push(
                                        {
                                            id:records[i].Id,
                                            name:records[i].Account__r.Name,
                                            address:records[i].Account__r.US_WSREMS__Address_Line_1__c,
                                            city:records[i].Account__r.US_WSREMS__City__c,
                                            state:records[i].Account__r.US_WSREMS__State__c,
                                            zip:records[i].Account__r.US_WSREMS__Zip__c,
                                            phone : '',
                                            miles : records[i].miles.toFixed(1),
                                            directionsUrl : 'https://www.google.com/maps/dir//'+records[i].Account__r.US_WSREMS__Address_Line_1__c+'.'+records[i].Account__r.US_WSREMS__City__c+','+records[i].Account__r.US_WSREMS__State__c+','+records[i].Account__r.US_WSREMS__Zip__c
                                        }
                                    );
                                }
                            }
                            
                            this.updateMapMarkers(records);
                            this.locations = locations;
                            console.log('locations::', locations);
                        }
                        console.log('result'+ JSON.stringify(this.records));
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
        if(this.participantType == 'Prescribers'){
            this.showHCP = true;
        }
        else if(this.participantType == 'Pharmacies'){
            this.showHCS = true; 
        }
    }

    connectedCallback() {
        if(this.programName == 'Tryvio'){
            this.tryvioBanner = true;
            loadStyle(this, customStyles)
            .then(() => {
                console.log('Styles loaded successfully');
            })
            .catch(error => {
                console.error('Error loading the styles', error);
            });
        }else if(this.programName == 'Piasky'){
            loadStyle(this, customStylesPiasky)
                .then(() => {
                    console.log('Styles loaded successfully');
                })
                .catch(error => {
                    console.error('Error loading the styles', error);
                });
        }else if(this.programName == 'Aveed'){
            loadStyle(this, customStylesAveed)
                .then(() => {
                    console.log('Styles loaded successfully');
                })
                .catch(error => {
                    console.error('Error loading the styles', error);
                });
        }else if(this.programName == 'Maci'){
            loadStyle(this, customStylesMaci)
                .then(() => {
                    console.log('Styles loaded successfully');
                })
                .catch(error => {
                    console.error('Error loading the styles', error);
                });
        }

    }
    updateMapMarkers(records) {
        var mapMarkers = [];
        this.paramMapMarkers = [];
        for(let i=0; i<records.length; i++){
            mapMarkers.push(
                {
                    location: {
                        PostalCode: records[i].Account__r.US_WSREMS__Zip__c,
                        City: records[i].Account__r.US_WSREMS__City__c,
                        State : records[i].Account__r.US_WSREMS__State__c
                    },
                    title: records[i].Account__r.Name ? records[i].Account__r.Name : records[i].Account__r.LastName +',' +records[i].Account__r.FirstName,
                    icon: 'standard:account',
                    value: records[i].Id
                }
            );
        }
        console.log('mapMarkers:::',mapMarkers);
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