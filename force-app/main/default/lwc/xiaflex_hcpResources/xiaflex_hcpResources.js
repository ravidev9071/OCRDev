import { LightningElement,api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customSecure';
import xiaflex_logo from "@salesforce/resourceUrl/xiaflex_HeaderLogo";
import xiaflex_adobeReader from "@salesforce/resourceUrl/xiaflex_adobeReader";
import xiaflex_iconDownload from "@salesforce/resourceUrl/xiaflex_iconDownload";
import xiaflex_iconSearch from "@salesforce/resourceUrl/xiaflex_iconSearch";
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import xiaflex_iconLink from "@salesforce/resourceUrl/xiaflex_iconLink";
import Redirect_URLs from '@salesforce/label/c.xiaflex_HCP_Recource_URL';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import { NavigationMixin } from 'lightning/navigation';
export default class Xiaflex_hcpResources extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordTypeDeveloperName='Prescriber';
    @api progId;
    @api portRole='Prescriber';
    @api progName ='XIAFLEX';
    isDisplayFiles = false;
    filesList = [];
    
    redirectUrls = [];
    logo = xiaflex_logo;
    iconSearch = xiaflex_iconSearch;
    adobeReader = xiaflex_adobeReader;
    iconDownload = xiaflex_iconDownload;
    iconLink = xiaflex_iconLink;
    
    connectedCallback() {
        try {
            loadStyle(this, customHomeStyles); 
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
                        "form": relatedFileResponse[item].Name.includes(' Form ')? true: false,
                        
                    }));
                    this.isDisplayFiles = true;
                }
                this.redirectUrls = urls.map(url => ({label: url.split('|')[0], url: url.split('|')[1]}));
                })
                .catch(error => {
                })
            })
            .catch(error => {
            })
            
        } catch (error) {
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