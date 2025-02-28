import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import aveed_customcssSecure from '@salesforce/resourceUrl/aveed_customcssSecure';
import getHCSWithProvidersDetail from '@salesforce/apex/Aveed_ManageHCSForARCtrl.getHCSWithProvidersDetail';
import getRelatedHealthcareSettings from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.getRelatedHealthcareSettings';
import getPickListValues from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getPicklistFieldValues';
import searchHCProvidersRecordsByRemsId from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.searchHCProvidersRecordsByRemsId';
import searchHCProvidersRecordsByName from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.searchHCProvidersRecordsByName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addPrescriberAffiliations from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.addPrescriberAffiliations';
import getCurrentUserAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getCurrentUserAccount';
import disassociateHCSFromAR from '@salesforce/apex/Aveed_ManageHCSForARCtrl.disassociateHCSFromAR';
import disassociateHCPFromAR from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.disassociateHCSFromAR';
import updateARVerification from '@salesforce/apex/Aveed_ManageHCSForARCtrl.updateARVerification';
import { NavigationMixin } from 'lightning/navigation';

export default class Aveed_manageHCS_detail extends NavigationMixin(LightningElement) {

    @api hcsRecordId;

    @track hcsProviders = [];
    @track stateOptions = [];
    @track healthcareSettings = [];
    @track searchProviderResults = [];
    @track hcproviders = [];

    selectedHCSSettingId;
    hcsRecord;
    showDetails = false;
    isLoading = false;
    disassociateModalOpen = false;
    associateAnotherHCP = false;
    selectedHCSId;
    selectedProviderId;
    disassociateHCS = false;
    selectedProviderItem;
    remsEnrollId;
    firstName;
    lastName;
    state;
    currentUserInfo = {};
    currentAccountInfo = {};
    showSearchHCPById = false;
    showSearchHCPByName = false;
    editReEnrollHCS = false;
    showARVerificationModal = false;
    arRepsConfirmation = false;
    showConfirmARVerifyErrorMessage = false;

    get hasSearchProviderResults() {
        return (this.searchProviderResults != null && this.searchProviderResults.length > 0);
    }

    get showAssociateButton() {
        return !(this.selectedProviderItem == null || this.selectedProviderItem.length === 0 || this.hcsRecordId == null || this.hcsRecordId.length === 0);
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        loadStyle(this, aveed_customcssSecure);
        this.handleInit();
    }

