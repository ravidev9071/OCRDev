import { LightningElement,api,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Aveed_SignUp extends LightningElement {
   
    @api programName = '';
    @api profileName = '';
    @api permissionSet = '';
    @api npiNotfoundWarning = '';
    value = '';
    isHealthcareRep=false;
    isProvider =false;
    isConfirm=false;
    showHCS=false;
    showHCP=false;
    options = [
        { label: 'Healthcare Setting Authorized Representative', value: 'AR' },
        { label: 'Prescribing Healthcare Provider', value: 'HCP' }
    ];
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
    }
    handleChange(event) {
       
        this.value = event.detail.value;
        
       if(this.value ==='AR'){
        this.isHealthcareRep=true;
        this.isProvider=false;
        this.showHCP =false;

       }else if(this.value ==='HCP'){
        this.isProvider=true;
        this.isHealthcareRep=false;
        this.showHCS=false;
       }
       this.isConfirm=true;
       
    }
    handleConfirmClick() {
        this.isConfirm=false;
        if(this.isProvider){
            this.showHCP =true;
        }else if(this.isHealthcareRep) {
            this.showHCS=true;
        }
        
        
    }
}