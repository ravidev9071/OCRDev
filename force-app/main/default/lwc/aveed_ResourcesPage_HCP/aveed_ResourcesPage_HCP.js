import { LightningElement,api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_resources';
import aveed_adobeReader from "@salesforce/resourceUrl/aveed_adobeReader";
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import Redirect_URLs from '@salesforce/label/c.Redirect_URLs';
import { NavigationMixin } from 'lightning/navigation';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
export default class Aveed_ResourcesPage_HCP extends NavigationMixin(LightningElement){
    @api recordId;
    @api recordTypeDeveloperName;
    @api programId;
    @api portalRole;
    @api progId;
    @track isDisplayFiles = false;
    filesList = [];
    
    redirectUrls = []; 
    iconAdobeReader =aveed_adobeReader;
    async connectedCallback() {
        try {
            loadStyle(this, customHomeStyles); 
            getProgramId({programName : this.programId}).then(res =>{
               
                this.progId = res;
                getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName,programId: this.progId,portalRole: this.portalRole })
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
            
        } catch (error) {
            console.log('error>>',error);
            this.isDisplayFiles = false;

        }

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