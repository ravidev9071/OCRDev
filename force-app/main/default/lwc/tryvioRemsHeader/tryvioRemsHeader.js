import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioRemsCustomNavCss from '@salesforce/resourceUrl/tryvioRemsCustomNavCss';
import tryvioIconLogo from '@salesforce/resourceUrl/tryvioIconLogo';
import { NavigationMixin } from 'lightning/navigation';
export default class TryvioRemsHeader extends NavigationMixin(LightningElement){  
    logo = tryvioIconLogo;
    connectedCallback() {
        loadStyle(this, customStyles);
        loadStyle(this, tryvioRemsCustomNavCss);
    }
    redirectHome(event){
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.location.href = value;
    }

    renderedCallback() {
        this.highlightCurrentPage();
    }

    highlightCurrentPage() {
        let pageName = this.getPageName();
        console.log('pagenameeeeee', pageName);
        const links = this.template.querySelectorAll('a');
        links.forEach(link => {
            console.log('pageName',pageName);
            console.log('linkkkk',link.getAttribute('href'));
            // Remove the active-link class from all links
            link.classList.remove('active-link');
            console.log('Am after');
            // Add the active-link class if the href matches the current path
            if (pageName == link.getAttribute('href')) {
                link.classList.add('active-link');
            }
            if (pageName === '' && link.getAttribute('href') == null) {
                link.classList.add('active-link');
            }
        });
    }

    getPageName() {
        const path = window.location.pathname;
        let pageNameList = path.split('/s/');
        let pageName = path.split('/s/')[1];
        pageName = pageName === 'tryvioremsippenrollmentform' ? 'tryvioremspharmacy' : pageName;
        pageName = pageName === 'tryvioremsippenrollmentformsuccess' ? 'tryvioremspharmacy' : pageName;
        pageName = pageName === 'tryvioremsoppenrollmentform' ? 'tryvioremspharmacy' : pageName;
        pageName = pageName === 'tryvioremsoppenrollmentformsuccess' ? 'tryvioremspharmacy' : pageName;
        pageName = pageName === 'tryvioremsregister' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'prescriber-enrollment-form' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'prescriber-enrollment-form-success' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'tryvioremskafail' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'tryvioremskaquestions' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'tryvioremskaquestionsmarked' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'tryvioremskaquestionsmarked2' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'tryvioremskaquestionsretaken' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'tryvioremskasuccessform' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'tryvioremsreviewmaterialhcp' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'tryvioremsreviewmaterialhcpconfirmation' ? 'tryvioremsprescriber' : pageName;
        pageName = pageName === 'tryvioremslocator' ? 'lookup' : pageName;
        pageName = pageName === 'rems-verification-success' ? 'tryvioremsverfication' : pageName;
        console.log('pageName::', pageName);
        return pageName;
    }

    handleHamburgerMenu(event) {
        console.log('inside hamger');
        console.log('--->',this.template.querySelector('[data-id="navBar"]').classList);
        if(this.template.querySelector('[data-id="navBar"]').classList && this.template.querySelector('[data-id="navBar"]').classList.value) {
            if(this.template.querySelector('[data-id="navBar"]').classList.value.includes("responsive")) {
                console.log('yes');
                this.template.querySelector('[data-id="navBar"]').classList.remove("responsive");
            } else {
                console.log('no');
                this.template.querySelector('[data-id="navBar"]').classList.add("responsive");
            }
        }
    }
}