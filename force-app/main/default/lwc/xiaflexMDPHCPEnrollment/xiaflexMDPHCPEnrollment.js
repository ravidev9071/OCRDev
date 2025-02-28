import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import xiaflex_IconSortAcc from "@salesforce/resourceUrl/xiaflex_IconSortAcc";
import customHomeStyles from '@salesforce/resourceUrl/xiaflexMDP_customcss'
import getNPIStatusVeeva from '@salesforce/apex/PiaSky_NPISearchControllerPortal.getNPIStatusVeeva';
import getAccountHcsRecordList from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getAccountRecordForSearch';
import getPickListValues from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getPicklistFieldValues';
import insertDataOnSubmit from '@salesforce/apex/xiaflex_Application_Enrollment_Class.insertHCPData';
import getExistingNPIRecordJS from '@salesforce/apex/xiaflex_NPISearchControllerPortal.getExistingNPIRecord';

export default class XiaflexMDPHCPEnrollment extends LightningElement {

    displaySection = false;
    displaySpinner = false;
    selectedrowvaluetrue = '';
    hcsSearch = false;
    hcsEntry = false;
    checkboxDisabled = false;
    displayOther = false;
    selectedHcsObject = '';
    signatureData = '';
    prescriberData ={};
    stateOptions = [];
    @track hcsAccountRecords = [];
    @track visibileAccounts = [];
    searchValue;
    displayInvalidNpi = false;
    disabled = false;
    hcsRecord = {};
    @track tabsetArr = new Array();
    @track prescriberData = {};
    iconSortAcc = xiaflex_IconSortAcc;

     showHCSNewForm = false;

    get degreeoptions() {
        return [
            { label: 'MD', value: 'MD' },
            { label: 'DO', value: 'DO' },
            { label: 'PA', value: 'PA' },
            { label: 'CNP', value: 'CNP' },
        ];
    }

    get phoneOptions() {
        return [
            { label: 'Office', value: 'Office' },
            { label: 'Mobile', value: 'Mobile' },
            { label: 'Home', value: 'Home' },
        ];
    }

    get contactOptions() {
        return [
            { label: 'Email', value: 'Email' },
            { label: 'Fax', value: 'Fax' },
        ];
    }

    

