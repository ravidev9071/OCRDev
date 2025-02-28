import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import getPickListValues from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getPicklistFieldValues';
import getCurrentUserAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getCurrentUserAccount';
import searchRecords from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.searchRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkDuplicateForHCSAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.checkDuplicateForHCSAccount';
import insertHealthCareSettingAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.insertHealthCareSettingAccount';
import addAffiliations from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.addAffiliations';
import createCaseAndServiceSummary from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.createHCSRecordsEnrollmentCase';
import updatePrescriberAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.updatePrescriberAccount';
import savePrescriberSignature from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.savePrescriberSignature';
import { NavigationMixin } from 'lightning/navigation';
import updatePortalStageForAccount from "@salesforce/apex/Aveed_HCPEnrollmentCtrl.updatePortalStageForAccount";
const PATH_MAP = new Map([[0, ".educationProgram"], [1, ".knowledgeProgram"], [2, ".completeProgram"]]);

export default class Aveed_HCPEnrollment extends NavigationMixin(LightningElement) {

    currentUserInfo = {};
    currentAccountInfo = {};
    showSpinner = false;
    showSuccessScreen = false;
    showEnrollmentForm = true;

    @track stateOptions = [];
    @track contactMethods = [];
    @track specialtyOptions = [];
    @track credentialOptions = [];
    selectedCredential = '';
    selectedContactMethod = '';
    selectedSpeciality = '';
    showFreeTextForDegree = false;
    showFreeTextForSpeciality = false;
    @track searchTerm = '';
    @track searchResults = [];
    @track associatedHCSResults = [];
    selectedHCS=[];
    showSearchResults = false;
    createSettingOption = false;
    selectedItem;
    healthCareSettingRecord = {};
    prescriberRecord = {};
    signatureData = '';
    healthCareSettingAccountId;
    currentPath = 2;
    completedPath = 2;
    specialtyOptionNotSelected = false;
    degreeOptionNotSelected = false;
    signatureRequired = false;
    showHCSHCPError = false;
    showAssociatedHCS = false;
    prevouslySelectedTemp;
    duplicateHCSRecord =false;
    get isAffiliateDisabled() {
        if (this.createSettingOption || (this.selectedItem != null && this.selectedItem.length > 0)) {
            return false;
        }
        return true;
    }

    get radioClass() {
        return `slds-radio ${this.orientation == 'horizontal' ? 'horizontal' : ''}`;
    }

    get hasSearchResults() {
        return (this.searchResults != null && this.searchResults.length > 0);
    }
    get hasAssociatedHCSResults(){
        return (this.associatedHCSResults != null && this.associatedHCSResults.length > 0);
    }

