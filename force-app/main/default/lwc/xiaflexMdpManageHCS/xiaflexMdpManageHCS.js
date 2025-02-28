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
    showEditModal = false;
    hcsRecord = '';

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.handleAccount();
    }

    handleAccount(){
        this.displaySpinner = true;
        console.log('tesrrr');
        console.log('testt'+Id);
            getPharmaAccount({userId: Id, programType: 'MDP'})
            .then(result =>{
                console.log('result=>', result);
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
                        remsStatusCertified: pharmaAcc.US_WSREMS__Status__c == 'Certified' ? pharmaAcc.US_WSREMS__Status__c : null
                    };
                    this.pharmAcc = [...this.pharmAcc, acc];
                });
            console.log('this.pharmAcc>>'+this.pharmAcc);
            })
            .catch(error =>{
                console.log('errtoi'+ error.body.message);
                this.displaySpinner = false;
            })
    }

    handleHcsDetail(event){
        var currentIndex = event.target.dataset.index;
        sessionStorage.setItem('pharmaId', this.pharmAcc[currentIndex].Id);
        console.log('id->', sessionStorage.getItem('pharmaId'));
    }

    handleAddPharmacy(){
       window.location.href = 'ar-pharmhcsenrollmentform';
    }

    handleRemoveAff(event){
        var currentIndex = event.target.dataset.index;
        console.log('this.pharmAcc.length-->', this.pharmAcc.length);
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
        this.showEditModal = false;
    }

    openEditModal(event){
        var currentIndex = event.target.dataset.index;
        sessionStorage.setItem('pharmaId', this.pharmAcc[currentIndex].Id);
        this.hcsRecord = this.pharmAcc[currentIndex].Id;
        this.showEditModal = true;
    }

    handleRemoveAffNow(currentIndex){
        console.log('currentIndex-->'+ currentIndex);
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