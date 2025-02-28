import { LightningElement,api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPatients from '@salesforce/resourceUrl/tryvioIconPatients';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import { NavigationMixin } from 'lightning/navigation';
export default class TryvioRemsPatient extends NavigationMixin(LightningElement){
    iconPatients = tryvioIconPatients;
    @api recordTypeDeveloperName='Patient';
    @api progId;
    @api portRole='Public';
    @api progName ='TRYVIO REMS';
    patientGuideUrl ='';
    patientRiskUrl = '';
    connectedCallback() {
        try{
            loadStyle(this, customStyles);
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
                            if(filesList[i].label == 'PATIENT GUIDE'){
                                this.patientGuideUrl = filesList[i].previewurl;
                            }
                            if(filesList[i].label == 'RISK OF BIRTH DEFECTS WITH TRYVIO'){
                                this.patientRiskUrl = filesList[i].previewurl;
                            }
                        }
                    }
                    console.log('patientGuideUrl'+ this.patientGuideUrl);
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