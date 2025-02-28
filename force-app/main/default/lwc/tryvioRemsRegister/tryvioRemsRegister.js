import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import { NavigationMixin } from 'lightning/navigation';
import getNPIStatusVeeva from '@salesforce/apex/TryvioEnrollmentCls.getNPISearch';
import getnpiaccount from '@salesforce/apex/TryvioEnrollmentCls.getaccount';
import insertDataOnSubmit from '@salesforce/apex/TryvioEnrollmentCls.insertDataOnSubmit';
import inValidNPI from '@salesforce/label/c.tryvio_Invalid_NPI';
import tryvioProgramName from '@salesforce/label/c.Tryvio_REMS_Program_Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SuccessMsg from '@salesforce/label/c.Tryvio_SuccessMsg';
import DuplicateEmail from '@salesforce/label/c.Tryvio_Duplicate_email_Error_Msg';
import ValidationMsg from '@salesforce/label/c.ValidationMsg';
import Isvalid_InvalidMsg from '@salesforce/label/c.Isvalid_InvalidMsg';
import duplicateNPI from '@salesforce/label/c.tryvio_Prescriber_Duplicate_NPI';
import NPI_EXIST from '@salesforce/label/c.tryvio_Duplicate_NPI';
import ErrorMsg from '@salesforce/label/c.ErrorMsg';
import customHomeStyles from '@salesforce/resourceUrl/tryvioremsCss';

export default class TryvioRemsRegister extends NavigationMixin(LightningElement) {
    showDetail = false;

    npiRecord = {};
    @api programName = tryvioProgramName;
    @api participantType = 'Prescriber';
    @api npiLabel = 'NPI';
    @api npiPlaceholder = '';
    @api prenpi = '';
    @api name = '';
    iconPrescriber = tryvioIconPrescriber;
    disabled = false;
    secDisabled = false;
    showLoading = false;
    displayInvalidNpi = false;
    displayInvalidNPIINVeeva = false;
    displaySpinner = false;
    searchValue;
    successMsg = SuccessMsg;

