import { LightningElement, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import LICENCE_STATE from '@salesforce/schema/Account.US_WSREMS__SLN_State__c';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import getLoggedInUserDetails from '@salesforce/apex/Aveed_MyProfileController.getLoggedInUserAccountDetails'
import updateAccountDetails from '@salesforce/apex/Aveed_MyProfileController.updateAccountDetails'
import createCaseAndServiceSummary from '@salesforce/apex/Aveed_MyProfileController.createCaseAndServiceSummary'

const accMap = {
    sOject: "Account",
    Id: undefined,
    FirstName: undefined,
    LastName: undefined,
    MiddleName: undefined,
    Fax: undefined,
    Phone: undefined,
    US_WSREMS__SLN__c: undefined,
    US_WSREMS__SLN_State__c: undefined,
    US_WSREMS__Preferred_Contact_Method__c: undefined,
    US_WSREMS__Professional_Designation__c: undefined,
    Medical_Specialty__c: undefined,
    US_WSREMS__Other__c: undefined,
    US_WSREMS__Other_Credentials__c: undefined,
    US_WSREMS__Title__c: undefined
}

export default class Aveed_MyProfile extends LightningElement {
    connectedCallback() {
        loadStyle(this, customHomeStyles);
    }
    npiRecord = {};
    recordTypeName;
    boolVisible = false;
    disableSave = false;
    isLoading = false;
    error;
    userList = [];
    finalUserList = [];
    userName;
    accountId;
    status;
    prescriberNPI;
    deaNumber;
    email;
    fax;
    stateLicenceNum;
    stateLicenceNumSt;
    otherTitleField;
    preferredMethodOfContact;
    firstName;
    middleName;
    lastName;
    phone;
    phonehcs;
    title;
    credentials;
    speciality;
    enrollmentId;
    credentialsOther;
    specialityOther;
    Otherspeciality;
    modifiedFirstName = '';
    modifiedLastName = '';
    modifiedTitle = '';
    modifiedContact = '';
    otherTitle = '';
    modifiedmiName = '';
    modifiedPosition = '';
    modifiedPhone = '';
    modifiedPhoneHCS = '';
    modifiedFax = '';
    modifiedSpeciality = '';
    modifiedStateLicenceNum = '';
    modifiedStateLicenceState = '';
    doCheck = false;
    mdCheck = false;
    nurseCheck = false;
    othersCheck = false;
    physicianCheck = false;
    practiceMCheck = false;
    @track faxCheck = false;
    @track emailCheck = false;
    endocrinologyCheck = false;
    urologyCheck = false;
    primaryCheck = false;
    otherSpecialityCheck = false;
    showPrescriberInfo = false;
    prescriberHcsInfo = false;
    otherCred = false;
    otherSpec = false;
    modifiedPhoneHCS1;
    @track roleHCS = '';
    @track stateName;
    @track state = [];
    @track ischeck = false;
    @track checkLic = false;
    @track ischecktitle = false;
    @track checkfax = false;
    @track checkmiddlename = false;
    title = '';
    titlechange = '';
    firstnamechange = '';
    lastnamechange = '';

    programName;
    _wiredResult;
    list = [];
    presciberRecordTypeId;


    get accountMaptoUpdate() {
        return accMap;
    }

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    Function({ error, data }) {
        if (data) {
            let objarray = data.recordTypeInfos;
            for (let i in objarray) {
                if (objarray[i].name == 'Prescriber') {
                    this.presciberRecordTypeId = objarray[i].recordTypeId;
                }
            }
        } else if (error) {
            this.error = error;
        }
    };

    @wire(getPicklistValues, { recordTypeId: '$presciberRecordTypeId', fieldApiName: LICENCE_STATE })
    stageValues({ error, data }) {
        if (data) {
            this.stateName = data.values;
            this.stateName.forEach((element) => {
                if ((element.value.length === 2) && (element.value !== 'AA') && (element.value !== 'AE')) {
                    this.state.push(element);

                }
            });
        } else if (error) {
            this.error = error;
        }
    }


    @wire(getLoggedInUserDetails)
    userInfo(wiredResult) {
        this.npiRecord = {};
        const { data, error } = wiredResult;
        this._wiredResult = wiredResult;
        if (data) {
            this.userList = data;

            let relatedAccountsarray = [];
            for (let row of this.userList) {
                const flattenedRow = {}
                let rowKeys = Object.keys(row);
                //console.log('rowKeys=='+rowKeys);
                rowKeys.forEach((rowKey) => {
                    const singleNodeValue = row[rowKey];
                    if (singleNodeValue.constructor === Object) {
                        this._flatten(singleNodeValue, flattenedRow, rowKey);
                    } else {
                        flattenedRow[rowKey] = singleNodeValue;
                    }
                });
                relatedAccountsarray.push(flattenedRow);
                this.finalUserList = relatedAccountsarray;
                for (let key in this.finalUserList) {

                    this.recordTypeName = data[key].Account.RecordType.Name;
                    //this.showPrescriberInfo = true;
                    if (this.recordTypeName == "Prescriber") {
                        this.showPrescriberInfo = true;
                    } else {
                        this.prescriberHcsInfo = true;
                    }
                    this.userName = data[key].Account.FirstName + " " + data[key].Account.LastName;
                    this.accountId = data[key].Account.Id;
                    this.status = data[key].Account.US_WSREMS__Status__c;
                    this.enrollmentId = data[key].Account.US_WSREMS__REMS_ID__c; // enrollment id
                    this.prescriberNPI = data[key].Account.US_WSREMS__National_Provider_Identifier__c; //Prescriber Field
                    this.deaNumber = data[key].Account.US_WSREMS__DEA__c; // DEA
                    this.firstName = data[key].Account.FirstName;
                    this.lastName = data[key].Account.LastName;
                    this.middleName = data[key].Account.MiddleName;
                    this.title = data[key].Account.US_WSREMS__Title__c;
                    this.roleHCS = data[key].Account.US_WSREMS__Professional_Designation__c;
                    if (this.showPrescriberInfo) {
                        this.email = data[key].Account.PersonEmail;
                    } else {
                        this.email = data[key].Account.US_WSREMS__Email__c;
                    }
                    this.phonehcs = data[key].Account.Phone;
                    this.phone = data[key].Account.Phone;
                    this.fax = data[key].Account.Fax;
                    this.preferredMethodOfContact = data[key].Account.US_WSREMS__Preferred_Contact_Method__c;
                    this.stateLicenceNum = data[key].Account.US_WSREMS__SLN__c;//state licence num 
                    this.stateLicenceNumSt = data[key].Account.US_WSREMS__SLN_State__c; //state licence state
                    this.credentials = data[key].Account.US_WSREMS__Professional_Designation__c; // degree / credentials 
                    // this.speciality = data[key].Account.Medical_Specialty__c; // speciality
                    this.speciality = data[key].Account.US_WSREMS__Specialty__c;
                    this.specialityOther = data[key].Account.US_WSREMS__Other_Credentials__c;
                    this.credentialsOther = data[key].Account.US_WSREMS__Other__c;

                    this.programName = data[key].Account.Program_Name__c;
                    if (this.showPrescriberInfo) {
                        this.npiRecord.enrollmentId = this.enrollmentId;
                        this.npiRecord.npi = this.prescriberNPI;
                        this.npiRecord.DEA = this.deaNumber;
                        this.npiRecord.licenceNum = this.stateLicenceNum;
                        this.npiRecord.licenceNumState = this.stateLicenceNumSt;
                        this.npiRecord.medicalSpeciality = this.speciality;
                    }
                    this.npiRecord.firstName = this.firstName;
                    this.npiRecord.middleName = this.middleName;
                    this.npiRecord.lastName = this.lastName;
                    this.npiRecord.preferredContactMethod = this.preferredMethodOfContact;
                    this.npiRecord.phone = this.phone;
                    this.npiRecord.title = this.title;
                    this.npiRecord.fax = this.fax;
                    this.npiRecord.email = this.email;
                    this.npiRecord.othercredentials = this.credentialsOther;
                    this.npiRecord.designation = this.credentials;
                    //this.npiRecord.othercredentials = data[key].Account.US_WSREMS__Other_Credentials__c;
                    this.npiRecord.specialityOther = this.specialityOther;
                    if (this.credentials == "DO") {
                        this.doCheck = true;
                    } else if (this.credentials == "MD") {
                        this.mdCheck = true;
                    } else if (this.credentials == "Nurse") {
                        this.nurseCheck = true;
                    } else if (this.credentials == "Physician Assistant") {
                        this.physicianCheck = true;
                    } else if (this.credentials == "Practice Manager") {
                        this.practiceMCheck = true;
                    } else {
                        this.othersCheck = true;
                        this.otherCred = true;

                    }

                    if (this.speciality == "Endocrinology") {
                        this.endocrinologyCheck = true;
                    } else if (this.speciality == "Urology") {
                        this.urologyCheck = true;
                    }
                    else if (this.speciality == "Primary Care") {
                        this.primaryCheck = true;
                    } else {
                        this.otherSpec = true;
                        this.otherSpecialityCheck = true;
                    }

                    if (this.preferredMethodOfContact == "Fax") {
                        this.faxCheck = true;
                    } else if (this.preferredMethodOfContact == "Email") {
                        this.emailCheck = true;
                    }
                }
            }

        }
        if (error) {
            this.error = error;
            console.log('error' + JSON.stringify(this.error));
        }
    }

    _flatten(nodeValue, flattenedRow, nodeName) {
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.' + key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }

    openModal() {
        console.log('test console');
        console.log('boolVisible', this.boolVisible);

        this.boolVisible = true;
        console.log('boolVisible', this.boolVisible);
    }

    handleInputChange(event) {
        this.validateInputs(event);
        this.eventName = event.target.name;
        let otherElement = this.template.querySelector('.otherElement');
        let specialityElement = this.template.querySelector('.specialityElement');
        console.log('eventName==' + this.eventName);
        if (this.eventName == "firstName") {
            this.modifiedFirstName = event.target.value;
        } else if (this.eventName == "mi") {
            this.modifiedmiName = event.target.value;
            this.checkmiddlename = true;
        } else if (this.eventName == "lastName") {
            this.modifiedLastName = event.target.value;
        } else if (this.eventName == "phone") {
            this.modifiedPhone = event.target.value;
        }
        else if (this.eventName == "phoneHCS") {
            this.modifiedPhoneHCS = event.target.value;
            this.ischeck = true;
        }
        else if (this.eventName == "fax") {
            this.modifiedFax = event.target.value;
            this.checkfax = true;

        } else if (this.eventName == "stateLicenceNum") {
            this.modifiedStateLicenceNum = event.target.value;
            this.checkLic = true;
        } else if (this.eventName == "title") {
            this.modifiedTitle = event.target.value;
            this.ischecktitle = true;
        } else if (this.eventName == "stateLicenceNumSt") {
            this.modifiedStateLicenceState = event.target.value;
        } else if (this.eventName == "contact") {
            this.modifiedContact = event.target.value;
            if (this.modifiedContact == "Fax") {
                this.faxCheck = true;
                this.emailCheck = false;
            } else if (this.modifiedContact == "Email") {
                this.emailCheck = true;
                this.faxCheck = false;
            }
        } else if (this.eventName == "position") {
            this.modifiedPosition = event.target.value;

            if (this.modifiedPosition == "DO") {
                this.doCheck = true;
                this.mdCheck = false;
                this.nurseCheck = false;
                this.physicianCheck = false;
                this.practiceMCheck = false;
                this.othersCheck = false;
            } else if (this.modifiedPosition == "MD") {
                this.doCheck = false;
                this.mdCheck = true;
                this.nurseCheck = false;
                this.physicianCheck = false;
                this.practiceMCheck = false;
                this.othersCheck = false;
            } else if (this.modifiedPosition == "Nurse") {
                this.doCheck = false;
                this.mdCheck = false;
                this.nurseCheck = true;
                this.physicianCheck = false;
                this.practiceMCheck = false;
                this.othersCheck = false;
            } else if (this.modifiedPosition == "Physician Assistant") {
                this.doCheck = false;
                this.mdCheck = false;
                this.nurseCheck = false;
                this.physicianCheck = true;
                this.practiceMCheck = false;
                this.othersCheck = false;
            } else if (this.modifiedPosition == "Practice Manager") {
                this.doCheck = false;
                this.mdCheck = false;
                this.nurseCheck = false;
                this.physicianCheck = false;
                this.practiceMCheck = true;
                this.othersCheck = false;
            } else {
                this.doCheck = false;
                this.mdCheck = false;
                this.nurseCheck = false;
                this.physicianCheck = false;
                this.practiceMCheck = false;
                this.othersCheck = true;
            }
            if (this.modifiedPosition == "Other") {
                this.otherCred = true;
            } else {
                this.otherCred = false;
            }
        } else if (this.eventName == "speciality") {
            this.modifiedSpeciality = event.target.value;
            if (this.modifiedSpeciality == "Endocrinology") {
                this.endocrinologyCheck = true;
                this.urologyCheck = false;
                this.primaryCheck = false;
                this.otherSpecialityCheck = false;
            } else if (this.modifiedSpeciality == "Primary Care") {
                this.endocrinologyCheck = false;
                this.urologyCheck = false;
                this.primaryCheck = true;
                this.otherSpecialityCheck = false;
            } else if (this.modifiedSpeciality == "Urology") {
                this.endocrinologyCheck = false;
                this.urologyCheck = true;
                this.primaryCheck = false;
                this.otherSpecialityCheck = false;
            } else if (this.modifiedSpeciality == "Other") {
                this.endocrinologyCheck = false;
                this.urologyCheck = false;
                this.primaryCheck = false;
                this.otherSpecialityCheck = true;
            }
            if (this.modifiedSpeciality == "Other") {
                this.otherSpec = true;
            } else {
                this.otherSpec = false;
            }
        } else if (this.eventName == "othersTitle") {
            this.otherTitle = event.target.value;
        } else if (this.eventName == "specialityOther") {
            this.Otherspeciality = event.target.value;
        }
    }

    validateInputs(event) {

        const fieldName = event.target.name;
        let fieldValue = event.target.value;
        let fieldnamerem = fieldValue.replace(/[^A-Za-z\s]/g, '');
        let fieldtitle = fieldValue.replace(/[^A-Za-z.\-'s]/g, '');
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {

            const phonePattern = /^(\s*\d\s*){10}$/;
            const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const namePatterns = /^[A-Za-z'. -]+$/;
            const faxPatterns = /^(\s*\d\s*){10}$/;
            const regex = /^[A-Za-z]+$/;


            if (fieldName === 'email' && inputField.name === fieldName && !fieldValue.match(emailPattern)) {
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid email address.');
                inputField.reportValidity();
            } if (fieldName === 'email' && inputField.name === fieldName && fieldValue.match(emailPattern)) {
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            } if (fieldName === 'phone' && inputField.name === fieldName && !numericPhone.match(phonePattern)) {
                if (inputField.value.length < 10 && inputField.value.length > 0) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter a valid Phone Number.');
                    inputField.reportValidity();
                }
                else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            } if (fieldName === 'phone' && inputField.name === fieldName && numericPhone.match(phonePattern)) {

                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }
            if (fieldName === 'phoneHCS' && inputField.name === fieldName && !numericPhone.match(phonePattern)) {
                if (inputField.value.length < 10 && inputField.value.length > 0) {
                    inputField.classList.add('slds-has-error');
                    inputField.setCustomValidity('Please enter a valid Phone Number.');
                    inputField.reportValidity();
                } else {
                    inputField.classList.remove('slds-has-error');
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }

            } if (fieldName === 'phoneHCS' && inputField.name === fieldName && numericPhone.match(phonePattern)) {

                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }


            if (fieldName === 'lastName' && inputField.name === fieldName && !fieldValue.match(namePatterns)) {

                inputField.classList.add('slds-has-error');
                inputField.reportValidity();
            } if (fieldName === 'lastName' && inputField.name === fieldName && fieldValue.match(namePatterns)) {

                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            } if (fieldName === 'firstName' && inputField.name === fieldName && !fieldValue.match(namePatterns)) {
                inputField.classList.add('slds-has-error');
                inputField.reportValidity();
            } if (fieldName === 'firstName' && inputField.name === fieldName && fieldValue.match(namePatterns)) {

                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }

            if (fieldName === 'mi' && inputField.name === fieldName) {
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
            if (fieldName === 'firstName' || fieldName === 'lastName' || fieldName === 'mi') {
                fieldValue = fieldnamerem
                event.target.value = fieldValue;
            }
            if (fieldName === 'title') {
                fieldValue = fieldtitle;
                event.target.value = fieldValue;
            }


            if (fieldName === 'fax' || fieldName === 'phone' || fieldName === 'phoneHCS') {
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                this.npiRecord[event.target.name] = fieldValue.replace(/\D/g, '');
            } else {
                this.npiRecord[event.target.name] = fieldValue;
            }
        });
    }

    formatPhoneNumber(phoneNumber) {
        const regex = /^(\d{3})(\d{3})(\d{4})$/;
        const parts = phoneNumber.match(regex);
        if (parts) {
            return `(${parts[1]}) ${parts[2]}-${parts[3]}`;
        }
        return phoneNumber;
    }

    closeModal() {
        this.isLoading = false;
        this.disableSave = false;
        this.boolVisible = false;
        this.modifiedFirstName = '';
        this.modifiedmiName = '';
        this.modifiedLastName = '';
        this.modifiedPhone = '';
        this.modifiedPhoneHCS = '';
        this.modifiedFax = '';
        this.modifiedTitle = '';
        this.modifiedContact = '';
        this.modifiedPosition = '';
        this.otherTitle = '';
        this.Otherspeciality = '';
        this.modifiedSpeciality = '';
        this.modifiedStateLicenceNum = '';
        this.modifiedStateLicenceState = '';
    }
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    saveModal() {
        if (this.isInputValid()) {
            this.disableSave = true;
            this.isLoading = true;

            this.accountMaptoUpdate.Id = this.accountId;
            if (this.modifiedFirstName != '' && this.modifiedFirstName != this.firstName) {
                this.accountMaptoUpdate.FirstName = this.modifiedFirstName;
                this.npiRecord.firstName = this.modifiedFirstName;
            }
            if (this.modifiedLastName != '' && this.modifiedLastName != this.lastName) {
                this.accountMaptoUpdate.LastName = this.modifiedLastName;
                this.npiRecord.lastName = this.modifiedLastName;
            }
            if (this.modifiedmiName != '' && this.modifiedmiName != this.middleName) {
                this.accountMaptoUpdate.MiddleName = this.modifiedmiName;
                this.npiRecord.middleName = this.modifiedmiName;
                this.checkmiddlename = false;
            }
            if (this.modifiedmiName === '' && this.checkmiddlename) {
                this.accountMaptoUpdate.MiddleName = this.modifiedmiName;
                this.npiRecord.middleName = this.modifiedmiName;
                this.checkmiddlename = false;
            }
            if (this.modifiedContact != '' && this.modifiedContact != this.preferredMethodOfContact) {
                this.accountMaptoUpdate.US_WSREMS__Preferred_Contact_Method__c = this.modifiedContact;
                this.npiRecord.preferredContactMethod = this.modifiedContact;
            }
            if (this.modifiedPhone != '' && this.modifiedPhone != this.phone) {
                this.accountMaptoUpdate.Phone = this.modifiedPhone;
                this.npiRecord.phone = this.modifiedPhone;
            }

            if (this.modifiedPhoneHCS != '' && this.modifiedPhoneHCS != this.phone) {
                this.accountMaptoUpdate.Phone = this.modifiedPhoneHCS;
                this.npiRecord.phone = this.modifiedPhoneHCS;
                this.ischeck = false;
            }
            if (this.modifiedPhoneHCS === '' && this.ischeck) {
                this.accountMaptoUpdate.Phone = this.modifiedPhoneHCS;
                this.npiRecord.phone = this.modifiedPhoneHCS;
                this.ischeck = false;
            }
            if (this.modifiedFax != '' && this.modifiedFax != this.fax) {
                this.accountMaptoUpdate.Fax = this.modifiedFax;
                this.npiRecord.fax = this.modifiedFax;
                this.checkfax = false;
            }
            if (this.modifiedFax === '' && this.checkfax) {
                this.accountMaptoUpdate.Fax = this.modifiedFax;
                this.npiRecord.fax = this.modifiedFax;
                this.checkfax = false;
            }
            if (this.modifiedTitle != '' && this.modifiedTitle != this.title) {
                this.accountMaptoUpdate.US_WSREMS__Title__c = this.modifiedTitle;
                this.npiRecord.title = this.modifiedTitle;
                this.ischecktitle = false;
            }
            if (this.modifiedTitle === '' && this.ischecktitle) {
                this.accountMaptoUpdate.US_WSREMS__Title__c = this.modifiedTitle;
                this.npiRecord.title = this.modifiedTitle;
                this.ischecktitle = false;
            }
            if (this.modifiedSpeciality != '' && this.modifiedSpeciality != this.speciality) {
                this.accountMaptoUpdate.US_WSREMS__Specialty__c = this.modifiedSpeciality;
                this.npiRecord.medicalSpeciality = this.modifiedSpeciality;
            }
            if (this.modifiedPosition != '' && this.modifiedPosition != this.credentials) {
                this.accountMaptoUpdate.US_WSREMS__Professional_Designation__c = this.modifiedPosition;
                this.npiRecord.designation = this.modifiedPosition;
            }
            if (this.otherTitle != '' && this.otherTitle != this.credentialsOther) {
                this.accountMaptoUpdate.US_WSREMS__Other__c = this.otherTitle;
                this.npiRecord.othercredentials = this.otherTitle;
            }
            if (this.Otherspeciality != '' && this.Otherspeciality != this.specialityOther) {
                this.accountMaptoUpdate.US_WSREMS__Other_Credentials__c = this.Otherspeciality;
                this.npiRecord.specialityOther = this.Otherspeciality;
            }
            if (this.modifiedStateLicenceNum != '' && this.modifiedStateLicenceNum != this.stateLicenceNum) {
                this.accountMaptoUpdate.US_WSREMS__SLN__c = this.modifiedStateLicenceNum;
                this.npiRecord.licenceNum = this.modifiedStateLicenceNum;
                this.checkLic = false;
            }
            if (this.modifiedStateLicenceNum === '' && this.checkLic) {
                this.accountMaptoUpdate.US_WSREMS__SLN__c = this.modifiedStateLicenceNum;
                this.npiRecord.licenceNum = this.modifiedStateLicenceNum;
                this.checkLic = false;
            }
            if (this.modifiedStateLicenceState != '' && this.modifiedStateLicenceState != this.stateLicenceNumSt) {
                this.accountMaptoUpdate.US_WSREMS__SLN_State__c = this.modifiedStateLicenceState;
                this.npiRecord.licenceNumState = this.modifiedStateLicenceState;

            }

            let updatedNpiRecord = { ...this.npiRecord };
            let inputRecords = {
                'recordDetails': JSON.stringify(updatedNpiRecord),
            };

            updateAccountDetails({ accountObject: this.accountMaptoUpdate })
                .then(result => {

                    createCaseAndServiceSummary({ 'inputRecords': inputRecords, personAccount: this.accountId, programName: this.programName })
                        .then(result => {

                            if (result == 'Success') {
                                const evt = new ShowToastEvent({
                                    title: '',
                                    message: 'Profile Updated Successfully',
                                    variant: 'success'
                                });
                                this.dispatchEvent(evt);
                                this.isLoading = false;
                                this.disableSave = false;
                                this.closeModal();
                                setTimeout(() => {
                                    return refreshApex(this._wiredResult);
                                }, 1000);
                            } else {

                            }
                        }).catch(error => {
                            this.error = error;
                            console.log('error==' + JSON.stringify(this.error));
                        });
                }).catch(error => {
                    this.error = error;
                    console.log('error==' + this.error);
                });
        }
    }
}