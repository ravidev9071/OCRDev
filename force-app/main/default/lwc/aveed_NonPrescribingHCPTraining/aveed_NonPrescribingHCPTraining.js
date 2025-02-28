import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import getPickListValues from '@salesforce/apex/Aveed_NonPrescribingHCPTrainingCtrl.getPicklistFieldValues';
import checkDuplicate from '@salesforce/apex/Aveed_NonPrescribingHCPTrainingCtrl.checkDuplicateAccounts';
import createNonPrescribingCaseAccountCreation from '@salesforce/apex/Aveed_NonPrescribingHCPTrainingCtrl.createNonPrescribingCaseAccountCreation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFilesPublicLink from '@salesforce/apex/Aveed_HCSEducationProgramCtrl.getFilesPublicLink';
import aveed_check from "@salesforce/resourceUrl/aveed_Iconcheck";
import { NavigationMixin } from 'lightning/navigation';


export default class Aveed_NonPrescribingHCPTraining extends NavigationMixin(LightningElement) {

    @api orientation = 'horizontal';
    //orientation -> vertical, horizontal

    @api radioGroupName = 'DegreeOptions';
    @track _degreeList = [];
    @track _selectedDegree = '';
     filesList = [];
    fileTitle = "AVEED REMS Education Program for Healthcare Settings"
    fileName = "AVEED REMS Education Program for Healthcare Providers";
    showNext = false;
     iconCheck = aveed_check;

    get isDisabled() {
        return !this.showNext;
    }

    stateOptions = [];

    accountRecord = {
        FirstName: '',
        LastName: '',
        Email: '',
        Phone: '',
        Degree: '',
        AddressLine1: '',
        AddressLine2: '',
        City: '',
        State: '',
        ZipCode: '',
        OtherDegree: ''
    };
    showFreeTextForDegree = false;
    optionNotSelected = false;
    isSubmitDisabled = true;
    userInformationToCollect = true;
    isSuccess = false;
    isLinkClicked = false;
    programName = 'AVEED REMS';
    showSpinner = false;

    get radioClass() {
        return `slds-radio ${this.orientation == 'horizontal' ? 'horizontal' : ''}`;
    }
     get isDisplayFiles() {
        return (this.fileURL != null && this.fileURL.length > 0);
    }

    async connectedCallback() {
        this.showSpinner = true;
        loadStyle(this, customHomeStyles);
        let radioOptions = [
            { label: 'MD', value: 'MD' },
            { label: 'DO', value: 'DO' },
            { label: 'NP', value: 'Nurse Practitioner' },
            { label: 'PA', value: 'PA' },
            { label: 'RN', value: 'APRN' },
            { label: 'MA', value: 'MA' },
            { label: 'Other', value: 'Other' },
        ];
        this._degreeList = radioOptions.map((opt, ind) => ({
            label: opt.label,
            value: opt.value,
            checked: opt.value === this._selectedDegree,
            key: ind,
            inputClass: `radio-input-${ind}`
        }));
     this.getStatePickListOptions();
      const result = await getFilesPublicLink({ 'fileTitle': this.fileName ,'portalRole':'Public' ,'record_type':'Prescriber'});
            if (result) {
                for (let file in result) {
                    this.fileURL = result[file].DistributionPublicUrl;
                }
            }

    }

    previewHandler(event) {
       this.isSubmitDisabled = false;
        this.showNext = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.fileURL
            }
        }, false);
    }

    getStatePickListOptions() {
        getPickListValues()
            .then((pickListVal) => {
                let stateOptionList = pickListVal.US_WSREMS__State__c;
                for (let key in stateOptionList) {
                    this.stateOptions = [...this.stateOptions, {
                        label: key,
                        value: stateOptionList[key]
                    }];
                }
            })
            .catch((error) => {
                console.log(error);
                console.log(error.message);
            }).finally(() => {
                this.showSpinner = false;
            });
    }

    validatePhoneNumber(event) {
        const fieldName = event.target.name;
      let fieldValue = event.target.value;
       let numericPhone = fieldValue.replace(/\D/g, '').replace('-');
       let phoneInput = this.template.querySelector('.phoneNumber');
       if(fieldName === 'Phone'){
              fieldValue = numericPhone;
               event.target.value = fieldValue;
            }
    }

    handleInputChange(event) {
        this.validatePhoneNumber(event);
        const { name, value } = event.target;
        if (name == 'Phone') {
            const regex = /^[0-9]*$/;
            let phoneValue = value.replace(/\D/g, '');
            if (phoneValue != null && phoneValue.length === 10) {
                event.target.value = this.formatPhoneNumber(phoneValue);
            }
            this.accountRecord = { ...this.accountRecord, [name]: phoneValue };
        } else {
            this.accountRecord = { ...this.accountRecord, [name]: value };
        }
    }

    handleFileLink(event) {
        this.isSubmitDisabled = false;
        this.isLinkClicked = true;
    }

    handleClick(event) {
        let key = event.currentTarget.dataset.key;
        if (!key && key !== 0) {
            return;
        }
        let input = this.template.querySelector(`.radio-input-${key}`);
        if (!input) {
            return;
        }

       
        
        this._selectedDegree = input.value;
        this.accountRecord = { ...this.accountRecord, 'Degree': input.value };
        this._degreeList = this._degreeList.map((obj) => {
            return {
                ...obj,
                checked: obj.value === input.value
            };
        });
        this.showFreeTextForDegree = false;
        if (this._selectedDegree === 'Other') {
            this.showFreeTextForDegree = true;
        }
        this.optionNotSelected = false;
    }

    formatPhoneNumber(phoneNumberString) {
        var cleaned = ('' + phoneNumberString).replace(/\D/g, '');
        var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (match) {
            return '(' + match[1] + ') ' + match[2] + '-' + match[3];
        }
        return null;
    }

    async handleSubmitForm() {
        let isValid = [...this.template.querySelectorAll('lightning-input'),
        ...this.template.querySelectorAll('lightning-combobox')
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        if (this._selectedDegree == null || this._selectedDegree == '' || this._selectedDegree.length === 0) {
            this.optionNotSelected = true;
        }
        isValid = isValid && !this.optionNotSelected;
       
        if (this.isSubmitDisabled) {
            return;
        }
        if (!isValid) {
            return;
        }
        this.showSpinner = true;

        let inputRecords = {
            'recordDetails': JSON.stringify(this.accountRecord),
            'programName': this.programName
        };
        try {
            const result = await checkDuplicate({ 'inputRecords': inputRecords, 'recordTypeName': 'General_Contact' });
            if (result != null && result === true) {
                this.showSpinner = false;
                this.showToast('Error', 'An account or contact with the same details already exists.', 'error');
                return;
            }
            const creationResult = await createNonPrescribingCaseAccountCreation({ 'payload': JSON.stringify(this.accountRecord) });
            this.showSpinner = false;
            if (creationResult != null && creationResult.isCreated === true) {
                this.userInformationToCollect = false;
                this.isSuccess = true;
            } else if (!creationResult.isCreated && creationResult.notificationMsg != null && creationResult.notificationMsg.length > 0) {
                this.showToast('Error', creationResult.notificationMsg, 'error');
            } else {
                this.showToast('Error', 'Something went wrong, please contact admin.', 'error');
            }
        } catch (error) {
            this.showSpinner = false;
            console.error(error);
            this.showToast('Error', JSON.stringify(error.body.message), 'error');
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

}