    label = {
        DuplicateEmail,
        ValidationMsg,
        Isvalid_InvalidMsg,
        inValidNPI,
        duplicateNPI,
        SuccessMsg,
        ErrorMsg,
        NPI_EXIST
    };
    isvisible = false;
    npiNotinrems = true;
    searchKeyword(event) {
        this.displaySpinner = true;
        this.searchValue = event.target.value;
        let field1 = this.template.querySelector('.search');
        this.displayInvalidNpi = false;
        if ((!this.searchValue || this.searchValue.length === 0 || (this.searchValue && (this.searchValue.length > 10 || !(/^\d+$/.test(this.searchValue)))))) {
            this.displayInvalidNpi = true;
        } else {
            this.valid = true;
            field1.validity = { valid: true };
            field1.setCustomValidity('');
            field1.reportValidity();
        }
        this.displaySpinner = false;
        console.log('search value: ' + this.searchValue);

    }
    async handleSearchKeyword() {
        this.displaySpinner = true;
        this.showLoading = true;
        this.showDetails = false;
        this.errorFields = [];
        this.showMsg = false;
        this.displayInvalidNPIINVeeva = false;
        this.npiRecord = {};
        let field1 = this.template.querySelector('.search');
        if ((!this.searchValue || this.searchValue.length === 0 || (this.searchValue && (this.searchValue.length > 10 || !(/^\d+$/.test(this.searchValue)))))) {
            this.valid = false;
            field1.validity = { valid: false };
            this.showToast('Error', 'Please enter valid NPI to search.', 'error');
            //field1.setCustomValidity('Please enter valid NPI to search.');
            field1.focus();
            field1.blur();
            field1.reportValidity();
        } else if (this.valid) {
            this.valid = true;
            field1.validity = { valid: true };
            field1.setCustomValidity('');
            field1.reportValidity();

            await getnpiaccount({ searchKey: this.searchValue, programName: this.programName })
                .then(result => {
                    console.log('result@@', result);
                    if (result != null) {
                        this.npiNotinrems = false;
                        let accountStatusListForDupliate = ['Certified','Decertified','Deactivated','Cancelled'];
                        if(accountStatusListForDupliate.includes(result.status)) {
                            console.log('entered');
                            this.showMsg = true;
                            this.npiNotinrems = false;
                            this.showToast('Information', this.label.NPI_EXIST, 'info');
                            return;
                        } else if (result.caseid !== "") {
                            console.log('entered first else if');
                            if (result.status == 'Pending' && result.Kastatus == 'Complete') {
                                try {
                                    this[NavigationMixin.Navigate]({
                                        type: 'comm__namedPage',
                                        attributes: {
                                            name: 'Prescriber_Enrollment_Form__c'
                                        }, state: {
                                            c__name: result.firstname + ' ' + result.lastname,
                                            c__npi: this.searchValue
                                        }
                                    });
                                } catch (error) {
                                    console.log('error --' + error.message);
                                }
                            }
                            else if (result.status == 'Pending' && result.Kastatus == 'Draft' && result.attempsmade < 3) {
                                try {

                                    this[NavigationMixin.Navigate]({
                                        type: 'comm__namedPage',
                                        attributes: {
                                            name: 'tryvioRemsKAQuestions__c'
                                        }, state: {
                                            c__name: result.firstname + ' ' + result.lastname,
                                            c__npi: this.searchValue,
                                            c_id: result.caseid
                                        }
                                    });
                                } catch (error) {
                                    console.log('error --' + error.message);
                                }
                            } else if (result.status == 'Pending' && result.attempsmade >= 3) {
                                try {
                                    this[NavigationMixin.Navigate]({
                                        type: 'comm__namedPage',
                                        attributes: {
                                            name: 'tryvioRemsKAFail__c'
                                        }, state: {
                                            c__name: result.firstname + ' ' + result.lastname,
                                            c__npi: this.searchValue,
                                            c_id: result.caseid
                                        }
                                    });
                                } catch (error) {
                                    console.log('error --' + error.message);
                                }
                            }
                        } else if (result.casenotcreated  && (!result.status || result.status == 'Pending' || result.status == '')) {
                            console.log('entered second else if');
                            try {
                                this[NavigationMixin.Navigate]({
                                    type: 'comm__namedPage',
                                    attributes: {
                                        name: 'tryvioRemsKAQuestionsReviewMaterialHCP__c',
                                    }, state: {
                                        c__name: result.firstname + ' ' + result.lastname,
                                        c__npi: this.searchValue,
                                        c__id: result.accountid,
                                        c__record: JSON.stringify(result),
                                        c__navigation: 'registerPage'
                                    }
                                });
                            } catch (error) {
                                console.log('error --' + error.message);
                            }
                        }
                        else {
                            console.log('entered else block');
                            this.npiNotinrems = true;
                        }
                    } else {
                        this.npiNotinrems = true;
                    }
                    

                    this.showLoading = false;
                }).catch(err => {
                    console.error(err);
                });
                if (this.npiNotinrems) {
                try {
                    // this.message = '';
                    this.showMsg = false;
                    const NPI_RESPONSE = await getNPIStatusVeeva({ searchNPIKey: this.searchValue,programName : this.programName, caseRecordTypeDevName : 'Prescriber_enrollment' });
                    console.log('NPI_RESPONSE=>', NPI_RESPONSE);
                    switch (NPI_RESPONSE) {

                        case 'Failed':
                            this.showMsg = true;
                            this.showLoading = false;
                            this.displaySpinner = false;
                            this.displayInvalidNPIINVeeva = true;
                            return;
                        default:
                            let result = JSON.parse(NPI_RESPONSE);
                            console.log('result', result);
                            this.isvisible = true;
                            this.disabled = true;
                            this.npiRecord.firstName = result.FirstName;
                            this.npiRecord.middleName = result.MiddleName;
                            this.npiRecord.lastName = result.LastName;
                            this.npiRecord.email = '';
                            this.npiRecord.confirmEmail = '';
                            this.npiRecord.phone = result.Phonenumber1 ? this.formatPhoneNumber(result.Phonenumber1) : result.Phonenumber1;
                            this.npiRecord.fax = result.fax;
                            this.npiRecord.address1 = result.StreetAddress;
                            this.npiRecord.address2 = result.StreetAddress2;
                            this.npiRecord.city = result.city;
                            this.npiRecord.state = result.State;
                            this.npiRecord.zip = result.postalCode;
                            this.npiRecord.npi = this.searchValue;
                            this.npiRecord.name = result.FirstName + ' ' + result.LastName;
                    }
                } catch (e) {
                    console.log('e->', e);
                    this.showToast('Error', e.message, 'error');
                }
            }
                console.log('npiNotinrems:::::', this.npiNotinrems);
        }
        this.showLoading = false;
        this.displaySpinner = false;
    }
    /**handleConfirmEmail(event) {
        let confirmEmail = event.target.value;
        const fieldName = event.target.name;
        let email = this.npiRecord.email;
        console.log('confirmEmail', confirmEmail);
        console.log('email', email);
        // let inputField = this.template.querySelector('.confirmEmail');
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {

            const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

            if (fieldName === 'confirmEmail' && inputField.name === fieldName) {
                if (confirmEmail !== email && !confirmEmail.match(emailPattern)) {

                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter same email address.');
                    inputField.reportValidity();
                    this.npiRecord.confirmEmail = null;
                } else if (confirmEmail === email && confirmEmail.match(emailPattern)) {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                    this.npiRecord.confirmEmail = confirmEmail;
                }
            }
        });
    }**/
    handleChange(event) {
        this.populateFields(event);
        this.validateInputs(event, false, true);
    }

