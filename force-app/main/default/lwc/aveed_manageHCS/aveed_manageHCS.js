import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import aveed_customcssSecure from '@salesforce/resourceUrl/aveed_customcssSecure';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCurrentUserAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getCurrentUserAccount';
import getPickListValues from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getPicklistFieldValues';
import getRelatedHealthcareSettings from '@salesforce/apex/Aveed_ManageHCSForARCtrl.getRelatedHealthcareSettings';
import disassociateHCSFromAR from '@salesforce/apex/Aveed_ManageHCSForARCtrl.disassociateHCSFromAR';
import updateARVerification from '@salesforce/apex/Aveed_ManageHCSForARCtrl.updateARVerification';
import { NavigationMixin } from 'lightning/navigation';

export default class Aveed_manageHCS extends NavigationMixin(LightningElement) {

    currentAccountInfo = {};
    currentUserInfo = {};
    isLoading = false;

    @track hcsSettings = [];
    @track stateOptions = [];

    disassociateModalOpen = false;
    associateAnotherHCS = false;
    selectedHCSId;
    arVerificationModal = false;
    editReEnrollHCS = false;
    showARVerificationModal = false;
    arRepsConfirmation = false;
    showConfirmARVerifyErrorMessage = false;
    hcsRecord = {};

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        loadStyle(this, aveed_customcssSecure);

        this.handleInit();
    }

    handleInit() {
        this.selectedHCSId = null;
        this.hcsSettings = [];
        this.stateOptions = [];
        this.handleGetRelatedHCSForAR();
        this.getStatePickListOptions();
        this.handleCurrentUserDetails();

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

    async handleGetRelatedHCSForAR() {
        this.isLoading = true;
        const result = await getRelatedHealthcareSettings({});
        if (result && result.length > 0) {
            this.hcsSettings = result.map((obj) => {
                return {
                    ...obj,
                    addressLine1: obj.US_WSREMS__Address_Line_1__c ? obj.US_WSREMS__Address_Line_1__c : '',
                    addressLine2: obj.US_WSREMS__Address_Line_2__c ? obj.US_WSREMS__Address_Line_2__c : '',
                    city: obj.US_WSREMS__City__c ? obj.US_WSREMS__City__c : '',
                    state: obj.US_WSREMS__State__c ? obj.US_WSREMS__State__c : '',
                    zip: obj.US_WSREMS__Zip__c ? obj.US_WSREMS__Zip__c : '',
                    reEnrollmentDate: this.convertISOToDateFormat(obj.US_WSREMS__Recertification_Due_Date__c),
                    arVerificationDate: this.convertISOToDateFormat(obj.US_WSREMS__VerificationDueDate__c),
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
        this.isLoading = false;
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

    handleHCSDetail(event) {
        this.selectedHCSId = event.target.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Manage_HCS_Detail__c'
            },
            state: {
                id: this.selectedHCSId //must be string
            }
        }).then(generatedUrl => {
            window.open(generatedUrl, '_self');
        });
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

    handleAssociateHCSModal() {
        this.associateAnotherHCS = true;
    }

    handleManageHCPs(event) {
        this.handleHCSDetail(event);
    }

    handleEditReEnroll(event) {
        this.selectedHCSId = event.target.dataset.id;
        this.editReEnrollHCS = true;
    }

    handleARCheck(event) {
        this.arRepsConfirmation = event.target.checked;
    }

    handleARVerification(event) {
        this.selectedHCSId = event.target.dataset.id;
        this.hcsRecord = this.hcsSettings.find((element) => element.Id === this.selectedHCSId);
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
            'hcsId': this.selectedHCSId,
            'isChecked': this.arRepsConfirmation
        });
        if (result && result === true) {
            this.isLoading = false;
            //do action
            this.closeModal();
            this.handleInit();
        } else {
            this.isLoading = false;
        }
    }

    disassociateHandler(event) {
        this.selectedHCSId = event.target.dataset.id;
        this.disassociateModalOpen = true;
    }

    async handleDisassociateSubmit(event) {
        try {
            this.disassociateModalOpen = false;
            this.isLoading = true;
            const result = await disassociateHCSFromAR({ hcsSettingId: this.selectedHCSId });
            if (result && result === true) {
                this.handleInit();
            }
        } catch (error) {
            this.isLoading = false;
            this.showError(error);
        }
    }

    handleDisassociateCancel() {
        this.disassociateModalOpen = false;
    }

    closeModal() {
        this.associateAnotherHCS = false;
        this.disassociateModalOpen = false;
        this.arVerificationModal = false;
        this.editReEnrollHCS = false;
        this.showARVerificationModal = false;
        this.showConfirmARVerifyErrorMessage = false;
        this.arRepsConfirmation = false;
    }

    handleAssociationProcess() {
        this.closeModal();
        window.location.reload();
    }

    handleAssociateCancel() {
        this.closeModal();
    }

    handleRefreshEvent(event) {
        this.closeModal();
        this.handleInit();
    }
}