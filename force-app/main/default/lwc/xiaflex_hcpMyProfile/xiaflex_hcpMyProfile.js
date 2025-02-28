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
import getStateListValues from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getPicklistFieldValues';
import getPickListValues from '@salesforce/apex/xiaflex_MyProfileController.getPicklistFieldValues'

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
    US_WSREMS__Other_Credentials__c: undefined
}


export default class Xiaflex_myProfile extends LightningElement {


    get accountMaptoUpdate() {
        return accMap;

    }
    @track displaySpinner = false;
    @track isShowModal = false;
    accountRecordTypeId;
    ratings;
    picklistValues = [];
    @track stateOptions = [];
    error;
    data;
    disableSave = false;
    pagerefresh;
    @track remsStatus;
    @track enrollmentidvalue;
    @track npivalue;
    @track emailvalue;
    @track phonevalue;
    @track phonetypevalue;
    @track faxvalue;
    @track preferredcommunicationvalue;
    @track degreevalue;
    @track specialityvalue;
    @track otherspecialityvalue;
    @track mainspecialityvalue;
    @track mevalue;
    @track licensevalue;
    @track licensestatevalue;
    @track firstnamevalue;
    @track middlenamevalue;
    @track lastnamevalue;
    @track suffixvalue;
    @track accountId;
    @track hcsEntry = false;
    //@track ShippingState = [];
    @track stateOptions = [];
    generalsurgeoncheck = true;
    plasticsurgeoncheck = false;
    urologistcheck = false;
    othersCheck = false;
    otherspeciality;

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
    modifiedLicenseState = '';
    otherSpecial = '';
    modifiedsuffix = '';
    modifiedME = '';

