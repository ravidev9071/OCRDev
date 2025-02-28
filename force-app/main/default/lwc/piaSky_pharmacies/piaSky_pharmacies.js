import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/piaSky_homecustomcss'
import getRelatedFilesByProgramName from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByProgramName';

export default class PiaSky_pharmacies extends LightningElement {

    filesList = [];
    filesMap = new Map();
    hlthcrPrviderSftyBrchr;
    phrmcyEnrlmntFrm;

    async connectedCallback() {
        loadStyle(this, customHomeStyles); 

        const relatedFileResponse = await getRelatedFilesByProgramName({recordTypeDevName: 'Patient',programName:'PiaSky REMS',portalRole:'Public' });
        if (relatedFileResponse) {
            this.filesList = Object.keys(relatedFileResponse).map(item => ({
            
                "label": relatedFileResponse[item].Name,
                "value": item,
                "url": relatedFileResponse[item].ContentDownloadUrl,
                "previewurl":relatedFileResponse[item].DistributionPublicUrl
                
            }));
            this.filesList.forEach((element)=>{
                this.filesMap.set(element.label,element);    
            });
            this.hlthcrPrviderSftyBrchr = this.filesMap.get('Healthcare Provider Safety Brochure')?.url;
            this.phrmcyEnrlmntFrm = this.filesMap.get('PIASKY Pharmacy Enrollment Form')?.url;
        }
        
    }

}