import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPharmacy from '@salesforce/resourceUrl/tryvioIconPharmacy';
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPickListValues from '@salesforce/apex/TryvioEnrollmentCls.getPicklistFieldValues';
import insertDataOnSubmit from '@salesforce/apex/TryvioEnrollmentCls.insertDataOnSubmit';
import SuccessMsg from '@salesforce/label/c.Tryvio_SuccessMsg';
import DuplicateEmail from '@salesforce/label/c.Tryvio_Duplicate_email_Error_Msg';
import ValidationMsg from '@salesforce/label/c.ValidationMsg';
import Isvalid_InvalidMsg from '@salesforce/label/c.Isvalid_InvalidMsg';
import inValidNPI from '@salesforce/label/c.tryvio_Invalid_NPI';
import duplicateNPI from '@salesforce/label/c.tryvio_Duplicate_NPI';
import ErrorMsg from '@salesforce/label/c.ErrorMsg';
export default class TryvioRemsOppEnrollmentForm extends NavigationMixin(LightningElement){   
    iconPharmacy = tryvioIconPharmacy;
    selectedPharmacyType = '';
    showDetail = false;
    existingAcc;
    npiRecord ={};
    arRecord = {};
    showModal = false;
    showOtherCredetial= false;
    participantType ='Outpatient Pharmacy';
    signatureData='';
    successMsg = SuccessMsg;
    label = {
        DuplicateEmail,
        ValidationMsg,
        Isvalid_InvalidMsg,
        inValidNPI,
        duplicateNPI,
        SuccessMsg,
        ErrorMsg
    };
    pharmacyTypeOptions = [
        { label: 'Retail', value: 'Retail' },
        { label: 'Specialty', value: 'Speciality' },
    ];

    credentialsOptions = [
        { label: 'RPh', value: 'R.Ph' },
        { label: 'PharmD', value: 'PharmD' },
        { label: 'BCPS', value: 'BCPS' },
        { label: 'Other (please specify)', value: 'Other' },
    ];
    preferredContactOptions = [
        { label: 'Office Phone', value: 'Office Phone' },
        { label: 'Email', value: 'Email' },
        { label: 'Mobile Phone', value: 'Mobile Phone' },
        { label: 'Text Message', value: 'Text Message' },
    ];

    selectedState = '';
    stateOptions = [];
    arJobTitleOptions = [];
    showError= false;
    errorFields = [];
    isloading = true;
    showOtherJob = false;

    handleNpiResult(event){
        console.log('handleNpiResult:::');
        console.log('In parent '+ JSON.stringify(event.detail));
        let accountStatusListForDupliate = ['Certified','Certified - On Hold','Pending','Decertified','Deactivated','Cancelled'];
        if(event.detail.accountStatus && accountStatusListForDupliate.includes(event.detail.accountStatus)) {
            this.showToast('Information', this.label.duplicateNPI, 'info');
        } else if(event.detail.vevaStatus == 'Failed') {
            this.showDetail = false;
        } else {
            const result = event.detail.response;
            this.showDetail = true;
            this.npiRecord.phone = result.Phonenumber1 ? this.formatPhoneNumber(result.Phonenumber1):result.Phonenumber1;
            this.npiRecord.address1 =result.StreetAddress;
            this.npiRecord.city=result.city;
            this.npiRecord.state=result.State != null && result.State != '' ? result.State : 'AK';;
            this.npiRecord.zip=result.postalCode;
            this.npiRecord.npi = result.npi;
            this.npiRecord.name = result.PharmacyName;
        }
        
    }

    getPickListValues(){
        getPickListValues()
        .then((pickListVal) => {
            console.log('returndata >>',pickListVal);
            console.log(pickListVal.US_WSREMS__State__c);
            var stateOptionList = pickListVal.US_WSREMS__State__c;
            var arJobTitleOptionList = pickListVal.US_WSREMS__Participant_Title__c;

            // this.selectOptions.push(option);
            let stateOptionArr = ['AA','AE','AP'];
            for (var i in stateOptionList) {
                if(!stateOptionArr.includes(stateOptionList[i])) {
                    const option = {
                        label: i,
                        value: stateOptionList[i]
                    };
                    this.stateOptions = [...this.stateOptions, option];
                }
            }
            for (var i in arJobTitleOptionList) {
                if(i == 'Hospital Pharmacist' || i == 'Head of Pharmacy and Therapeutics (P&T) committee'
                || i == 'Other') {
                    const option = {
                        label: i == 'Other' ? i + ' (Please Specify)' : i,
                        value: arJobTitleOptionList[i] 
                    };
                    this.arJobTitleOptions = [...this.arJobTitleOptions, option];
                }
            }
            console.log('this.stateOptions=>', this.stateOptions);
        })
        .catch((error) => {
            console.log('In connected call back error....');
            // This way you are not to going to see [object Object]
            console.log('Error is', error);
        });
    }

