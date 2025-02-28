import { LightningElement, api, track } from 'lwc';
import getNPIStatusVeeva from '@salesforce/apex/PiaSky_NPISearchControllerPortal.getNPIStatusVeeva';
import createRecordOnSubmit from '@salesforce/apex/piaSky_PrescriberEnrollmentForm.insertDataOnHCPSubmit';
import getPickListValues from '@salesforce/apex/piaSky_PrescriberEnrollmentForm.getPicklistFieldValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DuplicateEmail from '@salesforce/label/c.PiaSky_Duplicate_email_Error_Msg';
import ValidationMsg from '@salesforce/label/c.ValidationMsg';
import Isvalid_InvalidMsg from '@salesforce/label/c.Isvalid_InvalidMsg';
import inValidNPI from '@salesforce/label/c.piaSky_Invalid_NPI';
import duplicateNPI from '@salesforce/label/c.piaSky_Duplicate_NPI';
import SuccessMsg from '@salesforce/label/c.SuccessMsg';
import ErrorMsg from '@salesforce/label/c.ErrorMsg';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/piaSky_homecustomcss';

//Phone and fax formatng
export default class Org_npiSearch extends LightningElement {

    label = {
        DuplicateEmail,
        ValidationMsg,
        Isvalid_InvalidMsg,
        inValidNPI,
        duplicateNPI,
        SuccessMsg,
        ErrorMsg
    };
    npiRecord ={};
    @api programName = '';
    @api participantType = '';
    @api npiNotfoundWarning = '';

    @track stateOptions = [];
    @track acknowledged = false;

    searchValue = '';
    disabled = false;
    showMsg = false;
    message = this.label.ValidationMsg;
    showDetails = false;
    valid = true;
   
    showError= false;
    errorFields = [];

