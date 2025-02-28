import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import aveed_customcssSecure from '@salesforce/resourceUrl/aveed_customcssSecure';
import getRelatedHCProviderForAR from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.getRelatedHCProviderForAR';
import disassociateHCSFromAR from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.disassociateHCSFromAR';
import getRelatedHealthcareSettings from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.getRelatedHealthcareSettings';
import getPickListValues from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getPicklistFieldValues';
import searchHCProvidersRecordsByRemsId from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.searchHCProvidersRecordsByRemsId';
import searchHCProvidersRecordsByName from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.searchHCProvidersRecordsByName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addPrescriberAffiliations from '@salesforce/apex/Aveed_PharmHCSEnrollmentCtrl.addPrescriberAffiliations';
import getCurrentUserAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getCurrentUserAccount';

export default class Aveed_manageHCP extends LightningElement {

    disassociateModalOpen = false;
    associateAnotherHCP = false;
    disassociateMessage;
    selectedAccId;
    selectedIndex;
    providerId;
    selectedHCSId;
    selectedHCSSettingId;
    @track healthcareSettings = [];
    selectedHCProvider;
    showSearchHCPById = false;
    showSearchHCPByName = false;
    showHCPSearchedResults = false;
    stateOptions = [];
    @track searchProviderResults = [];
    selectedProviderItem;
    remsEnrollId;
    firstName;
    lastName;
    state;
    @track hcproviders = [];
    currentUserInfo = {};
    currentAccountInfo = {};
    isLoading = false;

    get showConfirmBtn() {
        let selectedRecord = this.hcproviders.filter((obj) => {
            return obj.Id === this.selectedAccId
        });
        if (selectedRecord && selectedRecord[0].isMultiple) {
            return false;
        }
        return true;
    }

    get hasSearchProviderResults() {
        return (this.searchProviderResults != null && this.searchProviderResults.length > 0);
    }

    get showMultiple() {
        let selectedRecord = this.hcproviders.filter((obj) => {
            return obj.Id === this.selectedAccId
        });
        if (selectedRecord && selectedRecord[0].isMultiple) {
            return (selectedRecord[0].isMultiple);
        }
        return false;
    }

