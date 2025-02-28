import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import searchRecords from '@salesforce/apex/SYN_PortalHCSHCPLookupSearchCtrl.searchRecords';
import searchHCPRecords from '@salesforce/apex/SYN_PortalHCSHCPLookupSearchCtrl.searchHCPRecords';
import aveed_IconLocation from "@salesforce/resourceUrl/aveed_IconLocation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Aveed_LookupScreen extends LightningElement {
    @track records = [];
    @track prescriber_records = [];
    participantType;
    @track searchKeyWordValue = '';
    @track sortDirection = 'utility:arrowdown';
    @track sortedBy = 'Name'; // Initial sorting column
    @track sortedByHCP = 'LastName';
    @track sortedDirection = 'asc'; // Initial sorting direction
    @track sortIcon = 'utility:arrowup';
    @track sortIconHCS = 'utility:arrowup';
    participantValidation = false;
    parseDataFinal = '';
    locatorUrl;
    iconLocation = aveed_IconLocation;
    showError = false;

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        let currentUrl = window.location.href;
        this.locatorUrl = currentUrl.substring(0, currentUrl.indexOf('s/')) + 's/locator';
    }
    handleChange(event) {
        this.searchKeyWordValue = event.target.value;
        const inputField = this.template.querySelector('lightning-input');
        inputField.setCustomValidity('');
        inputField.reportValidity();
        if (!this.searchKeyWordValue) {
            this.records = [];
            this.showError = false;
            inputField.setCustomValidity('Please enter value');
            inputField.reportValidity();
            inputField.focus();
        }
    }
    handleParticipantSelection(event) {
        this.participantType = event.target.value;
    }

    handleSearch() {
        this.prescriber_records = [];
        this.records = [];
        this.participantValidation = false;
        const inputField = this.template.querySelector('lightning-input');
        if (this.participantType) {
            inputField.setCustomValidity('');
            inputField.reportValidity();
            if (this.participantType && !this.searchKeyWordValue) {
                inputField.setCustomValidity('Please enter value');
                inputField.reportValidity();
                inputField.focus();
            } else if (this.participantType == 'Health_Care_Setting') {
                searchRecords({ searchKeyWord: this.searchKeyWordValue })
                    .then(result => {
                        this.showError = false;
                        this.records = result;
                        if (this.records.length == 0) {
                            this.showError = true;
                            this.noRecordMessage = 'No Accounts available for selected search criteria';
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching records:', error);
                    });
            } else if (this.participantType == 'Prescriber') {
                searchHCPRecords({ searchKeyWord: this.searchKeyWordValue })
                    .then(result => {
                        this.showError = false;
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
                            this.noRecordMessage = 'No Accounts available for selected search criteria';
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching records:', error);
                    });
            }

        } else {
            this.participantValidation = true;
        }

    }

    sortByColumn(event) {
        const clickedColumn = event.target.dataset.title; // Extract the column header text

        if (this.sortedBy === clickedColumn) {
            // Toggle sorting direction if the same column header is clicked again
            this.sortedDirection = this.sortedDirection === 'desc' ? 'asc' : 'desc';

            this.sortIconHCS = this.sortIconHCS === 'utility:arrowup' ? 'utility:arrowdown' : 'utility:arrowup';
        }
        else if (this.sortedByHCP === clickedColumn) {
            this.sortedDirection = this.sortedDirection === 'desc' ? 'asc' : 'desc';

            this.sortIcon = this.sortIcon === 'utility:arrowup' ? 'utility:arrowdown' : 'utility:arrowup';
        }
        else {
            // Update sorting column and set sorting direction to ascending
            this.sortedBy = clickedColumn;
            this.sortedByHCP = clickedColumn;
            this.sortedDirection = 'desc';
        }
        this.sortData(this.sortedBy, this.sortedDirection);

    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.prescriber_records));
        let parseDataHCS = JSON.parse(JSON.stringify(this.records));

        if (parseData != '') {
            let keyValue = (a) => {
                return a[fieldname];
            };
            let isReverse = direction === "desc" ? 1 : -1;
            parseData.sort((x, y) => {
                x = keyValue(x) ? keyValue(x) : "";
                y = keyValue(y) ? keyValue(y) : "";
                return isReverse * ((x > y) - (y > x));
            });
            this.prescriber_records = parseData;
        }
        if (parseDataHCS !== '') {
            let keyValue = (a) => {
                return a[fieldname];
            };
            let isReverse = direction === "desc" ? 1 : -1;
            parseDataHCS.sort((x, y) => {
                x = keyValue(x) ? keyValue(x) : "";
                y = keyValue(y) ? keyValue(y) : "";
                return isReverse * ((x > y) - (y > x));
            });
            this.records = parseDataHCS;
        }

    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

}