import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import getPickListValues from '@salesforce/apex/TryvioEnrollmentCls.getPicklistFieldValues';
import tryvioIconPharmacy from '@salesforce/resourceUrl/tryvioIconPharmacy';
import { NavigationMixin } from 'lightning/navigation';
import tryvioProgramName from '@salesforce/label/c.Tryvio_REMS_Program_Name';
import inValidNPI from '@salesforce/label/c.tryvio_Invalid_NPI';
import insertDataOnSubmit from '@salesforce/apex/TryvioEnrollmentCls.insertDataOnSubmit';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import duplicateNPI from '@salesforce/label/c.tryvio_Duplicate_NPI';
import SuccessMsg from '@salesforce/label/c.Tryvio_SuccessMsg';
import DuplicateEmail from '@salesforce/label/c.Tryvio_Duplicate_email_Error_Msg';
import ValidationMsg from '@salesforce/label/c.ValidationMsg';
import Isvalid_InvalidMsg from '@salesforce/label/c.Isvalid_InvalidMsg';
import ErrorMsg from '@salesforce/label/c.ErrorMsg';
export default class TryvioRemsIppEnrollmentForm extends NavigationMixin(LightningElement) {

    @api programName = tryvioProgramName;
    @api participantType = 'Inpatient Pharmacy';
    @api npiLabel = 'NPI';
    @api npiPlaceholder = '';
    @api prenpi = '';
    @api name = '';
    stateOptions = [];
    npiRecord = {};
    @track arRecord = {};
    @track shipRecord = {};
    @track selectedFacility;
    @track selectedPosition;
    @track selectedContactMethod;
    selectedPharmacyType = '';
    showOtherCredetial = '';
    signatureData = '';
    searchValue;
    invalidNPI = inValidNPI;
    iconPharmacy = tryvioIconPharmacy;
    @track showError = false;
    selectedsameAsAbove = false;
    disabled = false;
    isloading = false;
    displayInvalidNpi = false;
    showDetail = false;
    showModal = false;
    isShowOtherFacility = false;
    showOtherCredetial = false;
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

    @track facilityOptions = [
        { label: 'Hospital', value: 'Hospital' },
        { label: 'Nursing Home', value: 'Nursing Home' },
        { label: 'Rehab', value: 'Rehab' },
        { label: 'Mental Facility', value: 'Mental Facility' },
        { label: 'Assisted Living', value: 'Assisted Living' },
        { label: 'Prison', value: 'Prison' },
        { label: 'Other (please specify)', value: 'Other' }
    ];
    @track positionOptions = [
        { label: 'Hospital Pharmacist', value: 'Hospital Pharmacist' },
        { label: 'Head of Pharmacy & Therapeutics (P&C) Committee', value: 'Head of Pharmacy and Therapeutics (P&T) committee' },        
        { label: 'Other (please specify)', value: 'Other'}
    ];
    @track contactMethodOptions = [
        { label: 'Office Phone', value: 'Office Phone' },
        { label: 'Email', value: 'Email' },
        { label: 'Mobile Phone', value: 'Mobile Phone' },
        { label: 'Text Message', value: 'Text Message' }
    ];
    
