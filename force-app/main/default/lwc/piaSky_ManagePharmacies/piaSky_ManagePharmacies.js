import { LightningElement, track, wire } from 'lwc';
import Id from "@salesforce/user/Id";
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import DuplicateEmail from '@salesforce/label/c.PiaSky_Duplicate_email_Error_Msg';
import ValidationMsg from '@salesforce/label/c.ValidationMsg';
import Isvalid_InvalidMsg from '@salesforce/label/c.Isvalid_InvalidMsg';
import SuccessMsg from '@salesforce/label/c.SuccessMsg';
import ErrorMsg from '@salesforce/label/c.ErrorMsg';
import customHomeStyles from '@salesforce/resourceUrl/piasky_customSecure';
import createRecordOnSubmit from '@salesforce/apex/piasky_ManagePharmacies.createRecordOnSubmit';
import getPharmaAccount from '@salesforce/apex/piasky_ManagePharmacies.getPharmaAccount';
import updateAffRec from '@salesforce/apex/piasky_ManagePharmacies.updateAffRec';

export default class PiaSky_ManagePharmacies extends LightningElement {

    label = {
        DuplicateEmail,
        ValidationMsg,
        Isvalid_InvalidMsg,
        SuccessMsg,
        ErrorMsg
    };

    boolVisible = false;
    @track staffType = 'Staff';
    @track pharmaUser = {};
    @track affiliatedAcc = [];
    @track disableStaffType = false;
    @track showManageHCS = false;
    @track displaySpinner = false;
    
