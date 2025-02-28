import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customSecure';
import getPharmaAccount from '@salesforce/apex/xiaflex_ManagePharmacies.getARPharmaAccount';
import removeArAffiliation from '@salesforce/apex/xiaflex_ManagePharmacies.removeArAffiliation';
import Id from "@salesforce/user/Id";


export default class Xiaflex_manageHCS extends LightningElement {

    @track pharmAcc = [];
    pharmaAccDetail;
    displaySpinner = false;
    showWarningModal = false;

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.handleAccount();
    }

    handleAccount(){
        this.displaySpinner = true;
        getPharmaAccount({userId: Id, programType: 'REMS' })
            .then(result => {
                this.prescriberList = [];
                this.displaySpinner = false;
                result.forEach(pharmaAcc => {
                    const acc = {
                        Id: pharmaAcc.Id,
                        name: pharmaAcc.Name,
                        enrollId: pharmaAcc.US_WSREMS__REMS_ID__c,
                        address1: pharmaAcc.US_WSREMS__Address_Line_1__c,
                        address2: pharmaAcc.US_WSREMS__Address_Line_2__c,
                        city: pharmaAcc.US_WSREMS__City__c,
                        state: pharmaAcc.US_WSREMS__State__c,
                        zip: pharmaAcc.US_WSREMS__Zip__c,
                        npi: pharmaAcc.US_WSREMS__National_Provider_Identifier__c,
                        dea: pharmaAcc.US_WSREMS__DEA__c,
                        hcsType: pharmaAcc.US_WSREMS__Healthcare_Setting_Type__c,
                        remsStatusPending: pharmaAcc.US_WSREMS__Status__c != 'Certified' ? pharmaAcc.US_WSREMS__Status__c : null,
                        remsStatusCertified: pharmaAcc.US_WSREMS__Status__c == 'Certified' ? pharmaAcc.US_WSREMS__Status__c : null,
                        reenrollmentdate : pharmaAcc.US_WSREMS__Cases8__r && pharmaAcc.US_WSREMS__Cases8__r.length > 0 ? pharmaAcc.US_WSREMS__Cases8__r[0].CreatedDate.split('T')[0] : ''
                    };
                    this.pharmAcc = [...this.pharmAcc, acc];
                });
            })
            .catch(error =>{
                console.log('error ::'+ error.body);
                this.displaySpinner = false;
            })
    }

    handleHcsDetail(event){
        var currentIndex = event.target.dataset.index;
        sessionStorage.setItem('pharmaId', this.pharmAcc[currentIndex].Id);
    }

    handleAddPharmacy(){
       window.location.href = 'ar-pharmhcsenrollmentform';
    }

    handleRemoveAff(event){
        var currentIndex = event.target.dataset.index;
        if(this.pharmAcc.length <= 1){
            this.showWarningModal = true;
        } else{
            this.handleRemoveAffNow(currentIndex);
        }
    }

    handleConfirmWarning(){
        this.handleRemoveAffNow(0);
    }

    closeModal(){
        this.showWarningModal = false;
    }

    handleRemoveAffNow(currentIndex){
        let inputRecords = {
                'userId': Id,
                'pharmaId': this.pharmAcc[currentIndex].Id,
                'programName': 'Xiaflex',
                'recordType': 'Authorized Representative Affiliation'
            };
            this.displaySpinner = true;
            removeArAffiliation({'inputRecords': inputRecords}).then((result) => {
                window.location.href = 'manage-hcs';
                this.displaySpinner = false;
            }).catch(error => {
                this.showToast('Error', JSON.stringify(error.body.message), 'error');
                this.displaySpinner = false;
            });
    }
}