    async connectedCallback() {
        this.showEnrollmentForm = true;
        this.showSpinner = true;
        loadStyle(this, customHomeStyles);

        let contactMethodRadioOptions = [
            { label: 'Email', value: 'Email' },
            { label: 'Fax', value: 'Fax' }
        ];

        let degreeCredentialOptions = [
            { label: 'M.D.', value: 'MD' },
            { label: 'D.O.', value: 'DO' },
            { label: 'Physician Assistant', value: 'PA' },
            { label: 'Nurse Practitioner', value: 'NP' },
            { label: 'Other', value: 'Other' },
        ]

        let medicalSpecialityOptions = [
            { label: 'Endocrinology', value: 'Endocrinology' },
            { label: 'Primary Care', value: 'Primary Care' },
            { label: 'Urology', value: 'Urology' },
            { label: 'Other', value: 'Other' }
        ];


        this.getStatePickListOptions();

        try {
            const result = await getCurrentUserAccount({});

            if (result) {
                this.currentUserInfo = { ...result.currentUser };
                this.currentAccountInfo = { ...result.userAccount };
                this.selectedContactMethod = this.currentAccountInfo.US_WSREMS__Preferred_Contact_Method__c;
                this.selectedCredential = this.currentAccountInfo.US_WSREMS__Professional_Designation__c;
                this.selectedSpeciality = this.currentAccountInfo.Medical_Specialty__c;
                this.contactMethods = contactMethodRadioOptions.map((opt, ind) => ({
                    label: opt.label,
                    value: opt.value,
                    checked: opt.value === this.currentAccountInfo.US_WSREMS__Preferred_Contact_Method__c,
                    key: ind,
                    inputClass: `method-radio-input-${ind}`
                }));
                this.specialtyOptions = medicalSpecialityOptions.map((opt, ind) => ({
                    label: opt.label,
                    value: opt.value,
                    checked: opt.value === this.currentAccountInfo.Medical_Specialty__c,
                    key: ind,
                    inputClass: `speciality-radio-input-${ind}`
                }));
                this.credentialOptions = degreeCredentialOptions.map((opt, ind) => ({
                    label: opt.label,
                    value: opt.value,
                    checked: opt.value === this.currentAccountInfo.US_WSREMS__Professional_Designation__c,
                    key: ind,
                    inputClass: `degree-radio-input-${ind}`
                }));
                this.showFreeTextForSpeciality = false;
                this.showFreeTextForDegree = false;

                this.prescriberRecord = {
                    ...this.prescriberRecord,
                    firstName: this.currentAccountInfo.FirstName,
                    lastName: this.currentAccountInfo.LastName,
                    phoneNumber: this.currentAccountInfo.Phone,
                    faxNumber: this.currentAccountInfo.Fax,
                    extension: this.currentAccountInfo.US_WSREMS__EXT__c,
                    credentials: this.currentAccountInfo.US_WSREMS__Professional_Designation__c,
                    othercredentials: this.currentAccountInfo.US_WSREMS__Other_Credentials__c,
                    preferredContactMethod: this.currentAccountInfo.US_WSREMS__Preferred_Contact_Method__c,
                    medicalSpeciality: this.currentAccountInfo.US_WSREMS__Specialty__c,
                    specialityOther: this.currentAccountInfo.US_WSREMS__Other__c
                };

                this.currentAccountInfo.Phone = this.formatPhoneNumber(this.currentAccountInfo.Phone);
                this.currentAccountInfo.Fax = this.formatPhoneNumber(this.currentAccountInfo.Fax);
                this.showSpinner = false;
            }
        } catch (error) {
            console.error(error);
            this.showToast('Error', JSON.stringify(error.body.message), 'error');
            this.showSpinner = false;
        }
    }

    renderedCallback() {
        setTimeout(() => {
            let currentElement = this.template.querySelector(PATH_MAP.get(this.currentPath));
            this.currentPathHandler(currentElement);
            for (let i = 0; i < this.completedPath; i++) {
                let element = this.template.querySelector(PATH_MAP.get(i));
                this.completePathHandler(element);
            }

        }, 100)
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
        //input.checked = true;
        this.selectedContactMethod = input.value;
        this.contactMethods = this.contactMethods.map((obj) => {
            return {
                ...obj,
                checked: obj.value === input.value
            };
        });

        this.prescriberRecord = { ...this.prescriberRecord, 'preferredContactMethod': input.value };
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
        //input.checked = true;
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
        this.degreeOptionNotSelected = false;

        this.prescriberRecord = { ...this.prescriberRecord, 'credentials': input.value };
    }

    handleSpecialityClick(event) {
        let key = event.currentTarget.dataset.key;
        if (!key && key !== 0) {
            return;
        }
        let input = this.template.querySelector(`.speciality-radio-input-${key}`);
        if (!input) {
            return;
        }

        //make the input checked
        //input.checked = true;
        this.selectedSpeciality = input.value;
        this.specialtyOptions = this.specialtyOptions.map((obj) => {
            return {
                ...obj,
                checked: obj.value === input.value
            };
        });
        this.showFreeTextForSpeciality = false;
        if (this.selectedSpeciality === 'Other') {
            this.showFreeTextForSpeciality = true;
        }
        this.specialtyOptionNotSelected = false;

        this.prescriberRecord = { ...this.prescriberRecord, 'medicalSpeciality': input.value };
    }