    handleInit() {
        const paramValue = this.getUrlParamValue(window.location.href, 'id');
        this.hcsRecordId = paramValue;

        this.getCurrentHCSDetails();
        this.handleGetRelatedHealthcareSettings();
        this.getStatePickListOptions();
        this.handleCurrentUserDetails();
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    async handleCurrentUserDetails() {
        try {
            const result = await getCurrentUserAccount({});
            if (result) {
                this.currentUserInfo = { ...result.currentUser };
                this.currentAccountInfo = { ...result.userAccount };
            }
        } catch (error) {
            console.log(error);
        }
    }

    async handleGetRelatedHealthcareSettings() {
        try {
            const result = await getRelatedHealthcareSettings({});
            if (result) {
                for (let key in result) {
                    this.healthcareSettings.push({
                        label: result[key],
                        value: key
                    });
                }
            }
        } catch (error) {
            console.log(error);
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

    async getCurrentHCSDetails() {
        try {
            this.isLoading = true;
            const result = await getHCSWithProvidersDetail({ hcsId: this.hcsRecordId });
            if (result) {
                this.hcsRecord = {
                    ...result.hcsSetting,
                    addressLine1: result.hcsSetting.US_WSREMS__Address_Line_1__c ? result.hcsSetting.US_WSREMS__Address_Line_1__c : '',
                    addressLine2: result.hcsSetting.US_WSREMS__Address_Line_2__c ? result.hcsSetting.US_WSREMS__Address_Line_2__c : '',
                    city: result.hcsSetting.US_WSREMS__City__c ? result.hcsSetting.US_WSREMS__City__c : '',
                    state: result.hcsSetting.US_WSREMS__State__c ? result.hcsSetting.US_WSREMS__State__c : '',
                    zip: result.hcsSetting.US_WSREMS__Zip__c ? result.hcsSetting.US_WSREMS__Zip__c : '',
                    reEnrollmentDate: this.convertISOToDateFormat(result.hcsSetting.US_WSREMS__Recertification_Due_Date__c),
                    arVerificationDate: this.convertISOToDateFormat(result.hcsSetting.US_WSREMS__VerificationDueDate__c),
                    isPending: result.hcsSetting.US_WSREMS__Status__c === 'Pending',
                    isCertified: result.hcsSetting.US_WSREMS__Status__c === 'Certified',
                    isDecerifiedOrDeactivated: result.hcsSetting.US_WSREMS__Status__c === 'Decertified' || result.hcsSetting.US_WSREMS__Status__c === 'Deactivated',
                    status: result.hcsSetting.US_WSREMS__Status__c === 'Certified'
                        ? 'Certified' : result.hcsSetting.US_WSREMS__Status__c === 'Pending'
                            ? 'Pending' : result.hcsSetting.US_WSREMS__Status__c === 'Decertified'
                                ? 'Decertified' : result.hcsSetting.US_WSREMS__Status__c === 'Deactivated'
                                    ? 'Deactivated' : 'Pending'
                };

                if (result.hcsProviders != null && result.hcsProviders.length > 0) {
                    this.hcsProviders = result.hcsProviders.map((obj) => {
                        return {
                            ...obj,
                            addressLine1: obj.US_WSREMS__Address_Line_1__c ? obj.US_WSREMS__Address_Line_1__c : obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r ? obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c : '',
                            addressLine2: obj.US_WSREMS__Address_Line_2__c ? obj.US_WSREMS__Address_Line_2__c : obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r ? obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c : '',
                            city: obj.US_WSREMS__City__c ? obj.US_WSREMS__City__c : obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r ? obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c : '',
                            state: obj.US_WSREMS__State__c ? obj.US_WSREMS__State__c : obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r ? obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c : '',
                            zip: obj.US_WSREMS__Zip__c ? obj.US_WSREMS__Zip__c : obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r ? obj.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c : '',
                            isPending: obj.US_WSREMS__Status__c === 'Pending',
                            isCertified: obj.US_WSREMS__Status__c === 'Certified',
                            isDecerifiedOrDeactivated: obj.US_WSREMS__Status__c === 'Decertified' || obj.US_WSREMS__Status__c === 'Deactivated',
                            status: obj.US_WSREMS__Status__c === 'Certified'
                                ? 'Certified' : obj.US_WSREMS__Status__c === 'Pending'
                                    ? 'Pending' : obj.US_WSREMS__Status__c === 'Decertified'
                                        ? 'Decertified' : obj.US_WSREMS__Status__c === 'Deactivated'
                                            ? 'Deactivated' : 'Pending'
                        };
                    });
                }

                this.showDetails = true;
            }
            this.isLoading = false;
        } catch (error) {
            this.isLoading = false;
            this.showError(error);
        }
    }

    handleEditReEnroll(event) {
        this.selectedHCSId = event.target.dataset.id;
        this.editReEnrollHCS = true;
    }

    handleARCheck(event) {
        this.arRepsConfirmation = event.target.checked;
    }

    handleARVerification(event) {
        this.showARVerificationModal = true;
    }

    async handleVerifyARVerification(event) {
        this.showConfirmARVerifyErrorMessage = false;
        if (this.arRepsConfirmation === false) {
            this.showConfirmARVerifyErrorMessage = true;
            return;
        }
        this.isLoading = true;
        const result = await updateARVerification({
            'hcsId': this.hcsRecordId,
            'isChecked': this.arRepsConfirmation
        });
        if (result && result === true) {
            this.isLoading = false;
            //do action
            this.closeModal();
            this.handleRefreshEvent();
        } else {
            this.isLoading = false;
        }
    }

    handleOptionById() {
        this.showSearchHCPById = true;
        this.showSearchHCPByName = false;
    }

    handleOptionName() {
        this.showSearchHCPById = false;
        this.showSearchHCPByName = true;
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

    showError(error) {
        let errorMsg = error;
        if (error.body != null && error.body.message != null) {
            errorMsg = error.body.message;
        }
        this.isLoading = false;
        console.error(error);
        this.showToast('Error', JSON.stringify(errorMsg), 'error');
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

    handleDisassociateProvider(event) {
        this.selectedProviderId = event.target.dataset.id;
        this.selectedHCSId = event.target.dataset.hcsid;
        this.disassociateModalOpen = true;
    }

    handleDisassociate(event) {
        this.selectedHCSId = event.target.dataset.id;
        this.disassociateModalOpen = true;
        this.disassociateHCS = true;
    }

    handleAssociateHCP(event) {
        this.selectedProviderId = event.target.dataset.id;
        this.selectedHCSId = event.target.dataset.hcsid;
        this.associateAnotherHCP = true;
        this.selectedHCSSettingId = this.hcsRecordId;
        this.showSearchHCPById = true;
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
    }

    handleSelectState(event) {
        this.state = event.detail.value;
    }

    handleREMSId(event) {
        this.remsEnrollId = event.target.value;
    }

    handleInputChange(event) {
        const { name, value } = event.target;
        if (name === 'firstName' && value) {
            this.firstName = value;
        } else if (name === 'lastName' && value) {
            this.lastName = value;
        }
    }

    async handleHCPAssociate() {
        this.associateAnotherHCP = false;
        this.disassociateModalOpen = false;
        this.isLoading = true;
        try {
            const createProviderAffiliations = await addPrescriberAffiliations({ 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c, 'accountId': this.selectedProviderItem, 'healthCareSettingId': this.hcsRecordId });
            if (createProviderAffiliations && createProviderAffiliations === true) {
                this.handleResetValues();
                this.showToast('Success', 'Affiliations to the Healthcare Provider has been done successfully.', 'success');
                this.handleInit();
            } else {
                this.handleResetValues();
            }
        } catch (error) {
            this.showError(error);
        }
    }

    async handleSearchResults() {
        this.searchProviderResults = [];
        this.selectedProviderItem = null;
        try {
            if (this.showSearchHCPById) {
                let isValid = [...this.template.querySelectorAll('lightning-input[data-id="enrollmentId"]'),
                ...this.template.querySelectorAll('lightning-combobox[data-id="hcsettingsData"]'),
                ].reduce((validSoFar, inputField) => {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }, true);

               

                if (!isValid) {
                    return;
                }

                this.showHCPSearchedResults = true;
                this.isLoading = true;
                const result = await searchHCProvidersRecordsByRemsId({
                    searchString: this.remsEnrollId
                });
                if (result && result.length > 0) {
                    this.searchProviderResults = result.map((obj) => {
                        return {
                            ...obj,
                            checked: false,
                            addressLine1: obj.US_WSREMS__Address_Line_1__c ? obj.US_WSREMS__Address_Line_1__c : '',
                            addressLine2: obj.US_WSREMS__Address_Line_2__c ? obj.US_WSREMS__Address_Line_2__c : '',
                            city: obj.US_WSREMS__City__c ? obj.US_WSREMS__City__c : '',
                            state: obj.US_WSREMS__State__c ? obj.US_WSREMS__State__c : '',
                            zip: obj.US_WSREMS__Zip__c ? obj.US_WSREMS__Zip__c : ''
                        };
                    });
                } else {
                    this.searchProviderResults = [];
                }
                this.isLoading = false;
            } else {
                let isValid = [...this.template.querySelectorAll('lightning-input[data-id="enrollmentByName"]'),
                ...this.template.querySelectorAll('lightning-combobox[data-id="hcsettingsData"]'),
                ].reduce((validSoFar, inputField) => {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }, true);

               

                if (!isValid) {
                    return;
                }

                this.showHCPSearchedResults = true;
                this.isLoading = true;

                const result = await searchHCProvidersRecordsByName({
                    firstName: this.firstName,
                    lastName: this.lastName,
                    state: this.state
                });
                if (result && result.length > 0) {
                    this.searchProviderResults = result.map((obj) => {
                        return {
                            ...obj,
                            checked: false,
                            addressLine1: obj.US_WSREMS__Address_Line_1__c ? obj.US_WSREMS__Address_Line_1__c : '',
                            addressLine2: obj.US_WSREMS__Address_Line_2__c ? obj.US_WSREMS__Address_Line_2__c : '',
                            city: obj.US_WSREMS__City__c ? obj.US_WSREMS__City__c : '',
                            state: obj.US_WSREMS__State__c ? obj.US_WSREMS__State__c : '',
                            zip: obj.US_WSREMS__Zip__c ? obj.US_WSREMS__Zip__c : ''
                        };
                    });
                } else {
                    this.searchProviderResults = [];
                }
                this.isLoading = false;
            }
        } catch (error) {
            this.showError(error);
        }
    }

    async handleDisassociateSubmit() {
        try {
            this.disassociateModalOpen = false;
            this.isLoading = true;
            if (this.disassociateHCS) {
                const result = await disassociateHCSFromAR({ hcsSettingId: this.hcsRecordId });
                if (result && result === true) {
                    this[NavigationMixin.GenerateUrl]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'managehcp__c'
                        }
                    }).then(generatedUrl => {
                        window.open(generatedUrl, '_self');
                    });
                }
            } else {
                const result = await disassociateHCPFromAR({ hcsSettingId: this.hcsRecordId, hcsProviderId: this.selectedProviderId });
                if (result && result === true) {
                    this.handleResetValues();
                    this.handleInit();
                }
            }
        } catch (error) {
            this.isLoading = false;
            this.showError(error);
        }
    }

    handleResetValues() {
        this.searchProviderResults = [];
        this.remsEnrollId = null;
        this.firstName = null;
        this.lastName = null;
        this.state = null;
        this.showSearchHCPByName = false;
        this.showSearchHCPById = false;
        this.showHCPSearchedResults = false;
        this.associateAnotherHCP = false;
        this.disassociateModalOpen = false;
        this.selectedProviderItem = null;
        this.disassociateHCS = false;
        this.closeModal();
    }

    closeModal() {
        this.disassociateModalOpen = false;
        this.associateAnotherHCP = false;
        this.disassociateHCS = false;
        this.selectedProviderId = null;
        this.selectedHCSId = null;
        this.selectedHCSSettingId = null;
        this.showSearchHCPByName = false;
        this.showSearchHCPById = false;
        this.showHCPSearchedResults = false;
        this.editReEnrollHCS = false;
        this.showARVerificationModal = false;
        this.showConfirmARVerifyErrorMessage = false;
        this.arRepsConfirmation = false;
    }

    handleRefreshEvent(event) {
        this.handleResetValues();
        this.handleInit();
    }
}