    get showAssociateButton() {
        return !(this.selectedProviderItem == null || this.selectedProviderItem.length === 0 || this.selectedHCSSettingId == null || this.selectedHCSSettingId.length === 0);
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

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        loadStyle(this, aveed_customcssSecure);
        this.handleGetRelatedHCSForAR();
        this.handleGetRelatedHealthcareSettings();
        this.getStatePickListOptions();
        this.handleCurrentUserDetails();
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

    handleOptionById() {
        this.showSearchHCPById = true;
        this.showSearchHCPByName = false;
    }

    handleOptionName() {
        this.showSearchHCPById = false;
        this.showSearchHCPByName = true;
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

    async handleGetRelatedHCSForAR() {
        this.isLoading = true;
        const result = await getRelatedHCProviderForAR({});
        if (result && result.length > 0) {
            this.hcproviders = result.map((obj) => {
                let associatedHCSNames = [];
                for (let data of obj.hcsSettings) {
                    associatedHCSNames.push(data.hcSettingName);
                }
                return {
                    ...obj.provider,
                    associatedHCSNames: associatedHCSNames.join(", "),
                    isMultiple: associatedHCSNames.length > 1,
                    hcsRelatedToProvider: obj.hcsSettings,
                    addressLine1: obj.provider.US_WSREMS__Address_Line_1__c ? obj.provider.US_WSREMS__Address_Line_1__c : obj.provider.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r ? obj.provider.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_1__c : '',
                    addressLine2: obj.provider.US_WSREMS__Address_Line_2__c ? obj.provider.US_WSREMS__Address_Line_2__c : obj.provider.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r ? obj.provider.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Address_Line_2__c : '',
                    city: obj.provider.US_WSREMS__City__c ? obj.provider.US_WSREMS__City__c : obj.provider.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r ? obj.provider.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__City__c : '',
                    state: obj.provider.US_WSREMS__State__c ? obj.provider.US_WSREMS__State__c : obj.provider.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r ? obj.provider.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__State__c : '',
                    zip: obj.provider.US_WSREMS__Zip__c ? obj.provider.US_WSREMS__Zip__c : obj.provider.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r ? obj.provider.US_WSREMS__Prescriber_PrescribingInstitution__r[0].US_WSREMS__Health_Care_Setting__r.US_WSREMS__Zip__c : '',
                    isPending: obj.provider.US_WSREMS__Status__c === 'Pending',
                    isCertified: obj.provider.US_WSREMS__Status__c === 'Certified',
                    isDecerifiedOrDeactivated: obj.provider.US_WSREMS__Status__c === 'Decertified' || obj.provider.US_WSREMS__Status__c === 'Deactivated',
                    status: obj.provider.US_WSREMS__Status__c === 'Certified'
                        ? 'Certified' : obj.provider.US_WSREMS__Status__c === 'Pending'
                            ? 'Pending' : obj.provider.US_WSREMS__Status__c === 'Decertified'
                                ? 'Decertified' : obj.provider.US_WSREMS__Status__c === 'Deactivated'
                                    ? 'Deactivated' : 'Pending'
                };
            });
        }
        this.isLoading = false;
    }

    async handleDisassociateHCS(event) {
        this.selectedHCSId = event.target.dataset.id;
        try {
            this.disassociateModalOpen = false;
            this.isLoading = true;
            const result = await disassociateHCSFromAR({ hcsSettingId: this.selectedHCSId, hcsProviderId: this.selectedAccId });
            if (result && result === true) {
                this.handleGetRelatedHCSForAR();
            }
        } catch (error) {
            this.isLoading = false;
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
    }

    disassociateHandler(event) {
        this.selectedAccId = event.target.dataset.id;
        this.selectedIndex = event.target.dataset.index;
        this.disassociateModalOpen = true;

        let selectedRecord = this.hcproviders.filter((obj) => {
            return obj.Id === this.selectedAccId
        });

        if (selectedRecord) {
            this.hcsRelatedToProvider = selectedRecord[0].hcsRelatedToProvider;
        }
    }

    handleSelectHCS(event) {
        const { name, value } = event.target;
        this.selectedHCSSettingId = value;
    }

    openAssociateModal() {
        this.associateAnotherHCP = true;
        this.showSearchHCPById = true;
    }

    closeModal() {
        this.handleResetValues();
        this.associateAnotherHCP = false;
        this.disassociateModalOpen = false;
    }

    handleDisassociateCancel() {
        this.disassociateModalOpen = false;
    }

    async handleDisassociateSubmit() {
        try {
            this.disassociateModalOpen = false;
            this.isLoading = true;
            let hscSettingId = this.hcsRelatedToProvider[0].hcsAccountId;
            const result = await disassociateHCSFromAR({ hcsSettingId: hscSettingId, hcsProviderId: this.selectedAccId });
            if (result && result === true) {
                this.handleGetRelatedHCSForAR();
            }

        } catch (error) {
            this.isLoading = false;
            this.showError(error);
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

    get showHCPAssociateBtn() {
        return (this.selectedHCProvider && this.selectedHCProvider.length > 0);
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

    async handleHCPAssociate() {
        this.associateAnotherHCP = false;
        this.disassociateModalOpen = false;
        this.isLoading = true;
        try {
            const createProviderAffiliations = await addPrescriberAffiliations({ 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c, 'accountId': this.selectedProviderItem, 'healthCareSettingId': this.selectedHCSSettingId });
            if (createProviderAffiliations && createProviderAffiliations === true) {
                this.handleResetValues();
                this.showToast('Success', 'Affiliations to the Healthcare Provider has been done successfully.', 'success');
                this.handleGetRelatedHCSForAR();
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

                console.log(isValid);

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

    showError(error) {
        let errorMsg = error;
        if (error.body != null && error.body.message != null) {
            errorMsg = error.body.message;
        }
        this.isLoading = false;
        console.error(error);
        this.showToast('Error', JSON.stringify(errorMsg), 'error');
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
    }
}