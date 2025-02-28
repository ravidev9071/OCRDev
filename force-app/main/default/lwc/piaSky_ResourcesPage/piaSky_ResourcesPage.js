import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import Redirect_URLs from '@salesforce/label/c.Redirect_URLs';
import PiaSky_iconDownload from '@salesforce/resourceUrl/PiaSky_icondownload';
import PiaSky_iconnewwindow from '@salesforce/resourceUrl/PiaSky_iconNewWindow';
import getRelatedFilesByProgramName from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByProgramName';

export default class piaSkyResourceDownload extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordTypeDeveloperName;
    @api versionId;
    @api programId;
    @api portalRole;
    @api filesList;

    @track isDisplayFiles = false;
    filesList = [];
    filesMap = new Map();
    resourcesList = [];
    redirectUrls = [];
    PiaSkyiconDownload = PiaSky_iconDownload;
    PiaSkyiconNewWindow = PiaSky_iconnewwindow;

    async connectedCallback() {
        try {
            const relatedFileResponse = await getRelatedFilesByProgramName({recordTypeDevName: this.recordTypeDeveloperName,programName:'PiaSky REMS',portalRole:this.portalRole });
            const urls = Redirect_URLs.split(';');
            if (relatedFileResponse) {
                this.filesList = Object.keys(relatedFileResponse).map(item => ({
                
                    "label": relatedFileResponse[item].Name,
                    "value": item,
                    "url": relatedFileResponse[item].ContentDownloadUrl,
                    "previewurl":relatedFileResponse[item].DistributionPublicUrl
                    
                }));
                this.isDisplayFiles = true;
            }
            
            urls.forEach(url => {
                const [label,value] = url.split('|');
                if(label!=='Privacy Policy' && label!=='Terms of Use'){
                    this.redirectUrls.push({label: label, url: value});
                }
            });
            
            this.filesList.forEach((element)=>{
                this.filesMap.set(element.label,element);
                if(element.label != 'PIASKY Prescriber Enrollment Form' && element.label != 'PIASKY Pharmacy Enrollment Form'){
                    this.resourcesList.push(element);
                }
            });
            
        } catch (error) {
            console.log('error>>',error);
            this.isDisplayFiles = false;

        }

    }
    get firstFileUrl() {
        return this.filesMap.get('PIASKY Prescriber Enrollment Form')?.url;
    }

    get firstFileLabel() {
        return this.filesMap.get('PIASKY Prescriber Enrollment Form')?.label;
    }

    get secondFileUrl() {
        return this.filesMap.get('PIASKY Pharmacy Enrollment Form')?.url;
    }

    get secondFileLabel() {
        return this.filesMap.get('PIASKY Pharmacy Enrollment Form')?.label;
    }

}