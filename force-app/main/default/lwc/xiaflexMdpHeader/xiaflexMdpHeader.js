import { LightningElement,api,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflexMDP_customcss';
import navStyles from '@salesforce/resourceUrl/xiaflexMDP_navcss';
import xiaflex_Logo from "@salesforce/resourceUrl/xiaflexMDP_HeaderLogo";
export default class XiaflexMdpHeader extends LightningElement {
    xiaflexlogo = xiaflex_Logo;
    currentUrl;
    homeUrl;

    connectedCallback() {
        window.addEventListener('scroll', this.handleScrollBar.bind(this));
        loadStyle(this, customHomeStyles); 
        loadStyle(this,navStyles);
        this.currentUrl = window.location.href;
        this.homeUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s';
    }

    handleScrollBar(){
        const link= this.template.querySelector('.header');
    const scrollTop=window.scrollY || document.documentElement.scrollTop;
    if(scrollTop > 150){
    if(link && !link.classList.contains('positionFixed')){
        link.classList.add('positionFixed');
        }
    }
    else{
   
        if(link && link.classList.contains('positionFixed')){
            link.classList.remove('positionFixed');
      
        }
    }
    
    }
    
 
    isiSection(){
        window.scrollTo(0, document.body.scrollHeight);
    }

}