    getStatePickListOptions() {
        getPickListValues({
            objectName: 'Account',
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

    handleSearchTerm(event) {
        this.searchTerm = event.target.value;
    }

    async handleSearch(event) {
        this.showSpinner = true;
        this.showSearchResults = true;
        this.selectedItem = null;
        try {
            const results = await searchRecords({
                searchString: this.searchTerm
            });
            if (results) {
                this.searchResults = results.map((obj) => {
                    return {
                        ...obj,
                        checked: false
                    };
                });
            }
            this.showSpinner = false;
        } catch (error) {
            console.log(error);
            this.showSpinner = false;
            this.showToast('Error', JSON.stringify(error.body.message), 'error');
        }
    }

    handleSelectedRow(event) {
        let key = event.currentTarget.dataset.id;
        let tempArray =[];
        let tempValue;
        if (!key && key !== 0) {
            return;
        }
        this.searchResults = this.searchResults.map((obj) => {
            return {
                ...obj,
                checked: key === obj.Id
            };
        });
        tempArray = this.searchResults.filter(obj => obj.checked);
        tempValue = tempArray[0];
        tempValue.newrecord = false;
    const exists = this.associatedHCSResults.some(record => record.Id === key);
        if (this.prevouslySelectedTemp == null) {
          this.prevouslySelectedTemp =JSON.parse(JSON.stringify(tempValue));  
         
        }else{
            if(!exists){
                this.associatedHCSResults.pop(this.prevouslySelectedTemp);
            }
            
        }
       
        if(!exists){
            if(this.associatedHCSResults.length<10){
            this.associatedHCSResults.push(tempValue);
            }else{
            this.prevouslySelectedTemp = null;
            this.showToast('Error', 'You can associate upto 10 records only', 'error');
            }
        }
        
     
        this.associatedHCSResults = this.associatedHCSResults.map((obj) => {
            return {
                ...obj,
                checked: false
               
            };
        });
      
        this.selectedItem = key;
        this.showAssociatedHCS = true;
        this.createSettingOption = false;
      
    }
    handleAssociateHCSSelectedRow(event) {
       
        let key = event.currentTarget.dataset.id;
       
        if (!key && key !== 0) {
            return;
        }
        this.associatedHCSResults = this.associatedHCSResults.filter(obj => obj.Id !== key);   
    }

    handleCheckSetting(event) {
        this.createSettingOption = event.target.checked;
        this.selectedItem = null;
        if (event.target.checked) {
            this.searchResults = this.searchResults.map((obj) => {
                return {
                    ...obj,
                    checked: false
                };
            });
        }
    }

    handleInputChange(event) {
        const { name, value } = event.target;
        this.healthCareSettingRecord = { ...this.healthCareSettingRecord, [name]: value };
        this.healthCareSettingRecord = { ...this.healthCareSettingRecord, 'newrecord': true };
    }

    async handleAffiliate(event) {
        //validate values

        let isValid = [...this.template.querySelectorAll('lightning-input[data-id="affiliationData"]'),
        ...this.template.querySelectorAll('lightning-combobox[data-id="affiliationData"]')
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        console.log(isValid);

        if (!isValid) {
            return;
        }
        try {
            this.showSpinner = true;
            const result = await checkDuplicateForHCSAccount({ 'payload': JSON.stringify(this.healthCareSettingRecord), 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c });
            if (result != null && result === true) {
                this.showSpinner = false;
                this.duplicateHCSRecord = true;
                this.showToast('Error', 'An account or contact with the same details already exists.', 'error');
                return;
            }else{
                const matchRecord = (record, healthCareSettingRecord) => {
                    return (
                        record.Name === healthCareSettingRecord.Name &&
                        record.US_WSREMS__Address_Line_1__c === healthCareSettingRecord.US_WSREMS__Address_Line_1__c &&
                        record.US_WSREMS__City__c === healthCareSettingRecord.US_WSREMS__City__c &&
                        record.US_WSREMS__State__c === healthCareSettingRecord.US_WSREMS__State__c &&
                        record.US_WSREMS__Zip__c === healthCareSettingRecord.US_WSREMS__Zip__c
                    );
                };
                
                const exists = this.associatedHCSResults.some(record => matchRecord(record, this.healthCareSettingRecord));
                this.showSpinner = false;
               if(exists){
                this.showToast('Error', 'An account or contact with the same details already exists.', 'error');
               }
                this.duplicateHCSRecord = exists;
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

    async handleSubmit() {
        try {
            this.signatureRequired = false;
            let isValid = [...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-combobox')
            ].reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

            if (this.template.querySelector('c-rems-sign-pad')) {
                this.template.querySelector('c-rems-sign-pad').handleSaveSignature();
            }

            let isPhoneValid = false;
            const regex = /^[0-9]*$/;
            let phoneInput = this.template.querySelector('.phoneNumber');
            if (this.prescriberRecord.phoneNumber != null && this.prescriberRecord.phoneNumber.length > 0) {
                let phoneValue = this.prescriberRecord.phoneNumber.replace(/\D/g, '');
                if (regex.test(phoneValue) && phoneValue.length === 10) {
                    isPhoneValid = true;
                    phoneInput.setCustomValidity("");
                    phoneInput.reportValidity();
                } else {
                    phoneInput.setCustomValidity("Please enter valid Phone number");
                    phoneInput.reportValidity();
                    isPhoneValid = false;
                }
            }
            let isFaxValid = false;
            let faxNumberInput = this.template.querySelector('.faxNumber');
            if (this.prescriberRecord.faxNumber != null && this.prescriberRecord.faxNumber.length > 0) {
                let faxValue = this.prescriberRecord.faxNumber.replace(/\D/g, '');
                if (regex.test(faxValue) && faxValue.length === 10) {
                    isFaxValid = true;
                    faxNumberInput.setCustomValidity("");
                    faxNumberInput.reportValidity();
                } else {
                    faxNumberInput.setCustomValidity("Please enter valid Fax number");
                    faxNumberInput.reportValidity();
                    isFaxValid = false;
                }
            }

            if (this.selectedCredential == null || this.selectedCredential.length === 0) {
                this.degreeOptionNotSelected = true;
            } else {
                this.degreeOptionNotSelected = false;
            }

            if (this.selectedSpeciality == null || this.selectedSpeciality.length === 0) {
                this.specialtyOptionNotSelected = true;
            } else {
                this.specialtyOptionNotSelected = false;
            }
            isValid = isValid && isPhoneValid && isFaxValid;

            if (!isValid || this.selectedCredential == null || this.selectedCredential.length === 0 || this.selectedSpeciality == null || this.selectedSpeciality.length === 0) {
                return;
            }

            if (this.signatureData == null || this.signatureData == undefined || this.signatureData.length === 0) {
                this.showSpinner = false;
                this.signatureRequired = true;
                return;
            }
        
            this.showSpinner = true;
            const accountResult = await updatePrescriberAccount({ 'payload': JSON.stringify(this.prescriberRecord), 'accountId': this.currentAccountInfo.Id });
            if (accountResult != null && accountResult === false) {
                this.showSpinner = false;
                this.showToast('Error', 'Something went wrong, Please contact admin.', 'error');
            }
            const caseServiceResult = await createCaseAndServiceSummary({ accountId: this.currentAccountInfo.Id, 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c, 'payload': JSON.stringify(this.associatedHCSResults)});
            const signResult = await savePrescriberSignature({ 'accountId': this.currentAccountInfo.Id, 'signData': this.signatureData });
            this.showSpinner = false;
            this.completedPath += 1;
            let currentElement = this.template.querySelector(PATH_MAP.get(this.currentPath));
            this.completePathHandler(currentElement);
            this.showEnrollmentForm = false;
            await updatePortalStageForAccount({ 'accountId':  this.currentAccountInfo.Id, 'portalStage': '.completedEnrollment' });
            this.showSuccessScreen = true;
        } catch (error) {
            console.log(error);
            this.showSpinner = false;
            this.showError(error);
        }
    }

    handleContinue(event) {
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'managehcp__c'
            }
        }).then(generatedUrl => {
            window.open(generatedUrl, '_self');
        });
    }
    
  async  handleAnotherAffilation(event) {
        if (this.healthCareSettingRecord != null &&  Object.values(this.healthCareSettingRecord).length > 0){
            await this.handleAffiliate();
            if(!this.duplicateHCSRecord){
                if(this.prevouslySelectedTemp!=null){
                    this.associatedHCSResults.pop(JSON.parse(JSON.stringify(this.prevouslySelectedTemp)))
                  }
                  this.healthCareSettingRecord.Id=Date.now() + '-' + Math.floor(Math.random() * 1000);
                  
                  if(this.associatedHCSResults.length<10){
                  this.associatedHCSResults.push(JSON.parse(JSON.stringify(this.healthCareSettingRecord)));
                  this.healthCareSettingRecord = null;
                  this.showAssociatedHCS = true;  
                  }else{
                    this.showToast('Error', 'You can associate upto 10 records only', 'error');
                    this.healthCareSettingRecord = null;
                   // this.prevouslySelectedTemp = null;
                  }
            }else{
               // this.showToast('Error', 'Duplicate record found', 'error');
            }
        }else{
           /* if(this.healthCareSettingRecord.Id!=null){
            }*/
         
        }
            this.prevouslySelectedTemp=null;
            this.searchTerm ='';
            this.searchResults = [];
            this.selectedItem = null;
            this.showSearchResults = false;
            if(!this.duplicateHCSRecord){
                this.createSettingOption = false;
               
            }
      
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
}