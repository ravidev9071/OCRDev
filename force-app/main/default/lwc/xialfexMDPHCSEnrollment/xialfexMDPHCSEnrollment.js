import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountRecordForSearch from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getAccountRecordForSearch';
import getHCPRecordForSearch from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getHCPRecordForSearch';
import getPickListValues from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getPicklistFieldValues';
import insertHcsEnrollment from '@salesforce/apex/xiaflex_ManagePharmacies.insertHcsEnrollment';
import customHomeStyles from '@salesforce/resourceUrl/xiaflexMDP_customcss';
import xiaflex_IconSortAcc from "@salesforce/resourceUrl/xiaflex_IconSortAcc";
import getExistingAccountRecord from '@salesforce/apex/xiaflex_ManagePharmacies.getExistingARAccount';
import { NavigationMixin } from 'lightning/navigation';

export default class XialfexMDPHCSEnrollment extends NavigationMixin(LightningElement) {
    @track hcsAccountList;
    @track displaySection = false;
    @track anotherHcpEntry = false;
    @track displayOthers = false;
    @track hcsSearch = false;
    @track hcsEntry = false;
    @track hcpSearch = false;
    @track hcpEntry = false;
    @track isAffiliatedDisabled = true;
    @track checkboxDisabled = false;
    @track anotherButton = false;
    @track disableContinueFields = false;
    @track visibileAccounts = [];
    @track stateOptions = [];
    @track tabsetArr = new Array();
    selectedHCPRec = '';
    @track arRecord ={};
    signatureData = '';
    displaySpinner = false;
    faxEnable = false;
    showHCSNewForm = false;
    showHCPNewForm = false;
    selectedrowvaluetrue;
    selectedHCProwvaluetrue;
    hcsRecord = {};
    hcpRecordList = [];
    authRepRecord = {};
    existingAuthRepRecord = {};
    showModal = false;
    iconSortAcc = xiaflex_IconSortAcc;
    commUserId;
    Enrollvalue = 'NEW Enrollment';
    showHCSErrMsg = false;

    get phoneoptions(){
        return [
            {label: 'Main', value: 'Main'},
            {label: 'Direct', value: 'Direct'},
            {label: 'Mobile', value: 'Mobile'}
        ]; 
    }
    get contactOptions(){
        return [
            {label: 'Email', value: 'Email'},
            {label: 'Fax', value: 'Fax'},
        ];
    }
    get salutationoptions() {
        return [
            { label: 'Dr', value: 'Dr' },
            { label: 'Mr', value: 'Mr' },
            { label: 'Ms', value: 'Ms' },
            { label: 'Mrs', value: 'Mrs' }
        ];
    }
    get Enrollmentoptions(){
        return [
            { label: 'NEW Enrollment', value: 'NEW Enrollment' },
            { label: ' Enrollment Update', value: ' Enrollment Update' }
        ];
    }
    
    handleSignatureCompleted(event) {
        this.signatureData = event.detail.signdata;
    }
    handleClear(){
        this.template.querySelector('c-tryvio-sign-pad').handleClear();
    }
    get roleOptions() {
        return [
            { label: 'Office Staff', value: 'Office Staff' },
            { label: 'Clinician/Healthcare Provider', value: 'Clinician/ Healthcare Provider' },
            { label: 'Office Administration', value: 'Office Admin' },
            { label: 'Other (specify)', value: 'Other' },
        ];
    }

    get hcsType() {
        return [
            { label: 'Independent Practice', value: 'Independent Practice' },
            { label: 'Group Practice', value: 'Group Practice' },
            { label: 'Institution Central Purchasing (owned or under control of hospital system)', value: 'Institution Central Purchasing (owned or under control of hospital system)' },
            { label: 'Institution Direct Purchasing (owned or under control of hospital system)', value: 'Institution Direct Purchasing (owned or under control of hospital system)' },
            { label: 'Pharmacy  (XIAFLEX is not available for distribution by retail pharmacies. Retail pharmacies should not enroll.)', value: 'Pharmacy' },
        ];
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.getPickListValues();
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
    }

