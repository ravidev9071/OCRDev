import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_resources';
import Redirect_URLs from '@salesforce/label/c.Aveed_Redirect_URLs';
export default class Aveed_UtilityMenu extends LightningElement {
    redirectData = [];
    filteredRedirectData = [];
    connectedCallback() {
    loadStyle(this, customHomeStyles); 
    const urlPairs = Redirect_URLs.split(';');
    urlPairs.forEach(pair =>{
    const[name, link] =pair.split('|');
    this.redirectData.push({ name: name.trim(), link: link.trim() });
    });

    this.filteredRedirectData = this.redirectData.slice(0,2);
       
    }
    handleRedirect(event){
        const name = event.currentTarget.dataset.id;
        const redirect = this.redirectData.find(item => item.name === name);
        if(redirect){
            window.open(redirect.link, '_blank');
        }
       }
}