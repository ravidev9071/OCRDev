import { LightningElement,api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import xiaflex_logo from "@salesforce/resourceUrl/xiaflex_HeaderLogo";
import xiaflex_adobeReader from "@salesforce/resourceUrl/xiaflex_adobeReader";
import xiaflex_iconDownload from "@salesforce/resourceUrl/xiaflex_iconDownload";
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import xiaflex_iconSearch from "@salesforce/resourceUrl/xiaflex_iconSearch";
import Redirect_URLs from '@salesforce/label/c.Redirect_URLs';
import xiaflex_iconLink from "@salesforce/resourceUrl/xiaflex_iconLink";
import { NavigationMixin } from 'lightning/navigation';
export default class Xiaflex_ResourcesHCS extends NavigationMixin(LightningElement){

    @api recordId;
    @api recordTypeDeveloperName='Pharmacy';
    @api progId;
    @api progName = 'XIAFLEX';
    @api portRole='Public';
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
                console.log('res', res);
                this.progId = res;
                 getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName,programId: this.progId,portalRole: this.portRole })
                .then(result => {
                    console.log('result ',result);
                    const relatedFileResponse = result;
                const urls = Redirect_URLs.split(';');
                console.log('2',JSON.stringify(relatedFileResponse));
                if (relatedFileResponse) {
                    
                    this.filesList = Object.keys(relatedFileResponse).map(item => ({
                        "label": relatedFileResponse[item].Name,
                        "value": item,
                        "url": relatedFileResponse[item].ContentDownloadUrl,
                        "previewurl":relatedFileResponse[item].DistributionPublicUrl
                        
                    }));
                    this.isDisplayFiles = true;
                    for(let i=0; i<this.filesList.length;i++){
                        if(this.filesList[i].label == 'Medication Guide'){
                            this.filesList[i].url = 'https://endodocuments.com/XIAFLEX/MG';
                            this.filesList[i].label = 'https://endodocuments.com/XIAFLEX/MG';
                        }
                    }
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
            console.log(this.recordTypeDeveloperName,'1',this.progId,this.portRole);
            
        } catch (error) {
            console.log('error>>',error);
            this.isDisplayFiles = false;

        }

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