    get specialityOptions() {
        return [
            { label: 'General Surgeon', value: 'General Surgeon' },
            { label: 'Plastic Surgeon', value: 'Plastic Surgeon' },
            { label: 'Hand Surgeon', value: 'Hand Surgeon' },
            { label: 'Orthopedic Surgeon', value: 'Orthopedic Surgeon' },
            { label: 'Rheumatologist', value: 'Rheumatologist' },
            { label: 'Other (specify)', value: 'Other' },
        ];
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.getPickListValues();
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
                    // This way you are not to going to see [object Object]
                });
    }

    getNPIdetails(npiVal) {
        this.displaySpinner = true;
        getNPIStatusVeeva({ searchKey: this.searchValue, programName: 'XIAFLEX' })
            .then(result => {
                console.log('result:::', result);
                if(result == 'Failed'){
                    this.showToast('Error!', 'Please enter the valid NPI number', 'error');
                    this.displaySpinner = false;
                }else{
                    let npiResult = JSON.parse(result);
                    this.showDetails = true;
                    this.prescriberData.firstName = npiResult.FirstName;
                    this.prescriberData.middleName = npiResult.MiddleName;
                    this.prescriberData.lastName = npiResult.LastName;
                    this.prescriberData.fax = npiResult.fax;
                    this.prescriberData.email = result.email;   
                    this.prescriberData.npi = this.searchValue;                  
                    this.prescriberData.phoneType = '',
                    this.prescriberData.preferredContactMethod = '',
                    this.prescriberData.degree = '',
                    this.prescriberData.speciality = '',
                    this.disabled = true;
                    this.prescriberData.onhold = false;
                    if (npiResult.Phonenumber1) {
                        let numericPhone = npiResult.Phonenumber1.replace(/\D/g, '');
                        let formateNumber = this.formatPhoneNumber(numericPhone);
                        this.prescriberData.phone = formateNumber;
                    }
                    if (npiResult.fax) {
                        let numericPhone = npiResult.fax.replace(/\D/g, '');
                        let formateNumber = this.formatPhoneNumber(numericPhone);
                        this.prescriberData.fax = formateNumber;
                    }
                    this.displaySection = true;
                    this.displaySpinner = false;
                }
            })
            .catch(error => {
                this.displaySpinner = false;
            });
    }

    handleChange(event) {
        this.populateFields(event);
        this.validateInputs(event, false, true);
        this.handleDependentFields(event);
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
            const pharmaName = /^[a-zA-Z0-9 ]+$/;
            const faxPatterns = /^(\s*\d\s*){10}$/;
            const zipPattern = /^[0-9]{5}(?:-[0-9]{4})?$/;
            const npiPattern = /^[0-9]{10}$/;

            if ((fieldName === 'email' || fieldName === 'confirmEmail') && inputField.name === fieldName && !fieldValue.match(emailPattern)) {
               
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid email address.');
                inputField.reportValidity();
            } if ((fieldName === 'email' || fieldName === 'confirmEmail') && inputField.name === fieldName && fieldValue.match(emailPattern)) {
               
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
            } if (fieldName === 'name' && inputField.name === fieldName) {
                
                 if(fieldValue && !fieldValue.match(pharmaName)) {
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

    async handleSearch(){
        var hcsSearch =  this.template.querySelector('.hcsSearchData');
        if (!hcsSearch.checkValidity()) {
            hcsSearch.reportValidity()
        } else {
            var result = await this.getHcsAccountRecords(hcsSearch.value);
        }
    }

    async getHcsAccountRecords(hcsSearch) {
        this.hcsSearch = false;
        if (hcsSearch != null && hcsSearch.length > 0) {
            this.displaySpinner = true;
            getAccountHcsRecordList({ inputValue: hcsSearch, participantType: 'Healthcare', programType : 'MDP' })
                .then((accRecord) => {
                    if (accRecord != null) {
                        this.hcsAccountRecords = accRecord.map((acc, index) => ({
                            Id: acc.Id,
                            Name: acc.Name,
                            Address: acc.US_WSREMS__Address_Line_1__c != undefined ? acc.US_WSREMS__Address_Line_1__c : null,
                            City: acc.US_WSREMS__City__c != undefined ? acc.US_WSREMS__City__c : null,
                            State: acc.US_WSREMS__State__c != undefined ? acc.US_WSREMS__State__c : null,
                            ZIPCode: acc.US_WSREMS__Zip__c != undefined ? acc.US_WSREMS__Zip__c : null,
                            Phone: acc.Phone != undefined ? acc.Phone : null,
                            EnrollmentID: acc.US_WSREMS__REMS_ID__c,
                            mdpStatusPending: acc.US_WSREMS__Status__c != 'Certified' ? acc.US_WSREMS__Status__c : null,
                            mdpStatusCertified: acc.US_WSREMS__Status__c == 'Certified' ? acc.US_WSREMS__Status__c : null,
                            checked : false
                        }));
                    }
                    this.hcsSearch = true;
                    this.displaySpinner = false;
                })
                .catch((error) => {
                    this.displaySpinner = false;
                });
        }
    }

    handleRowSelection(event){
        this.selectedHcsObject = event.target.value;
        this.hcsEntry = false;
        this.checkboxDisabled = true;
        this.template.querySelector('.hcsCheck').checked = false;
        this.showHCSNewForm=false;
        var selectedRecId = event.currentTarget.dataset.recId;
        var currentIndex = event.currentTarget.dataset.index;
        this.hcsRecord.Id = selectedRecId;
        this.selectedrowvaluetrue  = event.currentTarget.dataset.recId;
        this.visibileAccounts = this.uncheckRadiobutton(this.visibileAccounts, this.selectedrowvaluetrue);
        this.template.querySelector('input[data-cmp="cannotFindCheck"]').checked = false;
        this.showHCSNewForm = false;
    }

    handleHcsEntry(event){
        this.showHCSNewForm = event.target.checked;
        if(event.currentTarget.checked) {
            this.selectedrowvaluetrue = null;
            this.hcsRecord = {};
            this.visibileAccounts = this.uncheckRadiobutton(this.visibileAccounts, this.selectedrowvaluetrue);
        }        
    }

    handleSignatureCompleted(event) {
        this.signatureData = event.detail.signdata;
    }

    handleSubmit(event){
        this.displaySpinner = true;
        this.template.querySelector('c-tryvio-sign-pad').handleSaveSignature();
        var prescriberObj = this.prescriberData;
        let isValid  = true;
        let validateRequiredFields = this.validateRequiredFields(event, true, false);
        console.log('validateRequiredFields:::', validateRequiredFields);
        if(validateRequiredFields) {
            let validateInputs = this.validateInputs(event, true, false);
            console.log('validateInputs:::', validateInputs);
            if(validateInputs) {
                let validateHCS = this.validateHCSData(event);
                console.log('validateHCS:::', validateHCS);
                if(validateHCS) {
                    this.template.querySelector('c-tryvio-sign-pad').handleSaveSignature();
                    let validateSignature = this.validateSignature(event);
                    console.log('validateSignature:::', validateSignature);
                    if(validateSignature) {
                        if (this.prescriberData.Id != null && this.prescriberData.Id != undefined) {
                            prescriberObj['Id'] = this.prescriberData.Id ;
                        }
                        if(!this.showHCSNewForm && this.selectedrowvaluetrue) {
                            this.hcsRecord.Id = this.selectedrowvaluetrue;
                        }
                        let inputRecords = {
                            'prescriberRecord': JSON.stringify(prescriberObj),
                            'hcsRecord': JSON.stringify(this.hcsRecord),
                            'programName': 'Xiaflex',
                            'programType': 'MDP',
                            'signatureData': this.signatureData
                        };
                        this.displaySpinner = true;
                        insertDataOnSubmit({ inputRecords: inputRecords })
                            .then(result => {
                                if (result == 'dupFound') {
                                    this.showToast('Error', 'Pharmacy/Healthcare Setting Account already exist', 'error');
                                    this.displaySpinner = false;
                                } else if (result == 'Success') {
                                    this.showToast('Success!', 'Record Saved Successfully', 'success');
                                    window.location.href = 'hcp-enrollment-form-success';
                                    this.displaySpinner = false;
                                }
                            })
                            .catch(error => {
                                this.displaySpinner = false;
                                console.log('Error=>', error)
                            })
                    }
                    
                }
            }
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

    handleCancel(){
        let location = window.location.href;
        location = location.substring(0, location.indexOf('s/'))+'s/login-Signup';
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

    updateRecords(event){
        var visibileAcc=[...event.detail.records];
        this.visibileAccounts =  this.uncheckRadiobutton(visibileAcc, this.selectedrowvaluetrue);
    }

    sortAccountRecords(event){
        this.visibileAccounts = [...this.visibileAccounts].sort((a, b) => {
            const lastNameA = a.Name.toLowerCase();
            const lastNameB = b.Name.toLowerCase();
            return lastNameA.localeCompare(lastNameB);
        });
    }

    searchKeyword(event) { 
        this.displaySpinner = true;
        this.searchValue = event.target.value;
        let field1 = this.template.querySelector('.search');
        this.displayInvalidNpi = false;
        if(!isFinite(event.target.value)) {
            event.target.value = event.target.value.toString().slice(0,-1);
            this.searchValue = event.target.value;
        }
        if (this.searchValue && (this.searchValue.length < 10 || this.searchValue.length > 10 || !(/^\d+$/.test(this.searchValue)))) {
            this.displayInvalidNpi = true;
            this.disabled = false;
        } else {
            this.valid = true;
            field1.validity = { valid: true };
            field1.setCustomValidity('');
            field1.reportValidity();
        }
        this.displaySpinner = false;

    }

    async handleSearchKeyword() {
        this.displaySpinner = true;
        this.showLoading = true;
        this.showDetails = false;
        this.errorFields = [];

        this.showMsg = false;

        if(this.displayInvalidNpi) {
            this.showToast('Warning', this.npiNotfoundWarning, 'warning');
            this.showLoading = false;
            this.displaySpinner = false;
            return;
        }
        this.prescriberData = {};
        let field1 = this.template.querySelector('.search');
        if (this.searchValue === undefined || (this.searchValue !== undefined && this.searchValue.length === 0)) {
            
            this.valid = false;
            field1.validity = { valid: false };
            field1.setCustomValidity('Please enter NPI to search.');
            field1.focus();
            field1.blur();
            field1.reportValidity();
            console.log('--4-->');
        } else if (this.valid) 
        {
            this.valid = true;
            field1.validity = { valid: true };
            field1.setCustomValidity('');
            field1.reportValidity();

            try {
                const EXISTING_ACCOUNT = await getExistingNPIRecordJS({programType : 'MDP', programName : 'XIAFLEX', NPI : this.searchValue});
                if(EXISTING_ACCOUNT != null && EXISTING_ACCOUNT.length > 0 ) {
                    if(EXISTING_ACCOUNT[0].Users && EXISTING_ACCOUNT[0].Users.length > 0){
                        if(EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Decertified' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Deactivated') {
                            this.showToast('Information', 'Your access is disabled. Please contact Xiaflex MDP Program at 1-877-313-1235 for assistance.' , 'info');
                        } else {
                            this.showToast('Information', 'Account already exists. Please log in using the \'Login\' button or \'Forgot Password?\' to proceed with accessing your account or contact Xiaflex MDP Program at 1-877-313-1235 for assistance".' , 'info');
                        }
                    } 
                    else if(EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Pending' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Cancelled' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c  == 'Certified'
                        || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Decertified' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Deactivated'
                    ) {
                        this.showToast('Information', 'The enrollment for the selected Healthcare Provider cannot be submitted at this time. Please contact Xiaflex MDP Program at 1-877-313-1235 for assistance.' , 'info');
                    }else{
                        this.showMsg = false;
                        this.getNPIdetails();     
                    }
                    
                }else{
                        this.showMsg = false;
                        this.getNPIdetails();     
                    }  
            } catch(e) {
                this.showToast('Error', e, 'error');
            }

        }
        this.showLoading = false;
        this.displaySpinner = false;
         this.dispatchEvent(new CustomEvent('testoast', {
            detail: {
                message: 'test'
            }
        }));
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

    validateInputs(event, isValidateALL, isFieldCheck) {

        try {
            const phonePattern = /^(\s*\d\s*){10}$/;
            const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const namePatterns = /^[A-Za-z'. -]+$/;
            const faxPatterns = /^(\s*\d\s*){10}$/;
            const extPatterns = /^[0-9]{1,10}$/;
            let zipPatterns = /^\d{5}$/;
            let isValid = true;

            let inputFields = this.template.querySelectorAll('.validate');
            inputFields.forEach(inputField => {

                
                const fieldName = isFieldCheck ? event.target.name : inputField.name;
                let fieldValue = isFieldCheck ? event.target.value : inputField.value;
                let numericPhone = fieldValue ? fieldValue.replace(/\D/g, '').replace('-') : fieldValue;

                if(isValidateALL || (isFieldCheck && fieldName && inputField.name === fieldName)) {
                    
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
                    
                    if ((fieldName == 'phone')) {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !numericPhone.match(phonePattern)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Phone Number.');
                        }
                        inputField.reportValidity();
                    } 

                    if ((fieldName === 'email' || fieldName === 'pemail' || fieldName === 'semail')) {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(emailPattern)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid email address.');
                        }
                        inputField.reportValidity();
                    } 
                    if ((fieldName === 'fax')) {
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
                } else {
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
        if(fieldName == 'speciality' ){
            if(fieldValue == 'Other'){
                this.displayOther = true;
              
            }else{
                this.displayOther = false;
                this.prescriberData.other = '';
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
            case 'npi':
                this.prescriberData.npi = fieldValue;
                break;
            case 'firstName':
                this.prescriberData.firstName = fieldValue;
                break;
            case 'middleName':
                this.prescriberData.middleName = fieldValue;
                break;
            case 'lastName':
                this.prescriberData.lastName = fieldValue;
                break;
            case 'onhold':
                this.prescriberData.onhold = event.target.checked;
                break;  
            case 'suffix':
                this.prescriberData.suffix = fieldValue;
                break;
            case 'email':
                this.prescriberData.email = fieldValue;
                break;
            case 'phone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.prescriberData.phone = fieldValue;
                break;
            case 'phoneType':
                this.prescriberData.phoneType = fieldValue;
                break;
            case 'fax':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.prescriberData.fax = fieldValue;
                break;
            case 'preferredContactMethod':
                this.prescriberData.preferredContactMethod = fieldValue;
                break;
            case 'degree':
                this.prescriberData.degree = fieldValue;
                break;
            case 'speciality':
                this.prescriberData.speciality = fieldValue;
                break;
            case 'other':
                this.prescriberData.other = fieldValue;
                break;
            
            case 'me':
                this.prescriberData.me = fieldValue;
                break;
            case 'license':
                this.prescriberData.license = fieldValue;
                break;
            case 'licenseState':
                this.prescriberData.licenseState = fieldValue;
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
            default:
        }    
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

    handleClear(){
        this.template.querySelector('c-tryvio-sign-pad').handleClear();
    }

    uncheckRadiobutton(records, selectedValue) {
        console.log('selectedValue::', selectedValue);
        console.log('records::', records);
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

    isiSection(){
        window.scrollTo(0, document.body.scrollHeight);
    }
}