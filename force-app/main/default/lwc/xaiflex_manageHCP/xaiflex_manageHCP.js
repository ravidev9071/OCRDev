import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customSecure';
import getPharmaAccount from '@salesforce/apex/xiaflex_ManagePharmacies.getARPharmaAccount';
import getRelatedHCPToAR from '@salesforce/apex/xiaflex_ManageHcpAR.getRelatedHCPToAR';
import removeArAffiliation from '@salesforce/apex/xiaflex_ManagePharmacies.removeArAffiliation';

import Id from "@salesforce/user/Id";

export default class Xaiflex_manageHCP extends LightningElement{

    pharmAcc = [];
    showAddAffiliationModal = false;
    displaySpinner = false;
    showRemoveAffiliation = false;
    selectedPharmaId = '';
    @track presPharmaList = [];
    @track pharmaList = [];
    @track presPharmaMap = new Map();

    connectedCallback() {
        loadStyle(this, customHomeStyles);
     //   this.handlePharmaAcc();
        this.getRelatedHCPToAR();
    }


    getRelatedHCPToAR() {
        this.displaySpinner = true;
        getRelatedHCPToAR({ userId: Id, programType: 'REMS' })
            .then(result => {
                this.displaySpinner = false;
                var data = result;
                let pharmaMap = new Map();
                let presMap = new Map();
                data.forEach(currentAff => {
                    if(!pharmaMap.has(currentAff.US_WSREMS__Prescriber__c)){
                        pharmaMap.set(currentAff.US_WSREMS__Prescriber__c, currentAff);
                    }
                    if(presMap.has(currentAff.US_WSREMS__Prescriber__c)){
                        var pharma = [];
                        pharma = presMap.get(currentAff.US_WSREMS__Prescriber__c);
                        var obj = {
                            Id: currentAff.US_WSREMS__Health_Care_Setting__r.Id,
                            Name: currentAff.US_WSREMS__Health_Care_Setting__r.Name,
                        }
                        var checkDup = true;
                        for(var i=0; i < pharma.length; i++){
                            if(pharma[i].Id == obj.Id){
                                checkDup = false;
                            }
                        }
                        if(checkDup){
                            pharma.push(obj);
                        }
                        presMap.set(currentAff.US_WSREMS__Prescriber__c, pharma);
                    } else{
                        var pharma = [];
                        var obj = {
                            Id: currentAff.US_WSREMS__Health_Care_Setting__r.Id,
                            Name: currentAff.US_WSREMS__Health_Care_Setting__r.Name,
                        }
                        pharma.push(obj);
                        presMap.set(currentAff.US_WSREMS__Prescriber__c, pharma);
                    }
                });
                this.pharmAcc = Array.from(pharmaMap.values());
                this.presPharmaMap = presMap;
                this.presPharmaList = this.pharmAcc.map(pharmAccItem => {
                    return {
                        ...pharmAccItem,
                        pharmaList: presMap.get(pharmAccItem.US_WSREMS__Prescriber__c),
                        selectedPharmaId: presMap.get(pharmAccItem.US_WSREMS__Prescriber__c)[0].Id
                    };
                });
            })
            .catch(error => {
                console.log('error ::' + error.body);
                this.displaySpinner = false;
            })
    }
    openAffiliateModal(){
        this.showAddAffiliationModal = true;
    }
    closeModal(){
        this.showAddAffiliationModal = false;
        this.showRemoveAffiliation = false;
    }

    handleRemoveModal(event){
        var currentIndex = event.currentTarget.dataset.index;
        var presId = this.presPharmaList[currentIndex].US_WSREMS__Prescriber__c;
        this.pharmaList = this.presPharmaMap.get(presId);
        this.showRemoveAffiliation = true;
    }

    handleSelectedPharma(event){
        var currentIndex = event.target.dataset.index;
        var selectedId = event.target.value;
        this.presPharmaList[currentIndex].selectedPharmaId = selectedId;
    }

    handlePharmaAcc() {
        this.displaySpinner = true;
        getPharmaAccount({ userId: Id, programType: 'REMS' })
            .then(result => {
                this.displaySpinner = false;
                var data = result;
                this.pharmAcc = data;
            })
            .catch(error => {
                console.log('error ::' + error.body.message);
                this.displaySpinner = false;
            })
    }

    handleRemove(event){
        var currentIndex = event.target.dataset.index;
        //this.displaySpinner = true;
        let inputRecords = {
                'prescriberId': this.presPharmaList[currentIndex].US_WSREMS__Prescriber__c,
                'pharmaId': this.presPharmaList[currentIndex].selectedPharmaId,
                'programName': 'Xiaflex',
                'recordType': 'Prescriber Affiliation'
            };
            removeArAffiliation({'inputRecords': inputRecords}).then((result) => {
                window.location.href = 'manage-hcp';
                this.displaySpinner = false;
            }).catch(error => {
                this.showToast('Error', JSON.stringify(error.body.message), 'error');
                this.displaySpinner = false;
            });
    }

}