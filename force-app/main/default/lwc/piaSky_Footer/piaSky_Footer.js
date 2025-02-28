import { LightningElement, api} from 'lwc';
import Redirect_URLs from '@salesforce/label/c.Redirect_URLs';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/piaSky_homecustomcss';


export default class FilesDownloadComponent extends LightningElement{
   redirectData = [];
   filteredRedirectData = [];
   @api recordTypeDeveloperName;
   @api portalRole;


   connectedCallback(){

    loadStyle(this, customHomeStyles);

    const urlPairs = Redirect_URLs.split(';');
    urlPairs.forEach(pair =>{
        const[name, link] =pair.split('|');
        this.redirectData.push({ name: name.trim(), link: link.trim() });
    });

    this.filteredRedirectData = this.redirectData.slice(3,5);

   }

   handleRedirect(event){
    const name = event.currentTarget.dataset.id;
    const redirect = this.redirectData.find(item => item.name === name);
    if(redirect){
        window.open(redirect.link, '_blank');
    }
   }

   handlechange(){
          const relatedFileResponse =  getRelatedFilesByProgramName({recordTypeDevName: this.recordTypeDeveloperName,programName:'PiaSky REMS',portalRole:this.portalRole });
   }

}