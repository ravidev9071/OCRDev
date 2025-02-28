import { LightningElement,api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
// import tryvioIconPharmacy from '@salesforce/resourceUrl/tryvioIconPharmacy';
// import tryvioIconPatients from '@salesforce/resourceUrl/tryvioIconPatients';
// import Phone from '@salesforce/label/c.tryvioPhone';
// import Fax from '@salesforce/label/c.tryvioFax';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
export default class TryvioRemsprescriber extends LightningElement {   
    guideUrl = '';
    patientGuideUrl ='';
    presEnrollFormGuideUrl = '';
    presKnowAssesmentGuideUrl = '';
    iconPrescriber = tryvioIconPrescriber;
    @api recordTypeDeveloperName='Prescriber';

    @api progId;
    @api portRole = 'Public';
    @api progName = 'TRYVIO REMS';
   /*  iconPharmacy = tryvioIconPharmacy;
    iconPatients = tryvioIconPatients;
    phone = Phone;
    fax = Fax; */
    connectedCallback() {
        try{
            loadStyle(this, customStyles);
            getProgramId({programName : this.progName}).then(res =>{
                this.progId = res;
                console.log('this.progId '+this.progId);
                console.log('this.portRole '+this.portRole);
                console.log('this.progName '+this.progName);
                console.log('this.recordTypeDeveloperName '+this.recordTypeDeveloperName);

                getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName, programId: this.progId, portalRole: this.portRole })
                .then(result => {
                    console.log(JSON.stringify(result));
                    console.log('result',JSON.stringify(result));
                    const relatedFileResponse = result;
                    if (relatedFileResponse) {
                        let filesList = Object.keys(relatedFileResponse).map(item => ({
                            "label": relatedFileResponse[item].Name,
                            "value": item,
                            "url": relatedFileResponse[item].ContentDownloadUrl,
                            "previewurl":relatedFileResponse[item].DistributionPublicUrl,                            
                        }));
                        for(let i=0; i<filesList.length; i++){

                            console.log('### filesList[i].label '+filesList[i].label);

                            if(filesList[i].label == 'PRESCRIBER AND PHARMACY GUIDE'){
                                this.guideUrl = filesList[i].previewurl;
                                console.log('guideurl',this.guideUrl);
                            }
                            
                            else if(filesList[i].label == 'PATIENT GUIDE'){
                                this.patientGuideUrl = filesList[i].previewurl;
                            }

                            else if(filesList[i].label == 'PRESCRIBER ENROLLMENT FORM'){
                                this.presEnrollFormGuideUrl = filesList[i].previewurl;
                            }

                            else if(filesList[i].label == 'PRESCRIBER KNOWLEDGE ASSESSMENT'){
                                this.presKnowAssesmentGuideUrl = filesList[i].previewurl;
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