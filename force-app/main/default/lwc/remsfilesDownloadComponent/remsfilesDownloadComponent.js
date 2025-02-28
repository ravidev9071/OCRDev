import { LightningElement, api, track } from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId'
import { NavigationMixin } from 'lightning/navigation'

export default class FilesDownloadComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordTypeDeveloperName;
    @api versionId;
    @api programId;
    @api portalRole;

    @track isDisplayFiles = false;
    filesList = [];
    

    async connectedCallback() {
        try {
            const relatedFileResponse = await getRelatedFilesByRecordId({recordTypeDevName: this.recordTypeDeveloperName,programId:this.programId,portalRole:this.portalRole });
            if (relatedFileResponse) {
                this.filesList = Object.keys(relatedFileResponse).map(item => ({
                
                    "label": relatedFileResponse[item].Name,
                    "value": item,
                    "url": relatedFileResponse[item].ContentDownloadUrl,
                    "previewurl":relatedFileResponse[item].DistributionPublicUrl
                    
                }));
                const rmrIndex = this.filesList.findIndex(x => x.label === 'Risk Management Report')
                const pefIndex = this.filesList.findIndex(x => x.label === 'Patient Enrollment Form')
                if (rmrIndex !== -1 && pefIndex !== -1) {
                    this.filesList.splice(pefIndex + 1, 0, this.filesList[rmrIndex])
                    let rmrCount = 1;
                    let rmrInd = 0;
                    this.filesList.map((x, i) => {
                        if (x.label === 'Risk Management Report') {
                            rmrCount += rmrCount;
                            rmrInd = i;  
                        }
                    })
                    if (rmrCount > 1) {
                        this.filesList.splice(rmrInd, 1);
                    }
                }
                this.isDisplayFiles = true;
            }
        } catch (error) {
            console.log('error>>',error);
            this.isDisplayFiles = false;

        }

    }


    // @wire(getRelatedFilesByRecordId, {
    //      recordTypeDevName: this.recordTypeDeveloperName,programId:this.programId,portalRole:this.portalRole })
    // wiredResult({ data, error }) {
    //     if (data) {
    //         this.filesList = Object.keys(data).map(item => ({
                
    //             "label": data[item].Name,
    //             "value": item,
    //             "url": data[item].ContentDownloadUrl,
    //             "previewurl":data[item].DistributionPublicUrl
                
    //         }))
    //      alert('portalRole'+data);
    //     }
    //     if (error) {
    //         console.log(error)
    //         //alert('portalRole1232432'+portalRole);
    //     }
    // }
    
    previewHandler(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:event.target.dataset.previewurl
            }}, false
        )
    }
}