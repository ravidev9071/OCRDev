import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from "@salesforce/user/Id";
import { NavigationMixin } from 'lightning/navigation';
import getPharmaAccount from '@salesforce/apex/xiaflex_ManagePharmacies.getPharmaAccount';
import removeAffiliation from '@salesforce/apex/xiaflex_ManagePharmacies.removeAffiliation';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customSecure';

export default class Xiaflex_HCP_manageHCS extends NavigationMixin(LightningElement) {

    @track pharmAcc = [];
    @track showRemovalModal = false;
    @track removePharmaAcc = {};
    @track pharmaName;
    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.handleAccount();
    }

    handleAccount(){
        this.displaySpinner = true;
            getPharmaAccount({userId: Id})
            .then(result =>{
                this.displaySpinner = false;
                var data = result;
                this.pharmAcc = data;
                data.forEach((rec, index) => {
                        this.pharmAcc[index].removeAffiliation = true;
                });
                
            })
            .catch(error =>{
                console.log('errtoi'+ error.body.message);
                this.displaySpinner = false;
            })
    }
    
    handleAnotherHCS(event){
       
        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'HCP_affiliateHCS__c'
                            }
                        });
    }

    handleClick(){
        
    }

    handleRemove(event){
        this.removePharmaAcc = {}
        var currentIndex = event.target.dataset.index;
        this.removePharmaAcc = this.pharmAcc[currentIndex];
        this.pharmaName = this.pharmAcc[currentIndex].Name;

        if(this.pharmAcc.length <= 1){
            this.showRemovalModal = true;
        } else{
            this.handleRemoveAffiliation();
        }
    }

    handleRemoveAffiliation(event){
        let inputRecords = {
            'programName': 'XiaFlex',
            'Id': this.removePharmaAcc.Id,
            'CurrentuserID': Id
        }; 
        removeAffiliation({inputRecords: inputRecords})
            .then(result =>{
                if(result == 'Success'){
                    this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'HCP_managerHCS__c'
                            }
                        });
                }
                if(result == 'logout'){
                     event.preventDefault();
                    this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                    pageName: 'home'
                    }
                    });
                }

            })
            .catch(error =>{
                console.log('errtoi'+ error.body.message);
            })
    
        this.showRemovalModal = false;
        
    }

    handleCancel(){
        this.showRemovalModal = false;
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