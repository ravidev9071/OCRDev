import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";
import xiaflex_IconSortAcc from "@salesforce/resourceUrl/xiaflex_IconSortAcc";
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customSecure';
import searchPrescribers from '@salesforce/apex/xiaflex_ManagePharmacies.getPrescriberList';
import insertprescriberPharmaAffiliation from '@salesforce/apex/xiaflex_ManagePharmacies.insertprescriberPharmaAffiliation';
import getPickListValues from '@salesforce/apex/xiaflex_Application_Enrollment_Class.getPicklistFieldValues';
import getPharmaAccount from '@salesforce/apex/xiaflex_ManagePharmacies.getARPharmaAccount';

export default class Xiaflex_prescriberAffiliateModal extends LightningElement {

    @api accType;
    @api pharmaAcc;
    @api programTypeCheck;
    @track hcpRecord = {};
    @track prescriberList = [];
    @track stateOptions = [];
    @track pharmAcc = [];
    @track visibileAccounts = [];
    selectedPharma = '';
    searchById = true;
    searchHcs = true;
    searchByIdPrescriberList = false;
    searchByNamePrescriberList = false;
    displaySpinner = false;
    hcpType = false;
    mdpType = false;
    selectedPrescriberID = '';
    iconSortAcc = xiaflex_IconSortAcc;

     connectedCallback() {
        if(this.accType == 'HCP'){
            this.hcpType = true;
        }
        if(this.programTypeCheck == 'MDP'){
            this.mdpType = true;
        }
        loadStyle(this, customHomeStyles);
        this.getPickListValues();
        this.handlePharmaAcc();
        this.hcpRecord = {
            state: null,
            firstName: null,
            lastName: null
        };
    }

    handlePharmaAcc() {
        this.displaySpinner = true;
        getPharmaAccount({ userId: Id, programType: 'REMS' })
            .then(result => {
                this.displaySpinner = false;
                var data = result;
                this.selectedPharma = data[0].Id;
                this.pharmAcc = data;
            })
            .catch(error => {
                console.log('error ::' + error.body.message);
                this.displaySpinner = false;
            })
    }

    getPickListValues(){
        this.displaySpinner = true;
        getPickListValues()
                .then((pickListVal) => {
                    var stateOptionList = pickListVal.US_WSREMS__State__c;
                    for (var i in stateOptionList) {
                        if(stateOptionList[i] != 'AA' && stateOptionList[i] != 'AE' && stateOptionList[i] != 'AP'){
                            const option = {
                                label: i,
                                value: stateOptionList[i]
                            };
                            this.stateOptions = [...this.stateOptions, option];
                            this.stateOptions.sort();
                        }
                    }
                    this.displaySpinner = false;
                })
                .catch((error) => {
                    this.displaySpinner = false;
                    console.log('Error ::', error);
                });
    }

    handleChangeSearchBy(event){
        this.searchByIdPrescriberList = false;
        this.searchByNamePrescriberList = false;
        this.searchHcs = true;
        this.prescriberList = [];
        this.visibileAccounts = [];
        if(event.target.name == 'hcpName'){
            this.searchById = false;
        } else if(event.target.name == 'hcpId'){
            this.searchById = true;
        }
    }

    handleAccDetails(event){
        let fieldValue = event.target.value;
        this.validateInputs(event);
        this.hcpRecord[event.target.name] = fieldValue;
    }

    handleSelectedPharma(event){
        this.selectedPharma = event.target.value;
    }

    validateInputs(event) {
        const fieldName = event.target.name;
        let fieldValue = event.target.value;        
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {

            const namePatterns = /^[A-Za-z'. -]+$/;

            if (fieldName === 'lastName' && inputField.name === fieldName && !fieldValue.match(namePatterns)) {
                
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid Name.');
                inputField.reportValidity();
            } if (fieldName === 'lastName' && inputField.name === fieldName && fieldValue.match(namePatterns)) {
                
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            } if (fieldName === 'firstName' && inputField.name === fieldName && !fieldValue.match(namePatterns)) {
                inputField.classList.add('slds-has-error');
                inputField.setCustomValidity('Please enter a valid Name.');
                inputField.reportValidity();
            } if (fieldName === 'firstName' && inputField.name === fieldName && fieldValue.match(namePatterns)) {
                inputField.classList.remove('slds-has-error');
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }
        });
    }

