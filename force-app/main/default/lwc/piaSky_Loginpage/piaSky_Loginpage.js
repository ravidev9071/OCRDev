import { LightningElement, track, api,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import customHomeStyles from '@salesforce/resourceUrl/piaSky_homecustomcss';
import DuplicateEmail from '@salesforce/label/c.PiaSky_Duplicate_email_Error_Msg';
import ValidationMsg from '@salesforce/label/c.ValidationMsg';
import Isvalid_InvalidMsg from '@salesforce/label/c.Isvalid_InvalidMsg';
import SuccessMsg from '@salesforce/label/c.SuccessMsg';
import ErrorMsg from '@salesforce/label/c.ErrorMsg';
import pharmacyNotFound from '@salesforce/label/c.PiaSKy_pharmacy_not_found';
import getPharmacyByIdentifier from '@salesforce/apex/PiaSky_NPISearchControllerPortal.getPharmacyByIdentifier';
import createRecordOnSubmit from '@salesforce/apex/PiaSky_NPISearchControllerPortal.createRecordOnSubmit';
import checkDuplicateEmail from '@salesforce/apex/PiaSky_NPISearchControllerPortal.checkDuplicateEmail';

export default class PiaSky_Loginpage extends LightningElement {
    

    label = {
        DuplicateEmail,
        ValidationMsg,
        Isvalid_InvalidMsg,
        SuccessMsg,
        ErrorMsg,
        pharmacyNotFound
    };


    @api programName;
    @api permissionSet;
    @api profileName;

    @track pharmacyIdentifier;
    @track firstName;
    @track lastName;
    @track email;
    @track confirmEmail;
    @track phone = '';
    @track isPharmacyFound = false;
    @track showDetailsPharmacy = false;

    //Regex Patterns
    emailPattern = '/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/';
    phonePattern = '^\\d{10}$';

    disabled = false;
    showMsg = false;
    message = this.label.ValidationMsg;
    showDetails = false;
    valid = true;
   
    showError= false;
    errorFields = [];

    showLoading = false;
    displaySpinner = false;

    connectedCallback() {
        loadStyle(this, customHomeStyles);     

    }
    handleIdentifierChange(event) {
       
        this.pharmacyIdentifier = event.target.value;
    }
    handleFNChange(event) {
        this.firstName = event.target.value;
    }

    handleLNChange(event) {
        this.lastName = event.target.value;
    }

    handleEmailChange(event) {
        this.email = event.target.value;
    }

    handlConfirmEmailChange(event) {
        this.confirmEmail = event.target.value;
    }

    handlePhoneChange(event) {
        let inputValue = event.target.value;
        // Remove all non-numeric characters
        const numericValue = inputValue.replace(/\D/g, '');
        this.phone = numericValue;
        this.template.querySelector('[data-phone]').value = this.phone;

        let phone=this.template.querySelector(".phone");
        let phoneVal=phone.value;
        if(phoneVal.match(this.phonePattern)){
            phone.setCustomValidity("");
        }else{
            phone.setCustomValidity("Please enter valid Phone Number");
        }
        phone.reportValidity();
    }

    handlePharmacySearch() {
        if (!this.pharmacyIdentifier) {
            this.showToast('Warning', 'Please enter Pharmacy Identifier', 'warning');
            return;
        }

        getPharmacyByIdentifier({ searchKey: this.pharmacyIdentifier})
            .then(result => {
                if (result && result.length > 0 ) {
                    this.pharmacy = result[0];                              
                    this.showDetailsPharmacy = true;
                }  else {
                    this.showDetailsPharmacy = false;
                    this.showToast('Error', this.label.pharmacyNotFound, 'error');
                }
            })
            .catch(error => {
                alert('Error fetching prescriber records: ');
            });
    }

    handleSubmit() {
        // Input field validations
        if (!this.firstName || !this.lastName || !this.email || !this.confirmEmail || !this.phone) {
            this.showToast('Warning', 'All fields are required', 'warning');
            return;
        }

        if (this.email !== this.confirmEmail) {
            this.showToast('Warning', 'Email and Confirm Email must match', 'warning');
            return;
        }     

        let phone=this.template.querySelector(".phone");
        let phoneVal=phone.value;
        if(phoneVal.match(this.phonePattern)){
            phone.setCustomValidity("");
        } else{
            phone.setCustomValidity("Please enter valid Phone Number");
            phone.reportValidity();
            return;
        }
        
             const recordData = {
            firstName: this.firstName,
            lastName: this.lastName,
            email: this.email,
            confirmEmail: this.confirmEmail,
            phone: this.phone,
        };
        
            let inputRecords = {
                'recordDetails': JSON.stringify(recordData),
                'programName': this.programName,
                'profileName':this.profileName,
                'permissionSet':this.permissionSet,
                'userType':'Staff'
            };  

            checkDuplicateEmail({ email: this.email })
            .then(isDuplicate => {
                if (isDuplicate) {
                    this.showToast('Warning',this.label.DuplicateEmail, 'warning');
                } else {  createRecordOnSubmit({ 'inputRecords': inputRecords, pharmaAcc: this.pharmacy.Id }).then((eachRec) => {
                 if (eachRec?.length > 13) {
                    this.showToast('Success', this.label.SuccessMsg, 'success');
                    this.disabled = false;
                    this.showDetails = false;
                    localStorage.setItem("userId", eachRec);
                    window.open( "\ registrationsuccess","_self");        
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
                }
            }).catch(error => {
                console.error('Error checking for duplicate email:', error);
                this.showToast('Error', 'Error checking for duplicate email', 'error');
            });
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