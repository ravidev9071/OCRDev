import { LightningElement,track,wire} from 'lwc';
import { loadStyle} from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customSecure';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex} from '@salesforce/apex';
import getLoggedInUserDetails from '@salesforce/apex/xiaflex_MyProfileController.getLoggedInUserAccountDetails';
import updateAccountDetails from '@salesforce/apex/xiaflex_MyProfileController.updateAccountDetails';
import { getObjectInfo, getPicklistValues} from "lightning/uiObjectInfoApi";
import Statefields from '@salesforce/schema/Account.US_WSREMS__SLN_State__c';
import ACCOUNT_OBJECT from "@salesforce/schema/Account";

const accMap = {
    sOject: "Account",
    Id: undefined,
    nameValue: undefined,
    middleName: undefined,
    FirstName: undefined,
    LastName: undefined,
    PersonEmail: undefined,
    Phone: undefined,
    US_WSREMS__Phone_Type__c: undefined,
    Fax: undefined,
    US_WSREMS__Preferred_Contact_Method__c: undefined,
    US_WSREMS__Professional_Designation__c: undefined,
    Medical_Specialty__c: undefined,
    US_WSREMS__SLN__c: undefined,
    US_WSREMS__SLN_State__c: undefined,
    US_WSREMS__Other_Credentials__c: undefined,
    Salutation: undefined,
    US_WSREMS__Role__c: undefined

}


export default class Xiaflex_myProfile extends LightningElement {


    get accountMaptoUpdate() {
        return accMap;

    }
    get roleOptions() {
        return [
            { label: 'Office Staff', value: 'Office Staff' },
            { label: 'Clinician/Healthcare Provider', value: 'Clinician/ Healthcare Provider' },
            { label: 'Office Administration', value: 'Office Admin' },
            { label: 'Other (Specify)', value: 'Other' },
        ];
    }
     handleRole(event) {
        if (event.target.value == 'Other') {
            this.displayOthers = true;
        }
        else {
            this.displayOthers = false;
        }
    }
    
    get salOption() {
        return [
            { label: 'Dr', value: 'Dr' },
            { label: 'Mr', value: 'Mr' },
            { label: 'Ms', value: 'Ms' },
        ];
    }
    get conOption() {
        return [
            { label: 'Email', value: 'Email' },
            { label: 'Fax', value: 'Fax' },
        ];
    }
    @track displayOthers = false;
    @track isShowModal = false;
    accountRecordTypeId;
    ratings;
    picklistValues = [];
    @track stateOptions = [];
    error;
    data;
    disableSave = false;
    displaySpinner = false;
    pagerefresh;
    @track enrollmentidvalue;
    @track status;
    @track emailvalue;
    @track phonevalue;
    @track phonetypevalue;
    @track faxvalue;
    @track preferredcommunicationvalue;
    @track mevalue;
    @track licensevalue;
    @track licensestatevalue;
    @track firstnamevalue;
    @track middlenamevalue;
    @track lastnamevalue;
    @track suffixvalue;
    @track accountId;
    @track Salutation;
    @track role;
    @track otherRole;

    modifiedfirstName = '';
    modifiedlastName = '';
    modifiedmiddleName = '';
    modifiedPhone = '';
    modifiedemail = ''
    modifiedPhoneType = '';
    modifiedFax = '';
    modifiedpreferredcommunication = '';
    modifiedDegree = '';
    modifiedSpecialty = '';
    modifiedLicense = '';
    modifiedSalutation = '';
    otherSpecial = '';
    modifiedRole = '';
    modifiedOtherRole = '';
    modifiedsuffixvalue = '';

  

    openModal() {
        this.isShowModal = true;
    }

