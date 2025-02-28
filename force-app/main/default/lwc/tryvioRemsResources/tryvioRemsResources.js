import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconResources from '@salesforce/resourceUrl/tryvioIconResources';
import tryvioIconPharmacy from '@salesforce/resourceUrl/tryvioIconPharmacy';
import tryvioIconDownload from '@salesforce/resourceUrl/tryvioIconDownload';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import tryvioIconPatients from '@salesforce/resourceUrl/tryvioIconPatients';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
//import getFileUrlByName from '@salesforce/apex/REMSFilePreviewController.getFilePreviewUrl';
import { NavigationMixin } from 'lightning/navigation';
export default class TryvioRemsResources extends NavigationMixin(LightningElement) {

    @api recordId;
    @api recordTypeDeveloperName='Prescribers';
    @api progId;
    @api portRole='Public';
    @api progName ='TRYVIO REMS';
    isDisplayFiles = false;
    filesList = [];
   
    redirectUrls = [];
    iconResources = tryvioIconResources;
    iconPharmacy = tryvioIconPharmacy;
    iconDownload = tryvioIconDownload;
    iconPrescriber = tryvioIconPrescriber;
    iconPatients = tryvioIconPatients;

    connectedCallback() {
        try{
            getProgramId({programName : this.progName}).then(res =>{
                this.progId = res;
                console.log('this.progId '+this.progId);
            })
        }
        catch(error){
            console.log('error>>',error);
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
    navigate(event) {
        console.log('inside method');
        console.log(event.target.dataset);
        console.log(event.target.dataset.recordtype);
        console.log(event.target.dataset.docname);

        const recordTypeName = event.target.dataset.recordtype;
        const docName = event.target.dataset.docname;
        var docNames=[];
        docNames.push(docName);

        if (docName && recordTypeName) {
            console.log('this.progId '+this.progId);
            console.log('this.portRole '+this.portRole);
            getRelatedFilesByRecordId({ recordTypeDevName: recordTypeName, programId: this.progId, portalRole: this.portRole })
                .then(result => {
                    console.log(JSON.stringify(result));
                    const relatedFileResponse = result;
                    if (relatedFileResponse) {
                        let filesList = Object.keys(relatedFileResponse).map(item => ({
                            "label": relatedFileResponse[item].Name,
                            "value": item,
                            "url": relatedFileResponse[item].ContentDownloadUrl,
                            "previewurl":relatedFileResponse[item].DistributionPublicUrl,                            
                        }));
                        console.log('filesList:::', filesList);
                        for(let i=0; i<filesList.length; i++){
                            if(filesList[i].label == docName){
                                window.open(filesList[i].previewurl,"__blank");
                            }
                        }
                    }
                })
                .catch(error => {
                    console.log(error);
                })
        }
    }
    
}