    @track isConfirmationModalOpen = false;
    @track confirmationModalTitle = '';
    @track confirmationModalMessage = '';
    @track currentIndex = null;


    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.handleAccount();
        
    }

    handleAccount(){
        this.displaySpinner = true;
            getPharmaAccount({userId: Id})
            .then(result =>{
                var affRec = [];
                this.disableStaffType = false;
                var i = 0;
                var data = result.acc;
                this.pharmaUser = data;
                data.US_WSREMS__Pharmacy_PreInstitutions__r.forEach(element => {
                    if(element.US_WSREMS__Pharmacy_User__r.Id != result.portalUser.Contact.AccountId){
                        affRec.push(element);
                    } 
                    if((element.US_WSREMS__Pharmacy_User__r.Id == result.portalUser.Contact.AccountId) && (element.US_WSREMS__User_Role__c != null) && (element.US_WSREMS__User_Role__c != undefined) && ((element.US_WSREMS__User_Role__c).includes('Secondary AR') || (element.US_WSREMS__User_Role__c).includes('Primary AR'))){
                        this.showManageHCS = true;
                    }
                    if(element.US_WSREMS__User_Role__c != null && element.US_WSREMS__User_Role__c != undefined && (element.US_WSREMS__User_Role__c).includes('Secondary AR')){
                        i++ ;
                        if(i >= 1){
                            this.disableStaffType = true;
                        }
                    }
                });
                this.affiliatedAcc = affRec;
                this.displaySpinner = false;
            })
            .catch(error =>{
                this.displaySpinner = false;
            })
    }

    openModal() {

        this.boolVisible = true;
    }

    handleStaffType(event){
        this.staffType = event.target.value;
        
    }

    handleChange(event) {
        this.validateInputs(event);
    }

    validateInputs(event) {

        const fieldName = event.target.name;
        let fieldValue = event.target.value;        
        let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {

            const phonePattern = /^(\s*\d\s*){10}$/;
            const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            if (fieldName === 'email' && inputField.name === fieldName && !fieldValue.match(emailPattern)) {
               
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
            }
            if(fieldName === 'phone') {                
                fieldValue = this.formatPhoneNumber(numericPhone);
                event.target.value = fieldValue;
                //this.npiRecord[event.target.name] = fieldValue.replace(/\D/g, '');
            }
        });
    }
    removeStaff(event){
        let index = event.target.dataset.index;
        this.currentIndex = index;
        this.confirmationModalTitle = "Confirmation";
        this.confirmationModalMessage = "Are you sure you want to remove the following user: " + this.affiliatedAcc[index].US_WSREMS__Pharmacy_User__r.FirstName + " " + this.affiliatedAcc[index].US_WSREMS__Pharmacy_User__r.LastName + "?";
        this.isConfirmationModalOpen = true;
    }

     handleYes() {
        this.displaySpinner = true;
        updateAffRec({affId: this.affiliatedAcc[this.currentIndex].Id})
        .then(result =>{
            if(result == 'Success'){
                this.affiliatedAcc.splice(this.currentIndex, 1);
            }
            this.displaySpinner = false;
            this.isConfirmationModalOpen = false;
        })
        .catch(error =>{
            this.displaySpinner = false;
            this.isConfirmationModalOpen = false;
        });
    }

    handleNo() {
        this.isConfirmationModalOpen = false;
    }

    sortAffiliatedAcc() {
        this.affiliatedAcc = [...this.affiliatedAcc].sort((a, b) => {
            const lastNameA = a.US_WSREMS__Pharmacy_User__r.LastName.toLowerCase();
            const lastNameB = b.US_WSREMS__Pharmacy_User__r.LastName.toLowerCase();
            return lastNameA.localeCompare(lastNameB);
        });
    }

   handleSubmit(){
       this.displaySpinner = true;
       var isValid = true;
       var submitObj = {};
       const emailPattern = /^[a-zA-Z0-9'._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

       var submitData = this.template.querySelectorAll(".modalSubmit");
       submitData.forEach(rec => {
           if (!rec.checkValidity() && rec.required== true && (rec.value =='' || rec.value == null)) {
                rec.reportValidity();
                isValid = false;   
            }
            else{
                if (rec.value && rec.value.length > 0) {
                    submitObj[rec.name] = rec.value;
                }
            }
       });

       if(submitObj.phone) {
            submitObj.phone = submitObj.phone.replace(/\D/g, '')

            if(submitObj.phone.length < 10 || submitObj.phone.length > 10) {
                this.showToast('Error', 'Please Enter a valid phone number', 'Error');
                this.showLoading = false;
                this.displaySpinner = false;
                return;
            }
        }

        if(submitObj.email) {
            var fieldValue = submitObj.email;
            if(!fieldValue.match(emailPattern)) {
                this.showToast('Error', 'Please Enter a valid email address', 'Error');
                this.showLoading = false;
                this.displaySpinner = false;
                return;
            }
        }
       submitObj['userType'] = this.staffType;
       if(isValid){
        let inputRecords = {
            'recordDetails': JSON.stringify(submitObj),
            'programName': 'PiaSky REMS',
            'participantType': 'Pharmacy/HCS Participant',
            'profileName': 'PiaSky Portal Profile',
            'permissionSet': 'PIASKY_PORTAL_PermissionSet'
        }; 

        createRecordOnSubmit({ 'inputRecords': inputRecords, pharmaAcc: this.pharmaUser.Id }).then((eachRec) => {
            if (eachRec?.length > 13) {
                this.showToast('Success', this.label.SuccessMsg, 'success');
                this.boolVisible = false;
                this.handleAccount();
                this.staffType = 'Staff';
                this.displaySpinner = false;
            }
                    
            if (eachRec === 'Failed') {
                this.showToast('Error', this.label.DuplicateEmail, 'error');
                this.displaySpinner = false;
            }
        }).catch(error => {
            this.displaySpinner = false;
            this.showToast('Error', JSON.stringify(error.body.message), 'error');
        });
       } else{
           this.displaySpinner = false;
           this.showToast('Error', 'Please Enter Valid values in the above fields', 'error');
       }
   }

   closeModal(){
       this.boolVisible = false;
   }
   
    closeConfirmationModal(){
        this.isConfirmationModalOpen = false;
    }

   showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
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