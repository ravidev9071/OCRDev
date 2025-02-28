import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import { NavigationMixin } from 'lightning/navigation';
import getPickListValues from '@salesforce/apex/TryvioEnrollmentCls.getPicklistFieldValues';
import insertDataOnSubmit from '@salesforce/apex/TryvioEnrollmentCls.insertDataOnSubmit';
import SuccessMsg from '@salesforce/label/c.Tryvio_SuccessMsg';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ValidationMsg from '@salesforce/label/c.ValidationMsg';
import ErrorMsg from '@salesforce/label/c.ErrorMsg';
import DuplicateEmail from '@salesforce/label/c.Tryvio_Duplicate_email_Error_Msg';
import Isvalid_InvalidMsg from '@salesforce/label/c.Isvalid_InvalidMsg';
import inValidNPI from '@salesforce/label/c.tryvio_Invalid_NPI';
import duplicateNPI from '@salesforce/label/c.tryvio_Duplicate_NPI';
import tryvioProgramName from '@salesforce/label/c.Tryvio_REMS_Program_Name';
import { CurrentPageReference } from 'lightning/navigation';
import getnpiaccount from '@salesforce/apex/TryvioEnrollmentCls.getaccount';
export default class TryvioPrescriberEnrollmentFormChild extends NavigationMixin(LightningElement) {
    preferredContactOptions = [
        { label: 'Office Phone', value: 'Office Phone' },
        { label: 'Email', value: 'Email' },
        { label: 'Mobile Phone', value: 'Mobile Phone' },
        { label: 'Text Message', value: 'Text Message' },
    ];
    specialityOptions = [
        { label: 'Nephrology', value: 'Nephrology' },
        { label: 'Cardiology', value: 'Cardiology' },
        { label: 'Endocrinology', value: 'Endocrinology' },
        { label: 'Internist', value: 'Internist' },
        { label: 'Other (please specify)', value: 'Other' },
    ];
    pdOptions = [
        { label: 'MD', value: 'MD' },
        { label: 'DO', value: 'DO' },
        { label: 'PA', value: 'PA' },
        { label: 'NP', value: 'NP' },
    ];
    selectedState = '';
    stateOptions = [];
    showError = false;
    errorFields = [];
    showModal = false;
    showOtherSpecialty = false;
    showOthersignpad = false;
    signatureData = '';
    dispsignatureData = '';
    Accountid;
    displaySpinner=false;
    @track npidisable=false;
    @track emaildisable=false;
    label = {
        DuplicateEmail,
        ValidationMsg,
        Isvalid_InvalidMsg,
        inValidNPI,
        duplicateNPI,
        SuccessMsg,
        ErrorMsg
    };
    successMsg = SuccessMsg;
    presname;
    presnpi;
    recordId;
    @track npiRecord = {};
    @track primaryCon = {};
    @track secCon = {};
    @api programName = tryvioProgramName;
    @api participantType = 'Prescriber';
    @track isloading=false;

    @wire(CurrentPageReference)
    CurrentPageReference(pageRef) {
        if (pageRef) {
            this.presname = pageRef.state.c__name;
            this.presnpi = pageRef.state.c__npi;
            this.recordId = pageRef.state.c_id;
            console.log('@@@@@@@@@@presname', this.presname);

        }
    }

    async getnpidata() {
        this.isloading=true;
        try{
            let result=await getnpiaccount({ searchKey: this.presnpi, programName: this.programName })
            this.npiRecord.firstName = result.firstname;
            this.npiRecord.middleName = result.middlename;
            this.npiRecord.lastName = result.lastname;
            this.npiRecord.email = result.email;
            this.npiRecord.fax = result.fax;
            this.npiRecord.address1 = result.address1;
            this.npiRecord.address2 = result.address2;
            this.npiRecord.city = result.city;
            this.npiRecord.state = result.State != null && result.State != '' ? result.State : 'None';
            this.npiRecord.zip = result.zip;
            this.npiRecord.npi = result.npi;
            this.npiRecord.email = result.email;
            this.npiRecord.specialty = result.specialty;
            this.npiRecord.otherSpecialty = result.other;
            this.npiRecord.offPhone = result.officePhone;
            this.npiRecord.phone = result.mobilePhone;
            this.npiRecord.fax = result.fax;
            this.npiRecord.ext = result.ext;
            this.npiRecord.proffDesig = result.professionalDesignation;
            this.npiRecord.preferredContactMethod = result.preferredContactMethod;
            this.npiRecord.officePractice = result.otherPractice;
            this.Accountid = result.accountid;
            if(this.npiRecord.phone) {
                this.npiRecord.phone = this.formatPhoneNumber(this.npiRecord.phone);
            }
            if(this.npiRecord.offPhone) {
                this.npiRecord.offPhone = this.formatPhoneNumber(this.npiRecord.offPhone);
            }
            if(this.npiRecord.fax) {
                this.npiRecord.fax = this.formatPhoneNumber(this.npiRecord.fax);
            }
            if(this.npiRecord.npi){
                this.npidisable=true;
            }
            if(this.npiRecord.email){
                this.emaildisable=true;
            }
                
        }catch(error){
            console.error=error;

        } finally{
            this.isloading=false;
        }
    }
    
