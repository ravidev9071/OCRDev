import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import customHomeStyles from '@salesforce/resourceUrl/piaSky_homecustomcss'

export default class Piasky_site_header extends LightningElement {
    currentUrl
    contactusUrl;

    connectedCallback() {
        loadStyle(this, customHomeStyles); 
        
    }
    renderedCallback() {
        this.highlightCurrentPage();
    }

    highlightCurrentPage() {
        const path = window.location.pathname;
        const links = this.template.querySelectorAll('a');

        links.forEach(link => {
            // Remove the active-link class from all links
            link.classList.remove('active-link');
            // Add the active-link class if the href matches the current path
            if (path.endsWith(link.getAttribute('href'))) {
                link.classList.add('active-link');
            }
            if (path.endsWith('/s/') && link.getAttribute('href') == null) {
                link.classList.add('active-link');
            }
        });
    }

    redirectHome(event){
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.open(value, '_self');
    }
    handlePageopen(event){
         this.currentUrl = window.location.href;
        this.contactusUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s/login-page';
        window.open(this.contactusUrl,'_self');
    }
}