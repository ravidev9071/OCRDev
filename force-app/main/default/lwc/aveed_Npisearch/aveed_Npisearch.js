import { LightningElement, api, track } from 'lwc';
import getNpis from '@salesforce/apex/NPISearchControllerPortal.getNpis';
import createRecordOnSubmit from '@salesforce/apex/NPISearchControllerPortal.createRecordOnSubmit';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DocumentFieldWM from '@salesforce/label/c.NPI_Case_Validation_Msg';
import ValidationMsg from '@salesforce/label/c.ValidationMsg';
import Isvalid_InvalidMsg from '@salesforce/label/c.Isvalid_InvalidMsg';
import SuccessMsg from '@salesforce/label/c.SuccessMsg';
import ErrorMsg from '@salesforce/label/c.ErrorMsg';
import duplicateNPI from '@salesforce/label/c.Aveed_Duplicate_NPI';
import duplicateEmail from '@salesforce/label/c.Aveed_Duplicate_Email';
import aveed_phone from '@salesforce/label/c.AVEED_PhoneNumber';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import getNPIStatusVeeva from '@salesforce/apex/PiaSky_NPISearchControllerPortal.getNPIStatusVeeva';
import getDEAStatusVeeva from '@salesforce/apex/PiaSky_NPISearchControllerPortal.getDEAStatusVeeva';

//Phone and fax formatng 
export default class aveed_Npisearch extends LightningElement {

    @track messageNPI = '';
    handleMouseIn() {
        this.messageNPI = 'Please enter your NPI and then click Search';
    }
    handleMouseOut() {
        this.messageNPI = '';
    }
    label = {
        DocumentFieldWM,
        ValidationMsg,
        Isvalid_InvalidMsg,
        SuccessMsg,
        ErrorMsg,
        duplicateNPI,
        duplicateEmail,
        aveed_phone
    };
    npiRecord = {};
    @api programName = '';
    @api participantType = '';
    @api profileName = '';
    @api permissionSet = '';
    @api npiNotfoundWarning = '';
    @api fontSize = '';
    @api fontColor = '';
    confirmEmail = '';
    email = '';

    searchValue = '';
    disabled = false;
    showMsg = false;
    message = this.label.ValidationMsg;
    @track showDetails = false;
    valid = true;
    DEA_validation = false;
    DEA_Validation_inprogress = true;
    showError = false;
    errorFields = [];