   async connectedCallback() {
        loadStyle(this, customStyles);
        await this.getnpidata();
        this.getPickListValues();
    }
    signImagedata(event) {
        this.ImageData = event.detail.signdata;
    }

    handleSignatureCompleted(event) {
        // Call the function you need when the event is triggered
        this.signatureData = event.detail.signdata;
    }
    handledispenseSignatureCompleted(event){
        this.dispsignatureData = event.detail.signdata;
    }
    handleClearSignature() {
        if(this.showOthersignpad) {
            this.template.querySelector('c-tryvio-sign-pad').handleClear();
        }
        this.template.querySelector('c-tryvio-sign-pad2').handleClear();
    }

    handleSubmit(event) {
        this.showLoading = true;
        this.displaySpinner = true;
        this.disabled = true;
        this.showError = false;
        this.errorFields = [];

        let validateRequiredFields = this.validateRequiredFields(event, true, false);
        console.log('validateRequiredFields:::', validateRequiredFields);
        if(validateRequiredFields) {
            let validateInputs = this.validateInputs(event, true, false);
            console.log('validateInputs:::', validateInputs);
            if(validateInputs) {
                this.template.querySelector('c-tryvio-sign-pad2').handleSaveSignature();
                if(this.showOthersignpad){
                    console.log('inside dispense signature');
                    this.template.querySelector('c-tryvio-sign-pad').handleSaveSignature();
                }
                let validateSignature = this.validateSignature(event);
                console.log('validateSignature:::', validateSignature);
                if(validateSignature) {
                    this.isloading = true;
                    let updatedNpiRecord = {...this.npiRecord};
                    
                    updatedNpiRecord.participantType = this.participantType;
                    if(this.showOthersignpad && (this.dispsignatureData !== null && this.dispsignatureData !== '')){
                        updatedNpiRecord.dispensesign=true;
                    }
                    console.log('dispensign',updatedNpiRecord.dispensesign);
        
                    console.log(JSON.stringify(this.npiRecord), 'updatedNpiRecord ' + JSON.stringify(updatedNpiRecord));
                    console.log('Accountid@@', this.Accountid);
                    let inputRecords = {
                        'recordDetails': JSON.stringify(updatedNpiRecord),
                        'programName': 'TRYVIO REMS',
                        'participantType': this.participantType,
                        'casecreation': 'Prescriberenrollmentcase',
                        'AccountId': this.Accountid,
                        'signatureData': this.signatureData,
                        'dispenssignatureData':this.dispsignatureData
                    };
                    console.log('Sending data to apex' + JSON.stringify(inputRecords));

                    insertDataOnSubmit({ 'inputRecords': inputRecords }).then((eachRec) => {
                        console.log(eachRec)
                        if (eachRec?.length > 15) {
                            this.disabled = false;
                            this.showDetails = false;
                            try {
                                    event.preventDefault();
                                    event.stopPropagation();
                                    this[NavigationMixin.Navigate]({
                                        type: 'comm__namedPage',
                                        attributes: {
                                            name: 'Prescriber_Enrollment_Form_Success__c'
                                        },state: {
                                            c__name: this.presname,
                                            c__npi: this.presnpi,
                                            c__id : eachRec
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
                        console.log('error::::', JSON.stringify(error));
                        console.log('error::::', JSON.stringify(error.body.message));
                        this.disabled = true;
                        this.showLoading = false;
                        this.displaySpinner = false;
                        this.showToast('Error', JSON.stringify(error.body.message), 'error');
                    });
                }
            }
        }
        this.showLoading = false;
        this.displaySpinner = false;
    }
    handleCancel() {
        this.showModal = true;
        // Logic to handle cancel action
    }
    handleCancelModal(event) {
        if (event.target.name == 'cancel') {
            this.showModal = false;
        }
        else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Home'
                }
            });
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
    getPickListValues() {
        getPickListValues()
            .then((pickListVal) => {
                console.log('returndata >>', pickListVal);
                console.log(pickListVal.US_WSREMS__State__c);
                var stateOptionList = pickListVal.US_WSREMS__State__c;

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
                console.log('this.stateOptions=>', this.stateOptions);
            })
            .catch((error) => {
                console.log('In connected call back error....');
                // This way you are not to going to see [object Object]
                console.log('Error is', error);
            });
    }
    handleChange(event) {
        this.populateFields(event);
        this.validateInputs(event, false, true);
        this.handleDependentFields(event);
    }
    handleDependentFields(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value;
        console.log(fieldName + ' =>> ' + fieldValue);
        if (fieldName == 'specialty') {
            if (fieldValue == 'Other') {
                this.showOtherSpecialty = true;
            } else {
                this.showOtherSpecialty = false;
                this.npiRecord.otherSpecialty = '';
            }
        }
        if (fieldName == 'sig') {
            if(!event.target.checked) {
                this.template.querySelector('c-tryvio-sign-pad').handleClear();
            }
            this.showOthersignpad = event.target.checked;
            console.log('this.showOthersignpad',this.showOthersignpad);
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
        if ((this.signatureData == null || this.signatureData == '') || (this.showOthersignpad && (this.dispsignatureData == null || this.dispsignatureData == ''))) {
            this.isloading = false;
            isSignatureData = false;
            console.log('inside::');
            this.showToast('Error', 'Please Sign to continue', 'Error');
            
        }
        return isSignatureData;
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

                console.log('before inputField.name::', inputField.name);
                console.log('before event.target.name::', event.target.name);

                if(isValidateALL || (isFieldCheck && fieldName && inputField.name === fieldName)) {

                    console.log('after inputField.name::', inputField.name);
                    console.log('after event.target.name::', event.target.name);
                
                    
                    if(fieldName === 'zip' &&  fieldValue  &&  fieldValue != undefined) {
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
                    
                    if (fieldName === 'zip') {
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
                    
                    if ((fieldName == 'primaryoPhone' || fieldName == 'oPhone' || fieldName == 'secondaryoPhone' || fieldName == 'phoneM')) {
                        console.log('fieldName23333::::', fieldName);
                        console.log('fieldName23333::::', fieldValue);
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
                }
            }
            return isValid;
        }
        catch (e) {
            console.log('error ' + e.message);
        }
    }
    populateFields(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value;
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        switch (fieldName) {
            case 'npi':
                this.npiRecord.npi = fieldValue;
                break;
            case 'firstName':
                this.npiRecord.firstName = fieldValue;
                break;
            case 'mi':
                this.npiRecord.middleName = fieldValue;
                break;
            case 'lastName':
                this.npiRecord.lastName = fieldValue;
                break;
            case 'specialty':
                this.npiRecord.specialty = fieldValue;
                break;
            case 'SpecialityOther':
                this.npiRecord.otherSpecialty = fieldValue;
                break;
            case 'PD':
                this.npiRecord.proffDesig = fieldValue;
                break;
            case 'OfficePractice':
                this.npiRecord.officePractice = fieldValue;
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
            case 'preferredContact':
                this.npiRecord.preferredContactMethod = fieldValue;
                break;
            case 'oPhone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord.offPhone = fieldValue;
                break;
            case 'ext':
                this.npiRecord.ext = fieldValue;
                break;
            case 'fax':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord.fax = fieldValue;
                break;
            case 'email':
                this.npiRecord.email = fieldValue;
                break;
            case 'phoneM':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord.phone = fieldValue;
                break;
            case 'pfirstName':
                this.npiRecord.pfirstname = fieldValue;
                break;
            case 'plastName':
                this.npiRecord.plastname = fieldValue;
                break;
            case 'primaryoPhone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord.pophone = fieldValue;
                break;
            case 'pext':
                this.npiRecord.pext = fieldValue;
                break;
            case 'pemail':
                this.npiRecord.pemail = fieldValue;
                break;
            case 'sfirstName':
                this.npiRecord.sfirstname = fieldValue;
                break;
            case 'slastName':
                this.npiRecord.slastname = fieldValue;
                break;
            case 'secondaryoPhone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord.sophone = fieldValue;
                break;
            case 'sext':
                this.npiRecord.sext = fieldValue;
                break;
            case 'semail':
                event.target.value = fieldValue;
                this.npiRecord.semail = fieldValue;
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
    
}