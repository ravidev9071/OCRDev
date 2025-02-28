import { LightningElement,api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import xiaflex_IconCheck from "@salesforce/resourceUrl/xiaflex_IconCheck";
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import { NavigationMixin } from 'lightning/navigation';

export default class Xiaflex_reviewMaterials extends NavigationMixin(LightningElement) {
    iconCheck = xiaflex_IconCheck;
    guideUrl = '';
    @api recordTypeDeveloperName='Prescriber';
    @api portRole='Public';
    progId='';
    @api progName ='XIAFLEX';
    npi = '5645634567';
    fileView;
    videoView;
    buttondisable = true;
    showfilelogo = false;
    showvideoLogo = false;
    connectedCallback() {
        try {
            loadStyle(this, customHomeStyles); 
            getProgramId({programName : this.progName}).then(res =>{
                this.progId = res;
                 getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName, programId: this.progId, portalRole: this.portRole })
                .then(result => {
                    const relatedFileResponse = result;
                if (relatedFileResponse) {
                    let filesList = Object.keys(relatedFileResponse).map(item => ({
                        "label": relatedFileResponse[item].Name,
                        "value": item,
                        "url": relatedFileResponse[item].ContentDownloadUrl,
                        "previewurl":relatedFileResponse[item].DistributionPublicUrl,
                        "form": relatedFileResponse[item].Name.includes(' Form ')? true: false,
                        
                    }));
                    for(let i=0;i<filesList.length;i++){
                        if(filesList[i].label.includes('Training Guide')){
                            this.guideUrl = filesList[i].previewurl;
                        }
                        else if(filesList[i].label.includes('Training Video')){
                            this.videoUrl = filesList[i].previewurl;;
                        }
                    }   
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
    handleNext(){
        this.buttondisable = false;
        this.showfilelogo = true;
    }
    handleNextVideo(){
        this.buttondisable = false;
        this.showvideoLogo = true;
    }

    navigateToEnrollment(event){
        try{
            event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes:{
                name: 'Prescriber_Enrollment_Form__c'
            },
            state:{
                'npi': this.npi,
            },
        });
    }
    catch(error){
        console.log('error --'+error.message);
    }
    }
}