    showLoading = false;
    displaySpinner = false;
    displayInvalidNpi = false;
    preferedContactMethodVlaue = '';
    DEA = '';
    LastName = '';
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
    getNPIdetails(){
        getNPIStatusVeeva({searchKey:this.searchValue,programName:'AVEED REMS'})
        .then(result => {
            if(result === 'Failed'){
                this.showMsg = true;
                this.message = 'The NPI entered cannot be found. Please re-enter the information or contact the AVEED REMS Contact Center at '+this.label.aveed_phone;
                this.disabled = false;
        }else{
            let npiResult = JSON.parse(result);
            this.showDetails = true;
            
            this.npiRecord.firstName = npiResult.FirstName; 
            this.npiRecord.middleName = npiResult.MiddleName;
            this.npiRecord.lastName = npiResult.LastName;
            this.LastName = npiResult.LastName;
            this.npiRecord.fax = npiResult.fax;
            this.npiRecord.email = result.email;
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
        this.disabled = true;
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
                this.showMsg = false;
                this.getNPIdetails();
            } catch (e) {
                this.showToast('Error', this.label.ErrorMsg, 'error');
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
    handleChangeEmail(event) {
        this.email = event.target.value;
        this.validateInputs(event);

    }
    handleChange(event) {
        this.validateInputs(event);

    }
    handlConfirmEmailChange(event) {
        this.confirmEmail = event.target.value;
    }

    validateInputs(event) {

        const fieldName = event.target.name;
        let fieldValue = event.target.value;
        if (fieldName === 'PMC') {
            this.preferedContactMethodVlaue = fieldValue;
        }
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {

            const phonePattern = /^(\s*\d\s*){10}$/;
            const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const namePatterns = /^[A-Za-z'. -]+$/;
            const faxPatterns = /^(\s*\d\s*){10}$/;
            const deaPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9,}$/;
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
                this.LastName = fieldValue;
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

            if (fieldName === 'middleName' && inputField.name === fieldName) {
                if (fieldValue && !fieldValue.match(namePatterns)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter a valid Name.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            }


            if (fieldName === 'fax' && inputField.name === fieldName) {
                if (fieldValue && !numericPhone.match(faxPatterns)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter a valid Fax.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }

            }
            if (fieldName === 'DEANUmber' && inputField.name === fieldName) {
                if (fieldValue && !fieldValue.match(deaPattern)) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter a valid DEA.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                    this.DEA = fieldValue;
                    this.getDEAValidation();
                }
            }
            
            if (fieldName === 'fax' || fieldName === 'phone') {
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord[event.target.name] = fieldValue.replace(/\D/g, '');
            } else {
                this.npiRecord[event.target.name] = fieldValue;
            }


        });
    }
    getDEAValidation() {
        this.DEA_Validation_inprogress = false;
        getDEAStatusVeeva({ DEA: this.DEA, LastName: this.LastName, programName: 'AVEED REMS' })
            .then(result => {
                if (result) {
                    this.DEA_validation = true;
                } else {
                    this.DEA_validation = false;
                }
                this.DEA_Validation_inprogress = true;
            }
            )
            .catch(error => {
            });
    }
    handleSubmitKeyword() {
        if (this.email !== this.confirmEmail) {
            this.showToast('Warning', 'Email and Confirm Email must match', 'warning');
            return;
        }
        this.showLoading = true;
        this.displaySpinner = true;

        this.disabled = true;
        this.showError = false;
        this.errorFields = [];

        const namePatterns = /^[A-Za-z'. -]+$/;

        let updatedNpiRecord = { ...this.npiRecord };
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (inputField.required == true && (inputField.value == '' || inputField.value == null)) {
                this.showError = true;
                this.errorFields.push(inputField.label);
            }
        });

        if (updatedNpiRecord.phone) {
            updatedNpiRecord.phone = updatedNpiRecord.phone.replace(/\D/g, '')
        }


        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (updatedNpiRecord.fax) {
            updatedNpiRecord.fax = updatedNpiRecord.fax.replace(/\D/g, '')

            if(updatedNpiRecord.fax.length < 10 || updatedNpiRecord.fax.length > 10) {
                this.showToast('Error', 'Please Enter a valid fax number', 'Error');
                this.showLoading = false;
                this.displaySpinner = false;
                return;
            }
        }
       if(this.DEA_validation == false && this.DEA_Validation_inprogress == true && this.DEA != null){
            this.showToast('Error', 'Please Enter a valid DEA', 'Error');
            this.showLoading = false;
            this.displaySpinner = false;
            return;
       }

        if(this.preferedContactMethodVlaue == '') {
           
                this.showToast('Error', 'Please select Preferred Method of Communication', 'Error');
                this.showLoading = false;
                this.displaySpinner = false;
                return;
        }
        updatedNpiRecord.participantType = this.participantType;
        updatedNpiRecord.DEA = this.DEA;
        updatedNpiRecord.PMC = this.preferedContactMethodVlaue;


        if (isInputsCorrect) {

            let inputRecords = {
                'recordDetails': JSON.stringify(updatedNpiRecord),
                'programName': this.programName,
                'participantType': this.participantType,
                'profileName': this.profileName,
                'permissionSet': this.permissionSet
            };
            createRecordOnSubmit({ 'inputRecords': inputRecords }).then((eachRec) => {
                if (eachRec?.length > 13) {
                    this.showToast('Success', this.label.SuccessMsg, 'success');
                    this.disabled = false;
                    this.showDetails = false;
                    localStorage.setItem("userId", eachRec);
                    var url = window.location.href;
                     window.open('\signup-confirmation', '_self');
                }
                
                if (eachRec === 'UserPresent') {
                    this.showToast('Error', 'An account with this information already exists. Please log in or contact the AVEED REMS at '+this.label.aveed_phone +' for assistance.', 'error');
                }

                if (eachRec === 'Certified') {
                    this.showToast('Error', 'An account with this information already exists. Please log in or contact the AVEED REMS at '+this.label.aveed_phone +' for assistance.', 'error');
                }

                if (eachRec === 'Disenrolled') {
                    this.showToast('Error', 'Please contact the AVEED REMS at '+this.label.aveed_phone +' for assistance.', 'error');
                }

                if (eachRec === 'Pending') {
                    this.showToast('Error', 'An account with this information already exists. Please contact the AVEED REMS at '+this.label.aveed_phone +' for assistance.', 'error');
                }

                if (eachRec === 'Failed') {
                    this.showToast('Error', this.label.ErrorMsg, 'error');
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


        if (this.npiRecord.fax) {
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