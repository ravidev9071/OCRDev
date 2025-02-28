import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customSecure';
import getPharmaAccount from '@salesforce/apex/xiaflex_ManagePharmacies.getPharmaAccountDetails';
import removeArAffiliation from '@salesforce/apex/xiaflex_ManagePharmacies.removeArAffiliation';
import Id from "@salesforce/user/Id";

export default class Xiaflex_manageHCS_detail extends LightningElement {

    @track hcsRecord = {};
    @track prescriber = []; 
    showAddAffiliationModal = false;
    showEditModal = false;
    showWarningModal = false;
    searchHcs = true;
    displaySpinner = false;

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        let pharmaId = sessionStorage.getItem('pharmaId');
        this.getHcsRecord(pharmaId);

    }

    getHcsRecord(accId){
        this.displaySpinner = true;
        getPharmaAccount({accId: accId})
        .then(result => {
                    if (result != null && result != undefined) {
                        var prescriberAcc = result.prescriber;
                        this.hcsRecord.Id = result.pharma[0].Id;
                        this.hcsRecord.name = result.pharma[0].Name;
                        this.hcsRecord.remsStatusPending = result.pharma[0].US_WSREMS__Status__c != 'Certified' ? result.pharma[0].US_WSREMS__Status__c : null;
                        this.hcsRecord.remsStatusCertified = result.pharma[0].US_WSREMS__Status__c == 'Certified' ? result.pharma[0].US_WSREMS__Status__c : null;
                        this.hcsRecord.enrollId = result.pharma[0].US_WSREMS__REMS_ID__c;
                        this.hcsRecord.dea = result.pharma[0].US_WSREMS__DEA__c;
                        this.hcsRecord.npi = result.pharma[0].US_WSREMS__National_Provider_Identifier__c;
                        this.hcsRecord.settingType = result.pharma[0].US_WSREMS__Healthcare_Setting_Type__c;
                        this.hcsRecord.addressLine1 = result.pharma[0].US_WSREMS__Address_Line_1__c;
                        this.hcsRecord.addressLine2 = result.pharma[0].US_WSREMS__Address_Line_2__c;
                        this.hcsRecord.city = result.pharma[0].US_WSREMS__City__c;
                        this.hcsRecord.state = result.pharma[0].US_WSREMS__State__c;
                        this.hcsRecord.zip = result.pharma[0].US_WSREMS__Zip__c;
                        prescriberAcc.forEach(presAcc => {
                            const acc = {
                                id: presAcc.Id,
                                name: presAcc.Name,
                                role: presAcc.US_WSREMS__Role__c,
                                enrollId: presAcc.US_WSREMS__REMS_ID__c,
                                address1: presAcc.US_WSREMS__Address_Line_1__c,
                                address2: presAcc.US_WSREMS__Address_Line_2__c,
                                city: presAcc.US_WSREMS__City__c,
                                state: presAcc.US_WSREMS__State__c,
                                zip: presAcc.US_WSREMS__Zip__c,
                                remsStatusPending: presAcc.US_WSREMS__Status__c != 'Certified' ? presAcc.US_WSREMS__Status__c : null,
                                remsStatusCertified: presAcc.US_WSREMS__Status__c == 'Certified' ? presAcc.US_WSREMS__Status__c : null
                            };
                            this.prescriber = [...this.prescriber, acc];
                        });
                    }
                    this.displaySpinner = false;
                    //this.displaySection = true;
                })
                .catch(error => {
                    this.displaySpinner = false
                })
                
    }

    openAffiliateModal(){
        this.showAddAffiliationModal = true;
    }

    openEditModal(){
        this.showEditModal = true;
    }

    handleRemovePharmaAff(event){
        this.displaySpinner = true;
        let inputRecords = {
                'userId': Id,
                'pharmaId': this.hcsRecord.Id,
                'programName': 'Xiaflex',
                'recordType': 'Authorized Representative Affiliation'
            };
            removeArAffiliation({'inputRecords': inputRecords}).then((result) => {
                window.location.href = 'manage-hcs';
                this.displaySpinner = false;
            }).catch(error => {
                this.showToast('Error', JSON.stringify(error.body.message), 'error');
                this.displaySpinner = false;
            });
    }

    handleRemovePrescriberAff(event){
        var currentIndex = event.target.dataset.index;
        if(this.prescriber.length <= 1){
            this.showWarningModal = true;
        } else{
            this.handleRemovePrescriberAffNow(currentIndex);
        }
    }

    handleConfirmWarning(){
        this.handleRemovePrescriberAffNow(0);
    }

    handleRemovePrescriberAffNow(currentIndex){
        this.displaySpinner = true;
        let inputRecords = {
                'prescriberId': this.prescriber[currentIndex].id,
                'pharmaId': this.hcsRecord.Id,
                'programName': 'Xiaflex',
                'recordType': 'Prescriber Affiliation'
            };
            removeArAffiliation({'inputRecords': inputRecords}).then((result) => {
                window.location.href = 'manage-hcs-detail';
                this.displaySpinner = false;
            }).catch(error => {
                this.showToast('Error', JSON.stringify(error.body.message), 'error');
                this.displaySpinner = false;
            });
    }

    closeModal(){
        this.showAddAffiliationModal = false;
        this.showEditModal = false;
        this.showWarningModal = false;
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