    validateNPI(event) {

    }

    validateRequiredFields(event) {
        this.showLoading = true;
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
        this.showLoading = false;
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
    formatPhoneNumber(phoneNumber) {
        const regex = /^(\d{3})(\d{3})(\d{4})$/;
        const parts = phoneNumber.match(regex);
        if (parts) {
            return `(${parts[1]}) ${parts[2]}-${parts[3]}`;
        }
        return phoneNumber;
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
    connectedCallback() {
        loadStyle(this, customStyles)
            .then(() => {
                console.log('Styles loaded successfully');
            })
            .catch(error => {
                console.error('Error loading the styles', error);
            });
    }
    handleContinue() {
        this.isvisible = true;
    }
    handleNpiChange(event) {

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
            default:
        }  

    }
    navigateToReviewMaterials(event) {
        console.log('Inside submit');
        this.showLoading = true;
        this.displaySpinner = true;
        this.secDisabled = true;
        this.showError = false;
        this.errorFields = [];
        let validateRequiredFields = this.validateRequiredFields(event, true, false);
        console.log('validateRequiredFields:::', validateRequiredFields);
        if(validateRequiredFields) {
            let validateInputs = this.validateInputs(event, true, false);
            console.log('validateInputs:::', validateInputs);
            if(validateInputs) {
                let updatedNpiRecord = { ...this.npiRecord };
                if (updatedNpiRecord.phone) {
                    updatedNpiRecord.phone = updatedNpiRecord.phone.replace(/\D/g, '')
                }
                let inputRecords = {
                    'recordDetails': JSON.stringify(updatedNpiRecord),
                    'programName': this.programName,
                    'participantType': this.participantType,
                    'casecreation': 'prescribercase'
                };
                console.log('inputRecords=>', inputRecords);
                insertDataOnSubmit({ 'inputRecords': inputRecords }).then((eachRec) => {
                    console.log(eachRec)
                    if (eachRec?.length > 15) {
                        //this.showToast('Success', this.successMsg, 'success');
                        try {
                            event.preventDefault();
                            event.stopPropagation();
                            this[NavigationMixin.Navigate]({
                                type: 'comm__namedPage',
                                attributes: {
                                    name: 'tryvioRemsKAQuestionsReviewMaterialHCP__c',
                                }, state: {
                                    c__name: updatedNpiRecord.name,
                                    c__npi: updatedNpiRecord.npi,
                                    c__id: eachRec,
                                    c__record: JSON.stringify(updatedNpiRecord),
                                    c__navigation: 'registerPage'
                                }
                            });
                        } catch (error) {
                            console.log('error --' + error.message);
                        }
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
                    console.log('erroron submit --' + error.message);
                    this.showToast('Error', JSON.stringify(error.message), 'error');
                });
            }
        }  
        this.showLoading = false;
        this.displaySpinner = false;      
    

    }

}