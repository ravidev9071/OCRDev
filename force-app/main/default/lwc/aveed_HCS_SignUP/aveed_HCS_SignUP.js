import { LightningElement, api, track } from 'lwc';
import createRecordOnSubmit from '@salesforce/apex/NPISearchControllerPortal.createRecordOnSubmit';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ValidationMsg from '@salesforce/label/c.ValidationMsg';
import Isvalid_InvalidMsg from '@salesforce/label/c.Isvalid_InvalidMsg';
import SuccessMsg from '@salesforce/label/c.SuccessMsg';
import ErrorMsg from '@salesforce/label/c.ErrorMsg';
import checkduplicate from '@salesforce/apex/NPISearchControllerPortal.checkARduplicate';
export default class Aveed_HCS_SignUP extends LightningElement {
    label = {
        
        ValidationMsg,
        Isvalid_InvalidMsg,
        SuccessMsg,
        ErrorMsg
    };
     @api programName = '';
     @api  participantType = '';
     @api  profileName = '';
     @api  permissionSet = '';
    FirstName;
    LastName;
    Email;
    Phone;
    npiRecord ={};
    showLoading = false;
    displaySpinner = false;
    confirmEmail= '';
    email='';
    
    connectedCallback() {
        loadStyle(this, customHomeStyles);     
        let css = this.template.host.style;
        css.setProperty('--lwc-colorTextLabel', this.fontColor);
        css.setProperty('--lwc-formLabelFontSize', this.fontSize);  

    }
    handleChange(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value;
        if(fieldName == 'phone' && fieldValue) {
            event.target.value = this.formatPhoneNumber(fieldValue);
        }
        this.validateInputs(event);
    }
    handleChangeEmail(event) {
        this.email = event.target.value;
        this.validateInputs(event);   
    }
    handlConfirmEmailChange(event) {
        this.confirmEmail = event.target.value;
    }
    validateInputs(event) {

        const fieldName = event.target.name;
        let fieldValue = event.target.value; 
           
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {

            const phonePattern = /^(\s*\d\s*){10}$/;
            const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const namePatterns = /^[A-Za-z'. -]+$/;
           
            if (fieldName === 'email' && inputField.name === fieldName && !fieldValue.match(emailPattern)) {
               
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid email address.');
                inputField.reportValidity();
            } if (fieldName === 'email' && inputField.name === fieldName && fieldValue.match(emailPattern)) {
               this.Email=fieldValue;
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            } if (fieldName === 'phone' && inputField.name === fieldName && !numericPhone.match(phonePattern)) {
                
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid Phone Number.');
                inputField.reportValidity();
            } if (fieldName === 'phone' && inputField.name === fieldName && numericPhone.match(phonePattern)) {
                this.Phone=fieldValue;
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            } if (fieldName === 'lastName' && inputField.name === fieldName && !fieldValue.match(namePatterns)) {
                
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid Name.');
                inputField.reportValidity();
            } if (fieldName === 'lastName' && inputField.name === fieldName && fieldValue.match(namePatterns)) {
                this.LastName=fieldValue;
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            } if (fieldName === 'firstName' && inputField.name === fieldName && !fieldValue.match(namePatterns)) {
              
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid Name.');
                inputField.reportValidity();
            } if (fieldName === 'firstName' && inputField.name === fieldName && fieldValue.match(namePatterns)) {
                this.FirstName=fieldValue;
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }

          //  this.npiRecord[event.target.name] = fieldValue;
           
           
             
            
        });
    }
    handleSubmitKeyword() {
       if (this.email !== this.confirmEmail) {
            this.showToast('Warning', 'Email and Confirm Email must match', 'warning');
            return;
        } 
         this.showLoading = true;
         this.displaySpinner = true;
         
         this.disabled = true;
         this.showError = false;
         this.errorFields = [];
 
         const namePatterns = /^[A-Za-z'. -]+$/;
 
         let updatedNpiRecord = {};
         let inputFields = this.template.querySelectorAll('.validate');
             inputFields.forEach(inputField => {
                 if(inputField.required== true && (inputField.value =='' || inputField.value == null) ) {
                    this.showError = true;
                    this.errorFields.push(inputField.label);
                 }        
         });
 
         if(this.Phone) {
             updatedNpiRecord.phone = this.Phone.replace(/\D/g, '')
         }
         
 
         const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
             .reduce((validSoFar, inputField) => {
                 inputField.reportValidity();
                 return validSoFar && inputField.checkValidity();
             }, true);
 
         
         updatedNpiRecord.participantType = this.participantType;
        updatedNpiRecord.firstName = this.FirstName;
         updatedNpiRecord.lastName=this.LastName;
        updatedNpiRecord.email=this.Email;
 
         if (isInputsCorrect) {    
 
             let inputRecords = {
                 'recordDetails': JSON.stringify(updatedNpiRecord),
                 'programName': this.programName,
                 'participantType': this.participantType,
                 'profileName':this.profileName,
                 'permissionSet':this.permissionSet
             };   
             
            checkduplicate({ 'inputRecords': inputRecords  }).then((eachRecord)=>{
                if (eachRecord === 'NotFound') {       
                createRecordOnSubmit({ 'inputRecords': inputRecords }).then((eachRec) => {
                 if (eachRec?.length > 13) {
                     this.showToast('Success', this.label.SuccessMsg, 'success');
                     this.disabled = false;
                     this.showDetails = false;
                     localStorage.setItem("userId", eachRec);
                     var url = window.location.href; 
                     window.open("\signup-confirmation", "_self");
                 }      
                 if (eachRec === 'Failed') {
                     this.showToast('Error', this.label.ErrorMsg, 'error');
                 }
                 this.showLoading = false;
                 this.displaySpinner = false;
             }).catch(error => {
                 this.disabled = true;
                 this.showLoading = false;
                 this.displaySpinner = false;
                 this.showToast('Error', JSON.stringify(error.body.message), 'error');
             });
            }else{
                this.showToast('Error', this.label.ValidationMsg, 'error');
                this.showLoading = false;
                this.displaySpinner = false;
               
            }

            }).catch(error => {
                 this.disabled = true;
                 this.showLoading = false;
                 this.displaySpinner = false;
                 this.showToast('Error', JSON.stringify(error.body.message), 'error');
             });
           
         } else {
            this.showLoading = false;
             this.displaySpinner = false;
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

}