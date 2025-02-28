import { LightningElement,api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPharmacy from '@salesforce/resourceUrl/tryvioIconPharmacy';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import { NavigationMixin } from 'lightning/navigation';
export default class TryvioRemsPharmacy extends NavigationMixin(LightningElement) {
    iconPharmacy = tryvioIconPharmacy;
    @api recordTypeDeveloperName='Pharmacy';
    @api progId;
    @api portRole = 'Public';
    @api progName = 'TRYVIO REMS';
    guideUrl = '';
    riskUrl = '';
    oppFormUrl = '';
    ippFormUrl = '';
   
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
                            if(filesList[i].label == 'PRESCRIBER AND PHARMACY GUIDE'){
                                this.guideUrl = filesList[i].previewurl;
                            }
                            else if(filesList[i].label == 'RISK OF BIRTH DEFECTS WITH TRYVIO'){
                                this.riskUrl = filesList[i].previewurl;
                            }
                            else if(filesList[i].label == 'OUTPATIENT PHARMACY ENROLLMENT FORM'){
                                this.oppFormUrl = filesList[i].previewurl;
                            }
                            else if(filesList[i].label == 'INPATIENT PHARMACY ENROLLMENT FORM'){
                                this.ippFormUrl = filesList[i].previewurl;
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

    navigateToOutPatient(event) {
        try {
            event.preventDefault();
            event.stopPropagation();
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'tryvioRemsOPPEnrollmentForm__c'
                }
            });
        } catch (error) {
            console.log('error --' + error.message);
        }
    }

    navigateToInPatient(event) {
        try {
            event.preventDefault();
            event.stopPropagation();
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'tryvioRemsIPPEnrollmentForm__c'
                }
            });
        } catch (error) {
            console.log('error --' + error.message);
        }
    }
}