    handleSearch(event){
        if(this.hcpType){
            if(this.selectedPharma == null || this.selectedPharma == '' || this.selectedPharma.length <= 0){
                this.showToast('Error!', 'Please fill the Pharmacy Account', 'error');
                return;
            }
        }
        if(this.searchById){
            var searchInput = this.template.querySelector('.searchHcp');
            var programType = '';
                if(this.mdpType){
                    programType = 'MDP';
                } else{
                    programType = 'REMS';
                }
            if (!searchInput.checkValidity()) {
                searchInput.reportValidity();
                return;
            } else{
                this.displaySpinner = true;
                this.prescriberList = [];
                searchPrescribers({ enrollId: searchInput.value, firstName: null, lastName: null,  programType: programType})
                .then((result) => {
                    result.forEach(presAcc => {
                        const acc = {
                                id: presAcc.Id,
                                name: presAcc.Name,
                                enrollId: presAcc.US_WSREMS__REMS_ID__c,
                                stakeholder: 'Prescribing HCP',
                                address1: presAcc.US_WSREMS__Address_Line_1__c,
                                address2: presAcc.US_WSREMS__Address_Line_2__c,
                                city: presAcc.US_WSREMS__City__c,
                                state: presAcc.US_WSREMS__State__c, 
                                zip: presAcc.US_WSREMS__Zip__c,
                                remsStatusPending: presAcc.US_WSREMS__Status__c != 'Certified' ? presAcc.US_WSREMS__Status__c : null,
                                remsStatusCertified: presAcc.US_WSREMS__Status__c == 'Certified' ? presAcc.US_WSREMS__Status__c : null
                            };
                            this.prescriberList = [...this.prescriberList, acc];
                    });
                    this.searchByIdPrescriberList = true;
                    this.searchHcs = false;
                    this.displaySpinner = false;
                })
                .catch(error => {
                    this.displaySpinner  = false;
                    console.log('Error ::', error);
                });
                return;
            }
        } else{
            if (this.hcpRecord.state == null || this.hcpRecord.state == 'None') {
                this.showToast('Error!', 'Please fill the State value', 'error');
                return;
            } else if(this.hcpRecord.lastName == null || this.hcpRecord.lastName.length <= 0){
                this.showToast('Error!', 'Please fill the Last Name', 'error');
                return;
            } else{
                this.displaySpinner = true;
                this.prescriberList = [];
                searchPrescribers({ enrollId: null, firstName: this.hcpRecord.firstName, lastName: this.hcpRecord.lastName, programType: programType})
                .then((result) => {
                    result.forEach(presAcc => {
                        const acc = {
                                id: presAcc.Id,
                                name: presAcc.Name,
                                enrollId: presAcc.US_WSREMS__REMS_ID__c,
                                stakeholder: 'Prescribing HCP',
                                address1: presAcc.US_WSREMS__Address_Line_1__c,
                                address2: presAcc.US_WSREMS__Address_Line_2__c,
                                city: presAcc.US_WSREMS__City__c,
                                state: presAcc.US_WSREMS__State__c, 
                                zip: presAcc.US_WSREMS__Zip__c,
                                remsStatusPending: presAcc.US_WSREMS__Status__c != 'Certified' ? presAcc.US_WSREMS__Status__c : null,
                                remsStatusCertified: presAcc.US_WSREMS__Status__c == 'Certified' ? presAcc.US_WSREMS__Status__c : null
                            };
                            this.prescriberList = [...this.prescriberList, acc];
                    });
                    this.searchByNamePrescriberList = true;
                    this.searchHcs = false;
                    this.displaySpinner = false;
                })
                .catch(error => {
                    this.displaySpinner = false;
                    console.log('Error->', error);
                });
                return;
            }
        }
    }

    handlePrescriberSelection(event){
        this.selectedPrescriberID = event.target.value;
    }

    handleAffiliate(event){
        if(this.selectedPrescriberID == null || this.selectedPrescriberID.length <=0 || this.selectedPrescriberID == undefined){
            this.showToast('Error!', 'Please select the prescriber first', 'error');
            return;
        }else{
            //insert affiliation
            var pharmacyId;
            if(this.hcpType){
                pharmacyId = this.selectedPharma;
            }else{
                pharmacyId = this.pharmaAcc;
            }
             let inputRecords = {
                'prescriberId': this.selectedPrescriberID,
                'pharmaId': pharmacyId,
                'programName': 'Xiaflex'
            };
            this.displaySpinner = true;
            insertprescriberPharmaAffiliation({'inputRecords': inputRecords}).then((result) => {
                if(result == 'Success'){
                    if(this.hcpType){
                        window.location.href = 'manage-hcp';
                    } else{
                        window.location.href = 'manage-hcs-detail';
                    }
                    this.displaySpinner = false;
                }
            }).catch(error => {
                this.showToast('Error', JSON.stringify(error.body.message), 'error');
                this.displaySpinner = false;
            });
        }
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('closemodal', {
            detail: {
                message: ''
            }
        }));
    }

    updateHCPRecords(event){
        var visibileAcc=[...event.detail.records];
        this.visibileAccounts = visibileAcc;
    }

    sortHCPAccountRecords(){
         this.visibileAccounts = [...this.visibileAccounts].sort((a, b) => {
            const enrollIdA = a.enrollId.toLowerCase();
            const enrollIdB = b.enrollId.toLowerCase();
            return enrollIdA.localeCompare(enrollIdB);
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

}