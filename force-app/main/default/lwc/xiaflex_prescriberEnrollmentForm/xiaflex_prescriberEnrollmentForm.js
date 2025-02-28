import { LightningElement, track, wire } from 'lwc';
import Id from "@salesforce/user/Id";
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import xiaflex_IconSortAcc from "@salesforce/resourceUrl/xiaflex_IconSortAcc";
import xiaflex_IconCheck from "@salesforce/resourceUrl/xiaflex_IconCheck";
import {NavigationMixin} from 'lightning/navigation';
import getUserDetails from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getLoggedInUserAccount';
import getAccountHcsRecordList from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getAccountRecordForSearch';
import getPickListValues from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getPicklistFieldValues';
import insertDataOnSubmit from '@salesforce/apex/xiaflex_Application_Enrollment_Class.insertHCPData';
import xiaflex_bgBlue from "@salesforce/resourceUrl/xiaflex_bgBlue";


export default class Xiaflex_prescriberEnrollmentForm extends NavigationMixin(LightningElement) {  

    iconSortAcc = xiaflex_IconSortAcc;
    iconCheck = xiaflex_IconCheck;
    userId = Id;
    @track hcsSearch = false;
    @track hcsEntry = false;
    @track displaySpecialtyOthers = false;
    @track isAffiliatedDisabled = true;
    @track tabsetArr = new Array();
    @track stateOptions = [];
    @track prescriberData = {};
    hcsRecord = {};
    npi='';
    signatureData = '';
    displaySpinner = false;
    selectedrowvaluetrue = '';
    showHCSNewForm = false;
    sortOrder = 'asc';
    showModal = false;

    get contactOptions() {
        return [
            { label: 'Email', value: 'Email' },
            { label: 'Fax', value: 'Fax' },
        ];
    }

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

    get hcsOptions() {
        return [
            { label: 'Inpatient', value: 'Inpatient' },
            { label: 'Outpatient/Clinic (not affiliated with hospital)', value: 'Outpatient/Clinic (not affiliated with hospital)' },
            { label: 'Outpatient/Clinic (affiliated with hospital)', value: 'Outpatient/Clinic (affiliated with hospital)' },
        ];
    }

    get Specialtyoptions() {
        return [
            { label: 'General Surgeon', value: 'General Surgeon' },
            { label: 'Plastic Surgeon', value: 'Plastic Surgeon' },
            { label: 'Urologist', value: 'Urologist' },
            { label: 'Other (specify)', value: 'Other' },
        ];
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        let url = window.location.href;
        let newUrl = new URL(url).searchParams;
        this.npi = newUrl.get('npi');
        this.getPickListValues();
        this.getUserAccount();
        var objToAdd = ({
            id: 0,
            index: 0,
            table: [],
            visibileAccounts: [],
            selectedObj: {},
            hcsSearch: false,
            hcsEntry: false,
            checkboxDisabled: false
        });
        this.tabsetArr.push(objToAdd);
    }
 renderedCallback() {
        setTimeout(() => {
            let currentElement = this.template.querySelector('.currentPath');
            this.currentPathHandler(currentElement);
             let element = this.template.querySelector('.completePath');
            this.completePathHandler(element);

        }, 100)
    }
     completePathHandler(element) {
        element.classList.remove('slds-is-current');
        element.classList.add('slds-is-complete');
        element.classList.remove('slds-is-incomplete');
    }

    currentPathHandler(element) {
        element.classList.add('slds-is-current');
        element.classList.remove('slds-is-complete');
       // element.classList.add('slds-is-incomplete');
    }
    getUserAccount(){
        getUserDetails({userId : this.userId})
        .then((data) => {
            var spec = this.Specialtyoptions.find(element => element.value == data.US_WSREMS__Specialty__c);
            var prescriberAcc = {
                Id: data.Id,
                NPI: data.US_WSREMS__National_Provider_Identifier__c,
                firstName: data.FirstName,
                middleName: data.MiddleName,
                lastName: data.LastName,
                email: data.PersonEmail,
                phone: data.Phone != null && data.Phone != '' ? this.formatPhoneNumber(data.Phone) : '',  
                fax: data.Fax != null && data.Fax != '' ? this.formatPhoneNumber(data.Fax) : '',
                me: data.US_WSREMS__Legal_Guardian_Relationship__c,
                suffix: data.US_WSREMS__Legal_Guardian_Name__c,
                PhoneType: data.US_WSREMS__Phone_Type__c,
                preferredContactMethod: data.US_WSREMS__Preferred_Contact_Method__c,
                Degree: data.US_WSREMS__Professional_Designation__c,
                Speciality: spec != undefined && spec.value == data.US_WSREMS__Specialty__c ? data.US_WSREMS__Specialty__c : undefined,
                other: data.US_WSREMS__Other_Credentials__c,
                hcsOption: data.US_WSREMS__Healthcare_Setting_Type__c,
                License: data.US_WSREMS__SLN__c,
                LicenseState: data.US_WSREMS__SLN_State__c,
            }
            //this.template.querySelector('select.licenseState').value = prescriberAcc.LicenseState;
            this.prescriberData = prescriberAcc;
            if(this.prescriberData.Speciality == 'Other'){
                this.displaySpecialtyOthers = true;
            }
        })
        .catch((error) => {
           console.log('error=>', error)
        });
    }

    

