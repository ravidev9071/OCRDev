import { LightningElement,api,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import aveed_ArrowRight from "@salesforce/resourceUrl/aveed_iconArrowRight";
import aveed_adobeReader from "@salesforce/resourceUrl/aveed_adobeReader";
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import Redirect_URLs from '@salesforce/label/c.Redirect_URLs';
import { NavigationMixin } from 'lightning/navigation';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import Fax from '@salesforce/label/c.AVEED_FaxNumber';
export default class Aveed_HCPCertification extends NavigationMixin(LightningElement)  {
    iconArrowRight = aveed_ArrowRight;
    iconAdobeReader =aveed_adobeReader;
    @api recordId;
    @api recordTypeDeveloperName;
    @api programId;
    @api portalRole;
    @api progId;
    @track isDisplayFiles = false;
    filesList = [];
    
    redirectUrls = [];
    label = {
        Fax
    };
    filename="AVEED REMS Education Program for Healthcare Providers";
    previewurl;
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
       
        for(var i=0;i< this.filesList.length;i++){
          
            if(this.filesList[i].label === this.filename){
                
             
                this.previewurl =this.filesList[i].previewurl;
                
                
            }
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:this.previewurl
            }}, false
        )
       
    }
}