import { LightningElement, api,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/piaSky_homecustomcss'
import PiaSky_Arrow from "@salesforce/resourceUrl/PiaSky_iconArrowRight"
import getRelatedFilesByProgramName from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByProgramName';

export default class PiaSky_prescriber extends LightningElement {
    piaskyArrow = PiaSky_Arrow;
    @api recordTypeDeveloperName;
    @api portalRole;
    filesList = [];
    prscriberEnlmntFrm = {};
    @track resourcesList = [];
    isDisplayFiles = true;
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
    }

    async connectedCallback(){

        const relatedFileResponse = await getRelatedFilesByProgramName({recordTypeDevName: this.recordTypeDeveloperName,programName:'PiaSky REMS',portalRole:this.portalRole });
        if (relatedFileResponse) {
            console.log('relatedFileResponse>..',relatedFileResponse);
            this.filesList = Object.keys(relatedFileResponse).map(item => ({
            
                "label": relatedFileResponse[item].Name,
                "value": item,
                "url": relatedFileResponse[item].ContentDownloadUrl,
                "previewurl":relatedFileResponse[item].DistributionPublicUrl
                
            }));
            this.isDisplayFiles = true;

        }
        this.filesList.forEach((element)=>{
            if(element.label != 'PIASKY Prescriber Enrollment Form' && element.label != 'PIASKY Pharmacy Enrollment Form'){
                this.resourcesList.push(element);
            }
            if(element.label ==='PIASKY Prescriber Enrollment Form'){
                this.prscriberEnlmntFrm = element;
            }
        });

    }
    
}