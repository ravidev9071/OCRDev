import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPharmacy from '@salesforce/resourceUrl/tryvioIconPharmacy';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import tryvioIconPatients from '@salesforce/resourceUrl/tryvioIconPatients';
import Phone from '@salesforce/label/c.tryvioPhone';
import Fax from '@salesforce/label/c.tryvioFax';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
export default class TryvioRemsHome extends LightningElement {
    @api recordTypeDeveloperName='Pharmacy';
    @api progId;
    @api portRole = 'Public';
    @api progName = 'TRYVIO REMS';
    iconPharmacy = tryvioIconPharmacy;
    iconPrescriber = tryvioIconPrescriber;
    iconPatients = tryvioIconPatients;
    phone = Phone;
    fax = Fax;
    
    guideUrl = '';
    connectedCallback() {
        loadStyle(this, customStyles);
        try{
            getProgramId({programName : this.progName}).then(res =>{
                this.progId = res;
                console.log('this.progId '+this.progId);
                getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName, programId: this.progId, portalRole: this.portRole })
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
                        for(let i=0; i<filesList.length; i++){
                            if(filesList[i].label == 'PRESCRIBER AND PHARMACY GUIDE'){
                                this.guideUrl = filesList[i].previewurl;
                                console.log('guideURL:::', this.guideUrl);
                            }
                        }
                    }
                })
                .catch(error => {
                    console.log(error);
                })
            })
        }
        catch(error){
            console.log('error>>',error);
        }
    }
}