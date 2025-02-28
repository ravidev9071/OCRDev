import { LightningElement, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import Id from "@salesforce/user/Id";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedHCSList from '@salesforce/apex/aveed_HCS_RecordsManager.getRelatedHCSList';
import disassociateHandler from '@salesforce/apex/aveed_HCS_RecordsManager.disassociateHandler';
import searchRecords from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.searchRecords';
import checkDuplicateForHCSAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.checkDuplicateForHCSAccount';
import insertHealthCareSettingAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.insertHealthCareSettingAccount';
import addAffiliations from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.addAffiliations';
import getCurrentUserAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getCurrentUserAccount';
import getPickListValues from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getPicklistFieldValues';

export default class Aveed_HCP_manageHCS extends LightningElement {

    disassociateModalOpen = false;
    msg;
    isLoading = false;
    searchTerm = '';
    openAddHCSModal = false;
    showSearchResults = false;
    @track searchResults = [];
    createSettingOption = false;
    currentAccountInfo = {};
    @track hcsList = [];
    healthCareSettingRecord = {};
    @track stateOptions = [];
    @track certiandnot;
    @track hcscertified1;

    async connectedCallback() {
        this.isLoading = true;
        loadStyle(this, customHomeStyles);

        this.getStatePickListOptions();

        try {
            const result = await getCurrentUserAccount({});
            if (result) {
                this.currentAccountInfo = { ...result.userAccount };
            }
        } catch (error) {
            console.error(error);
            this.showToast('Error', JSON.stringify(error.body.message), 'error');
        }

        this.isLoading = false;

    }

    @wire(getRelatedHCSList, { userId: Id })
    getAccountList({ data, error }) {
        if (data) {
            this.hcsList = JSON.parse(JSON.stringify(data));
            this.hcsList = data.map(hcsRecord => {
                return {
                    ...hcsRecord,
                    formattedCreatedDate: this.convertISOToDateFormat(hcsRecord.US_WSREMS__Recertification_Due_Date__c),
                    hcscertified1: this.hcscertified12(hcsRecord.US_WSREMS__Status__c)
                };
            });

        }
    }
    hcscertified12(certifield) {

        if (certifield == 'Certified') {
            this.certiandnot = true;
            return this.certiandnot;
        }
        else {
            this.certiandnot = false;
            return this.certiandnot;
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

    disassociateHandler(event) {
        event.preventDefault();
        this.selectedAccId = event.target.dataset.id;
        this.selectedIndex = event.target.dataset.index;
        if (this.hcsList.length == 1) {
            this.msg = 'WARNING: By clicking Submit you will be removing your association with ' + this.hcsList[this.selectedIndex].Name + ' , this could disenroll you or ' + this.hcsList[this.selectedIndex].Name + ' from the AVEED REMS. If you have questions, you can call the Call Center 1-855-755-0494 for assistance.';
            //this.msg = 'You must be associated to a certified healthcare setting to remain certified. If you proceed with disassociating you will be deactivated';
        } else {
            this.msg = 'You are going to disassociate this current Health Care Setting: ' + this.hcsList[this.selectedIndex].Name;
        }
        this.disassociateModalOpen = true;

    }

    handleCancel() {
        this.disassociateModalOpen = false;
    }

    handleSubmit() {
        this.disassociateModalOpen = false;
        this.isLoading = true;
        disassociateHandler({ accountId: this.selectedAccId, hcsCount: this.hcsList.length }).then((response) => {
            if (response == true) {
                this.hcsList.splice(this.selectedIndex, 1);
            }
            this.isLoading = false;
        });
    }

    addHCSModalOpener() {

        this.openAddHCSModal = true;
    }

    closeAddHCSModal() {
        this.openAddHCSModal = false;
        this.showSearchResults = false;
    }

    handleSearchTerm(event) {
        this.searchTerm = event.target.value;
    }

    async handleSearch(event) {
        this.isLoading = true;
        this.showSearchResults = true;
        this.selectedItem = null;
        try {
            const results = await searchRecords({
                searchString: this.searchTerm
            });

            if (results) {
                this.hasSearchResults = true;
                this.searchResults = results.map((obj) => {
                    return {
                        ...obj,
                        checked: false
                    };
                });
            } else {
                this.hasSearchResults = false;
            }
            this.isLoading = false;
        } catch (error) {
            console.log(error);
            this.isLoading = false;
            this.showToast('Error', JSON.stringify(error.body.message), 'error');
        }
    }

    handleSelectedRow(event) {
        let key = event.currentTarget.dataset.id;
        if (!key && key !== 0) {
            return;
        }
        this.searchResults = this.searchResults.map((obj) => {
            return {
                ...obj,
                checked: key === obj.Id
            };
        });

        this.selectedItem = key;
        this.createSettingOption = false;
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
    }

    get isAffiliateDisabled() {
        if (this.createSettingOption || (this.selectedItem != null && this.selectedItem.length > 0)) {
            return false;
        }
        return true;
    }

    async handleAffiliate(event) {
        //validate values

        let isValid = [...this.template.querySelectorAll('lightning-input[data-id="affiliationData"]'),
        ...this.template.querySelectorAll('lightning-combobox[data-id="affiliationData"]')
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);



        if (!isValid) {
            return;
        }
        try {
            this.isLoading = true;
            const result = await checkDuplicateForHCSAccount({ 'payload': JSON.stringify(this.healthCareSettingRecord), 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c });

            if (result != null && result === true) {
                this.isLoading = false;
                this.showToast('Error', 'An account or contact with the same details already exists.', 'error');
                return;
            }
            var creationResult;
            if (this.createSettingOption) {
                creationResult = await insertHealthCareSettingAccount({ 'payload': JSON.stringify(this.healthCareSettingRecord), 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c });
            }
            let hcsSettingId = (creationResult != null && creationResult.length > 0) ? creationResult : this.selectedItem;
            this.healthCareSettingAccountId = hcsSettingId;
            const createAffiliations = await addAffiliations({ 'programId': this.currentAccountInfo.US_WSREMS__REMS_Program__c, 'accountId': this.currentAccountInfo.Id, 'healthCareSettingId': hcsSettingId });
            if (createAffiliations != null && createAffiliations === true) {
                this.isLoading = false;
                this.showToast('Success', 'Affiliation to Health Care Setting has been done successfully.', 'success');
                this.closeAddHCSModal();
                window.location.reload();
            }
            else if (createAffiliations == false) {
                this.isLoading = false;
                this.showToast('Error', 'Selected Health Care Setting is already Affiliated with Health Care Provider.', 'error');
            }
            else {
                this.isLoading = false;
                this.showToast('Error', 'Something went wrong, Please contact admin.', 'error');
            }

        } catch (error) {
            this.isLoading = false;
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