    async handleHcsAccountRecords(currentIndex) {

        let accRecords = await this.getAccountHcsRecords(currentIndex);
        this.tabsetArr[currentIndex].showHCSErrMsg = false;
        if (accRecords != null) {
            var hcsAccount = accRecords.map((acc, index) => ({
                Id: acc.Id,
                Name: acc.Name,
                Address: acc.US_WSREMS__Address_Line_1__c != undefined ? acc.US_WSREMS__Address_Line_1__c : null,
                City: acc.US_WSREMS__City__c != undefined ? acc.US_WSREMS__City__c : null,
                State: acc.US_WSREMS__State__c != undefined ? acc.US_WSREMS__State__c : null,
                ZIPCode: acc.US_WSREMS__Zip__c != undefined ? acc.US_WSREMS__Zip__c : null,
                Phone: acc.Phone != undefined ? acc.Phone : undefined,
                EnrollmentID: acc.US_WSREMS__REMS_ID__c,
                checked: false,                
                remsStatusPending: acc.US_WSREMS__Status__c != 'Certified' ? acc.US_WSREMS__Status__c : null,
                remsStatusCertified: acc.US_WSREMS__Status__c == 'Certified' ? acc.US_WSREMS__Status__c : null
            }));
            for (let i in this.tabsetArr) {
                if (i == currentIndex) {
                    this.tabsetArr[i].hcsSearch = true;
                    this.tabsetArr[i].table = hcsAccount;
                }
            }
            if(hcsAccount.length == 0) {
                this.tabsetArr[currentIndex].showHCSErrMsg = true;
            }

        }

        

    }