    getPicklistValuesForField({
        data,
        error
    }) {
        if (error) {
            // TODO: Error handling
            console.error(error)
        } else if (data) {
            this.picklistValues = [...data.values]
        }
    }

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
        this.modifiedDegree = '';
        this.modifiedSpecialty = '';
        this.modifiedLicense = '';
        this.modifiedLicenseState = '';
        this.otherSpecial = ''; 
        this.isShowModal = false;
        
    }
    handleInputChange(event) {

        this.eventName = event.target.name;
        //let otherElement = this.template.querySelector('.otherElement');
        let fieldValue = event.target.value;
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        const phonePattern = /^(\s*\d\s*){10}$/;
        
        if(this.eventName == "ME"){
            this.modifiedME = event.target.value;
        }else if (this.eventName == "suffix") {
            this.modifiedsuffix = event.target.value;
        } else if (this.eventName == "firstName") {
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
            this.modifiedPhone = fieldValue;
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
        } else if (this.eventName == "License") {
            this.modifiedLicense = event.target.value;
        } else if (this.eventName == "LicenseState") {
            this.modifiedLicenseState = event.target.value;
        } else if (this.eventName == "Communication") {
            this.modifiedpreferredcommunication = event.target.value;
            if (this.modifiedpreferredcommunication == "Email") {
                this.emailcheck = true;
                this.faxcheck = false;
            } else if (this.modifiedpreferredcommunication == "Fax") {
                this.emailcheck = false;
                this.faxcheck = true;
            }
        } else if (this.eventName == "PhoneType") {
            this.modifiedPhoneType = event.target.value;
            if (this.modifiedPhoneType == "Office") {
                this.officecheck = true;
                this.mobilecheck = false;
                this.homecheck = false;
            } else if (this.modifiedPhoneType == "Mobile") {
                this.officecheck = false;
                this.mobilecheck = true;
                this.homecheck = false;
            } else {
                this.officecheck = false;
                this.mobilecheck = false;
                this.homecheck = true;
            }
        } else if (this.eventName == "Degree") {
            this.modifiedDegree = event.target.value;
            if (this.modifiedDegree == "MD") {
                this.mdcheck = true;
                this.docheck = false;
                this.pacheck = false;
                this.cnpcheck = false;
            } else if (this.modifiedDegree == "DO") {
                this.mdcheck = false;
                this.docheck = true;
                this.pacheck = false;
                this.cnpcheck = false;
            } else if (this.modifiedDegree == "PA") {
                this.mdcheck = false;
                this.docheck = false;
                this.pacheck = true;
                this.cnpcheck = false;
            } else {
                this.mdcheck = false;
                this.docheck = false;
                this.pacheck = false;
                this.cnpcheck = true;
            }
        } else if (this.eventName == "Specialty") {
            this.modifiedSpecialty = event.target.value;
            /*
                if(this.modifiedSpecialty == "Others"){
                    otherElement.classList.remove('slds-hide');
                } else {
                    otherElement.classList.add('slds-hide');
                }
            */
            if (this.modifiedSpecialty == "General Surgeon") {
                this.generalsurgeoncheck = true;
                this.plasticsurgeoncheck = false;
                this.urologistcheck = false;
                this.hcsEntry = false;
                //  this.othersCheck = false;
            } else if (this.modifiedSpecialty == "Plastic Surgeon") {
                this.generalsurgeoncheck = false;
                this.plasticsurgeoncheck = true;
                this.urologistcheck = false;
                this.hcsEntry = false;
                this.othersCheck = false;
            } else if (this.modifiedSpecialty == "Urologist") {
                this.generalsurgeoncheck = false;
                this.plasticsurgeoncheck = false;
                this.urologistcheck = true;
                this.hcsEntry = false;
                // this.othersCheck = false;

            } else {
                this.otherscheck = true;
                this.hcsEntry = true;
                this.generalsurgeoncheck = false;
                this.plasticsurgeoncheck = false;
                this.urologistcheck = false;

            }


        } else if (this.eventName == "SpecialtyOther") {
            this.otherSpecial = event.target.value;
        }

    }
    saveModal() {
        this.displaySpinner = true;
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
        if (this.modifiedPhone != '' && this.modifiedPhone != this.phonevalue) {
            this.accountMaptoUpdate.Phone = this.modifiedPhone;
        }
        if (this.modifiedPhoneType != '' && this.modifiedPhoneType != this.phonetypevalue) {
            this.accountMaptoUpdate.US_WSREMS__Phone_Type__c = this.modifiedPhoneType;
        }
        if (this.modifiedFax != '' && this.modifiedFax != this.faxvalue) {
            this.accountMaptoUpdate.Fax = this.modifiedFax;
        }
        if (this.modifiedpreferredcommunication != '' && this.modifiedpreferredcommunication != null) {
            this.accountMaptoUpdate.US_WSREMS__Preferred_Contact_Method__c = this.modifiedpreferredcommunication;
        }
        if (this.modifiedDegree != '' && this.modifiedDegree != this.degreevalue) {
            this.accountMaptoUpdate.US_WSREMS__Professional_Designation__c = this.modifiedDegree;
        }
        if (this.modifiedSpecialty != '' && this.modifiedSpecialty != this.specialityvalue) {
            this.accountMaptoUpdate.Medical_Specialty__c = this.modifiedSpecialty;
        }
        if (this.modifiedLicense != '' && this.modifiedLicense != this.licensevalue) {
            this.accountMaptoUpdate.US_WSREMS__SLN__c = this.modifiedLicense;
        }
        if (this.modifiedLicenseState != '' && this.modifiedLicenseState != this.licensestatevalue) {
            this.accountMaptoUpdate.US_WSREMS__SLN_State__c = this.modifiedLicenseState;
        }
        if (this.otherSpecial != '') {
            this.accountMaptoUpdate.US_WSREMS__Other_Credentials__c = this.otherSpecial;
        }
        if(this.modifiedsuffix != '' && this.modifiedsuffix != this.suffixvalue){
             this.accountMaptoUpdate.US_WSREMS__Legal_Guardian_Name__c = this.modifiedsuffix;
        }
        if(this.modifiedME != '' && this.modifiedME != this.mevalue){
             this.accountMaptoUpdate.US_WSREMS__Legal_Guardian_Relationship__c = this.modifiedME;
        }

        refreshApex(this.pagerefresh);
        refreshApex(this.data);
        refreshApex(this.userInfo);

        updateAccountDetails({
                accountObject: this.accountMaptoUpdate
            })
            .then(result =>{

                if(result == 'Success')
                {this.displaySpinner = false;
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
            })
            .catch(error => {
                this.error = error;
                console.log('error==' + JSON.stringify(this.error));
            });
        this.isShowModal = false;
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.getStateListValues();
        this.getAccDetails();
        
    }

    getStateListValues(){
        getStateListValues()
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
                })
                .catch((error) => {
                    console.log('Error is', error);
                });
    }

    generateOptions(options) {
        return options.map(option => ({
            label: option.charAt(0).toUpperCase() + option.slice(1),
            value: option.toLowerCase()
        }));
    }