    handleNpiResult(event) {
        try {
            console.log('In parent ' + JSON.stringify(event.detail));
            let accountStatusListForDupliate = ['Certified','Certified - On Hold','Pending','Decertified','Deactivated','Cancelled'];
            if(event.detail.accountStatus && accountStatusListForDupliate.includes(event.detail.accountStatus)) {
                this.showToast('Information', this.label.duplicateNPI, 'info');
            } else if(event.detail.veevaStatus == 'Failed') {
                this.showDetail = false;
            } else {
                const result = event.detail.response;
                this.showDetail = true;
                this.npiRecord.phone = this.formatPhoneNumber(result.Phonenumber1);
                this.npiRecord.address1 = result.StreetAddress;
                this.npiRecord.city = result.city;
                this.npiRecord.state = result.State != null && result.State != '' ? result.State : 'AK';;
                this.npiRecord.zip = result.postalCode;
                this.npiRecord.npi = result.npi;
                this.npiRecord.name = result.PharmacyName;
            }
        }
        catch (e) {
            console.log('e->', e);
            this.showToast('Error', e.message, 'error');
        }
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
                console.log('Error is', error);
            });
    }

    connectedCallback() {
        this.isloading = false;
        this.shipRecord.shipAsAbove = false;
        loadStyle(this, customStyles);
        this.getPickListValues();
    }

    handleSignatureCompleted(event) {
        this.signatureData = event.detail.signdata;
        console.log('this.signa', this.signatureData);
    }
    handleClearSignature() {
        this.template.querySelector('c-tryvio-sign-pad').handleClear();
    }
    handleCancel() {
        this.showModal = true;
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

    handleFacilityChange(event) {
        this.npiRecord.facilityType = event.detail.value;
        if (this.npiRecord.facilityType === 'Other') {
            this.template.querySelector('.TypeOther').classList.remove('slds-hide');
            this.template.querySelector('.TypeOther').classList.add('slds-show');
        } else {
            this.template.querySelector('#.ypeOther').classList.remove('slds-show');
            this.template.querySelector('.TypeOther').classList.add('slds-hide');
        }
    }

    handlePositionChange(event) {
        this.selectedPosition = event.detail.value;
        if (this.selectedPosition === 'Other') {
            this.template.querySelector('#CredOther').classList.remove('slds-hide');
            this.template.querySelector('#CredOther').classList.add('slds-show');
        } else {
            this.template.querySelector('#CredOther').classList.remove('slds-show');
            this.template.querySelector('#CredOther').classList.add('slds-hide');
        }
    }

    handleContactMethodChange(event) {
        this.selectedContactMethod = event.detail.value;
    }

    handleShipAddressChange(event) {
        if (event.target.checked) {
            this.template.querySelector('.PharmShipAddress').classList.remove('slds-show');
            this.template.querySelector('.PharmShipAddress').classList.add('slds-hide');
            this.shipRecord.shipAsAbove = true;
            this.shipRecord.shipAddress1 = this.npiRecord.address1;
            this.shipRecord.shipAddress2 = this.npiRecord.address2;
            this.shipRecord.shipCity = this.npiRecord.city;
            this.shipRecord.shipState = this.npiRecord.state;
            this.shipRecord.shipZip = this.npiRecord.zip;
            this.shipRecord.shipPhone = this.npiRecord.phone;
            this.shipRecord.shipExt = this.npiRecord.ext;
            this.shipRecord.shipFax = this.npiRecord.fax;
        } else {
            this.shipRecord.shipAsAbove = false;
            this.template.querySelector('.PharmShipAddress').classList.remove('slds-hide');
            this.template.querySelector('.PharmShipAddress').classList.add('slds-show');
            this.shipRecord.shipAddress1 = '';
            this.shipRecord.shipAddress2 = '';
            this.shipRecord.shipCity = '';
            this.shipRecord.shipState = '';
            this.shipRecord.shipZip = '';
            this.shipRecord.shipPhone = '';
            this.shipRecord.shipExt = '';
            this.shipRecord.shipFax = '';
        }
    }

    handleDismissError() {
        this.showError = false;
    }

    handleSubmit(event) {
        this.disabled = true;
        let validateRequiredFields = this.validateRequiredFields(event, true, false);
        console.log('validateRequiredFields:::', validateRequiredFields);
        if(validateRequiredFields) {
            let validateInputs = this.validateInputs(event, true, false);
            console.log('validateInputs:::', validateInputs);
            if(validateInputs) {
                this.template.querySelector('c-tryvio-sign-pad').handleSaveSignature();
                let validateSignature = this.validateSignature(event);
                console.log('validateSignature:::', validateSignature);
                if(validateSignature) {
                    this.isloading = true;
                    let updatedNpiRecord = {...this.npiRecord};
                    updatedNpiRecord.participantType = this.participantType;
                    updatedNpiRecord.AR = this.arRecord;
                    updatedNpiRecord.Sh = this.shipRecord;        
                    console.log(JSON.stringify(this.arRecord));
                    console.log(JSON.stringify(this.npiRecord), 'updatedNpiRecord ' + JSON.stringify(updatedNpiRecord));
                    let inputRecords = {
                        'recordDetails': JSON.stringify(updatedNpiRecord),
                        'programName': 'TRYVIO REMS',
                        'participantType': this.participantType,
                        'signatureData': this.signatureData,
                        'arDetails': JSON.stringify(this.arRecord),
                        'shipDetails': JSON.stringify(this.shipRecord),
                        'formType': 'IPP',

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

                        if (eachRec === 'duplicateEmail') {
                            this.showToast('Error', this.label.DuplicateEmail, 'error');
                        }

                        if (eachRec === 'duplicateNPI') {
                            this.showToast('Error', this.label.duplicateNPI, 'error');
                        }

                        this.isloading = false;
                    }).catch(error => {
                        console.log('error::::', JSON.stringify(error));
                        console.log('error::::', JSON.stringify(error.body.message));
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
        location = location.substring(0, location.indexOf('/s/'))+'/s/tryvioremsippenrollmentformsuccess?id='+eachRec;
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
        console.log(fieldName + ' =>> ' + fieldValue)
        if (fieldName == 'credentials') {
            this.showOtherCredetial = false;
            if (fieldValue == 'other') {
                this.showOtherCredetial = true;
            }
        }
        else if (fieldName == 'pharmacyType') {
            this.selectedPharmacyType = event.detail.value;
            this.npiRecord.facilityTypes = this.selectedPharmacyType;
            this.isShowOtherFacility = false;
            this.npiRecord.facilityOther = '';
            if(fieldValue == 'Other') {
                this.isShowOtherFacility = true;
            } 
        }
        else if (fieldName == 'position') {
            this.arRecord.position = event.detail.value;
        } else if (fieldName == 'arjobtitle') {
            this.showOtherCredetial = false;
            if (fieldValue == 'Other') {
                this.showOtherCredetial = true;
                this.arRecord.other = event.detail.value;
                this.npiRecord.AR.other = event.detail.value;
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
        return isSignatureData;
    }

    validateInputs(event, isValidateALL, isFieldCheck) {
        try {
            const phonePattern = /^(\s*\d\s*){10}$/;
            const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const namePatterns = /^[A-Za-z'. -]+$/;
            const zipPatterns = /^\d{5}(-\d{4})?$/;
            const faxPatterns = /^(\s*\d\s*){10}$/;
            const extPatterns = /^[0-9]{1,10}$/;
            let isValid = true;
            
            let inputFields = this.template.querySelectorAll('.validate');
            inputFields.forEach(inputField => {
                console.log('inputField:::::', JSON.stringify(inputField));
                const fieldName = isFieldCheck ? event.target.name : inputField.name;
                let fieldValue = isFieldCheck ? event.target.value : inputField.value;
                console.log('fieldName:::',fieldName);
                let numericPhone = fieldValue ? fieldValue.replace(/\D/g, '').replace('-') : fieldValue;

                if(isValidateALL || (isFieldCheck && fieldName && inputField.name === fieldName)) {
                    console.log('fieldName:::',fieldName);
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
                    if ((fieldName === 'offPhone' || fieldName === 'oPhone' || fieldName === 'offPhone' ||
                          fieldName === 'shipoffPhone' || fieldName === 'arOffPhone')) {
                            console.log('phone rror');
                            inputField.classList.remove('slds-has-error');
                            inputField.setCustomValidity('');
                            console.log('common');
                            console.log('fieldValue:::', fieldValue);
                            console.log('numericphone:::', numericPhone);
                            if(!numericPhone.match(phonePattern)) {
                                isValid = false;
                                inputField.classList.add('slds-has-error');
                                inputField.setCustomValidity('Please enter a valid Phone Number.');
                            }
                        
                            inputField.reportValidity();
                    } 
                    
                    if ((fieldName === 'zip' || fieldName === 'shipzip')) {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(!fieldValue.match(zipPatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Zip can be 5 digits or 9 digits.');
                        }
                        inputField.reportValidity();

                    } 
                    if(fieldName === 'ext' || fieldName === 'shipext' || fieldName === 'arExt') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(extPatterns)){
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter valid Ext.');
                        }
                        inputField.reportValidity();
                    }  
                    
                    if (fieldName === 'lastName') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(namePatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Name.');
                        }
                        inputField.reportValidity();
                    }  
                    
                    if (fieldName === 'fname') {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if(fieldValue && !fieldValue.match(namePatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Name.');
                        } 
                        inputField.reportValidity();                        
                    }

                    if (fieldName === 'mi' ) {
                        inputField.classList.remove('slds-has-error');
                        inputField.setCustomValidity('');
                        if (fieldValue && !fieldValue.match(namePatterns)) {
                            isValid = false;
                            inputField.classList.add('slds-has-error');
                            inputField.setCustomValidity('Please enter a valid Name.');
                            inputField.reportValidity();
                        } 
                        inputField.reportValidity();
                    }

                    if ((fieldName === 'fax' || fieldName === 'faxAR' || fieldName === 'shipfax') ) {
                        console.log('fax rror');
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
            case 'arOffPhone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.arRecord.offPhone = fieldValue;
                break;
            case 'ext':
                this.npiRecord.ext = fieldValue;
                break;
            case 'fax':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord.fax = fieldValue;
                break;
            case 'facilityOther':
                this.npiRecord.facilityOther = fieldValue;
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
            case 'other':
                this.arRecord.other = fieldValue;
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
            case 'shipfname':
                this.shipRecord.firstName = fieldValue;
                break;
            case 'shipmi':
                this.shipRecord.mi = fieldValue;
                break;
            case 'shiplastName':
                this.shipRecord.lastName = fieldValue;
                break;
            case 'shipaddress1':
                this.shipRecord.shipAddress1 = fieldValue;
                break;
            case 'shipaddress2':
                this.shipRecord.shipAddress2 = fieldValue;
                break;
            case 'shipcity':
                this.shipRecord.shipCity = fieldValue;
                break;
            case 'shipstate':
                this.shipRecord.shipState = fieldValue;
                break;
            case 'shipzip':
                this.shipRecord.shipZip = fieldValue;
                break;
            case 'shipoffPhone':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.shipRecord.shipPhone = fieldValue;
                break;
            case 'shipext':
                this.shipRecord.shipExt = fieldValue;
                break;
            case 'shipfax':
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue; 
                this.shipRecord.shipFax = fieldValue;
                break;
            case 'shipAsAbove':
                this.shipRecord.shipAsAbove = fieldValue;
                break;
            case 'arExt':
                this.arRecord.ext = fieldValue;
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