    getPickListValues() {
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

    async handleContinue(event) {
        let validateRequiredFields = this.validateRequiredFields_Continue(event, true, false);
        if(validateRequiredFields) {
            let validateInputs = this.validateInputs(event, true, false);
            console.log('validateInputs:::', validateInputs);
            if(validateInputs) {
                if(this.authRepRecord.email != this.authRepRecord.confirmemail) {
                    this.showToast('Error!', 'Please enter the same email address', 'error');
                    return;
                }
                const EXISTING_ACCOUNT = await getExistingAccountRecord({
                                                    programType: 'MDP',
                                                    programName: 'XIAFLEX',
                                                    firstName: this.authRepRecord.firstName,
                                                    lastName: this.authRepRecord.lastName,
                                                    email: this.authRepRecord.email
                                                });
                this.existingAuthRepRecord = EXISTING_ACCOUNT;
                if(EXISTING_ACCOUNT && EXISTING_ACCOUNT.Users && EXISTING_ACCOUNT.Users.length > 0
                    ){
                    this.showToast('Error!', 'Account already exists. Please log in using the `Login` button or `Forgot Password?` to proceed with accessing your account or contact Xiaflex REMS Program at 1-877-313-1235 for assistance.', 'error');
                    return;
                } 
                this.arRecord.phone = null;
                this.arRecord.fax = null;
                this.arRecord.preferredContactMethod = null;
                this.arRecord.role = null;
                this.arRecord.other = null;
                this.disableContinueFields = false;
                this.displaySection = true;
            }
        }
    }

    async handleHcsAccountRecords(){
        this.visibileAccounts = [];
        this.hcsSearch = false;
        this.showHCSErrMsg = false;
        this.checkboxDisabled = false;
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
                this.selectedrowvaluetrue = null;
                this.hcsRecord = {};           
                this.checkboxDisabled = false;
            } 
        } else {
            this.showHCSErrMsg = true;
        }
        
    }

    async handleHcpAccountRecords(currentIndex){
        this.showHCPNewForm = false;
        this.tabsetArr[currentIndex].table = [];
        this.tabsetArr[currentIndex].hcpEntry = false;
        this.tabsetArr[currentIndex].visibileAccounts = [];
        this.tabsetArr[currentIndex].showHCPErrMsg = false;
        this.tabsetArr[currentIndex].hcpSearch = false;
        this.tabsetArr[currentIndex].checkboxDisabled = false;
        let accRecords = await this.getAccountHcsRecords('Prescriber', currentIndex);
        if (accRecords && accRecords.length > 0) {
            var hcpAccount = accRecords.map((acc, index) => ({ 
                Id: acc.US_WSREMS__Prescriber__c,
                FirstName: acc.US_WSREMS__Prescriber__r.FirstName,
                LastName: acc.US_WSREMS__Prescriber__r.LastName,
                NPI: acc.US_WSREMS__Prescriber__r.US_WSREMS__National_Provider_Identifier__c != undefined ? acc.US_WSREMS__Prescriber__r.US_WSREMS__National_Provider_Identifier__c : null,
                Address: acc.US_WSREMS__Health_Care_Setting__c  ? (acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c  ? acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c : null) : null,
                City: acc.US_WSREMS__Health_Care_Setting__c  ? (acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c  ? acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c : null) : null,
                State: acc.US_WSREMS__Health_Care_Setting__c  ? (acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c  ? acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c : null) : null,
                ZIPCode: acc.US_WSREMS__Health_Care_Setting__c  ? (acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c  ? acc.US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c : null) : null,
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
            this.hcpSearch = true;
        } else {
            this.tabsetArr[currentIndex].showHCPErrMsg = true;
            this.tabsetArr[currentIndex].hcpSearch = true;
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
                return getHCPRecordForSearch({ inputValue :  inputValue, programType : 'MDP' })
                .then((accRecord) => {
                    return accRecord;
                })
                .catch((error) => {
                    console.log('Error is', error);
                });
            }else{
                return getAccountRecordForSearch({ inputValue :  inputValue, participantType : participant, programType : 'MDP' })
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

    handleSearch(event) {
        if (event.target.name == 'hcsSearchButton') {
            var queryData = this.template.querySelector(".hcsSearchData");
            if(queryData.value == '' || queryData.value == undefined || queryData.value == null) {
                this.selectedrowvaluetrue = null;
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

    handleAddRecords(event){
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
            this.showHCSNewForm = event.target.checked;
            if(event.currentTarget.checked) {
                this.selectedrowvaluetrue = null;
                this.hcsRecord = {};
                this.visibileAccounts = this.uncheckRadiobutton(this.visibileAccounts, this.selectedHCProwvaluetrue);
            }
        }
        else if (event.target.name == 'hcpEntryOption'){
            this.showHCPNewForm = event.target.checked;
            var currentIndex = event.currentTarget.dataset.index;
            this.tabsetArr[currentIndex].hcpEntry = event.target.checked;
            this.tabsetArr[currentIndex].selectedObj = {};
            this.tabsetArr[currentIndex].visibileAccounts = this.uncheckRadiobutton(this.tabsetArr[currentIndex].visibileAccounts, '');
        }
    }

    handleRowSelection(event) {
        if(event.target.name == 'selectedHCPRow'){
            console.log('inside hcp');
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
            console.log('inside hcs');
            var selectedRecId = event.currentTarget.dataset.recId;
            this.selectedrowvaluetrue  = event.currentTarget.dataset.recId;
            this.checkboxDisabled = true;
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

    handelAnotherButton(){
        this.anotherHcpEntry = true;
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

    handelAnotherHCPSearch(event){
        if(event.target.name == 'Search'){
            this.isAffiliatedDisabled = true;
            this.template.querySelector('.searchButton').classList.add('slds-hide');
            this.template.querySelector('.removeButton').classList.remove('slds-hide');
        } else if(event.target.name == 'Remove'){
            this.isAffiliatedDisabled = false;
            this.template.querySelector('.removeButton').classList.add('slds-hide');
            this.template.querySelector('.searchButton').classList.remove('slds-hide');
        }
    }

    handleSubmit(event) {
        this.template.querySelector('c-tryvio-sign-pad').handleSaveSignature();
        var hcpRecs = [];
        let isValid  = true;
        let validateRequiredFields = this.validateRequiredFields(event, true, false);
        if(validateRequiredFields) {
            let validateInputs = this.validateInputs(event, true, false);
            console.log('validateInputs:::', validateInputs);
            if(validateInputs) {
                let validateHCS = this.validateHCSData(event);
                console.log('validateHCS:::', validateHCS);
                if(validateHCS) {
                    let validateHCP = this.validateHCPData(event);
                    console.log('validateHCP:::', validateHCP);
                    if(validateHCP) {
                        let validateSignature = this.validateSignature(event);
                        console.log('validateSignature:::', validateSignature);
                        if(validateSignature) {
                            if(this.showHCSNewForm && this.hcsRecord.npi == null  &&  this.hcsRecord.hin == null && this.hcsRecord.dea == null && this.hcsRecord.ncpdp == null ) {
                                this.showToast('Error', 'Please provide at least one identifier', 'Error');
                                this.showLoading = false;
                                isInputsCorrect = false;
                                return;
                            }
                            if (this.arRecord.Id != null && this.arRecord.Id != undefined) {
                                this.authRepRecord['Id'] = this.arRecord.Id ;
                            }
                            if(!this.showHCSNewForm && this.selectedrowvaluetrue) {
                                this.hcsRecord.Id = this.selectedrowvaluetrue;
                            }
                            var existingARRecord = this.existingAuthRepRecord && this.existingAuthRepRecord.Id ? this.existingAuthRepRecord.Id : '';
                            console.log('hcpRecordList::', JSON.stringify(this.hcpRecordList));
                            let inputRecords = {
                                'arRecord': JSON.stringify(this.authRepRecord),
                                'hcsRecord': JSON.stringify(this.hcsRecord),
                                'existingARRecordId' : existingARRecord,
                                'programName': 'Xiaflex',
                                'programType': 'MDP',
                                'signatureData': this.signatureData
                            };
                            this.displaySpinner = true;
                            insertHcsEnrollment({'inputRecords': inputRecords, 'hcpRecord': JSON.stringify(this.hcpRecordList)}).then((result) => {
                                console.log('result:::',result);
                                if(result == 'dupFound'){
                                    this.showToast('Error', 'Pharmacy/Healthcare Setting Account already exist', 'error');
                                    this.displaySpinner = false;
                                } else if(result == 'Success'){
                                    this[NavigationMixin.Navigate]({
                                        type: 'comm__namedPage',
                                        attributes: {
                                        name: 'pharmHCSEnrollmentForm_success__c'
                                    }
                                    });
                
                                    this.displaySpinner = false;
                                }
                            }).catch(error => {
                                console.log('error:::',error);
                                this.showToast('Error', JSON.stringify(error.body.message), 'error');
                                this.displaySpinner = false;
                            });
                        }
                    }
                }
            }
        } 
        
    }

    sortHCSAccountRecords(event){
        this.visibileAccounts = [...this.visibileAccounts].sort((a, b) => {
            const lastNameA = a.Name.toLowerCase();
            const lastNameB = b.Name.toLowerCase();
            return lastNameA.localeCompare(lastNameB);
        });
    }

    sortHCSRecords(recordList){
        let recordSortedList = [...recordList].sort((a, b) => {
            const lastNameA = a.Name.toLowerCase();
            const lastNameB = b.Name.toLowerCase();
            return lastNameA.localeCompare(lastNameB);
        });
        return recordSortedList;
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
    sortHCPRecords(recordList){
        let recordSortedList = [...recordList].sort((a, b) => {
            const lastNameA = a.LastName.toLowerCase();
            const lastNameB = b.LastName.toLowerCase();
            return lastNameA.localeCompare(lastNameB);
        });
        return recordSortedList;
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
        location = location.substring(0, location.indexOf('s/'));
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

    updateHCSRecords(event){
        var visibileAcc=[...event.detail.records];
        this.visibileAccounts =  this.uncheckRadiobutton(visibileAcc, this.selectedrowvaluetrue);
        this.visibileAccounts = this.sortHCSRecords(this.visibileAccounts);
    }

    updateRecords(event){
        var currentIndex = event.currentTarget.dataset.index;
        var visibileAcc=[...event.detail.records];
        let selectedRecordId = this.tabsetArr[currentIndex].selectedObj ? this.tabsetArr[currentIndex].selectedObj.Id : null;
        this.tabsetArr[currentIndex].visibileAccounts = this.uncheckRadiobutton(visibileAcc, selectedRecordId);
        this.tabsetArr[currentIndex].visibileAccounts = this.sortHCPRecords(this.tabsetArr[currentIndex].visibileAccounts);
        
    }

    validateRequiredFields(event) {
        this.displaySpinner = true;
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (inputField.required == true && (!inputField.value || inputField.value == undefined || inputField.value == '' || inputField.value == null)) {
                isValid = false;
                inputField.reportValidity();
            }
        });
        if(!isValid) {
            this.showToast('Error', 'Please fill all the required fields.', 'error');
        }
        this.displaySpinner = false;
        return isValid;
    }

    validateRequiredFields_Continue(event) {
        this.displaySpinner = true;
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.arSubmit');
        inputFields.forEach(inputField => {
            if (inputField.required == true && (!inputField.value || inputField.value == undefined || inputField.value == '' || inputField.value == null)) {
                isValid = false;
                inputField.reportValidity();
            }
        });
        if(!isValid) {
            this.showToast('Error', 'Please fill all the required fields.', 'error');
        }
        this.displaySpinner = false;
        return isValid;
    }

    validateInputs(event, isValidateALL, isFieldCheck) {

        try {
            const phonePattern = /^(\s*\d\s*){10}$/;
            const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const namePatterns = /^[A-Za-z'. -]+$/;
            const faxPatterns = /^(\s*\d\s*){10}$/;
            const extPatterns = /^[0-9]{1,10}$/;
            const npiPattern = /^[0-9]{10}$/;
            const deaPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9}$/;
            const ncpdpPattern = /^[0-9]{7}$/;
            let zipPatterns = /^\d{5}$/;
            let isValid = true;

            let inputFields = this.template.querySelectorAll('.validate');
            inputFields.forEach(inputField => {

                
                const fieldName = isFieldCheck ? event.target.name : inputField.name;
                let fieldValue = isFieldCheck ? event.target.value : inputField.value;
                let numericPhone = fieldValue ? fieldValue.replace(/\D/g, '').replace('-') : fieldValue;

                if(isValidateALL || (isFieldCheck && fieldName && inputField.name === fieldName)) {

                    if (fieldName === 'npi') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(npiPattern)) {
                           inputField.classList.add('slds-has-error');
                           inputField.setCustomValidity('Please enter valid NPI.');
                           inputField.reportValidity();
                       } 
                       inputField.reportValidity();
                   } 
                   if ((fieldName === 'dea')) {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(deaPattern)) {
                           inputField.classList.add('slds-has-error');
                           inputField.setCustomValidity('Please enter valid DEA.');
                           inputField.reportValidity();
                       } 
                       inputField.reportValidity();
                   } 
                   if (fieldName === 'hin') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(deaPattern)) {
                           inputField.classList.add('slds-has-error');
                           inputField.setCustomValidity('Please enter valid HIN.');
                           inputField.reportValidity();
                       }
                       inputField.reportValidity();
                   } 
                   if (fieldName === 'ncpdp') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(ncpdpPattern)) {
                           inputField.classList.add('slds-has-error');
                           inputField.setCustomValidity('Please enter valid NCPDP Value.');
                           inputField.reportValidity();
                       }
                       inputField.reportValidity();
                   }
                    
                    if(fieldName === 'hcszipcode' &&  fieldValue  &&  fieldValue != undefined) {
                        if(fieldValue.length > 5 && !fieldValue.includes('-')) {
                            zipPatterns = /^\d{9}$/;
                        } else if(fieldValue.length > 5 && fieldValue.includes('-')) {
                            zipPatterns = /^\d{5}(-\d{4})?$/;
                        }
                    }

                    if ((fieldName === 'lastName' || fieldName === 'plastName' || fieldName === 'slastName')) {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(namePatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Last Name.');
                        }
                        inputField.reportValidity();
                    } 
                    if ((fieldName == 'firstName' || fieldName == 'pfirstName' || fieldName == 'sfirstName')) {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(namePatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid first Name.');
                        }
                        inputField.reportValidity();
                    } 
                    if (fieldName === 'mi') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if (fieldValue && !fieldValue.match(namePatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid MI.');
                        } 
                        inputField.reportValidity();
                    }                
                    
                    if (fieldName === 'hcszipcode') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(zipPatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Zip can be 5 digits or 9 digits.');
                        }
                        inputField.reportValidity();
                    }
                    
                    if(fieldName === 'ext' || fieldName === 'pext' || fieldName === 'sext') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(extPatterns)){
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Ext');
                        }
                        inputField.reportValidity();
                    }
                    
                    if ((fieldName == 'phone' || fieldName == 'hcsphone')) {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !numericPhone.match(phonePattern)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Phone Number.');
                        }
                        inputField.reportValidity();
                    } 

                    if ((fieldName === 'email' || fieldName === 'confirmemail' || fieldName === 'pemail' || fieldName === 'semail')) {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(emailPattern)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid email address.');
                        }
                        inputField.reportValidity();
                    } 
                    if ((fieldName === 'fax' || fieldName === 'hcsfax')) {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if (fieldValue && !numericPhone.match(faxPatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Fax.');
                        } 
                        inputField.reportValidity();
                    }
                }
            });
            if(!isValid) {
                if(isValidateALL) {
                    this.showToast('Error', 'Please enter valid data', 'error');
                } 
            }
            return isValid;
        }
        catch (e) {
            console.log('error ' + e.message);
        }
    }

    handleDependentFields(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value;  
        if(fieldName == 'role' ){
            if(fieldValue == 'Other'){
                this.displayOthers = true;
            }else{
                this.displayOthers = false;
                this.arRecord.other = '';
            }
        }
    }

    validateSignature(event) {
        this.isloading = true;
        let isSignatureData = true;
        if (this.signatureData == null || this.signatureData == '') {
            this.isloading = false;
            isSignatureData = false;
            this.showToast('Error', 'Please Sign to continue', 'Error');
            
        }
        this.isloading = false;
        return isSignatureData;
    }

    populateFields(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value;
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        switch (fieldName) {
            case 'firstName':
                this.authRepRecord.firstName = fieldValue;
                break;
            case 'middleName':
                this.authRepRecord.middleName = fieldValue;
                break;
            case 'lastName':
                this.authRepRecord.lastName = fieldValue;
                break;
            case 'suffix':
                this.authRepRecord.suffix = fieldValue;
                break;
            case 'email':
                this.authRepRecord.email = fieldValue;
                break;
            case 'confirmemail':
                this.authRepRecord.confirmemail = fieldValue;
                break;
            case 'salutation':
                this.authRepRecord.salutation = fieldValue;
                break;
            case 'phone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.authRepRecord.phone = fieldValue;
                break;
            case 'fax':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.authRepRecord.fax = fieldValue;
                break;
            case 'preferredContactMethod':
                this.authRepRecord.preferredContactMethod = fieldValue;
                break;
            case 'phoneType':
                this.authRepRecord.phoneType = fieldValue;
                break;
            case 'role':
                this.authRepRecord.role = fieldValue;
                break;
            case 'otherRole':
                this.authRepRecord.other = fieldValue;
                break;
            case 'npi':
                this.hcsRecord.npi = fieldValue;
                break;
            case 'hin':
                this.hcsRecord.hin = fieldValue;
                break;
            case 'dea':
                this.hcsRecord.dea = fieldValue;
                break;
            case 'ncpdp':
                this.hcsRecord.ncpdp = fieldValue;
                break;
            case 'hcsname':
                this.hcsRecord.name = fieldValue;
                break;
            case 'hcsaddress1':
                this.hcsRecord.address1 = fieldValue;
                break;
            case 'hcsaddress2':
                this.hcsRecord.address2 = fieldValue;
                break;
            case 'hcscity':
                this.hcsRecord.city = fieldValue;
                break;
            case 'hcsstate':
                this.hcsRecord.state = fieldValue;
                break;
            case 'hcszipcode':
                this.hcsRecord.zipCode = fieldValue;
                break;
            case 'hcsphone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.hcsRecord.phone = fieldValue;
                break;
            case 'hcsfax':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.hcsRecord.fax = fieldValue;
                break;
            case 'hcsType':
                this.hcsRecord.hcsType = fieldValue;
                break;            
            default:
        }    
    }

    populateHCPFields(event) {

    }

    validateHCSData(event) {
        var isValid = true;
        var hcsSearch = this.template.querySelector(".hcsSearchData");
        if (!hcsSearch.checkValidity()) {
            hcsSearch.reportValidity();
            isValid = false;
            return isValid;
        }
        if(!this.showHCSNewForm && !this.selectedrowvaluetrue) {
            this.showToast('Error', 'Please select any HCS', 'error');
            isValid = false;
            return isValid;
        }
        return isValid;
    }

    validateHCPData(event) {
        this.hcpRecordList = [];
        var isValid = true;
        var hcpSearch = this.template.querySelector(".hcpSearchData");
        if (!hcpSearch.checkValidity()) {
            hcpSearch.reportValidity();
            isValid = false;
            return isValid;
        }

        let isHCPCompleted = true;
        for (var i in this.tabsetArr) {
            if (this.tabsetArr[i].hcpEntry) {
                var hcpObj = JSON.stringify(this.tabsetArr[i].hcpRec);
                this.hcpRecordList.push(hcpObj);
            } else {
                if(this.tabsetArr[i].selectedObj && this.tabsetArr[i].selectedObj != null && this.tabsetArr[i].selectedObj != undefined){
                    var hcpObj = JSON.stringify(this.tabsetArr[i].selectedObj);
                    if(this.tabsetArr[i].selectedObj.Id != null){
                        this.hcpRecordList.push((hcpObj));
                    } else{
                        isHCPCompleted = false;
                    }
                }
            }
        }
        console.log('----> HCP--->', JSON.stringify(this.hcpRecordList));
        if(!isHCPCompleted) {
            this.showToast('Error', 'Please select any HCP', 'error');
            isValid = false;
            return isValid;
        }
        return isValid;
    }

    handleChange(event) {
        this.populateFields(event);
        this.validateInputs(event, false, true);
        this.handleDependentFields(event);
    }

    
    getExtRec() {
        getExistingAccountRecord(
            {
                programType: 'REMS',
                programName: 'XIAFLEX',
                firstName: this.authRepRecord.firstName,
                lastName: this.authRepRecord.lastName,
                email: this.authRepRecord.email
            }).then(result => {
                console.log('existing ac result::', result);
                return result;
            }).catch(error => {
                this.showToast('Error', JSON.stringify(error.body.message), 'error');
                this.displaySpinner = false;
            });       
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
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage', 
            attributes: {
                pageName: 'home'
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