import { LightningElement,api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import xiaflex_logo from "@salesforce/resourceUrl/xiaflex_HeaderLogo";
import xiaflex_adobeReader from "@salesforce/resourceUrl/xiaflex_adobeReader";
import xiaflex_iconDownload from "@salesforce/resourceUrl/xiaflex_iconDownload";
import xiaflex_iconSearch from "@salesforce/resourceUrl/xiaflex_iconSearch";
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import xiaflex_iconLink from "@salesforce/resourceUrl/xiaflex_iconLink";
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import { NavigationMixin } from 'lightning/navigation';
export default class Xiaflex_resourcesHCP extends NavigationMixin(LightningElement){
    @api recordId;
    @api recordTypeDeveloperName='Prescriber';
    @api progId;
    @api portRole='Public';
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
            getProgramId({programName : this.progName}).then(res =>{
                this.progId = res;

                 getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName, programId: this.progId, portalRole: this.portRole })
                .then(result => {
                    const relatedFileResponse = result;
                const urls = '';
                if (relatedFileResponse) {
                    
                    this.filesList = Object.keys(relatedFileResponse).map(item => ({
                        "label": relatedFileResponse[item].Name,
                        "value": item,
                        "url": relatedFileResponse[item].ContentDownloadUrl,
                        "previewurl":relatedFileResponse[item].DistributionPublicUrl,
                        "form": relatedFileResponse[item].Name.includes(' Form ')? true: false,
                        "icon": relatedFileResponse[item].Name.includes('Medication Guide') || relatedFileResponse[item].Name.includes('Prescribing Information')?this.iconLink:this.iconDownload
                    }));
                    for(let i=0; i<this.filesList.length;i++){
                        if(this.filesList[i].label == 'Medication Guide'){
                            this.filesList[i].url = 'https://endodocuments.com/XIAFLEX/MG';
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