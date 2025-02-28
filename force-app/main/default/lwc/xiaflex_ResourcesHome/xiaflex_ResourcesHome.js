import { LightningElement,api,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import xiaflex_HCP from "@salesforce/resourceUrl/xiaflex_iconHCP";
import xiaflex_HCS from "@salesforce/resourceUrl/xiaflex_iconHCS";
import xiaflex_iconSearch from "@salesforce/resourceUrl/xiaflex_iconSearch";
import { NavigationMixin } from 'lightning/navigation';
import navStyles from '@salesforce/resourceUrl/xiaflex_navcss';
export default class Xiaflex_ResourcesHome extends NavigationMixin(LightningElement){
    
    redirectUrls = []; 
    iconHCP = xiaflex_HCP;
	iconHCS = xiaflex_HCS;
    iconSearch = xiaflex_iconSearch;
    currentUrl;
    homeUrl;
    hcpResourceUrl;
    hcsResourceUrl;
    patientResourceUrl;
    lookupUrl;
   
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
        loadStyle(this, navStyles); 
        this.currentUrl = window.location.href;
        this.homeUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s'; 
        this.hcpResourceUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s/resourceshcp';
        this.hcsResourceUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s/resourceshcs';
        this.patientResourceUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s/resourcepatient'; 
        this.lookupUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s/hcp-hcs-lookup'; 


    }
    
    previewHandler(event) {
        console.log('onclic'+event.target.dataset.previewurl);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:event.target.dataset.previewurl
            }}, false
        )
    }
}