import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import xiaflex_IconSortAcc from "@salesforce/resourceUrl/xiaflex_IconSortAcc";
import getPickListValues from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getPicklistFieldValues';
import getAccountRecordForSearch from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getAccountRecordForSearch';
import getHCPRecordForSearch from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getHCPRecordForSearch';
import insertHcsEnrollment from '@salesforce/apex/xiaflex_ManagePharmacies.insertHcsEnrollment';
import getARrecord from '@salesforce/apex/xiaflex_ManagePharmacies.getARrecord';
import { NavigationMixin } from 'lightning/navigation';


export default class Xiaflex_AR_pharmHCSEnrollmentForm extends NavigationMixin(LightningElement) {

    displayOthers = false;
    hcsSearch = false;
    hcsEntry = false;
    isAffiliatedDisabled = true;
    anotherHcpEntry = false;
    hcpSearch = false;
    displaySpinner = false;
    checkboxDisabled = false;
    hcsAccountList;
    signatureData = '';
    //disableContinueFields = false;
    @track arRecord ={};
    @track stateOptions = [];
    @track visibileAccounts = [];
    @track tabsetArr = new Array();
    showModal = false;
    iconSortAcc = xiaflex_IconSortAcc;
    showHCSErrMsg = false;

    get contactOptions(){
        return [
            {label: 'Email', value: 'Email'},
            {label: 'Fax', value: 'Fax'},
        ];
    }

    get roleOptions() {
        return [
            { label: 'Office Staff', value: 'Office Staff' },
            { label: 'Clinician/Healthcare Provider', value: 'Clinician/ Healthcare Provider' },
            { label: 'Office Administration', value: 'Office Admin' },
            { label: 'Other (Specify)', value: 'Other' },
        ];
    }
    get salOption() {
        return [
            { label: 'Dr', value: 'Dr' },
            { label: 'Mr', value: 'Mr' },
            { label: 'Ms', value: 'Ms' },
        ];
    }

    get hcsType() {
        return [
            { label: 'Independent Practice', value: 'Independent Practice' },
            { label: 'Group Practice', value: 'Group Practice' },
            { label: 'Institution Central Purchasing (owned or under control of hospital system)', value: 'Institution Central Purchasing (owned or under control of hospital system)' },
            { label: 'Institution Direct Purchasing (owned or under control of hospital system)', value: 'Institution Direct Purchasing (owned or under control of hospital system)' },
            { label: 'Pharmacy', value: 'Pharmacy' },
        ];
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        var objToAdd = ({
            id: 0,
            index: 0,
            table: [],
            visibileAccounts: [],
            selectedObj: {},
            hcpRec: {},
            hcpSearch: false,
            hcpEntry: false,
            checkboxDisabled: false,
            selectedHCP : null
        });
        this.tabsetArr.push(objToAdd);
        this.getArRecord();
        this.getPickListValues();
    }

    getArRecord(){
        this.displaySpinner = true;
        getARrecord({userId: Id, programName: 'Xiaflex'})
        .then(result => {
                    if (result != null && result != undefined) {
                        this.arRecord.Id = result.Id;
                        this.arRecord.firstName = result.FirstName,
                        this.arRecord.middleName = result.MiddleName,
                        this.arRecord.lastName = result.LastName,
                        this.arRecord.suffix = result.US_WSREMS__Legal_Guardian_Name__c ,
                        this.arRecord.email = result.PersonEmail,
                        this.arRecord.phone = result.Phone != null && result.Phone != '' ? this.formatPhoneNumber(result.Phone) : '';
                        this.arRecord.fax = result.Fax != null && result.Fax != '' ? this.formatPhoneNumber(result.Fax) : '';
                        this.arRecord.preferredContactMethod = result.US_WSREMS__Preferred_Contact_Method__c;
                        this.arRecord.role = result.US_WSREMS__Role__c;
                        this.arRecord.other = result.US_WSREMS__Other__c;
                        this.arRecord.salutation = result.Salutation;
                        if(this.arRecord.role == 'Other' && this.arRecord.other != null){
                            this.displayOthers = true;
                        }
                        
                    }
                    this.displaySpinner = false;
                })
                .catch(error => {
                    this.displaySpinner = false;
                    console.log('Error ::', error)
                })
                
    }

