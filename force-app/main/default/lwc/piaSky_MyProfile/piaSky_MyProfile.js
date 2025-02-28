import { LightningElement,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import {refreshApex} from '@salesforce/apex';
import customHomeStyles from '@salesforce/resourceUrl/piasky_customSecure'
import getLoggedInUserDetails from '@salesforce/apex/PiaSky_MyProfileController.getLoggedInUserAccountDetails'
import updateAccountDetails from '@salesforce/apex/PiaSky_MyProfileController.updateAccountDetails'
import createCaseAndServiceSummary from '@salesforce/apex/PiaSky_MyProfileController.createCaseAndServiceSummary'

const accMap = {
    sOject: "Account",
    Id: undefined,
    US_WSREMS__Email__c: undefined,
    US_WSREMS__Preferred_Contact_Method__c: undefined,
    US_WSREMS__Participant_Title__c: undefined,
    FirstName: undefined,
    LastName: undefined,
    US_WSREMS__Other__c: undefined
}

export default class PiaSky_MyProfile extends LightningElement {
   
    npiRecord ={};
    boolVisible = false;
    disableSave = false;
    isLoading = false;
    error;
    userList = [];
    finalUserList = [];
    userName;
    accountId;
    email;
    status;
    title;
    otherTitleField;
    preferredMethodOfContact;
    firstName;
    lastName;
    modifiedFirstName = '';
    modifiedLastName = '';
    modifiedTitle = '';
    modifiedContact = '';
    otherTitle = '';
    pharmacistCheck = false;
    nurseCheck = false;
    othersCheck = false;
    phoneCheck = false;
    emailCheck = false;
    programName;
    _wiredResult;

    showTitleError = false;
    showContactError = false;

    connectedCallback() {
        loadStyle(this, customHomeStyles);
    }

    get accountMaptoUpdate(){
        return accMap;
    }

    @wire(getLoggedInUserDetails)
    userInfo(wiredResult){
        this.npiRecord = {};
        const{data, error} = wiredResult;
        this._wiredResult = wiredResult;
        if(data){
            this.userList = data;
            let relatedAccountsarray = [];
            for(let row of this.userList){
                const flattenedRow = {}
                let rowKeys =  Object.keys(row);
                rowKeys.forEach((rowKey) => {
                    const singleNodeValue = row[rowKey];
                    if(singleNodeValue.constructor === Object) {
                         this._flatten(singleNodeValue, flattenedRow, rowKey);
                    } else{
                        flattenedRow[rowKey] = singleNodeValue;
                    }
                });
                relatedAccountsarray.push(flattenedRow);
                this.finalUserList = relatedAccountsarray;
                for (let key in this.finalUserList) {
                    //onsole.log('data=='+JSON.stringify(data));
                    this.userName = data[key].Account.Name;
                    this.accountId = data[key].Account.Id;
                    this.status = data[key].Account.US_WSREMS__Status__c;
                    this.title = data[key].Account.US_WSREMS__Participant_Title__c;
                    this.email = data[key].Account.US_WSREMS__Email__c;
                    this.firstName = data[key].Account.FirstName;
                    this.lastName = data[key].Account.LastName;
                    this.otherTitleField = data[key].Account.US_WSREMS__Other__c;
                    this.preferredMethodOfContact = data[key].Account.US_WSREMS__Preferred_Contact_Method__c;
                    this.npiRecord.preferredContactMethod = this.preferredMethodOfContact;
                    this.programName = data[key].Account.Program_Name__c;
                    this.npiRecord.title = this.title;
                    this.npiRecord.firstName = this.firstName; 
                    this.npiRecord.middleName = data[key].Account.MiddleName;
                    this.npiRecord.lastName = this.lastName;
                    this.npiRecord.phone = data[key].Account.Phone;
                    this.npiRecord.address1 = data[key].Account.US_WSREMS__Address_Line_1__c;
                    this.npiRecord.city = data[key].Account.US_WSREMS__City__c;
                    this.npiRecord.state = data[key].Account.US_WSREMS__State__c;
                    this.npiRecord.zip= data[key].Account.US_WSREMS__Zip__c;
                    this.npiRecord.npi = data[key].Account.US_WSREMS__National_Provider_Identifier__c;
                    this.npiRecord.fax = data[key].Account.US_WSREMS__Fax_Number__c;
                    this.npiRecord.email = data[key].Account.US_WSREMS__Email__c;
                    if(this.title == "Pharmacist"){
                        this.pharmacistCheck = true;
                    } else if(this.title == "Nurse"){
                        this.nurseCheck = true;
                    } else if(this.title == "Other"){
                        this.othersCheck = true;
                        this.otherTitleField = this.title +' '+ data[key].Account.US_WSREMS__Other__c;
                    }

                    if(this.preferredMethodOfContact == "Phone"){
                        this.phoneCheck = true;
                    } else if(this.preferredMethodOfContact == "Email"){
                        this.emailCheck = true;
                    }
                }
            }
        }
        if(error){
            this.error = error;
        }
    }

    _flatten(nodeValue, flattenedRow, nodeName){
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            flattenedRow[finalKey] = nodeValue[key];
        })
    }

    openModal() {
        this.boolVisible = true;
    }

    handleInputChange(event){
        this.eventName = event.target.name;        
        let otherElement = this.template.querySelector('.otherElement');
        if(this.eventName == "firstName"){
            this.modifiedFirstName = event.target.value;
        } else if(this.eventName == "lastName"){
            this.modifiedLastName = event.target.value;
        } else if(this.eventName == "title"){
            this.modifiedTitle = event.target.value;       
            if(this.modifiedTitle == "Pharmacist"){
                this.pharmacistCheck = true;
                this.nurseCheck = false;
                this.othersCheck = false;
                this.showTitleError = false; 
            } else if(this.modifiedTitle == "Nurse"){
                this.nurseCheck = true;
                this.othersCheck = false;
                this.pharmacistCheck = false;
                 this.showTitleError = false; 
            } else {
                this.othersCheck = true;
                this.pharmacistCheck = false;
                this.nurseCheck = false;
                 this.showTitleError = false; 
            }
            if(this.modifiedTitle == "Other"){
                otherElement.classList.remove('slds-hide');
            } else {
                otherElement.classList.add('slds-hide');
            }
        } else if(this.eventName == "contact"){
            this.modifiedContact = event.target.value;
            if(this.modifiedContact == "Phone"){
                this.phoneCheck = true;
                this.emailCheck = false;
                this.showContactError = false; 
            } else if(this.modifiedContact == "Email"){
                this.emailCheck = true;
                this.phoneCheck = false;
                this.showContactError = false; 
            }
        } else if(this.eventName == "othersTitle"){
            this.otherTitle = event.target.value;
        }

    }

    closeModal(){
        this.boolVisible = false;
        this.modifiedFirstName = '';
        this.modifiedLastName = '';
        this.modifiedTitle = '';
        this.modifiedContact = '';
        this.otherTitle = '';
    }
    
    saveModal(){
        if((this.modifiedTitle === '' || this.modifiedTitle === undefined) && (this.title === '' ||  this.title === undefined)) {
            this.showTitleError = true;
        }
        if((this.modifiedContact === '' || this.modifiedContact === undefined ) && (this.preferredMethodOfContact  === '' || this.preferredMethodOfContact  === undefined)) {
            this.showContactError = true;
        }  
      if((this.modifiedTitle != "" || this.title != undefined ) && (this.modifiedContact != "" || this.preferredMethodOfContact != undefined)){ 
      
        this.disableSave = true;
        this.isLoading = true;
        this.accountMaptoUpdate.Id = this.accountId;
        if(this.modifiedFirstName != '' && this.modifiedFirstName != this.firstName){
            this.accountMaptoUpdate.FirstName = this.modifiedFirstName;
            this.npiRecord.firstName = this.modifiedFirstName;
        }
        if(this.modifiedLastName != '' && this.modifiedLastName != this.lastName){
            this.accountMaptoUpdate.LastName = this.modifiedLastName;
            this.npiRecord.lastName = this.modifiedLastName;
        }
        if(this.modifiedTitle != '' && this.modifiedTitle != this.title){
            this.accountMaptoUpdate.US_WSREMS__Participant_Title__c = this.modifiedTitle;
            this.npiRecord.title = this.modifiedTitle;
        }
        if(this.modifiedContact != '' && this.modifiedContact != this.preferredMethodOfContact){
            this.accountMaptoUpdate.US_WSREMS__Preferred_Contact_Method__c = this.modifiedContact;
            this.npiRecord.preferredContactMethod =  this.modifiedContact;
        }
        if(this.otherTitle != ''){
            this.accountMaptoUpdate.US_WSREMS__Other__c = this.otherTitle;
            this.npiRecord.otherContact = this.otherTitle;
        }

        let updatedNpiRecord = {...this.npiRecord};
        let inputRecords = {
            'recordDetails': JSON.stringify(updatedNpiRecord),
        }; 

        updateAccountDetails({accountObject : this.accountMaptoUpdate})
            .then(result => {
                createCaseAndServiceSummary({ 'inputRecords': inputRecords, personAccount : this.accountId, programName : this.programName})
                    .then(result=>{
                        if(result == 'Success'){
                            const evt = new ShowToastEvent({
                                title:'',
                                message:'Profile Updated Successfully' ,
                                variant:'success'
                            });
                            this.dispatchEvent(evt);
                            this.isLoading = false;
                            this.disableSave = false;
                            this.pharmacistCheck = false;
                            this.nurseCheck = false;
                            this.othersCheck = false;
                            this.phoneCheck = false;
                            this.emailCheck = false;
                            this.closeModal();
                            setTimeout(() =>{
                                return refreshApex(this._wiredResult);
                            },1000);
                        } else {
                            console.log('Account Update Failed');
                        }
                    }).catch(error => {
                        this.error = error;
                    });
            }).catch(error => {
                this.error = error;
            });
    }
    }
    
}