    getPickListValues(){
        getPickListValues()
                .then((pickListVal) => {
                    var stateOptionList = pickListVal.US_WSREMS__State__c;
                    for (var i in stateOptionList) {
                        let selectedState = false; 
                        if(stateOptionList[i] != 'AA' && stateOptionList[i] != 'AE' && stateOptionList[i] != 'AP'){
                            if( stateOptionList[i] == this.prescriberData.LicenseState){
                                selectedState = true;
                            }
                            const option = {
                                label: i,
                                value: stateOptionList[i],
                                isSelected: selectedState
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


    getAccountHcsRecords(currentIndex) {
        var queryData = this.template.querySelectorAll(".hcsSearchData");
        var searchData;
        queryData.forEach((currentItem, index) => {
            if(index == currentIndex){
                searchData = currentItem.value;
            }
        });
        if (searchData != null && searchData.length > 0) {
            return getAccountHcsRecordList({ inputValue : searchData, participantType : 'Healthcare', programType : 'REMS' })
                .then((accRecord) => {
                    return accRecord;
                })
                .catch((error) => {
                    // This way you are not to going to see [object Object]
                    console.log('Error is', error);
                });
        }
        else {
            return null;
        }
    }

    handleSpeciality(event) {
        this.prescriberData['Speciality'] = event.target.value;
        if (event.target.value == 'Other') {
            this.displaySpecialtyOthers = true;
        }
        else {
            this.displaySpecialtyOthers = false;
        }

    }

    handleRowSelection(event) {
        var selectedRecId = event.currentTarget.dataset.recId;
        var currentIndex = event.currentTarget.dataset.index;
        this.hcsRecord.Id = selectedRecId;
        this.selectedrowvaluetrue  = event.currentTarget.dataset.recId;
        this.tabsetArr[currentIndex].table.forEach(rec => {
            if(rec.Id == selectedRecId){
                rec.checked = true;
            } else{
                rec.checked = false;
            }
        });
        this.template.querySelector('input[data-cmp="cannotFindCheck"]').checked = false;
        this.showHCSNewForm = false;
    }

   async handleSearch(event) {
        var i = event.currentTarget.dataset.index;
        this.hcsSearch = false;
        this.tabsetArr[i].hcsSearch = false;
        this.tabsetArr[i].table = [];
        this.tabsetArr[i].visibileAccounts = [];

        var queryData = this.template.querySelector(".hcsSearchData");
            if (!queryData.checkValidity()) {
                queryData.reportValidity()
            } else {
                await this.handleHcsAccountRecords(event.currentTarget.dataset.index);
                this.hcsSearch = true;
            }
    }

    handleHCSEntry(event) {
        var currentIndex = event.currentTarget.dataset.index;
        this.showHCSNewForm = event.currentTarget.checked;
        if(event.currentTarget.checked) {
            let inputFields = this.template.querySelectorAll('input[data-cmp="hcsCheckbox"]');
            inputFields.forEach(inputField => {
                inputField.checked = false;
            });
        }
         this.tabsetArr[currentIndex].table.forEach(rec => {
                rec.checked = false;
        });
        if(this.showHCSNewForm){
            this.selectedrowvaluetrue = '';
            delete this.hcsRecord['Id'];
        }
    }

    handleClick(event) {
        var queryData = this.template.querySelector(".input2");
        var valuej = document.getElementById('input2').value;

    }

    handleSignatureCompleted(event) {
        this.signatureData = event.detail.signdata;
    }
    handleClear(){
        this.template.querySelector('c-tryvio-sign-pad').handleClear();
    }

    handleSubmit(event){
        this.displaySpinner = true;
        this.template.querySelector('c-tryvio-sign-pad').handleSaveSignature();
        var prescriberObj = this.prescriberData;
        let isValid  = true;
        let validateRequiredFields = this.validateRequiredFields(event, true, false);
        if(validateRequiredFields) {
            let validateInputs = this.validateInputs(event, true, false);
            if(validateInputs) {
                let validateHCS = this.validateHCSData(event);
                if(validateHCS) {
                    this.template.querySelector('c-tryvio-sign-pad').handleSaveSignature();
                    let validateSignature = this.validateSignature(event);
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
                                    window.location.href = 'prescriber-enrollment-form-success';
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
        this.displaySpinner = false;
    }

    sortAccountRecords(event){
        var currentIndex = event.currentTarget.dataset.index;
        var visibleRecords = this.tabsetArr[currentIndex].visibileAccounts;
        this.tabsetArr[currentIndex].visibileAccounts = [...visibleRecords].sort((a, b) => {
            const lastNameA = a.Name.toLowerCase();
            const lastNameB = b.Name.toLowerCase();
            var result = lastNameA.localeCompare(lastNameB);    
            return (this.sortOrder == 'asc') ? result : (result == 0) ? 0 : (result < 1) ? 1 : -1; 
        });
        this.sortOrder = this.sortOrder == 'asc'?'desc':'asc';
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    updateRecords(event){
        var currentIndex = event.currentTarget.dataset.index;
        var visibileAcc=[...event.detail.records];
        this.tabsetArr[currentIndex].visibileAccounts = visibileAcc;
    }

    handleClearSignature(){
        this.template.querySelector('c-xiaflex_canvas-signature').handleClear();
    }
    

    formatPhoneNumber(phoneNumber) {
        const regex = /^(\d{3})(\d{3})(\d{4})$/;
        const parts = phoneNumber.match(regex);
        if (parts) {
            return `(${parts[1]}) ${parts[2]}-${parts[3]}`;
        }
        return phoneNumber;
    }

    handleChange(event) {
        this.populateFields(event);
        this.validateInputs(event, false, true);
        this.handleDependentFields(event);
    }


    validateRequiredFields(event) {
        this.displaySpinner = true;
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.hcpSubmit');
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
                this.displaySpecialtyOthers = true;
                this.prescriberData.other = fieldValue;
            }else{
                this.displaySpecialtyOthers = false;
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
            case 'otherspeciality':
                this.prescriberData.other = fieldValue;
                break;
            case 'hcsOption':
                this.prescriberData.hcsOption = fieldValue;
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

    handleRadioSelection(event){
        let targetFieldName = event.target.dataset.targetfld;
        if(targetFieldName){
            this.prescriberData[targetFieldName] = event.target.value;
        }
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
            event.stopPropagation();
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes:{
                    name: 'reviewMaterial__c'
                },
            });         
        }
    }
}