    getPickListValues(){
        this.displaySpinner = true;
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
                    this.displaySpinner = false;
                })
                .catch((error) => {
                    this.displaySpinner = false;
                    console.log('Error ::', error);
                });
    }

    async handleHcsAccountRecords(){
        this.visibileAccounts = [];
        this.hcsSearch = false;
        this.showHCSErrMsg = false;
        let accRecords = await this.getAccountHcsRecords('Healthcare', null);
        if (accRecords != null) {
            this.hcsAccountList = accRecords.map((acc, index) => ({
                Id: acc.Id,
                Name: acc.Name,
                Address: acc.US_WSREMS__Address_Line_1__c != undefined ? acc.US_WSREMS__Address_Line_1__c : null,
                City: acc.US_WSREMS__City__c != undefined ? acc.US_WSREMS__City__c : null,
                State: acc.US_WSREMS__State__c != undefined ? acc.US_WSREMS__State__c : null,
                ZIPCode: acc.US_WSREMS__Zip__c != undefined ? acc.US_WSREMS__Zip__c : null,
                Phone: acc.Phone != undefined ? acc.Phone : null,
                EnrollmentID: acc.US_WSREMS__REMS_ID__c,
                remsStatusPending: acc.US_WSREMS__Status__c != 'Certified' ? acc.US_WSREMS__Status__c : null,
                remsStatusCertified: acc.US_WSREMS__Status__c == 'Certified' ? acc.US_WSREMS__Status__c : null,
                remsstatus : acc.US_WSREMS__Status__c,
                checked : false
            }));
            this.hcsSearch = true;
            if(this.hcsAccountList.length == 0) {
                this.showHCSErrMsg = true;
                this.selectedHCPRec = null;
                this.hcsRecord = {};           
                this.checkboxDisabled = false;
            }
        }
        this.hcsSearch = true;
    }

    async handleHcpAccountRecords(currentIndex){
        this.tabsetArr[currentIndex].table = [];
        this.tabsetArr[currentIndex].visibileAccounts = [];
        this.tabsetArr[currentIndex].hcpSearch = false;
        this.tabsetArr[currentIndex].showHCPErrMsg = false;
        let accRecords = await this.getAccountHcsRecords('Prescriber', currentIndex);
        if (accRecords != null) {
            var hcpAccount = accRecords.map((acc, index) => ({ 
                Id: acc.US_WSREMS__Prescriber__c,
                FirstName: acc.US_WSREMS__Prescriber__r.FirstName,
                LastName: acc.US_WSREMS__Prescriber__r.LastName,
                NPI: acc.US_WSREMS__Prescriber__r.US_WSREMS__National_Provider_Identifier__c != undefined ? acc.US_WSREMS__Prescriber__r.US_WSREMS__National_Provider_Identifier__c : null,
                Address: acc.US_WSREMS__Health_Care_Setting__c != undefined ? (acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c != undefined ? acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c : null) : null,
                City: acc.US_WSREMS__Health_Care_Setting__c != undefined ? (acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c != undefined ? acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c : null) : null,
                State: acc.US_WSREMS__Health_Care_Setting__c != undefined ? (acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c != undefined ? acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c : null) : null,
                ZIPCode: acc.US_WSREMS__Health_Care_Setting__c != undefined ? (acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c != undefined ? acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c : null) : null,
                Phone: acc.US_WSREMS__Prescriber__r.Phone != undefined ? acc.US_WSREMS__Prescriber__r.Phone : null,
                EnrollmentID: acc.US_WSREMS__Prescriber__r.US_WSREMS__REMS_ID__c,
                remsStatusPending: acc.US_WSREMS__Prescriber__r.US_WSREMS__Status__c != 'Certified' ? acc.US_WSREMS__Prescriber__r.US_WSREMS__Status__c : null,
                remsStatusCertified: acc.US_WSREMS__Prescriber__r.US_WSREMS__Status__c == 'Certified' ? acc.US_WSREMS__Prescriber__r.US_WSREMS__Status__c : null,
                status : acc.US_WSREMS__Prescriber__r.US_WSREMS__Status__c,
                showHCSErrMsg : false,
                checked : false
            }));
            this.tabsetArr[currentIndex].hcpSearch = true;
            this.tabsetArr[currentIndex].table = hcpAccount;
            if(hcpAccount.length == 0) {
                this.tabsetArr[currentIndex].showHCPErrMsg = true;
                this.tabsetArr[currentIndex].selectedHCP = null;
                this.tabsetArr[currentIndex].selectedObj = {};
                this.tabsetArr[currentIndex].checkboxDisabled = false;
            }
        }
    }

    getAccountHcsRecords(participant, currentIndex) {
        var inputValue = '';
        if(participant == 'Healthcare'){
            var queryData = this.template.querySelector(".hcsSearchData");
            inputValue = queryData.value;
        } else if(participant == 'Prescriber'){
            var queryData = this.template.querySelectorAll(".hcpSearchData");
            queryData.forEach((currentItem, index) => {
                if(index == currentIndex){
                    if (!currentItem.checkValidity()) {
                        currentItem.reportValidity();
                    }else{
                        inputValue = currentItem.value;
                    }
                }
            });
        }
        
        if (inputValue != null && inputValue.length > 0) {
            if(participant == 'Prescriber'){
                return getHCPRecordForSearch({ inputValue :  inputValue, programType : 'REMS' })
                .then((accRecord) => {
                    return accRecord;
                })
                .catch((error) => {
                    console.log('Error is', error);
                });
            }else{
                return getAccountRecordForSearch({ inputValue :  inputValue, participantType : participant, programType : 'REMS' })
                .then((accRecord) => {
                    return accRecord;
                })
                .catch((error) => {
                    console.log('Error is', error);
                });
            }
            
        }
        else {
            return null;
        }
    }

    handleChange(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value;
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        this.validateInputs(event);
        if(fieldName == 'role'){
            if(fieldValue == 'Other'){
                this.displayOthers = true;
            } else{
                this.displayOthers = false;
            }
        }
        if (fieldName === 'fax' || fieldName === 'phone') {
            fieldValue = this.formatPhoneNumber(numericPhone);
            this.arRecord[fieldName] = fieldValue;
        } else {
            this.arRecord[fieldName] = fieldValue;
        }
    }

    handleSearch(event) {
        if (event.target.name == 'hcsSearchButton') {
            var queryData = this.template.querySelector(".hcsSearchData");
            if(queryData.value == '' || queryData.value == undefined || queryData.value == null) {
                this.selectedHCPRec = null;
            }
            if (!queryData.checkValidity()) {
                queryData.reportValidity()
            } else {
                this.handleHcsAccountRecords();
            }
        }
              

        else if (event.target.name == 'hcpSearchButton') {
                this.handleHcpAccountRecords(event.currentTarget.dataset.index);
        }
    }

    validateInputs(event) {

        const fieldName = event.target.name;
        let fieldValue = event.target.value;        
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {

            const phonePattern = /^(\s*\d\s*){10}$/;
            const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const namePatterns = /^[A-Za-z'. -]+$/;
            const faxPatterns = /^(\s*\d\s*){10}$/;
            const zipPattern = /^[0-9]{5}(?:-[0-9]{4})?$/;
            const npiPattern = /^[0-9]{10}$/;
            const deaPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9}$/;
            const ncpdpPattern = /^[0-9]{7}$/;

            if (fieldName === 'email' && inputField.name === fieldName && !fieldValue.match(emailPattern)) {
               
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid email address.');
                inputField.reportValidity();
            } if (fieldName === 'email' && inputField.name === fieldName && fieldValue.match(emailPattern)) {
               
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            } if (fieldName === 'phone' && inputField.name === fieldName && !numericPhone.match(phonePattern)) {
                
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid Phone Number.');
                inputField.reportValidity();
            } if (fieldName === 'phone' && inputField.name === fieldName && numericPhone.match(phonePattern)) {
               
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            } if (fieldName === 'lastName' && inputField.name === fieldName && !fieldValue.match(namePatterns)) {
                
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid Name.');
                inputField.reportValidity();
            } if (fieldName === 'lastName' && inputField.name === fieldName && fieldValue.match(namePatterns)) {
                
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            } if (fieldName === 'firstName' && inputField.name === fieldName && !fieldValue.match(namePatterns)) {
                
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid Name.');
                inputField.reportValidity();
            } if (fieldName === 'firstName' && inputField.name === fieldName && fieldValue.match(namePatterns)) {
                
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }if (fieldName === 'zipCode' && inputField.name === fieldName) {
                
                 if(fieldValue && !fieldValue.match(zipPattern)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter valid Zip Code.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
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
            } if ((fieldName === 'dea') && inputField.name === fieldName) {
                
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
            } if (fieldName === 'middleName' && inputField.name === fieldName ) {

                if(fieldValue && !fieldValue.match(namePatterns)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter a valid Name.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
          } if (fieldName === 'fax' && inputField.name === fieldName ) { 

                if(fieldValue && !numericPhone.match(faxPatterns)) {
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

    handleAddRecords(){
        if(this.tabsetArr.length < 10){
            var objToAdd = ({
                id: this.tabsetArr.length,
                index: this.tabsetArr.length,
                table: [],
                hcpRec: {},
                hcpSearch: false,
                hcpEntry: false,
                checkboxDisabled: false,
                showHCSErrMsg : false,
                selectedHCP : null
            });
            this.tabsetArr.push(objToAdd);
        } else{
            this.showToast('Error', 'You can add only 10 prescribers on Pharmacy', 'error');
        }
        this.isAffiliatedDisabled  = true;
    }

    handleEntryOption(event) {
        if (event.target.name == 'hcsEntryOption') {
            this.hcsEntry = event.target.checked;
            if(event.currentTarget.checked) {
                this.selectedHCPRec = null;
                this.visibileAccounts = this.uncheckRadiobutton(this.visibileAccounts, this.selectedHCProwvaluetrue);
            }
        }
        else if (event.target.name == 'hcpEntryOption'){
            var currentIndex = event.currentTarget.dataset.index;
            this.tabsetArr[currentIndex].hcpEntry = event.target.checked;
            this.tabsetArr[currentIndex].selectedObj = {};
            this.tabsetArr[currentIndex].visibileAccounts = this.uncheckRadiobutton(this.tabsetArr[currentIndex].visibileAccounts, '');
        }
    }

    handleRowSelection(event) {
        if(event.target.name == 'selectedHCPRow'){
            var currentIndex = event.currentTarget.dataset.index;
            var objSelected = {};
            objSelected['Id'] = event.currentTarget.dataset.recId;
            this.tabsetArr[currentIndex].checkboxDisabled = true;
            this.tabsetArr[currentIndex].selectedObj = objSelected;
            this.tabsetArr[currentIndex].hcpEntry = false;
            this.tabsetArr[currentIndex].selectedHCP = event.currentTarget.dataset.recId;
            this.tabsetArr[currentIndex].visibileAccounts = this.uncheckRadiobutton(this.tabsetArr[currentIndex].visibileAccounts,event.currentTarget.dataset.recId );
            if(this.tabsetArr.length < 10){
                this.isAffiliatedDisabled = false;
            }
            else {
                this.isAffiliatedDisabled = true;
            }
            this.showHCPNewForm = false;
        }
        if(event.target.name == 'selectedHCSRow'){
            var selectedRecId = event.currentTarget.dataset.recId;
            this.selectedHCPRec  = event.currentTarget.dataset.recId;
            this.checkboxDisabled = true;
            this.hcsEntry = false;
            if(this.template.querySelector('input[data-cmp="cannotFindHCSCheck"]')) {
                this.template.querySelector('input[data-cmp="cannotFindHCSCheck"]').checked = false;
            }
            this.showHCSNewForm = false;
            this.visibileAccounts.forEach(rec => {
                if(rec.Id === selectedRecId){
                    if(rec.remsstatus == 'Pending' || rec.remsstatus == 'Cancelled') {
                        this.showToast('Error', 'The enrollment for the selected Healthcare Setting cannot be submitted at this time. Please contact Xiaflex REMS Program at 1-877-313-1235 for assistance.', 'Error');
                        event.target.checked = false;
                        rec.checked = false;
                    } else {
                        this.hcsRecord.Id = selectedRecId;
                        this.hcsRecord.hcsStatus = rec.remsstatus;
                        rec.checked = true;
                    }
                } else{
                    rec.checked = false;
                }
            });
            
        }
    }

    handleHCPRec(event){
        this.validateInputs(event);
        var currentIndex = event.currentTarget.dataset.index;
        var isValid = true;
        this.tabsetArr[currentIndex].hcpRec[event.target.name] = event.target.value;
        var data2 = this.template.querySelectorAll('lightning-input[data-my-id="' + currentIndex + '"]');
        data2.forEach(rec => {
            if (!rec.checkValidity()) {
                isValid = false;
            }
        });
        if(isValid){
            if(this.tabsetArr.length < 10){
                this.isAffiliatedDisabled = false;
            }
            else {
                this.isAffiliatedDisabled = true;
            }
        }
        
    }

    handelAnotherButton(){
        this.anotherHcpEntry = true;
    }

    handleSignatureCompleted(event) {
        this.signatureData = event.detail.signdata;
    }

    handleClear(){
        this.template.querySelector('c-tryvio-sign-pad').handleClear();
    }

    handleSubmit() {
        this.template.querySelector('c-tryvio-sign-pad').handleSaveSignature();
        var hcsObj = {};
        var hcpRecs = [];
        let isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        var hcsSearch = this.template.querySelector(".hcsSearchData");
        if (!hcsSearch.checkValidity()) {
            hcsSearch.reportValidity();
            isInputsCorrect = false;
        }
        var hcpSearch = this.template.querySelectorAll(".hcpSearchData");
        hcpSearch.forEach(hcp => {
            if (!hcp.checkValidity()) {
                hcp.reportValidity();
                isInputsCorrect = false;
            }
        });

        if (this.hcsEntry) {
            var hcsVal = this.template.querySelectorAll(".hcsSubmit");
            hcsVal.forEach(rec => {
                if (rec.value && rec.value.length > 0) {
                    hcsObj[rec.name] = rec.value;
                }
            });

            if(hcsObj.npi == null  &&  hcsObj.hin == null && hcsObj.dea == null && hcsObj.ncpdp == null ) {
                this.showToast('Error', 'Please provide at least one identifier', 'Error');
                this.showLoading = false;
                isInputsCorrect = false;
                return;
            }
            if(hcsObj.state == 'None'){
                this.showToast('Error!','Please select state value', 'error');
                isInputsCorrect = false;
                return;
            }
        } else {
            if (this.selectedHCPRec != null && this.selectedHCPRec.length > 0) {
                hcsObj['Id'] = this.selectedHCPRec;
            } else {
                isInputsCorrect = false;
            }
        }
        for (var i in this.tabsetArr) {
            if (this.tabsetArr[i].hcpEntry) {
                var hcpObj = JSON.stringify(this.tabsetArr[i].hcpRec);
                hcpRecs.push(hcpObj);
            } else {
                if(this.tabsetArr[i].selectedObj != null && this.tabsetArr[i].selectedObj != undefined){
                    var hcpObj = JSON.stringify(this.tabsetArr[i].selectedObj);
                     if(this.tabsetArr[i].selectedObj.Id != null){
                        hcpRecs.push((hcpObj));
                    } else{
                        this.showToast('Error', 'Please select the Healthcare Provider', 'Error');
                        this.showLoading = false;
                        return;
                    }
                }
            }
        }

        if(this.signatureData == null){
            this.showToast('Error', 'Please Sign to continue', 'Error');
            this.showLoading = false;
            return;
        }
        if (isInputsCorrect) {    
            let inputRecords = {
                'arRecord': JSON.stringify(this.arRecord),
                'hcsRecord': JSON.stringify(hcsObj),
                'programName': 'Xiaflex',
                'programType': 'REMS',
                'signatureData': this.signatureData
            };
            this.displaySpinner = true;

            insertHcsEnrollment({'inputRecords': inputRecords, 'hcpRecord': JSON.stringify(hcpRecs)}).then((result) => {
                if(result == 'dupFound'){
                    this.showToast('Error', 'Pharmacy/Healthcare Setting Account already exist', 'error');
                    this.displaySpinner = false;
                } else if(result == 'Success'){
                    window.location.href = 'manage-hcs';
                    this.displaySpinner = false;
                }
            }).catch(error => {
                this.showToast('Error', JSON.stringify(error.body.message), 'error');
                this.displaySpinner = false;
            });
        } else{ 
            this.showToast('Error!','Please fill the Required Fields', 'error');
        }

    }

    sortHCSAccountRecords(event){
        this.visibileAccounts = [...this.visibileAccounts].sort((a, b) => {
            const lastNameA = a.Name.toLowerCase();
            const lastNameB = b.Name.toLowerCase();
            return lastNameA.localeCompare(lastNameB);
        });
    }

    sortHCPAccountRecords(event){
            var currentIndex = event.currentTarget.dataset.index;
            var visibleRecords = this.tabsetArr[currentIndex].visibileAccounts;
            this.tabsetArr[currentIndex].visibileAccounts = [...visibleRecords].sort((a, b) => {
            const lastNameA = a.LastName.toLowerCase();
            const lastNameB = b.LastName.toLowerCase();
            return lastNameA.localeCompare(lastNameB);
        });
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

    formatPhoneNumber(phoneNumber) {
        const regex = /^(\d{3})(\d{3})(\d{4})$/;
        const parts = phoneNumber.match(regex);
        if (parts) {
            return `(${parts[1]}) ${parts[2]}-${parts[3]}`;
        }
        return phoneNumber;
    }

    updateHCSRecords(event){
        var visibileAcc=[...event.detail.records];
        this.visibileAccounts =  this.uncheckRadiobutton(visibileAcc, this.selectedHCPRec);
    }

    updateRecords(event){
        var currentIndex = event.currentTarget.dataset.index;
        var visibileAcc=[...event.detail.records];
        this.tabsetArr[currentIndex].visibileAccounts = this.uncheckRadiobutton(visibileAcc, this.tabsetArr[currentIndex].selectedObj.Id);
    }

    handleCancel() {
        this.showModal = true;
        // Logic to handle cancel action
    }
    handleCancelModal(event){
        if(event.target.name == 'cancel'){
            this.showModal = false;
        }
        else{
            console.log('else name');
        
            event.preventDefault();
            event.stopPropagation();
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes:{
                    name: 'manageHCS__c'
                },
            });
        }
    }

    uncheckRadiobutton(records, selectedValue) {
        var finalRecords = JSON.parse(JSON.stringify(records));
        for(var i =0;i<finalRecords.length;i++) {
            if(selectedValue && selectedValue == finalRecords[i].Id) {
                finalRecords[i].checked = true;
            } else {
                finalRecords[i].checked = false;
            }
        }
        return finalRecords;
    }
}