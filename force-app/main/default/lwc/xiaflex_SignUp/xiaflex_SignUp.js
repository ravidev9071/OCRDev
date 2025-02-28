import { LightningElement,api,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import xiaflex_bgBlue from "@salesforce/resourceUrl/xiaflex_bgBlue";

export default class xiaflex_SignUp extends LightningElement {
    
    @api programName = ''; 
    @api profileName = '';
    @api permissionSet = '';  
    @api npiNotfoundWarning = '';
    value = ''; 
    isConfirm=false;
    showHCP=false;
    
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
    }
    
    handleConfirmClick() {
        this.isConfirm=false;
            this.showHCP =true;
        
        
    }
}