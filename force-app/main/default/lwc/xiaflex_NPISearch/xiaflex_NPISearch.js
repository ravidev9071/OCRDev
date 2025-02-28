import { LightningElement, api, track, wire } from 'lwc';
import getExistingNPIRecordJS from '@salesforce/apex/xiaflex_NPISearchControllerPortal.getExistingNPIRecord';
import createRecordOnSubmit from '@salesforce/apex/xiaflex_NPISearchControllerPortal.createRecordOnSubmit';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DocumentFieldWM from '@salesforce/label/c.NPI_Case_Validation_Msg';
import ValidationMsg from '@salesforce/label/c.ValidationMsg';
import Isvalid_InvalidMsg from '@salesforce/label/c.Isvalid_InvalidMsg';
import SuccessMsg from '@salesforce/label/c.SuccessMsg';
import ErrorMsg from '@salesforce/label/c.ErrorMsg';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import { NavigationMixin } from 'lightning/navigation';
import getNPIStatusVeeva from '@salesforce/apex/PiaSky_NPISearchControllerPortal.getNPIStatusVeeva';
//Phone and fax formatng 
export default class Xiaflex_NPISearch extends NavigationMixin(LightningElement) {

    label = {
        DocumentFieldWM,
        ValidationMsg,
        Isvalid_InvalidMsg,
        SuccessMsg,
        ErrorMsg
    };
    npiRecord ={};
    @api programName = '';
    @api participantType = '';
    @api profileName = '';
    @api permissionSet = '';
    @api npiNotfoundWarning = '';
    @api fontSize='';
    @api fontColor='';
    @api newInput = '';
    searchValue = '';
    disabled = false;
    showMsg = false;
    message = this.label.ValidationMsg;
    showDetails = false;
    valid = true;
    showErrorMessage = false;
    errorMessage = '';
    npiavailable;
    npinotavailable;
   
    showError= false;
    errorFields = [];