    closeModal() {
        this.modifiedfirstName = '';
        this.modifiedlastName = '';
        this.modifiedmiddleName = '';
        this.modifiedPhone = '';
        this.modifiedemail = ''
        this.modifiedPhoneType = '';
        this.modifiedFax = '';
        this.modifiedpreferredcommunication = '';
        this.modifiedSalutation = '';
        this.modifiedOtherRole = '';
        this.modifiedRole = '';
        this.isShowModal = false;
        
    }
    handleInputChange(event) {

        this.eventName = event.target.name;
        let fieldValue = event.target.value;
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        const phonePattern = /^(\s*\d\s*){10}$/;
        
        if (this.eventName == "firstName") {
            this.modifiedfirstName = event.target.value;
        } else if (this.eventName == "middleName") {
            this.modifiedmiddleName = event.target.value;
        } else if (this.eventName == "lastName") {
            this.modifiedlastName = event.target.value;
        } else if (this.eventName == "email") {
            this.modifiedemail = event.target.value;
        } else if (this.eventName == "Phone") {
            if(!numericPhone.match(phonePattern)){
                event.target.classList.add('slds-has-error');
                event.target.setCustomValidity('Please enter a valid Phone Number.');
                event.target.reportValidity();
            } else {
                event.target.classList.remove('slds-has-error');
                event.target.setCustomValidity('');
                event.target.reportValidity();
            }
            fieldValue = this.formatPhoneNumber(numericPhone);
            event.target.value = fieldValue;
            this.modifiedPhone = event.target.value;
        } else if (this.eventName == "Fax") {
            if(!numericPhone.match(phonePattern)){
                event.target.classList.add('slds-has-error');
                event.target.setCustomValidity('Please enter a valid Phone Number.');
                event.target.reportValidity();
            } else {
                event.target.classList.remove('slds-has-error');
                event.target.setCustomValidity('');
                event.target.reportValidity();
            }
            fieldValue = this.formatPhoneNumber(numericPhone);
            event.target.value = fieldValue;
            this.modifiedFax = fieldValue;
        } else if (this.eventName == "Salutation") {
            this.modifiedSalutation = event.target.value;
        } else if (this.eventName == "ContactMethod") {
            this.modifiedpreferredcommunication = event.target.value;
        } else if (this.eventName == "PhoneType") {
            this.modifiedPhoneType = event.target.value;
           
        } else if (this.eventName == "role") {
            this.modifiedRole = event.target.value;;
             if (event.target.value == 'Other') {
            this.displayOthers = true;
            }
             else {
            this.displayOthers = false;
            } 
            

        } 
        if (this.eventName == "otherRole") {
            this.modifiedOtherRole = event.target.value;
        } 
        if(this.eventName == "Suffix"){
            this.modifiedsuffixvalue = event.target.value;
        }

    }
    saveModal() {
        this.accountMaptoUpdate.Id = this.accountId;
        if (this.modifiedfirstName != '' && this.modifiedfirstName != this.firstnamevalue) {
            this.accountMaptoUpdate.FirstName = this.modifiedfirstName;
        }
        if (this.modifiedmiddleName != '' && this.modifiedmiddleName != this.middlenamevalue) {
            this.accountMaptoUpdate.middleName = this.modifiedmiddleName;
        }
        if (this.modifiedlastName != '' && this.modifiedlastName != this.lastnamevalue) {
            this.accountMaptoUpdate.LastName = this.modifiedlastName;
        }
        if (this.modifiedemail != '' && this.modifiedemail != this.emailvalue) {
            this.accountMaptoUpdate.PersonEmail = this.modifiedemail;
        }
        if (this.modifiedSalutation != '' && this.modifiedSalutation != this.Salutation) {
            this.accountMaptoUpdate.Salutation = this.modifiedSalutation;
        }
        if (this.modifiedPhone != '' && this.modifiedPhone != this.phonevalue) {
            this.accountMaptoUpdate.Phone = this.modifiedPhone;
        }
        if (this.modifiedFax != '' && this.modifiedFax != this.faxvalue) {
            this.accountMaptoUpdate.Fax = this.modifiedFax;
        }
        if(this.role != this.modifiedRole && this.modifiedRole != ''){
            this.accountMaptoUpdate.US_WSREMS__Role__c = this.modifiedRole;
        }
        if(this.otherRole != this.modifiedOtherRole && this.modifiedOtherRole != ''){
            this.accountMaptoUpdate.US_WSREMS__Other__c = this.modifiedOtherRole;
        }  
         if(this.suffixvalue != this.modifiedsuffixvalue && this.modifiedsuffixvalue != ''){
            this.accountMaptoUpdate.US_WSREMS__Legal_Guardian_Name__c = this.modifiedsuffixvalue;

        }
        if (this.modifiedpreferredcommunication != '' && this.modifiedpreferredcommunication != this.preferredcommunicationvalue) {
            this.accountMaptoUpdate.US_WSREMS__Preferred_Contact_Method__c = this.modifiedpreferredcommunication;
        }
        refreshApex(this.pagerefresh);
        refreshApex(this.data);
        refreshApex(this.userInfo);
        this.displaySpinner = true;
        updateAccountDetails({
                accountObject: this.accountMaptoUpdate
            })
            .then(result =>{

                if(result == 'Success')
                {
                    const evt = new ShowToastEvent({
                        title:'',
                        message:'Profile Updated Successfully' ,
                        variant:'success'
                    }); 
                    this.dispatchEvent(evt);
                }
                refreshApex(this.pagerefresh);
                refreshApex(this.data);
                refreshApex(this.userInfo);
                this.getAccDetails();
                this.displaySpinner = false;
            })
            .catch(error => {
                this.displaySpinner = false;
                this.error = error;
            });
        this.isShowModal = false;
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        //this.getPickListValues();
        this.getAccDetails();
    
    }

 
    getAccDetails() {
        this.displaySpinner = true;
        getLoggedInUserDetails()
            .then(result => {
                //  this.NPIVALUE = data[0].Account.US_WSREMS__National_Provider_Identifier__c;
                this.enrollmentidvalue = result[0].Account.US_WSREMS__REMS_ID__c;
                this.status = result[0].Account.US_WSREMS__Status__c;
                this.npivalue = result[0].Account.US_WSREMS__National_Provider_Identifier__c;
                this.emailvalue = result[0].Account.PersonEmail;
                this.phonevalue = result[0].Account.Phone
                this.phonetypevalue = result[0].Account.US_WSREMS__Phone_Type__c;
                this.faxvalue = result[0].Account.Fax;
                this.preferredcommunicationvalue = result[0].Account.US_WSREMS__Preferred_Contact_Method__c;
                this.Salutation = result[0].Account.Salutation;
                this.specialityvalue = result[0].Account.Medical_Specialty__c;
                this.otherspecialityvalue = result[0].Account.US_WSREMS__Other_Credentials__c;
                this.nameValue = result[0].Account.Name;
                this.role = result[0].Account.US_WSREMS__Role__c;
                this.suffixvalue = result[0].Account.US_WSREMS__Legal_Guardian_Name__c
                if (result[0].Account.US_WSREMS__Role__c == 'Other') {
                    this.otherRole = result[0].Account.US_WSREMS__Other__c;
                    this.displayOthers = true;
                } else{
                  this.displayOthers = false;
                }
                this.licensevalue = result[0].Account.US_WSREMS__SLN__c;
                this.licensestatevalue = result[0].Account.US_WSREMS__SLN_State__c;
                this.firstnamevalue = result[0].Account.FirstName;
                this.middlenamevalue = result[0].Account.MiddleName;
                this.lastnamevalue = result[0].Account.LastName;
                this.accountId = result[0].Account.Id;
               

                this.displaySpinner = false;
            })
            .catch(error => {
                this.displaySpinner = false;
                console.log('error==' + JSON.stringify(error));
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

}