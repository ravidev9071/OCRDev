import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import aveed_customcssSecure from '@salesforce/resourceUrl/aveed_customcssSecure';
import getCurrentAccountHCSDetails from '@salesforce/apex/Aveed_ManageHCSForARCtrl.getCurrentAccountHCSDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPickListValues from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getPicklistFieldValues';
import saveARSignature from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.saveARSignature';
import updateArAccountRecord from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.updateArRecord';
import updateHCSAccountRecord from '@salesforce/apex/Aveed_ManageHCSForARCtrl.updateHCSAccountRecord';

export default class Aveed_editReEnrollManageHCS extends LightningElement {

    @api hcsId;

    currentAccountInfo = {};
    showSpinner = false;
    signatureData = '';
    healthCareSettingRecord = {};
    hcsEnrollmentCase = {};
    prescriberRecord = {};
    hcsAccountRecord = {};
    contactMethodNotSelected = false;
    credentialNotSelected = false;
    hasOnSiteEquipment;
    selectedContactMethod;
    selectedCredential;

    functionOperation;
    functionNotSelected = false;

    @track functionOptions = [];
    @track stateOptions = [];
    @track contactMethods = [];
    @track yesNoOptions = [];
    @track credentialOptions = [];
    @track searchTerm = '';
    @track settingTypeOptions = [];
    signatureRequired = false;

    get radioClass() {
        return `slds-radio ${this.orientation == 'horizontal' ? 'horizontal' : ''}`;
    }

    get isEditForm() {
        return (this.functionOperation === 'Edit');
    }

    get isReEnroll() {
        return (this.functionOperation === 'Re-enroll');
    }