    showLoading = false;
    displaySpinner = false;
    displayInvalidNpi = false;
    showOtherCredetial = false;
    showOtherSpecialty = false;
    signatureData = '';
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
        this.getPickListValues();
    }
    handleSignatureCompleted(event) {
        // Call the function you need when the event is triggered
        this.signatureData = event.detail.signdata;
    }
    handleClear(){
        this.template.querySelector('c-pia-sky_signature-pad').handleClear();
    }
    getPickListValues(){
        getPickListValues()
                .then((pickListVal) => {
                    var stateOptionList = pickListVal.US_WSREMS__State__c;

                    for (var i in stateOptionList) {
                        const option = {
                            label: i,
                            value: stateOptionList[i]
                        };
                        this.stateOptions = [...this.stateOptions, option];
                    }
                })
                .catch((error) => {
                    console.log('Error is', error);
                });
    }
    

    searchKeyword(event) {
        this.displaySpinner = true;
        this.searchValue = event.target.value;
        let field1 = this.template.querySelector('.search');
        this.displayInvalidNpi = false;
        if (this.searchValue && (this.searchValue.length > 10 || !(/^\d+$/.test(this.searchValue)))) {
            this.displayInvalidNpi = true;
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

        this.npiRecord = {};
        let field1 = this.template.querySelector('.search');
        if (this.searchValue === undefined || (this.searchValue !== undefined && this.searchValue.length === 0)) {
            this.valid = false;
            field1.validity = { valid: false };
            field1.setCustomValidity('Please enter NPI to search.');
            field1.focus();
            field1.blur();
            field1.reportValidity();
        } else if (this.valid) {
            this.valid = true;
            field1.validity = { valid: true };
            field1.setCustomValidity('');
            field1.reportValidity();
            

            try {
                // this.message = '';
                this.showMsg = false;
                const NPI_RESPONSE = await getNPIStatusVeeva({ searchKey: this.searchValue,programName : this.programName });
                switch(NPI_RESPONSE){
                    
                    case 'Failed':
                        this.showMsg = true;
                        // this.message = this.label.Isvalid_InvalidMsg;
                        this.showToast('Error', this.label.inValidNPI, 'error');
                        break;    
                    default:
                        let result = JSON.parse(NPI_RESPONSE);
                        this.showDetails = true;
                        this.npiRecord.firstName = result.FirstName; 
                        this.npiRecord.middleName = result.MiddleName;
                        this.npiRecord.lastName = result.LastName;
                        this.npiRecord.phone = result.Phonenumber1 != null && result.Phonenumber1 != '' ? this.formatPhoneNumber(result.Phonenumber1) : '';
                        this.npiRecord.fax = result.fax != null && result.fax != '' ? this.formatPhoneNumber(result.fax) : '';
                        this.npiRecord.address1 =result.StreetAddress;
                        this.npiRecord.address2 =result.StreetAddress2;
                        this.npiRecord.city=result.city;
                        this.npiRecord.state=result.State != null && result.State != '' ? result.State : 'None';
                        this.npiRecord.zipCode=result.postalCode;
                        this.npiRecord.npi = this.searchValue;
                        this.disabled = true;
                }
            } catch(e) {
                console.log('e->', e);
                this.showToast('Error', this.label.ErrorMsg, 'error');
            }
        }
        this.showLoading = false;
        this.displaySpinner = false;

    }

    handleConfirmEmail(event){
        let confirmEmail = event.target.value;
        let email = this.npiRecord.email;
        let inputField = this.template.querySelector('.confirmEmail');
        const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        
        if (confirmEmail !== email && !confirmEmail.match(emailPattern)) {
            inputField.classList.add('slds-has-error');
            inputField.setCustomValidity('Please enter same email address as above.');
            inputField.reportValidity();
            this.npiRecord.confirmEmail = null;
        } else if (confirmEmail === email && confirmEmail.match(emailPattern)) {
            inputField.classList.remove('slds-has-error');
            inputField.setCustomValidity('');
            inputField.reportValidity();
            this.npiRecord.confirmEmail = confirmEmail;
        }
    }


    handleSearchKeyword1(){
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
        } else if (this.valid) {
            this.valid = true;
            this.npiRecord.firstName = 'Test';
            this.npiRecord.lastName = 'Name';
            this.npiRecord.email = 'test@email.com';
            this.showDetails = true;
            this.disabled = true;
        }
        this.showLoading = false;
        this.displaySpinner = false;

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
        this.validateInputs(event);
        const fieldName = event.target.name;
        let fieldValue = event.target.value;  
        if(fieldName == 'credentials' ){
            if(fieldValue == 'other'){
                this.showOtherCredetial = true
            }else{
                this.showOtherCredetial = false
            }
        }

        if(fieldName == 'specialty' ){
            if(fieldValue == 'other'){
                this.showOtherSpecialty = true
            }else{
                this.showOtherSpecialty = false
            }
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
            const zipCodePatterns = /^\d{5}(-\d{4})?$/;
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
            }

            if (fieldName === 'middleName' && inputField.name === fieldName ) {

                if(fieldValue && !fieldValue.match(namePatterns)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter a valid Name.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
          }
          

            if (fieldName === 'fax' && inputField.name === fieldName ) { 

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
            if (fieldName === 'zipCode' && inputField.name === fieldName ) { 
                if(fieldValue && !fieldValue.match(zipCodePatterns)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter a valid Zip Code.');
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
                this.npiRecord[event.target.name] = fieldValue.replace(/\D/g, '');
            }else {
                this.npiRecord[event.target.name] = fieldValue;
            }
            
            
        });
    }

    handleCheckBox(){
        this.acknowledged = event.target.checked;
    }

    handleSubmitKeyword() {
        this.template.querySelector('c-pia-sky_signature-pad').handleSaveSignature();
        this.showLoading = true;
        this.displaySpinner = true;
        this.disabled = true;
        this.showError = false;
        this.errorFields = [];

        const namePatterns = /^[A-Za-z'. -]+$/;

        let updatedNpiRecord = {...this.npiRecord};
        let inputFields = this.template.querySelectorAll('.validate');
            inputFields.forEach(inputField => {
                if(inputField.required== true && (inputField.value =='' || inputField.value == null) ) {
                   this.showError = true;
                   this.errorFields.push(inputField.label);
                }        
        });

        if(updatedNpiRecord.phone) {
            updatedNpiRecord.phone = updatedNpiRecord.phone.replace(/\D/g, '')
        }
        

        let isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if(updatedNpiRecord.fax) {
            updatedNpiRecord.fax = updatedNpiRecord.fax.replace(/\D/g, '')

            if(updatedNpiRecord.fax.length < 10 || updatedNpiRecord.fax.length > 10) {
                this.showToast('Error', 'Please Enter a valid fax number', 'Error');
                this.showLoading = false;
                this.displaySpinner = false;
                return;
            }
        }

        if(updatedNpiRecord.middleName && !updatedNpiRecord.middleName.match(namePatterns)) {
                this.showToast('Error', 'Please Enter a valid Middle Name', 'Error');
                this.showLoading = false;
                this.displaySpinner = false;
                return;
        }
        if(updatedNpiRecord.confirmEmail != updatedNpiRecord.email || updatedNpiRecord.confirmEmail == null || updatedNpiRecord.confirmEmail == ''){
            this.showToast('Error', 'Please Enter the Same Email address', 'Error');
                this.showLoading = false;
                this.displaySpinner = false;
                return;
        }
        if(updatedNpiRecord.state && updatedNpiRecord.state == 'None') {
            this.showToast('Error', 'Please Select the State value', 'Error');
            this.showLoading = false;
            this.displaySpinner = false;
            return;
    }
        updatedNpiRecord.participantType = this.participantType;

        /*if (this.acknowledged == false) {
            this.showToast('Error', 'Please Acknowledge the Information', 'Error');
            this.showLoading = false;
            this.displaySpinner = false;
            return;
        }*/

        if(this.signatureData == null){
            this.showToast('Error', 'Please Sign to continue', 'Error');
            this.showLoading = false;
            this.displaySpinner = false;
            return;
        }
        isInputsCorrect = updatedNpiRecord?.specialty == null ? false : isInputsCorrect
        isInputsCorrect = updatedNpiRecord?.credentials == null ? false : isInputsCorrect

        if(!isInputsCorrect){
            this.showToast('Error', 'Please enter data in all of the required fields', 'Error'); 
            this.showLoading = false;
            this.displaySpinner = false;
            return;
        }
        if (isInputsCorrect) {    

            let inputRecords = {
                'recordDetails': JSON.stringify(updatedNpiRecord),
                'programName': 'PiaSky REMS',
                'participantType': this.participantType,
                'signatureData' : this.signatureData

            };       

            createRecordOnSubmit({ 'inputRecords': inputRecords }).then((eachRec) => {

                if (eachRec?.length > 15) {
                    this.showToast('Success', this.label.SuccessMsg, 'success');
                    this.disabled = false;
                    this.showDetails = false;
                    localStorage.setItem("userId", eachRec);
                    let location = window.location.href;
                    location = location.substring(0, location.indexOf('s/'))+'s/piasky-prescriberenrollment-success';
                    window.open(location,'_self');        
                }
                        
                if (eachRec === 'duplicateEmail') {
                    this.showToast('Error', this.label.DuplicateEmail, 'error');
                }

                if (eachRec === 'duplicateNPI') {
                    this.showToast('Error', this.label.duplicateNPI, 'error');
                }

                this.showLoading = false;
                this.displaySpinner = false;
            }).catch(error => {
                this.disabled = true;
                this.showLoading = false;
                this.displaySpinner = false;
                this.showToast('Error', JSON.stringify(error.body.message), 'error');
            });
        } else {
           this.showLoading = false;
            this.displaySpinner = false;
        }
        

        if(this.npiRecord.fax) {
            this.npiRecord.fax = this.formatPhoneNumber(this.npiRecord.fax);
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

    formatPhoneNumber(phoneNumber) {
        const regex = /^(\d{3})(\d{3})(\d{4})$/;
        const parts = phoneNumber.match(regex);
        if (parts) {
            return `(${parts[1]}) ${parts[2]}-${parts[3]}`;
        }
        return phoneNumber;
    }
}