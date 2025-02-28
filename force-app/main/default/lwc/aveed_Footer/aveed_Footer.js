import { LightningElement,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import Phone from '@salesforce/label/c.AVEED_PhoneNumber';
import Redirect_URLs from '@salesforce/label/c.Aveed_Redirect_URLs';
import getFilesPublicLink from '@salesforce/apex/Aveed_HCSEducationProgramCtrl.getFilesPublicLink';
import { NavigationMixin } from 'lightning/navigation';

export default class Aveed_Footer extends NavigationMixin(LightningElement) {
    redirectData = [];
    filteredRedirectData = [];
    fileName = "Terms of use";
    @track fileURL;
  
    label = {
        Phone
    };
   async connectedCallback() {
        loadStyle(this, customHomeStyles); 
        const urlPairs = Redirect_URLs.split(';');
    urlPairs.forEach(pair =>{
    const[name, link] =pair.split('|');
    this.redirectData.push({ name: name.trim(), link: link.trim() });
    });

    this.filteredRedirectData = this.redirectData.slice(2);
    const result = await getFilesPublicLink({ 'fileTitle': this.fileName ,'portalRole':'Public' ,'record_type':'Patient'});
    if (result) {
        for (let file in result) {
            this.fileURL = result[file].DistributionPublicUrl;
        }
    }
   
} 

    handleRedirect(event){
        const name = event.currentTarget.dataset.id;
        const redirect = this.redirectData.find(item => item.name === name);
        if(redirect){
            window.open(redirect.link, '_blank');
        }
       }
       previewHandler(event) {
       
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.fileURL
            }
        }, false);
    }
}