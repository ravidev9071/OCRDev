import { LightningElement,api,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import xiaflex_HCP from "@salesforce/resourceUrl/xiaflex_iconHCP";
import xiaflex_HCS from "@salesforce/resourceUrl/xiaflex_iconHCS";
import xiaflex_bgBlue from "@salesforce/resourceUrl/xiaflex_bgBlue";
import xiaflex_iconSearch from "@salesforce/resourceUrl/xiaflex_iconSearch";
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import Redirect_URLs from '@salesforce/label/c.Redirect_URLs';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
export default class Xiaflex_Main extends LightningElement{
    @api recordId;
    @api recordTypeDeveloperName='Patient';
    @api progId;
    @api progName ='XIAFLEX';
    @api portRole='Public';
    isDisplayFiles = false;
    filesList = [];
    urlFile='';
    
    redirectUrls = [];
    iconHCP = xiaflex_HCP;
	iconHCS = xiaflex_HCS;
    iconSearch = xiaflex_iconSearch;
    bgBlue = xiaflex_bgBlue;
    homeURL;
    showCertificationEnrollment = false;
    showCertificationEnrollmentHCP = false;
    
   
     connectedCallback() {
        loadStyle(this, customHomeStyles); 
        this.homeURL = window.location.href;  
        const urls = Redirect_URLs.split(';');
            getProgramId({programName : this.progName}).then(res =>{
                this.progId = res;

                 getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName, programId: this.progId, portalRole: this.portRole })
                .then(result => {
                const relatedFileResponse = result;
                const urls = Redirect_URLs.split(';');
                if (relatedFileResponse) {
                    
                    this.filesList = Object.keys(relatedFileResponse).map(item => ({
                        "label": relatedFileResponse[item].Name,
                        "value": item,
                        "url": relatedFileResponse[item].ContentDownloadUrl,
                        "previewurl":relatedFileResponse[item].DistributionPublicUrl,
                        
                    }));
                    for(let i=0; i<this.filesList.length;i++){
                        if(this.filesList[i].label.includes('What You Need to Know About XIAFLEX Treatment for Peyronie')){
                            this.urlFile = this.filesList[i].previewurl;
                        }
                    }
                    this.isDisplayFiles = true;
                }
                this.redirectUrls = urls.map(url => ({label: url.split('|')[0], url: url.split('|')[1]}));
                })
                .catch(error => {
                    console.log(error);
                })
            })
            .catch(error => {
                console.log(error);
            }) 
    }  
    handleOnlineCertification(){
        this.showCertificationEnrollment = !this.showCertificationEnrollment;
    }

    handleOnlineCertificationHCP(){
        this.showCertificationEnrollmentHCP = !this.showCertificationEnrollmentHCP;
    }
    openHCP(){
        this.currentUrl = window.location.href;
       this.login = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s/login-Signup';
       window.open(this.login,'_self');
    }
    openHCS(){
        this.currentUrl = window.location.href;
        this.hcs = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s/pharm-hcs-enrollment-form';
        window.open(this.hcs,'_self');
    }
    previewHandler(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:event.target.dataset.previewurl
            }}, false
        )
    }
}