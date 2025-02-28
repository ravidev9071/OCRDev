import {LightningElement, track} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from "@salesforce/user/Id";
import getAccountRecordForSearch from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getAccountRecordForSearch';
import insertHCPSubmit from '@salesforce/apex/xiaflex_ManagePharmacies.insertHCPSubmit';
import getPickListValues from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getPicklistFieldValues';
import customHomeStyles from '@salesforce/resourceUrl/xiaflexMDP_customcss';
import xiaflex_IconSortAcc from "@salesforce/resourceUrl/xiaflex_IconSortAcc";

export default class Xiaflex_HCP_affiliateHCS extends LightningElement {
    displaySpinner = false;
    @track displaySearch = false;
    @track hcsEntry = false;
    @track hcsAccountList = [];
    @track visibileAccounts = [];
    @track stateOptions = [];
    @track checkboxDisabled = false;
    userId = Id;
    iconSortAcc = xiaflex_IconSortAcc;
    selectedHCS; 
    displaySpinner = false;
    showHCSErrMsg = false;
    get hcsType() {
        return [
            { label: 'Independent Practice', value: 'Independent Practice' },
            { label: 'Group Practice', value: 'Group Practice' },
            { label: 'Institution Central Purchasing (owned or under control of hospital system)', value: 'Institution Central Purchasing (owned or under control of hospital system)' },
            { label: 'Institution Direct Purchasing (owned or under control of hospital system)', value: 'Institution Direct Purchasing (owned or under control of hospital system)' },
            { label: 'Pharmacy (XIAFLEX is not available for distribution by retail pharmacies. Retail pharmacies should not enroll.)', value: 'Pharmacy (XIAFLEX is not available for distribution by retail pharmacies. Retail pharmacies should not enroll.)' },
        ];
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.getPickListValues();
        
    }

    async handleHcsAccountRecords(){
        this.displaySearch = false;
        this.showHCSErrMsg = false;
        let accRecords = await this.getAccountHcsRecords();
        if (accRecords != null) {
            this.hcsAccountList = accRecords.map((acc, index) => ({
                Id: acc.Id,
                Name: acc.Name,
                Address: acc.US_WSREMS__Address_Line_1__c != undefined ? acc.US_WSREMS__Address_Line_1__c : null,
                City: acc.US_WSREMS__City__c != undefined ? acc.US_WSREMS__City__c : null,
                State: acc.US_WSREMS__State__c != undefined ? acc.US_WSREMS__State__c : null,
                ZIPCode: acc.US_WSREMS__Zip_Code__c != undefined ? acc.US_WSREMS__Zip_Code__c : null,
                Phone: acc.Phone != undefined ? acc.Phone : null,
                checked: false,
                EnrollmentID: acc.US_WSREMS__REMS_ID__c,
                mdpStatusPending: acc.US_WSREMS__Status__c != 'Certified' ? acc.US_WSREMS__Status__c : null,
                mdpStatusCertified: acc.US_WSREMS__Status__c == 'Certified' ? acc.US_WSREMS__Status__c : null
            }));
            if(this.hcsAccountList.length == 0) {                
                this.showHCSErrMsg = true;            
            } 
        }
        this.displaySearch = true;
    }

    getAccountHcsRecords() {
        var searchData = this.template.querySelector(".hcsSearchData").value;
        if (searchData != null && searchData.length > 0) {
            return getAccountRecordForSearch({ inputValue : searchData, participantType : 'Healthcare', programType : 'MDP' })
                .then((accRecord) => {
                    return accRecord;
                })
                .catch((error) => {
                    console.log('Error is', error);
                });
        }
        else {
            return null;
        }
    }

    getPickListValues(){
        getPickListValues()
                .then((pickListVal) => {
                    var stateOptionList = pickListVal.US_WSREMS__State__c;

                    for (var i in stateOptionList) {
                        if(stateOptionList[i] != 'AA' && stateOptionList[i] != 'AE' && stateOptionList[i] != 'AP'){
                            const option = {
                                label: i,
                                value: stateOptionList[i]
                            };
                            this.stateOptions = [...this.stateOptions, option];
                            this.stateOptions.sort();
                        }
                    }
                })
                .catch((error) => {
                    console.log('Error is', error);
                });
    }