    async connectedCallback() {
        this.showSpinner = true;
        loadStyle(this, customHomeStyles);
        loadStyle(this, aveed_customcssSecure);

        let contactMethodRadioOptions = [
            { label: 'Email', value: 'Email' },
            { label: 'Fax', value: 'Fax' }
        ];

        let yesNoOptions = [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];

        let functionOptions = [
            { label: 'Edit', value: 'Edit' },
            { label: 'Re-enroll', value: 'Re-enroll' }
        ];

        let degreeCredentialOptions = [
            { label: 'M.D.', value: 'MD' },
            { label: 'D.O.', value: 'DO' },
            { label: 'Nurse', value: 'Nurse' },
            { label: 'Physician Assistant', value: 'PA' },
            { label: 'Practice Manager', value: 'Practice Manager' },
            { label: 'Other', value: 'Other' },
        ];

        let settingTypeRadioOptions = [
            { label: 'Group Practice', value: 'Group Practice' },
            { label: 'Independent practice', value: 'Independent practice' },
            { label: 'Institution', value: 'Institution' },
            { label: 'Central Ordering Pharmacy', value: 'Central Ordering Pharmacy' },
            { label: 'Infusion Center', value: 'Infusion Center' },
            { label: 'Other', value: 'Other' },
        ];

        this.getStatePickListOptions();

        try {
            const result = await getCurrentAccountHCSDetails({ hcsId: this.hcsId });
            if (result) {
                this.currentAccountInfo = { ...result.currentAccount };
                this.hcsAccountRecord = { ...result.hcsSetting };
                this.hcsEnrollmentCase = { ...result.hcsEnrollmentCase };
                this.selectedContactMethod = this.currentAccountInfo.US_WSREMS__Preferred_Contact_Method__c;
                this.selectedCredential = this.currentAccountInfo.US_WSREMS__Professional_Designation__c;

                this.contactMethods = contactMethodRadioOptions.map((opt, ind) => ({
                    label: opt.label,
                    value: opt.value,
                    checked: opt.value === this.currentAccountInfo.US_WSREMS__Preferred_Contact_Method__c,
                    key: ind,
                    inputClass: `method-radio-input-${ind}`
                }));

                this.credentialOptions = degreeCredentialOptions.map((opt, ind) => ({
                    label: opt.label,
                    value: opt.value,
                    checked: opt.value === this.currentAccountInfo.US_WSREMS__Professional_Designation__c,
                    key: ind,
                    inputClass: `degree-radio-input-${ind}`
                }));

                this.yesNoOptions = yesNoOptions.map((opt, ind) => ({
                    label: opt.label,
                    value: opt.value,
                    checked: this.hcsEnrollmentCase.ManagePOMEorAnaphylaxis__c === opt.value ? true : false,
                    key: ind,
                    inputClass: `yesno-radio-input-${ind}`
                }));

                this.settingTypeOptions = settingTypeRadioOptions.map((opt, ind) => ({
                    label: opt.label,
                    value: opt.value,
                    checked: this.hcsAccountRecord.US_WSREMS__Healthcare_Setting_Type__c === opt.value ? true : false,
                    key: ind,
                    inputClass: `settingtype-radio-input-${ind}`
                }));

                this.showFreeTextForDegree = false;

                this.prescriberRecord = {
                    ...this.prescriberRecord,
                    firstName: this.currentAccountInfo.FirstName,
                    lastName: this.currentAccountInfo.LastName,
                    middleName: this.currentAccountInfo.MiddleName,
                    title: this.currentAccountInfo.US_WSREMS__Title__c,
                    phoneNumber: this.currentAccountInfo.Phone,
                    faxNumber: this.currentAccountInfo.Fax,
                    extension: this.currentAccountInfo.US_WSREMS__EXT__c,
                    credentials: this.currentAccountInfo.US_WSREMS__Professional_Designation__c,
                    othercredentials: this.currentAccountInfo.US_WSREMS__Other_Credentials__c,
                    preferredContactMethod: this.currentAccountInfo.US_WSREMS__Preferred_Contact_Method__c
                };

                this.currentAccountInfo.US_WSREMS__Phone_Number__c = this.formatPhoneNumber(this.currentAccountInfo.US_WSREMS__Phone_Number__c);
                this.currentAccountInfo.Phone = this.formatPhoneNumber(this.currentAccountInfo.Phone);
                this.currentAccountInfo.Fax = this.formatPhoneNumber(this.currentAccountInfo.Fax);

                this.healthCareSettingRecord = {
                    ...this.healthCareSettingRecord,
                    name: this.hcsAccountRecord.Name,
                    dea: this.hcsAccountRecord.US_WSREMS__DEA__c,
                    addressLine1: this.hcsAccountRecord.US_WSREMS__Address_Line_1__c,
                    addressLine2: this.hcsAccountRecord.US_WSREMS__Address_Line_2__c,
                    city: this.hcsAccountRecord.US_WSREMS__City__c,
                    state: this.hcsAccountRecord.US_WSREMS__State__c,
                    zip: this.hcsAccountRecord.US_WSREMS__Zip__c,
                    settingType: this.hcsAccountRecord.US_WSREMS__Healthcare_Setting_Type__c,
                    phone: this.hcsAccountRecord.Phone,
                    faxNumber: this.hcsAccountRecord.Fax,
                    emailAddress: this.hcsAccountRecord.US_WSREMS__Email__c,
                };
                this.hcsAccountRecord.US_WSREMS__Phone_Number__c = this.formatPhoneNumber(this.hcsAccountRecord.US_WSREMS__Phone_Number__c);
                this.hcsAccountRecord.Phone = this.formatPhoneNumber(this.hcsAccountRecord.Phone);
                this.hcsAccountRecord.Fax = this.formatPhoneNumber(this.hcsAccountRecord.Fax);

                if (this.hcsAccountRecord.US_WSREMS__Date_Enrolled__c != null && this.hcsAccountRecord.US_WSREMS__Date_Enrolled__c != undefined) {
                    const reEnrollmentDate = new Date(this.hcsAccountRecord.US_WSREMS__Recertification_Due_Date__c);
                    // Example enrollment date
                    const today = new Date();
                    // Calculate the difference in days 
                    const timeDiff = reEnrollmentDate - today;
                    const daysDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));
                    // Difference in days // Get the edit button element
                    // Check if the enrollment date is less than 60 days from today 
                    if (daysDiff < 60) {
                        functionOptions = [
                            { label: 'Edit', value: 'Edit' },
                            { label: 'Re-enroll', value: 'Re-enroll' }
                        ];

                    } else {
                        functionOptions = [
                            { label: 'Edit', value: 'Edit' }
                        ];
                    }
                }

                this.functionOptions = functionOptions.map((opt, ind) => ({
                    label: opt.label,
                    value: opt.value,
                    checked: false,
                    key: ind,
                    inputClass: `function-radio-input-${ind}`
                }));

                this.showSpinner = false;
            }
        } catch (error) {
            this.showError(error);
        }
    }

    convertISOToDateFormat(isoDateTime) {
        // Create a new Date object from the ISO date-time string
        const date = new Date(isoDateTime);

        if (isNaN(date)) {
        }
        else {
            // Extract the day, month, and year
            const day = String(date.getUTCDate()).padStart(2, '0');
            const month = String(date.getUTCMonth() + 1).padStart(2, '0'); // Months are zero-indexed
            const year = date.getUTCFullYear();
            // Format the date as DD/MM/YYYY
            const formattedDate = `${month}/${day}/${year}`;
            return formattedDate;
        }
    }

    handleContactMethodClick(event) {
        let key = event.currentTarget.dataset.key;
        if (!key && key !== 0) {
            return;
        }
        let input = this.template.querySelector(`.method-radio-input-${key}`);
        if (!input) {
            return;
        }

        //make the input checked
        this.selectedContactMethod = input.value;
        this.contactMethods = this.contactMethods.map((obj) => {
            return {
                ...obj,
                checked: obj.value === input.value
            };
        });

        this.contactMethodNotSelected = false;
        this.prescriberRecord = { ...this.prescriberRecord, 'preferredContactMethod': input.value };
    }

    handleYesNoClick(event) {
        let key = event.currentTarget.dataset.key;
        if (!key && key !== 0) {
            return;
        }
        let input = this.template.querySelector(`.yesno-radio-input-${key}`);
        if (!input) {
            return;
        }

        this.yesNoOptions = this.yesNoOptions.map((obj) => {
            return {
                ...obj,
                checked: obj.value === input.value
            };
        });
        this.hasOnSiteEquipment = input.value;

        this.prescriberRecord = { ...this.prescriberRecord, 'hasOnSiteEquipment': input.value };
    }

    handleFunctionClick(event) {
        let key = event.currentTarget.dataset.key;
        if (!key && key !== 0) {
            return;
        }
        let input = this.template.querySelector(`.function-radio-input-${key}`);
        if (!input) {
            return;
        }

        this.functionOptions = this.functionOptions.map((obj) => {
            return {
                ...obj,
                checked: obj.value === input.value
            };
        });
        this.functionOperation = input.value;
    }

    handleDegreeClick(event) {
        let key = event.currentTarget.dataset.key;
        if (!key && key !== 0) {
            return;
        }
        let input = this.template.querySelector(`.degree-radio-input-${key}`);
        if (!input) {
            return;
        }

        //make the input checked
        this.selectedCredential = input.value;
        this.credentialOptions = this.credentialOptions.map((obj) => {
            return {
                ...obj,
                checked: obj.value === input.value
            };
        });
        this.showFreeTextForDegree = false;
        if (this.selectedCredential === 'Other') {
            this.showFreeTextForDegree = true;
        }
        this.credentialNotSelected = false;
        this.prescriberRecord = { ...this.prescriberRecord, 'credentials': input.value };
    }

    handleOnChangeEvt(event) {
        const { name, value } = event.target;
        if (name == 'phoneNumber' || name == 'faxNumber') {
            const regex = /^[0-9]*$/;
            let phoneValue = value.replace(/\D/g, '');
            if (phoneValue != null && phoneValue.length === 10) {
                event.target.value = this.formatPhoneNumber(phoneValue);
            }
            this.prescriberRecord = { ...this.prescriberRecord, [name]: phoneValue };
        } else {
            this.prescriberRecord = { ...this.prescriberRecord, [name]: value };
        }
    }

    handleSettingInputChange(event) {
        const { name, value } = event.target;
        if (name == 'phone' || name == 'faxNumber') {
            const regex = /^[0-9]*$/;
            let phoneValue = value.replace(/\D/g, '');
            if (phoneValue != null && phoneValue.length === 10) {
                event.target.value = this.formatPhoneNumber(phoneValue);
            }
            this.healthCareSettingRecord = { ...this.healthCareSettingRecord, [name]: phoneValue };
        } else {
            this.healthCareSettingRecord = { ...this.healthCareSettingRecord, [name]: value };
        }
    }

    getStatePickListOptions() {
        getPickListValues({
            objectName: 'Case',
            fieldAPIName: 'US_WSREMS__State__c'

        }).then((pickListVal) => {
            let stateOptionList = pickListVal.US_WSREMS__State__c;
            for (let key in stateOptionList) {
                this.stateOptions = [...this.stateOptions, {
                    label: key,
                    value: stateOptionList[key]
                }];
            }
        }).catch((error) => {
            console.log(error);
            console.log(error.message);
        }).finally(() => {
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

    showError(error) {
        let errorMsg = error;
        if (error.body != null && error.body.message != null) {
            errorMsg = error.body.message;
        }
        this.showSpinner = false;
        console.error(error);
        this.showToast('Error', JSON.stringify(errorMsg), 'error');
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancelform', { detail: 'cancel' }));
    }

    formatPhoneNumber(phoneNumberString) {
        var cleaned = ('' + phoneNumberString).replace(/\D/g, '');
        var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (match) {
            return '(' + match[1] + ') ' + match[2] + '-' + match[3];
        }
        return null;
    }

    handleSettingTypeClick(event) {
        let key = event.currentTarget.dataset.key;
        if (!key && key !== 0) {
            return;
        }
        let input = this.template.querySelector(`.settingtype-radio-input-${key}`);
        if (!input) {
            return;
        }

        this.settingTypeOptions = this.settingTypeOptions.map((obj) => {
            return {
                ...obj,
                checked: obj.value === input.value
            };
        });

        this.healthCareSettingRecord = { ...this.healthCareSettingRecord, 'settingType': input.value };
    }

    handleSignatureCompleted(event) {
        // Call the function you need when the event is triggered
        this.signatureData = event.detail.signdata;
    }

    handleClear() {
        this.template.querySelector('c-pia-sky_signature-pad').handleClear();
    }

    async handleSubmitForm() {
        this.signatureRequired = false;
        let isValid = [...this.template.querySelectorAll('lightning-input'),
        ...this.template.querySelectorAll('lightning-combobox')
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        if (this.selectedContactMethod == null || this.selectedContactMethod.length === 0) {
            this.contactMethodNotSelected = true;
        } else {
            this.contactMethodNotSelected = false;
        }

        if (this.selectedCredential == null || this.selectedCredential.length === 0) {
            this.credentialNotSelected = true;
        } else {
            this.credentialNotSelected = false;
        }

        if (this.functionOperation == null || this.functionOperation.length === 0) {
            this.functionNotSelected = true;
        } else {
            this.functionNotSelected = false;
        }

        if (!isValid
            || this.selectedCredential == null
            || this.selectedCredential.length === 0
            || this.selectedContactMethod == null
            || this.selectedContactMethod.length === 0
            || this.functionOperation == null
            || this.functionOperation.length === 0) {
            return;
        }
        try {
            this.showSpinner = true;

            if (this.template.querySelector('c-rems-sign-pad')) {
                this.template.querySelector('c-rems-sign-pad').handleSaveSignature();
            }

            if (this.signatureData == null || this.signatureData == undefined || this.signatureData.length === 0) {
                this.signatureRequired = true;
                this.showSpinner = false;
                return;
            }

            const accountResult = await updateArAccountRecord({ 'payload': JSON.stringify(this.prescriberRecord), 'accountId': this.currentAccountInfo.Id });
            if (accountResult != null && accountResult === false) {
                this.showSpinner = false;
                this.showToast('Error', 'Something went wrong, Please contact admin.', 'error');
            }

            const hcsAccountResult = await updateHCSAccountRecord({ 'arAccountId': this.currentAccountInfo.Id, 'payload': JSON.stringify(this.healthCareSettingRecord), 'accountId': this.hcsAccountRecord.Id, operationType: this.functionOperation, 'ManagePOMEAnaphylaxis': this.hasOnSiteEquipment });
            if (hcsAccountResult != null && hcsAccountResult === false) {
                this.showSpinner = false;
                this.showToast('Error', 'Something went wrong, Please contact admin.', 'error');
            }

            if (this.functionOperation === 'Re-enroll') {
                const signARResult = await saveARSignature({ 'accountId': this.currentAccountInfo.Id, 'signData': this.signatureData });
                const signHCSResult = await saveARSignature({ 'accountId': this.healthCareSettingRecord.Id, 'signData': this.signatureData });
            }

            this.dispatchEvent(new CustomEvent('operationcomplete', { detail: 'completed' }));
            this.showSpinner = false;
        } catch (error) {
            this.showError(error);
        }
    }
}