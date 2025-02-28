import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import getCurrentUserAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getCurrentUserAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPickListValues from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getPicklistFieldValues';
import searchHCSettingRecords from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.searchHCSettingRecords';
import searchARRecords from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.searchARRecords';
import checkDuplicateForHCSAccount from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.checkDuplicateForHCSAccount';
import checkDuplicateForHCProviderAccount from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.checkDuplicateForHCProviderAccount';
import insertHealthCareSettingAccount from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.insertHealthCareSettingAccount';
import insertHealthCareProviderAccount from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.insertHealthCareProvider';
import addPrescriberAffiliations from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.addPrescriberAffiliations';
import addARAffiliations from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.addARAffiliations';
import checkDuplicateaddARAffiliations from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.checkDuplicateARAffiliations';
import updateArRecord from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.updateArRecord';
import createCaseAndServiceSummary from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.createCaseAndServiceSummary';
import saveARSignature from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.saveARSignature';
import { NavigationMixin } from 'lightning/navigation';
import isCertifiedAR from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.isCertifiedAR';

const PATH_MAP = new Map([[0, ".educationProgram"], [1, ".completeProgram"]]);

export default class Aveed_pharmHCSEnrollmentForm extends NavigationMixin(LightningElement) {

    @api hidePath = false;

    currentUserInfo = {};
    currentAccountInfo = {};
    showSpinner = false;
    showSuccessScreen = false;
    showEnrollmentForm = true;
    selectedCredential = '';
    selectedCredential1 = '';
    selectedContactMethod = '';
    selectedhandleSetting = '';
    selectedYesNoOption = '';
    showFreeTextForDegree = false;
    showFreeTextForDegree1 = false
    showFreeTextForSpeciality = false;
    showSearchResults = false;
    signatureData = '';
    searchSetting = '';
    searchProvider = '';
    showSearchSettingResults = false;
    showSearchProviderResults = false;
    selectedProviderItem;
    createProviderOption = false;
    selectedSettingItem;
    createSettingOption = false;
    showModal = false;
    healthCareProviderRecord = {};
    healthCareSettingRecord = {};

    @track stateOptions = [];
    @track contactMethods = [];
    @track yesNoOptions = [];
    @track credentialOptions = [];
    @track searchTerm = '';
    @track searchProviderResults = [];
    @track searchSettingResults = [];
    @track settingTypeOptions = [];

    currentPath = 1;
    completedPath = 1;

    contactMethodNotSelected = false;
    credentialNotSelected = false;
    contactMethodhandleSetting = false;
    hasOnSiteEquipment;
    signatureRequired = false;
    showHCSHCPError = false;
    showHCSHCPDuplicateError = false;
    isDisabled = false

    get isAffiliateDisabled() {
        let flag = true;
        //check setting section
        let settingFlag = true;
        if (this.createSettingOption || (this.selectedSettingItem != null && this.selectedSettingItem.length > 0)) {
            settingFlag = false;
        }
        let providerFlag = true;
        //check provider section
        if (this.createProviderOption || (this.selectedProviderItem != null && this.selectedProviderItem.length > 0)) {
            providerFlag = false;
        }
        flag = settingFlag || providerFlag;
        return flag;
    }

    get radioClass() {
        return `slds-radio ${this.orientation == 'horizontal' ? 'horizontal' : ''}`;
    }

    get hasSearchProviderResults() {
        return (this.searchProviderResults != null && this.searchProviderResults.length > 0);
    }

    get hasSearchSettingResults() {
        return (this.searchSettingResults != null && this.searchSettingResults.length > 0);
    }

    renderedCallback() {
        setTimeout(() => {
            for (let i = 0; i < this.completedPath; i++) {
                let element = this.template.querySelector(PATH_MAP.get(i));
                this.completePathHandler(element);
            }
        }, 100);
    }

    completePathHandler(element) {
        element.classList.remove('slds-is-current');
        element.classList.add('slds-is-complete');
        element.classList.remove('slds-is-incomplete');
    }

    currentPathHandler(element) {
        element.classList.add('slds-is-current');
        element.classList.remove('slds-is-complete');
        element.classList.add('slds-is-incomplete');
    }