    validateInputs(event) {

        const fieldName = event.target.name;
        let fieldValue = event.target.value;     
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {

            const namePatterns = /^[A-Za-z'. -]+$/;
            const zipPattern = /^[0-9]{5}(?:-[0-9]{4})?$/;
            const npiPattern = /^[0-9]{10}$/;
            const deaPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9}$/;
            const ncpdpPattern = /^[0-9]{7}$/;

           if (fieldName === 'name' && inputField.name === fieldName) {
                
                 if(fieldValue && !fieldValue.match(namePatterns)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter a valid Name.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            } if (fieldName === 'zipCode' && inputField.name === fieldName) {
                
                 if(fieldValue && !fieldValue.match(zipPattern)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter valid Zip Code.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            } if (fieldName === 'phone' && inputField.name === fieldName && !numericPhone.match(phonePattern)) {
                
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid Phone Number.');
                inputField.reportValidity();
            } if (fieldName === 'phone' && inputField.name === fieldName && numericPhone.match(phonePattern)) {
               
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            } if (fieldName === 'npi' && inputField.name === fieldName) {
                
                 if(fieldValue && !fieldValue.match(npiPattern)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter valid NPI.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            } if (fieldName === 'dea' && inputField.name === fieldName) {
                
                 if(fieldValue && !fieldValue.match(deaPattern)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter valid DEA.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            } if (fieldName === 'hin' && inputField.name === fieldName) {
                
                 if(fieldValue && !fieldValue.match(deaPattern)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter valid HIN.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            } if (fieldName === 'ncpdp' && inputField.name === fieldName) {
                
                 if(fieldValue && !fieldValue.match(ncpdpPattern)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter valid NCPDP Value.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            } if (fieldName === 'fax' && inputField.name === fieldName ) { 

                if(fieldValue && !numericPhone.match(phonePattern)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter a valid Fax.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            }

            if(fieldName === 'fax' || fieldName === 'phone') {                
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
            }
        });
    }

    handleSearch(){
        var queryData = this.template.querySelector(".hcsSearchData");
            if (!queryData.checkValidity()) {
                queryData.reportValidity()
            } else {
                this.handleHcsAccountRecords();
            }
       
    }

    handleHcsEntry(event){
        if(event.currentTarget.checked) {
            let inputFields = this.template.querySelectorAll('input[data-cmp="hcsCheckbox"]');
            inputFields.forEach(inputField => {
                inputField.checked = false;
            });
            this.hcsAccountList.forEach(rec => {
                rec.checked = false;
            });
        }
        this.hcsEntry = event.target.checked;
    }

    handleRowSelection(event) {
        this.checkboxDisabled = true;
        this.hcsEntry = false;
        this.selectedHCS = event.target.value;
        this.hcsAccountList.forEach(rec => {
            if(rec.Id == this.selectedHCS){
                rec.checked = true;
            } else{
                rec.checked = false;
            }
        });
        this.template.querySelector('input[data-cmp="cannotFindCheck"]').checked = false;
    }

    handleSubmit(){
        var hcsObj = {};
        let isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if(this.hcsEntry){
            var hcsVal = this.template.querySelectorAll(".hcsSubmit");
            hcsVal.forEach(rec => {
                if (rec.value && rec.value.length > 0) {
                    hcsObj[rec.name] = rec.value;
                }
            });
            if(hcsObj.zipCode == undefined || hcsObj.name == undefined || hcsObj.address1 == undefined || hcsObj.city == undefined) {
                this.showToast('Error', 'Please fill the required fields', 'Error');
                this.showLoading = false;
                isInputsCorrect = false;
                this.displaySpinner = false;
                return;
            }
            if(hcsObj.npi == undefined && hcsObj.hin == undefined && hcsObj.ncpdp == undefined && hcsObj.dea ==  undefined){
                this.showToast('Error', 'Please provide at least one identifier', 'Error');
                this.showLoading = false;
                isInputsCorrect = false;
                this.displaySpinner = false;
                //return;
            }
        } else {
            if (this.selectedHCS != null) {
                hcsObj['Id'] = this.selectedHCS;
            } else {
                isInputsCorrect = false;
            }
        }
        let inputRecords = {
            'recordDetails': JSON.stringify(hcsObj),
            'programName': 'XiaFlex',
            'Id': hcsObj.Id != null ? hcsObj.Id : null,
            'programType': 'MDP'
        };

        console.log('input->', inputRecords);

        if (isInputsCorrect) {

            this.displaySpinner = true;
            insertHCPSubmit({ 'inputRecords': inputRecords, 'userId': this.userId, 'hcsEntry': this.hcsEntry}).then((result) => {
                if(result != null){
                if (result == 'Success') {
                    this.displaySpinner = false;
                    window.location.href = 'hcp-managehcs';
                } else if (result == 'dupFound') {
                    this.displaySpinner = false;
                        this.showToast('Error', 'An affiliation already exists with selected participant', 'Error');
}
                }
            }).catch(error => {
                this.displaySpinner = false;
            });
            // window.location.href = 'hcp-managehcs';
        }
        
    }

    updateHCSRecords(event){
        var visibileAcc=[...event.detail.records];
        this.visibileAccounts = visibileAcc;
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

    handleCancel(){
        let location = window.location.href;
        location = location.substring(0, location.indexOf('s/'))+'s/hcp-managehcs';
        window.open(location,'_self'); 
    }

    formatPhoneNumber(phoneNumber) {
        const regex = /^(\d{3})(\d{3})(\d{4})$/;
        const parts = phoneNumber.match(regex);
        if (parts) {
            return `(${parts[1]}) ${parts[2]}-${parts[3]}`;
        }
        return phoneNumber;
    }
    handleSort(event){
        this.visibileAccounts = [...this.visibileAccounts].sort((a, b) => {
            const NameA = a.Name.toLowerCase();
            const NameB = b.Name.toLowerCase();
            return NameA.localeCompare(NameB);
        });
    }
}