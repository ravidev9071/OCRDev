import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from "@salesforce/user/Id";
import getPharmaAccount from '@salesforce/apex/xiaflex_ManagePharmacies.getPharmaAccount';
import removeAffiliation from '@salesforce/apex/xiaflex_ManagePharmacies.removeAffiliation';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customSecure';

export default class Xiaflex_HCP_manageHCS extends LightningElement {

    @track pharmAcc = [];
    @track showRemovalModal = false;
    @track removePharmaAcc = {};
    @track pharmaName;
displaySpinner = false;
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
                    console.log('data',data);
                        this.pharmAcc[index].removeAffiliation = true;
                });
                
            })
            .catch(error =>{
                console.log('errtoi'+ error.body.message);
                this.displaySpinner = false;
            })
    }
    
    handleAnotherHCS(){
        window.location.href = 'hcp-affiliatehcs';
    }

    handleClick(){
        
    }

    handleRemove(event){
         this.displaySpinner = true;
        this.removePharmaAcc = {}
        this.showRemovalModal = true;
        var currentIndex = event.target.dataset.index;
        this.removePharmaAcc = this.pharmAcc[currentIndex];
        this.pharmaName = this.pharmAcc[currentIndex].Name;

        if(this.pharmAcc.length <= 1){ 
            this.displaySpinner = false;
            this.showWarningModal = true;
        } else{
            this.handleRemoveAffiliation();
        }
    }

    handleRemoveAffiliation(){
        this.displaySpinner = true;
        let inputRecords = {
            'programName': 'XiaFlex',
            'Id': this.removePharmaAcc.Id,
            'CurrentuserID': Id
        }; 
        removeAffiliation({inputRecords: inputRecords})
            .then(result =>{
                if(result == 'Success'){
                window.location.href = 'hcp-managehcs';
                }
                if(result == 'logout'){
                     this.currentUrl = window.location.href;
                            this.homeUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s';
                    window.location.href = this.homeUrl;
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