    async connectedCallback() {
        this.showEnrollmentForm = true;
        this.showSpinner = true;
        loadStyle(this, customHomeStyles);

        let contactMethodRadioOptions = [
            { label: 'Email', value: 'Email' },
            { label: 'Fax', value: 'Fax' }
        ];

        let yesNoOptions = [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
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

        this.settingTypeOptions = settingTypeRadioOptions.map((opt, ind) => ({
            label: opt.label,
            value: opt.value,
            checked: false,
            key: ind,
            inputClass: `settingtype-radio-input-${ind}`
        }));

        this.getStatePickListOptions();

        try {
            const arResult = await isCertifiedAR({});
            if (arResult && arResult === true) {
                this.isDisabled = true;
            }
            const result = await getCurrentUserAccount({});
            if (result) {
                this.currentUserInfo = { ...result.currentUser };
                this.currentAccountInfo = { ...result.userAccount };
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
                    checked: false,
                    key: ind,
                    inputClass: `yesno-radio-input-${ind}`
                }));

                this.showFreeTextForDegree = false;
                this.showFreeTextForDegree1 = false;

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
                this.showSpinner = false;
            }
        } catch (error) {
            this.showError(error);
        }
    }

    handleSearchSetting(event) {
        this.searchSetting = event.target.value;
    }

    handleSearchProvider(event) {
        this.searchProvider = event.target.value;
    }

    async searchHealthCareSetting(event) {
        this.showSpinner = true;
        this.showSearchSettingResults = true;
        this.selectedSettingItem = null;
        this.searchSettingResults = [];
        try {
            const results = await searchHCSettingRecords({
                searchString: this.searchSetting
            });
            if (results) {
                this.searchSettingResults = results.map((obj) => {
                    return {
                        ...obj,
                        checked: false
                    };
                });
            }
            this.showSpinner = false;
        } catch (error) {
            this.showError(error);
        }
    }

    async searchHealthCareProvider(event) {
        this.showSpinner = true;
        this.showSearchProviderResults = true;
        this.selectedProviderItem = null;
        this.searchProviderResults = [];
        try {
            const results = await searchARRecords({
                searchString: this.searchProvider
            });
            if (results) {
                this.searchProviderResults = results.map((obj) => {
                    return {
                        ...obj,
                        addressLine1: obj.US_WSREMS__Address_Line_1__c ? obj.US_WSREMS__Address_Line_1__c : (obj.US_WSREMS__Prescriber_PrescribingInstitution__r && obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r) ? obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c : '',
                        addressLine2: obj.US_WSREMS__Address_Line_2__c ? obj.US_WSREMS__Address_Line_2__c : (obj.US_WSREMS__Prescriber_PrescribingInstitution__r && obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r) ? obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c : '',
                        city: obj.US_WSREMS__City__c ? obj.US_WSREMS__City__c : (obj.US_WSREMS__Prescriber_PrescribingInstitution__r && obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r) ? obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c : '',
                        state: obj.US_WSREMS__State__c ? obj.US_WSREMS__State__c : (obj.US_WSREMS__Prescriber_PrescribingInstitution__r && obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r) ? obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c : '',
                        zip: obj.US_WSREMS__Zip__c ? obj.US_WSREMS__Zip__c : (obj.US_WSREMS__Prescriber_PrescribingInstitution__r && obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r) ? obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c : '',
                        checked: false
                    };
                });
            }
            this.showSpinner = false;
        } catch (error) {
            this.showError(error);
        }
    }

    handleSelectedProviderRow(event) {
        let key = event.currentTarget.dataset.id;
        if (!key && key !== 0) {
            return;
        }
        this.searchProviderResults = this.searchProviderResults.map((obj) => {
            return {
                ...obj,
                checked: key === obj.Id
            };
        });
        this.selectedProviderItem = key;
        this.createProviderOption = false;
    }

    handleCheckProvider(event) {
        this.createProviderOption = event.target.checked;
        this.selectedProviderItem = null;
        if (event.target.checked) {
            this.searchProviderResults = this.searchProviderResults.map((obj) => {
                return {
                    ...obj,
                    checked: false
                };
            });
        }
    }

    handleSelectedRow(event) {
        let key = event.currentTarget.dataset.id;
        if (!key && key !== 0) {
            return;
        }
        this.searchSettingResults = this.searchSettingResults.map((obj) => {
            return {
                ...obj,
                checked: key === obj.Id
            };
        });
        this.selectedSettingItem = key;
        this.createSettingOption = false;
    }

    handleCheckSetting(event) {
        this.createSettingOption = event.target.checked;
        this.selectedSettingItem = null;
        if (event.target.checked) {
            this.searchSettingResults = this.searchSettingResults.map((obj) => {
                return {
                    ...obj,
                    checked: false
                };
            });
        }
    }

    handleProviderInputChange(event) {
        const { name, value } = event.target;
        this.healthCareProviderRecord = { ...this.healthCareProviderRecord, [name]: value };
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

    formatPhoneNumber(phoneNumberString) {
        var cleaned = ('' + phoneNumberString).replace(/\D/g, '');
        var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (match) {
            return '(' + match[1] + ') ' + match[2] + '-' + match[3];
        }
        return null;
    }

    handleSignatureCompleted(event) {
        // Call the function you need when the event is triggered
        this.signatureData = event.detail.signdata;
    }

    handleClear() {
        this.template.querySelector('c-rems-sign-pad').handleClear();
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

    handleSettingTypeClick(event) {
        let key = event.currentTarget.dataset.key;
        if (!key && key !== 0) {
            return;
        }
        let input = this.template.querySelector(`.settingtype-radio-input-${key}`);
        if (!input) {
            return;
        }
        this.selectedCredential1 = input.value;
        this.settingTypeOptions = this.settingTypeOptions.map((obj) => {
            return {
                ...obj,
                checked: obj.value === input.value
            };
        });
        this.showFreeTextForDegree1 = false;
        if (this.selectedCredential1 === 'Other') {
            this.showFreeTextForDegree1 = true;
        }
        this.healthCareSettingRecord = { ...this.healthCareSettingRecord, 'settingType': input.value };
    }

    handleContactMethodClick(event) {
        if (this.isDisabled) {
            return;
        }
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
        this.selectedhandleSetting = input.value;
        this.yesNoOptions = this.yesNoOptions.map((obj) => {
            return {
                ...obj,
                checked: obj.value === input.value
            };
        });
        this.hasOnSiteEquipment = input.value;

        this.prescriberRecord = { ...this.prescriberRecord, 'hasOnSiteEquipment': input.value };
        this.contactMethodhandleSetting = false;
    }

    handleDegreeClick(event) {
        if (this.isDisabled) {
            return;
        }
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

    async handleAffiliations() {
        //validate values

        let isValid = [...this.template.querySelectorAll('lightning-input[data-id="affiliationData"]'),
        ...this.template.querySelectorAll('lightning-input[data-id="affiliationProviderData"]'),
        ...this.template.querySelectorAll('lightning-combobox[data-id="affiliationData"]'),
        ...this.template.querySelectorAll('lightning-combobox[data-id="affiliationProviderData"]'),
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        if (!isValid) {
            return false;
        }
        try {
            this.showSpinner = true;
            const result = await checkDuplicateForHCSAccount({ 'payload': JSON.stringify(this.healthCareSettingRecord), 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c });
            if (result != null && result === true) {
                this.showSpinner = false;
                this.showToast('Error', 'HealthCare Setting with the same details already exists.', 'error');
                return false;
            }
            const providerResult = await checkDuplicateForHCProviderAccount({ 'payload': JSON.stringify(this.healthCareProviderRecord), 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c });
            if (providerResult != null && providerResult === true) {
                this.showSpinner = false;
                this.showToast('Error', 'HealthCare Provider with the same details already exists.', 'error');
                return false;
            }

            var hcSettingcreationResult;
            if (this.createSettingOption) {
                hcSettingcreationResult = await insertHealthCareSettingAccount({ 'payload': JSON.stringify(this.healthCareSettingRecord), 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c });
            }
            let hcsSettingId = (hcSettingcreationResult != null && hcSettingcreationResult.length > 0) ? hcSettingcreationResult : this.selectedSettingItem;
            this.healthCareSettingAccountId = hcsSettingId;
            const createSettingAffiliations = await addARAffiliations({ 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c, 'accountId': this.currentAccountInfo.Id, 'healthCareSettingId': hcsSettingId });

            var hcProviderCreationResult;
            if (this.createProviderOption) {
                hcProviderCreationResult = await insertHealthCareProviderAccount({ 'payload': JSON.stringify(this.healthCareProviderRecord), 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c });
            }
            let hcsProviderId = (hcProviderCreationResult != null && hcProviderCreationResult.length > 0) ? hcProviderCreationResult : this.selectedProviderItem;
            this.healthCareProviderAccountId = hcsProviderId;
            const createProviderAffiliations = await addPrescriberAffiliations({ 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c, 'accountId': hcsProviderId, 'healthCareSettingId': hcsSettingId });
            return true;
        } catch (error) {
            this.showError(error);
        }
    }

    async handleSubmit() {
        this.signatureRequired = false;
        this.showHCSHCPError = false;
        let isValid = [...this.template.querySelectorAll('lightning-input[data-id="arInputs"]'),
        ...this.template.querySelectorAll('lightning-combobox')
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        let affiliationsCreationIsValid = [...this.template.querySelectorAll('lightning-input[data-id="affiliationData"]'),
        ...this.template.querySelectorAll('lightning-input[data-id="affiliationProviderData"]'),
        ...this.template.querySelectorAll('lightning-combobox[data-id="affiliationData"]'),
        ...this.template.querySelectorAll('lightning-combobox[data-id="affiliationProviderData"]'),
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        if (!this.isDisabled) {
            if (this.selectedContactMethod == null || this.selectedContactMethod.length === 0) {
                this.contactMethodNotSelected = true;
            } else {
                this.contactMethodNotSelected = false;
            }
            if (this.selectedhandleSetting == null || this.selectedhandleSetting.length === 0) {
                this.contactMethodhandleSetting = true;
            } else {
                this.contactMethodhandleSetting = false;
            }
            if (this.selectedCredential == null || this.selectedCredential.length === 0) {
                this.credentialNotSelected = true;
            } else {
                this.credentialNotSelected = false;
            }
            if (!isValid || this.selectedCredential == null || this.selectedCredential.length === 0 || this.selectedContactMethod == null || this.selectedContactMethod.length === 0 || this.selectedhandleSetting == null || this.selectedhandleSetting.length === 0) {
                return;
            }
        } else {
            if (!isValid || !affiliationsCreationIsValid) {
                return;
            }
        }

        try {
            if (this.template.querySelector('c-rems-sign-pad')) {
                this.template.querySelector('c-rems-sign-pad').handleSaveSignature();
            }

            if (this.signatureData == null || this.signatureData == undefined || this.signatureData.length === 0) {
                this.signatureRequired = true;
                this.showSpinner = false;
                return;
            }

            if (!this.createSettingOption) {
                if (this.selectedSettingItem == null || this.selectedSettingItem.length === 0) {
                    this.showSpinner = false;
                    this.showHCSHCPError = true;
                    return;
                }
            } else {
                const duplicateAR = await checkDuplicateaddARAffiliations({ 'accountId': this.healthCareProviderAccountId, 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c, 'healthCareSettingId': this.healthCareSettingAccountId, 'arAccountId': this.currentAccountInfo.Id });

                if (duplicateAR) {
                    this.showSpinner = false;
                    this.showHCSHCPDuplicateError = true;
                    return;
                }
            }

            const result = await this.handleAffiliations();
            if (!result) {
                this.showSpinner = false;
                return;
            }

            this.showSpinner = true;

            if (this.healthCareSettingAccountId == null || this.healthCareSettingAccountId == undefined) {
                this.showSpinner = false;
                this.showHCSHCPError = true;
                return;
            }

            const accountResult = await updateArRecord({ 'payload': JSON.stringify(this.prescriberRecord), 'accountId': this.currentAccountInfo.Id });
            if (accountResult != null && accountResult === false) {
                this.showSpinner = false;
                this.showToast('Error', 'Something went wrong, Please contact admin.', 'error');
            }
            const caseServiceResult = await createCaseAndServiceSummary({ 'accountId': this.currentAccountInfo.Id, 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c, 'healthCareSettingId': this.healthCareSettingAccountId, 'healthCareProviderId': this.healthCareProviderAccountId, 'ManagePOMEAnaphylaxis': this.hasOnSiteEquipment });

            const signResult = await saveARSignature({ 'accountId': this.currentAccountInfo.Id, 'signData': this.signatureData });

            this.showSpinner = false;
            if (this.hidePath) {
                this.dispatchEvent(new CustomEvent('associationcompleted', { detail: 'completed' }));
            }
            if (!this.hidePath) {
                this.showEnrollmentForm = false;
                this.showSuccessScreen = true;
                this.completedPath += 1;
                let currentElement = this.template.querySelector(PATH_MAP.get(this.currentPath));
                this.completePathHandler(currentElement);
            }
        } catch (error) {
            this.showError(error);
        }
    }

    handleContinue(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'managehcp__c'
            }
        }).then(() => {
            window.open(generatedUrl, '_self');
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
        this.showToast('Error', JSON.stringify(errorMsg), 'error');
    }

    handleCancel() {
        this.showModal = true;
    }
    handleCancelModal(event) {
        if (event.target.name == 'cancel') {
            this.showModal = false;
        }
        else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Home'
                }
            });
        }
    }
}