    showLoading = false;
    displaySpinner = false;
    displayInvalidNpi = false;
    preferedContactMethodVlaue = '';
    DEA='';
    get options() {
        return [
            { label: 'Email', value: 'Email' },
            { label: 'Fax', value: 'Fax' },
        ];
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);     
        let css = this.template.host.style;
        css.setProperty('--lwc-colorTextLabel', this.fontColor);
        css.setProperty('--lwc-formLabelFontSize', this.fontSize);  

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
    getNPIdetails(){
        getNPIStatusVeeva({searchKey:this.searchValue,programName:'XIAFLEX'})
        .then(result => {
            if(result == 'Failed'){
                    this.showToast('Error!', 'Please enter the valid NPI number', 'error');
                    this.displaySpinner = false;
                    this.disabled = false;
                }else{
                        let npiResult = JSON.parse(result);
                        this.showDetails = true;
                        this.npiRecord.firstName = npiResult.FirstName; 
                        this.npiRecord.middleName = npiResult.MiddleName;
                        this.npiRecord.lastName = npiResult.LastName;
                        this.npiRecord.fax = npiResult.fax;
                        this.npiRecord.email = result.email;
                        this.confirmEmail = '';
                        this.npiRecord.npi = this.searchValue;
                        this.disabled = true;
                        if(npiResult.Phonenumber1) {
                            let numericPhone = npiResult.Phonenumber1.replace(/\D/g, '');
                            let formateNumber = this.formatPhoneNumber(numericPhone);
                            this.npiRecord.phone = formateNumber;
                        }
                        if(npiResult.fax) {
                            let numericPhone = npiResult.fax.replace(/\D/g, '');
                            let formateNumber = this.formatPhoneNumber(numericPhone);
                            this.npiRecord.fax = formateNumber;
                        }
                }
                  
        }
        )
        .catch(error => {
        });
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

        this.npiRecord = {};
        let field1 = this.template.querySelector('.search');
        if (this.searchValue === undefined || (this.searchValue !== undefined && this.searchValue.length === 0)) {
            
            this.valid = false;
            field1.validity = { valid: false };
            field1.setCustomValidity('Please enter NPI to search.');
            field1.focus();
            field1.blur();
            field1.reportValidity();
        } else if (this.valid) 
        {
            this.valid = true;
            field1.validity = { valid: true };
            field1.setCustomValidity('');
            field1.reportValidity();
            

            try {
                const EXISTING_ACCOUNT = await getExistingNPIRecordJS({programType : 'REMS', programName : 'XIAFLEX', NPI : this.searchValue});
                if(EXISTING_ACCOUNT != null && EXISTING_ACCOUNT.length > 0 ) {
                    if(EXISTING_ACCOUNT[0].Users && EXISTING_ACCOUNT[0].Users.length > 0){
                        if(EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Decertified' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Deactivated') {
                            this.showToast('Information', 'Your access is disabled. Please contact Xiaflex REMS Program at 1-877-313-1235 for assistance.' , 'info');
                        } else {
                            this.showToast('Information', 'Account already exists. Please log in using the \'Login\' button or \'Forgot Password?\' to proceed with accessing your account or contact Xiaflex REMS Program at 1-877-313-1235 for assistance".' , 'info');
                        }
                    } 
                    else if(EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Pending' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Cancelled' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c  == 'Certified'
                        || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Decertified' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Deactivated'
                    ) {
                        this.showToast('Information', 'The enrollment for the selected Healthcare Provider cannot be submitted at this time. Please contact Xiaflex REMS Program at 1-877-313-1235 for assistance.' , 'info');
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

    handleCancelKeyword() {
        this.showLoading = true;

        //Reset form to inital state
        this.disabled = false;
        this.showDetails = false;
        this.showMsg = false;
        this.errorFields = [];
        this.searchValue = '';
        this.showError = false;


        this.showLoading = false;

    }

    handleChange(event) {
        this.populateFields(event);
        this.validateInputs(event, false, true);
    }

    handlePCM(event){
        this.preferedContactMethodVlaue = event.target.value;
    }

    handleSubmitKeyword(event) {
        this.showLoading = true;
        this.displaySpinner = true;
        this.showErrorMessage = false;
        this.errorMessage = '';
        
        this.disabled = true;
        this.showError = false;
        this.errorFields = [];

        const namePatterns = /^[A-Za-z'. -]+$/;
        let validateRequiredFields = this.validateRequiredFields(event, true, false);
        if(validateRequiredFields) {
            let validateInputs = this.validateInputs(event, true, false);
            console.log('validateInputs:::', validateInputs);
            if(validateInputs) {
                let updatedNpiRecord = {...this.npiRecord};
                if(this.preferedContactMethodVlaue == '') {
                    this.showToast('Error', 'Please select Preferred Method of Communication', 'error');
                    this.showErrorMessage = true;
                    this.errorMessage = 'Please select Preferred Method of Communication';
                    this.showLoading = false;
                    this.displaySpinner = false;
                    return;
                }
                updatedNpiRecord.participantType = this.participantType;
                updatedNpiRecord.DEA = this.DEA;
                updatedNpiRecord.PMC=this.preferedContactMethodVlaue;

                let inputRecords = {
                    'recordDetails': JSON.stringify(updatedNpiRecord),
                    'programName': this.programName,
                    'participantType': this.participantType,
                    'profileName':this.profileName,
                    'permissionSet':this.permissionSet,
                    'email':this.npiRecord.email,
                    'programtype': 'REMS'
                };
                this.newInput = JSON.stringify(inputRecords);
                createRecordOnSubmit({ inputRecord:this.newInput }).then((eachRec) => { 
                        if(eachRec == 'Success'){
                        this.navigateToSuccess(event);
                        }
                            
                    if (eachRec === 'Error') {
                        this.showToast('Error', this.label.ErrorMsg, 'error');
                        this.showErrorMessage = true;
                        this.errorMessage = this.label.ErrorMsg;
                    }
                    if (eachRec == 'dupFound'){
                        this.showToast('Duplicate Found','The enrollment for the selected Healthcare Provider cannot be submitted at this time. Please contact Xiaflex REMS Program at 1-877-313-1235 for assistance.','error');
                        this.showErrorMessage = true;
                        this.errorMessage = 'The enrollment for the selected Healthcare Provider cannot be submitted at this time. Please contact Xiaflex REMS Program at 1-877-313-1235 for assistance.';
                    }
                    this.showLoading = false;
                    this.displaySpinner = false;
                }).catch(error => {
                    this.disabled = true;
                    this.showLoading = false;
                    this.displaySpinner = false;
                    this.showToast('Error', JSON.stringify(error.body.message), 'error');
                    this.showErrorMessage = true;
                    this.errorMessage = JSON.stringify(error.body.message);
                });
            }else{
                this.showLoading = false;
                this.displaySpinner = false;
            }
        }  

    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
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
    navigateToSuccess(event){
        try{
            event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes:{
                name: 'registerSuccess__c'
            },
        });
    }
    catch(error){
        console.log('error --'+error.message);
    }
    }

    validateRequiredFields(event) {
        this.showLoading = true;
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
            this.showLoading = false;
            this.displaySpinner = false;
            this.showToast('Error', 'Please fill all the required fields.', 'error');
        }
        
        return isValid;
    }

    validateInputs(event, isValidateALL, isFieldCheck) {

        const phonePattern = /^(\s*\d\s*){10}$/;
        const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        const namePatterns = /^[A-Za-z'. -]+$/;
        let isValid = true;
        let email;
        let confirmEmail;
        let isValidEmail = true;
        let isValidConfirmEmail = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {

            console.log('inputField:::::', JSON.stringify(inputField));
            const fieldName = isFieldCheck ? event.target.name : inputField.name;
            let fieldValue = isFieldCheck ? event.target.value : inputField.value;
            console.log('fieldName:::',fieldName);
            let numericPhone = fieldValue ? fieldValue.replace(/\D/g, '').replace('-') : fieldValue;

            if(isValidateALL || (isFieldCheck && fieldName && inputField.name === fieldName)) {

                if (fieldName === 'email' || fieldName === 'confirmEmail') {
                    email = fieldName === 'email' ? fieldValue : email;
                    confirmEmail = fieldName === 'confirmEmail' ? fieldValue : confirmEmail;
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    if( fieldValue && !fieldValue.match(emailPattern)) {
                        isValid = false;
                        inputField.classList.add('slds-has-error');
                        inputField.setCustomValidity('Please enter a valid email address.');
                        isValidEmail = fieldName === 'email' ? false : isValidEmail;
                        isValidConfirmEmail = fieldName === 'confirmEmail' ? false : isValidConfirmEmail;
                    }
                    inputField.reportValidity();
                } 
                 if (fieldName === 'phone') { 
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    if(!numericPhone.match(phonePattern)) {
                        isValid = false;
                        inputField.classList.add('slds-has-error');
                        inputField.setCustomValidity('Please enter a valid Phone Number.');
                    }
                    inputField.reportValidity();
                } 

                if (fieldName === 'fax') { 
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    if(fieldValue && !numericPhone.match(phonePattern)) {
                        isValid = false;
                        inputField.classList.add('slds-has-error');
                        inputField.setCustomValidity('Please enter a valid fax Number.');
                    }
                    inputField.reportValidity();
                } 
                if (fieldName === 'lastName') {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    if(!fieldValue.match(namePatterns)) {
                        isValid = false;
                        inputField.classList.add('slds-has-error');
                        inputField.setCustomValidity('Please enter a valid Last Name.');
                    }
                    inputField.reportValidity();
                } 
                if (fieldName === 'firstName') {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    if(!fieldValue.match(namePatterns)) {
                        isValid = false;
                        inputField.classList.add('slds-has-error');
                        inputField.setCustomValidity('Please enter a valid First Name.');
                    }
                    inputField.reportValidity();
                } 

                if(isValidateALL && isValidEmail && isValidConfirmEmail && fieldName === 'confirmEmail' && email != fieldValue) {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    if(!fieldValue.match(namePatterns)) {
                        inputField.classList.add('slds-has-error');
                        inputField.setCustomValidity('Please enter same email address.');
                    }
                    inputField.reportValidity();
                }
            }
        });
        if(!isValid) {
            if(isValidateALL) {
                this.showToast('Error', 'Please enter valid data', 'error');
            }
        } else if(isValidateALL && email != confirmEmail) {
            isValid = false;
            this.showToast('Error', 'Please enter same email address.', 'error');
        }
        return isValid;
    }

    populateFields(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value;
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        switch(fieldName) {
            case 'lastName':
             this.npiRecord.lastName = fieldValue;
             break;
            case 'firstName':
             this.npiRecord.firstName = fieldValue;
             break;
            case 'email':
              this.npiRecord.email = fieldValue;
              break;
            case 'confirmEmail':
                this.npiRecord.confirmEmail = fieldValue;
                break;
            case 'phone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord.phone = fieldValue;
                break;
            case 'fax':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord.fax = fieldValue;
                break;
            default:
        }  

    }
}