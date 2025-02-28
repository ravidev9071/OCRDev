import { LightningElement, api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_homecustomcss';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import { NavigationMixin } from 'lightning/navigation';

export default class Xiaflex_Footer extends NavigationMixin(LightningElement) {
	@api recordId;
    @api recordTypeDeveloperName;
    @api versionId;
    @api programId;
    @api portalRole;

    isDisplayFiles = false;
    filesList = [];

    async connectedCallback() {
        try {
            loadStyle(this, customHomeStyles); 
            getProgramId({programName : this.programId}).then(res =>{
                this.progId = res;
                getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName,programId: this.progId,portalRole: this.portalRole })
                .then(result => {
                    const relatedFileResponse = result;
                    if (relatedFileResponse) {
                        this.filesList = Object.keys(relatedFileResponse).map(item => ({
                            "label": relatedFileResponse[item].Name,
                            "value": item,
                            "url": relatedFileResponse[item].ContentDownloadUrl,
                            "previewurl":relatedFileResponse[item].DistributionPublicUrl, 
                        }));
                        this.isDisplayFiles = true;
                    }
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