    connectedCallback() {
         loadStyle(this, customStyles)
        .then(() => {
            console.log('Styles loaded successfully');
            this.isloading = false;
        })
        .catch(error => {
            console.error('Error loading the styles', error);
        }); 
        this.getPickListValues();
    }   

    handleSignatureCompleted(event) {
        // Call the function you need when the event is triggered
        this.signatureData = event.detail.signdata;
        console.log('this.signa' ,this.signatureData );
    }
    handleClearSignature(){
        this.template.querySelector('c-tryvio-sign-pad').handleClear();
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
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Home'
                }
            });
        }
    }
    handleContinue() {
        this.template.querySelector('.FormDetails').classList.remove('slds-hide');
    }
    handleSubmit(event) {
        this.disabled = true;
        let validateRequiredFields = this.validateRequiredFields(event, true, false);
        if(validateRequiredFields) {
            let validateInputs = this.validateInputs(event, true, false);
            if(validateInputs) {
                this.template.querySelector('c-tryvio-sign-pad').handleSaveSignature();
                let validateSignature = this.validateSignature(event);
                if(validateSignature) {
                    this.isloading = true;
                    let updatedNpiRecord = {...this.npiRecord};
                    updatedNpiRecord.participantType = this.participantType;
                    updatedNpiRecord.AR = this.arRecord;
                    console.log(JSON.stringify(this.arRecord));
                    console.log(JSON.stringify(this.npiRecord),'updatedNpiRecord '+JSON.stringify(updatedNpiRecord));
                    let inputRecords = {
                        'recordDetails': JSON.stringify(updatedNpiRecord),
                        'programName': 'TRYVIO REMS',
                        'participantType': this.participantType,
                        'signatureData' : this.signatureData,
                        'arDetails' : JSON.stringify(this.arRecord),
                        'formType' : 'OPP'
                    };       
                    console.log('Sending data to apex' + JSON.stringify(inputRecords));
                    insertDataOnSubmit({ 'inputRecords': inputRecords }).then((eachRec) => {
                        console.log(eachRec)
                        if (eachRec?.length > 15) {
                            //this.showToast('Success', this.successMsg, 'success');
                            this.disabled = false;
                            this.showDetails = false;
                            localStorage.setItem("userId", eachRec);
                            this.redirectToSuccessPage(event, eachRec);
                        }
                        if (eachRec === 'duplicateNPI') {
                            this.showToast('Error', this.label.duplicateNPI, 'error');
                        }
                        this.isloading = false;
                    }).catch(error => {
                        this.disabled = true;
                        this.isloading = false;
                        this.showToast('Error', JSON.stringify(error.body.message), 'error');
                    });
                }
            }
        } 
    }
    redirectToSuccessPage(event, eachRec) {
        let location = window.location.href;
        location = location.substring(0, location.indexOf('/s/'))+'/s/tryvioremsoppenrollmentformsuccess?id='+eachRec;
        window.open(location,'_self');   
    }

    handleChange(event) {
        this.populateFields(event);
        this.validateInputs(event, false, true);
        this.handleDependentFields(event);
    }

    handleDependentFields(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value;  
        console.log(fieldName+' =>> '+fieldValue)
        if(fieldName == 'credentials' ){
            this.arRecord.credentials = event.detail.value;
            if(!this.npiRecord.AR) {
                this.npiRecord.AR = {};
            }
            this.npiRecord.AR.credentials = event.detail.value;
            if(fieldValue == 'Other'){
                this.showOtherCredetial = true;
            }else{
                this.showOtherCredetial = false;
            }
        }
        else if(fieldName == 'pharmacyType'){
            this.selectedPharmacyType = event.detail.value;
            this.npiRecord.type = this.selectedPharmacyType;
        } else if(fieldName == 'arjobtitle' ){
            this.showOtherJob = false;
            if(fieldValue == 'Other'){
                this.showOtherJob = true;
            }
        }
    }

    validateRequiredFields(event) {
        this.isloading = true;
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
        this.isloading = false;
        return isValid;
    }

    validateSignature(event) {
        this.isloading = true;
        let isSignatureData = true;
        if (this.signatureData == null || this.signatureData == '') {
            this.isloading = false;
            isSignatureData = false;
            console.log('inside::');
            this.showToast('Error', 'Please Sign to continue', 'Error');
            
        }
        this.isloading = false;
        return isSignatureData;
    }

    validateInputs(event, isValidateALL, isFieldCheck) {
        try{
            const phonePattern = /^(\s*\d\s*){10}$/;
            const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const namePatterns = /^[A-Za-z'. -]+$/;
            const zipPatterns = /^\d{5}(-\d{4})?$/;
            const faxPatterns = /^(\s*\d\s*){10}$/;
            const extPatterns = /^[0-9]{1,10}$/;
            let isValid = true;
            let inputFields = this.template.querySelectorAll('.validate');
            inputFields.forEach(inputField => {
                const fieldName = isFieldCheck ? event.target.name : inputField.name;
                let fieldValue = isFieldCheck ? event.target.value : inputField.value;
                console.log('fieldName:::',fieldName);
                let numericPhone = fieldValue ? fieldValue.replace(/\D/g, '').replace('-') : fieldValue;
                if(isValidateALL || (isFieldCheck && fieldName && inputField.name === fieldName)) {

                    if (fieldName === 'email') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(!fieldValue.match(emailPattern)) { 
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid email address.');
                        }
                        inputField.reportValidity();
                    } 
                    
                    if ((fieldName === 'offPhone' ||  fieldName === 'oPhone' || fieldName === 'offPhone')) {
                            inputField.classList.remove('slds-has-error');
                            inputField.setCustomValidity('');
                            if(!numericPhone.match(phonePattern)) {
                                isValid = false;
                                inputField.classList.add('slds-has-error');
                                inputField.setCustomValidity('Please enter a valid Phone Number.');
                            }
                            inputField.reportValidity();
                    }                     
                    
                    if(fieldName === 'zip') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(!fieldValue.match(zipPatterns)){
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Zip can be 5 or 9 digits.');
                        }
                        inputField.reportValidity();
                    }
                    if(fieldName === 'ext' ||  fieldName == 'extAR') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(extPatterns)){
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter valid Ext.');
                        }
                        inputField.reportValidity();
                    }
                    /*if (fieldName === 'name') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(!fieldValue.match(namePatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Name.');
                        }
                        inputField.reportValidity();
                    } */
                    if (fieldName === 'lastName') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(!fieldValue.match(namePatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Name.');
                        }
                        inputField.reportValidity();
                    } 
                    if (fieldName === 'fname') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(!fieldValue.match(namePatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Name.');
                        }
                        inputField.reportValidity();
                    } 
                    /*if (fieldName === 'mi') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(namePatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Name.');
                        } 
                        inputField.reportValidity();
                    }*/
                    if ((fieldName === 'fax' || fieldName === 'faxAR' )&& inputField.name === fieldName ) { 
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !numericPhone.match(faxPatterns)) {
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
        } catch(e){
            console.log('error '+e.message);
        }
    }
    populateFields(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value;
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        switch(fieldName) {
            case 'type':
             this.npiRecord.type = fieldValue;
             break;
            case 'name':
             this.npiRecord.name = fieldValue;
             break;
            case 'address1':
              this.npiRecord.address1 = fieldValue;
              break;
            case 'address2':
                this.npiRecord.address2 = fieldValue;
                break;
            case 'city':
                this.npiRecord.city = fieldValue;
                break;
            case 'state':
                this.npiRecord.state = fieldValue;
                break;
            case 'zip':
                this.npiRecord.zip = fieldValue;
                break;
            case 'offPhone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord.phone = fieldValue;
                break;
            case 'ext':
                this.npiRecord.ext = fieldValue;
                break;
            case 'fax':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord.fax = fieldValue;
                break;
            case 'fname':
                this.arRecord.firstName = fieldValue;
                break;
            case 'mi':
                this.arRecord.mi = fieldValue;
                break;
            case 'lastName':
                this.arRecord.lastName = fieldValue;
                break;
            case 'arjobtitle':
                this.arRecord.title = fieldValue;
                break;
            case 'arothertitle':
                this.arRecord.othertitle = fieldValue;
                break;
            case 'credentials':
                this.arRecord.credentials = fieldValue;
                break;
            case 'othercredentials':
                this.arRecord.othercredentials = fieldValue;
                break;
            case 'oPhone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.arRecord.offPhone = fieldValue;
                break;
            case 'extAR':
                this.arRecord.ext = fieldValue;
                break;
            case 'faxAR':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.arRecord.fax = fieldValue;
                break;
            case 'email':
                this.arRecord.email = fieldValue;
                break;
            case 'phoneM':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.arRecord.mPhone = fieldValue;
                break;
            case 'preferredContact':
                this.arRecord.preferredContactMethod = fieldValue;
                break;
              default:
        }  

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
    
}