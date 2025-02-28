import { LightningElement, track, api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import getPickListValues from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getPicklistFieldValues';
import getARrecord from '@salesforce/apex/xiaflex_ManagePharmacies.getARrecord';
import getPharmaAccount from '@salesforce/apex/xiaflex_ManagePharmacies.getPharmaAccountDetails';
import insertArEditEnroll from '@salesforce/apex/xiaflex_ManagePharmacies.insertArEditEnroll';

export default class Xiaflex_AR_editReenroll extends LightningElement {

    displayOthers = false;
    displaySpinner = false;
    reEnroll = false;
    showModalContent = false;
    signatureData = '';
    @track arRecord = {};
    @track stateOptions = [];
    @track pharmaRecord = {};
    @api accType;
    @api pharmaAcc;
    reEnrollmentDate;

    get contactOptions(){
        return [
            {label: 'Email', value: 'Email'},
            {label: 'Fax', value: 'Fax'},
        ];
    }

    get functionOptions(){
        if (this.accType == 'HCSMDP') {
            return [
                { label: 'Edit', value: 'edit' },
            ];
        } else {
            const today = new Date();
            const timeDiff = this.reEnrollmentDate - today;
            const daysDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));
            if (daysDiff < 90) {
                return [
                    { label: 'Edit', value: 'edit' },
                    { label: 'Re-Enroll', value: 'reenroll' },
                ];
            }else{
                return [
                    { label: 'Edit', value: 'edit' }
                ];
            }
        }

    }

    get salutation(){
        return [
            {label: 'Dr', value: 'Dr'},
            {label: 'Mr', value: 'Mr'},
            {label: 'Ms', value: 'Ms'},
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
    
    get hcsType() {
        return [
            { label: 'Independent Practice', value: 'Independent practice' },
            { label: 'Group Practice', value: 'Group practice' },
            { label: 'Institution Central Purchasing (owned or under control of hospital system)', value: 'Institution Central Purchasing (owned or under control of hospital system)' },
            { label: 'Institution Direct Purchasing (owned or under control of hospital system)', value: 'Institution Direct Purchasing (owned or under control of hospital system)' },
            { label: 'Pharmacy', value: 'Pharmacy' },
        ];
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.getArRecord();
        this.getPickListValues();
        let pharmaId = sessionStorage.getItem('pharmaId');
        this.getHcsRecord(pharmaId);
        if(this.accType != null && this.accType != undefined && this.accType.length > 0){
            this.showModalContent = true;
        }
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
                    console.log('Error=>', error)
                })
                
    }

    getHcsRecord(accId){
        this.displaySpinner = true;
        getPharmaAccount({accId: accId})
        .then(result => {
                    if (result != null && result != undefined) {
                        var prescriberAcc = result.prescriber;
                        this.pharmaRecord.Id = result.pharma[0].Id;
                        this.pharmaRecord.name = result.pharma[0].Name;
                        this.pharmaRecord.status = result.pharma[0].US_WSREMS__Status__c;
                        this.pharmaRecord.enrollId = result.pharma[0].US_WSREMS__REMS_ID__c;
                        this.pharmaRecord.dea = result.pharma[0].US_WSREMS__DEA__c;
                        this.pharmaRecord.npi = result.pharma[0].US_WSREMS__National_Provider_Identifier__c;
                        this.pharmaRecord.hin = result.pharma[0].US_WSREMS__HIN__c;
                        this.pharmaRecord.ncpdp = result.pharma[0].US_WSREMS__NCPDP__c;
                        this.pharmaRecord.phone = result.pharma[0].Phone != null && result.pharma[0].Phone != '' ? this.formatPhoneNumber(result.pharma[0].Phone) : '';
                        this.pharmaRecord.fax = result.pharma[0].Fax != null && result.pharma[0].Fax != '' ? this.formatPhoneNumber(result.pharma[0].Fax) : '';
                        this.pharmaRecord.hcsType = result.pharma[0].US_WSREMS__Healthcare_Setting_Type__c;
                        this.pharmaRecord.settingType = result.pharma[0].US_WSREMS__Healthcare_Setting_Type__c;
                        this.pharmaRecord.address1 = result.pharma[0].US_WSREMS__Address_Line_1__c;
                        this.pharmaRecord.address2 = result.pharma[0].US_WSREMS__Address_Line_2__c;
                        this.pharmaRecord.city = result.pharma[0].US_WSREMS__City__c;
                        this.pharmaRecord.state = result.pharma[0].US_WSREMS__State__c != null ? result.pharma[0].US_WSREMS__State__c : None;
                        this.pharmaRecord.zipCode = result.pharma[0].US_WSREMS__Zip__c;
                        if(result.pharma[0].US_WSREMS__Recertification_Due_Date__c){
                            this.reEnrollmentDate = this.convertISOToDateFormat(result.pharma[0].US_WSREMS__Recertification_Due_Date__c);
                        }
                    }
                    this.displaySpinner = false;
                })
                .catch(error => {
                    this.displaySpinner = false;
                    console.log('Error=>', error)
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
                    console.log('Error is', error);
                });
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

    handlePharmaChange(event){
        const fieldName = event.target.name;
        let fieldValue = event.target.value;
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        this.validateInputs(event);
        if (fieldName === 'fax' || fieldName === 'phone') {
            fieldValue = this.formatPhoneNumber(numericPhone);
            this.pharmaRecord[event.target.name] = fieldValue;
        } else {
            this.pharmaRecord[event.target.name] = fieldValue;
        }
    }

    async validateInputs(event) {

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
            const deaPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9}$/;
            const ncpdpPattern = /^[0-9]{7}$/;

            if (fieldName === 'email'&& inputField.name === fieldName && !fieldValue.match(emailPattern)) {
               
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

    handleFunction(event){
        if(event.target.value == 'reenroll'){
            this.reEnroll = true;
        } else{
            this.reEnroll = false;
        }
    }

    handleSignatureCompleted(event) {
        this.signatureData = event.detail.signdata;
    }
    handleClear(){
        this.template.querySelector('c-tryvio-sign-pad').handleClear();
    }

    handleSubmit() {
        let isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if(this.pharmaRecord.npi == null  &&  this.pharmaRecord.hin == null && this.pharmaRecord.dea == null && this.pharmaRecord.ncpdp == null ) {
            this.showToast('Error', 'Please provide at least one identifier', 'Error');
            this.showLoading = false;
            isInputsCorrect = false;
            return;
        }
        if(this.pharmaRecord.state == 'None'){
            this.showToast('Error!','Please select state value', 'error');
            isInputsCorrect = false;
            return;
        }
        if(this.reEnroll){
            this.template.querySelector('c-tryvio-sign-pad').handleSaveSignature();
            if(this.signatureData == null){
                this.showToast('Error', 'Please Sign to continue', 'Error');
                this.showLoading = false;
                return;
            }
        }
        if (isInputsCorrect) {    
            let inputRecords = {
                'arRecord': JSON.stringify(this.arRecord),
                'hcsRecord': JSON.stringify(this.pharmaRecord),
                'reenroll': JSON.stringify(this.reEnroll),
                'signatureData': this.signatureData,
                'programName': 'Xiaflex'
            };
            this.displaySpinner = true;
            insertArEditEnroll({'inputRecords': inputRecords}).then((result) => {
                if(this.showModalContent){
                    window.location.href = 'manage-hcs-detail';
                } else{
                    window.location.href = 'manage-hcs';
                }
                this.displaySpinner = false;
            }).catch(error => {
                this.showToast('Error', JSON.stringify(error.body.message), 'error');
                this.displaySpinner = false;
            });
        } else{ 
            this.showToast('Error!','Please fill the Required Fields', 'error');
        }
    }

    handleCancel(){
        if(this.showModalContent){
             this.dispatchEvent(new CustomEvent('closemodal', {
                detail: {
                    message: ''
                }
            }));
        } else{
            window.location.href = 'manage-hcs';
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

    convertISOToDateFormat(isoDateTime) {
        // Create a new Date object from the ISO date-time string
        const date = new Date(isoDateTime);

        if (isNaN(date)) {
        }
        else {
            //date.setFullYear(date.getFullYear() + 2);
            // Extract the day, month, and year
            const day = String(date.getUTCDate()).padStart(2, '0');
            const month = String(date.getUTCMonth() + 1).padStart(2, '0'); // Months are zero-indexed
            const year = date.getUTCFullYear();
            return new Date(year,month,day);
        }
    }


}