/*
    getpick()
    {
        const departments = ['','AK','AL','AR','AS','AZ','CA','CO','CT','DC','DE','FL','GA','GU','HI','IA','ID','IL','IN','KS','KY','LA','MA','MD','ME','MI','MN','MO','MP','MS','MT','NC','ND','NE','NH','NJ','NM','NV','NY','OH','OK','OR','PA','PR','RI','SC','SD','TN','TX','UT','VA','VI','VT','WA','WI','WV','WY'];// Your list of departments
        this.ShippingState = this.generateOptions(departments);
    }
        */

    getPickListValues() {
        getPickListValues()
            .then((pickListVal) => {
                var stateOptionList = pickListVal.US_WSREMS__SLN_State__c;

                // this.selectOptions.push(option);

                for (var i in stateOptionList) {
                    const option = {
                        label: i,
                        value: stateOptionList[i]
                    };
                    this.stateOptions = [...this.stateOptions, option];
                }
            })
            .catch((error) => {
                // This way you are not to going to see [object Object]
                console.log('Error is', error);
            });
    }

    getAccDetails() {
        getLoggedInUserDetails()
            .then(result => {
                //  this.NPIVALUE = data[0].Account.US_WSREMS__National_Provider_Identifier__c;
                this.enrollmentidvalue = result[0].Account.US_WSREMS__REMS_ID__c;
                this.npivalue = result[0].Account.US_WSREMS__National_Provider_Identifier__c;
                this.emailvalue = result[0].Account.PersonEmail;
                this.phonevalue = result[0].Account.Phone != null && result[0].Account.Phone != '' ? this.formatPhoneNumber(result[0].Account.Phone) : '';
                this.phonetypevalue = result[0].Account.US_WSREMS__Phone_Type__c;
                this.faxvalue = result[0].Account.Fax != null && result[0].Account.Fax != '' ? this.formatPhoneNumber(result[0].Account.Fax) : '';
                this.preferredcommunicationvalue = result[0].Account.US_WSREMS__Preferred_Contact_Method__c;
                this.degreevalue = result[0].Account.US_WSREMS__Professional_Designation__c;
                this.specialityvalue = result[0].Account.Medical_Specialty__c;
                this.otherspecialityvalue = result[0].Account.US_WSREMS__Other_Credentials__c;
                this.nameValue = result[0].Account.Name;
                if (result[0].Account.Medical_Specialty__c == 'Other') {
                    this.mainspecialityvalue = result[0].Account.US_WSREMS__Other_Credentials__c;
                } else {
                    this.mainspecialityvalue = result[0].Account.Medical_Specialty__c;
                }

//US_WSREMS__Legal_Guardian_Name__c
                this.mevalue = result[0].Account.US_WSREMS__Legal_Guardian_Relationship__c;
                this.suffixvalue = result[0].Account.US_WSREMS__Legal_Guardian_Name__c;
                this.licensevalue = result[0].Account.US_WSREMS__SLN__c;
                this.licensestatevalue = result[0].Account.US_WSREMS__SLN_State__c;
                this.firstnamevalue = result[0].Account.FirstName;
                this.middlenamevalue = result[0].Account.MiddleName;
                this.lastnamevalue = result[0].Account.LastName;
                this.accountId = result[0].Account.Id;
                this.remsStatus = result[0].Account.US_WSREMS__Status__c;
                if (this.phonetypevalue == "Office") {
                    this.officecheck = true;
                } else if (this.phonetypevalue == "Mobile") {
                    this.mobilecheck = true;
                } else {
                    this.homecheck = true;
                }
                if (this.preferredcommunicationvalue == "Email") {
                    this.emailcheck = true;
                    this.faxcheck = false;
                } else if (this.preferredcommunicationvalue == "Fax") {
                    this.faxcheck = true;
                    this.emailcheck = false;
                }

                if (this.degreevalue == "MD") {
                    this.mdcheck = true;
                } else if (this.degreevalue == "DO") {
                    this.docheck = true;
                } else if (this.degreevalue == "PA") {
                    this.pacheck = true;
                } else {
                    this.cnpcheck = true;
                }

                if (this.specialityvalue == "General Surgeon") {
                    this.generalsurgeoncheck = true;
                } else if (this.specialityvalue == "Plastic Surgeon") {
                    this.plasticsurgeoncheck = true;
                } else if (this.specialityvalue == "Urologist") {
                    this.urologistcheck = true;
                } else {
                    this.otherscheck = true;
                    this.hcsEntry = true;
                }


            })
            .catch(error => {
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