import { LightningElement,api } from 'lwc';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class Xiaflex_Footer extends NavigationMixin(LightningElement) {
@api recordId;
@api recordTypeDeveloperName;
@api versionId;
@api programId;
@api portalRole;

isiStyle;
paddingTop150;
isShortVersion=true;
isDisplayFiles = false;
filesList = [];
get isDesktop() {
    return FORM_FACTOR === 'Large';
}
async connectedCallback() {
    window.addEventListener('scroll', this.handleScroll.bind(this));
this.isiStyle='max-height:130px;';
    try {
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

handleScroll(){
    if(this.isDesktop){
    const link= this.template.querySelector('.isi');
const scrollTop=window.scrollY || document.documentElement.scrollTop;
if(scrollTop > 250){
    this.isShortVersion=false;
if(link && !link.classList.contains('expanded')){
this.isiStyle='position:relative;';
    }
    if(this.paddingTop150){
        this.paddingTop150='';
    }
}
else{
    
    if(!this.paddingTop150)
    this.paddingTop150='margin-top:100px;';
// if(link && link.classList.contains('intersect')){
    //  link.classList.remove('intersect');
    if(link && link.classList.contains('expanded')){
    this.isiStyle='';
    this.isShortVersion=false;
    }
    else{
    this.isiStyle='max-height:130px;';
    this.isShortVersion=true;
    }
    }
}

}


    expandISI() {
    const link= this.template.querySelector('.isi');
    if(this.isDesktop){
    const scrollTop=window.scrollY || document.documentElement.scrollTop;
    
    if(link && link.classList.contains('expanded')){
    link.classList.remove('expanded');
    if(scrollTop > 250){
        this.isShortVersion=false;
    this.isiStyle='position:relative;';
    }
    else{
        this.isShortVersion=true;
        this.isiStyle='position:fixed;max-height:130px;';   
    }
    }
    else if(link){
    
    if(scrollTop > 250){
        this.isShortVersion=true;
        this.isiStyle='position:fixed;max-height:130px;bottom:0px;';   
        window.scrollTo(0,0);
    }
    else{
        this.isShortVersion=false;
        link.classList.add('expanded');
    this.isiStyle='';
    }

    }
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