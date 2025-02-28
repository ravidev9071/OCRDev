import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflexMDP_customcss';
import customNavStyles from '@salesforce/resourceUrl/xiaflexMDP_navcss';
import xiaflex_Logo from "@salesforce/resourceUrl/xiaflexMDP_HeaderLogo";
import xiaflexIconCaretDown from "@salesforce/resourceUrl/xiaflexMDP_IconCaretDown";
import loggedinUserDetails from '@salesforce/apex/SYN_PiaSkyRDAList.loggedinUserDetails';
import loggedOutUser from '@salesforce/apex/SYN_PiaSkyRDAList.loggedOutUser';
import communityPath from "@salesforce/community/basePath";

export default class XiaflexMdpContentHeaderAR extends LightningElement {
    xiaflexlogo = xiaflex_Logo;
    currentUrl;
    homeUrl;
    iconCaretDown = xiaflexIconCaretDown;
    isLogined = true;
    userName;

    connectedCallback(){
        loadStyle(this, customHomeStyles); 
        loadStyle(this, customNavStyles);
        this.currentUrl = window.location.href;
        this.homeUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s';
        this.loggeduserDetailsJS();
    }

    loggeduserDetailsJS() {
        loggedinUserDetails()
            .then(result => {
                this.userName = result.userName;
                this.isLogined = true;
            })
            .catch(error => {
                //this.isLoading = false;
            });
    }
    handleOnselect(event) {
        if(event.detail.value=='logout') {
            this.logout();
        }
    }
    // menu selected item only active...Pratap M
    renderedCallback(){
        const path = window.location.pathname;
        const links = this.template.querySelectorAll('a');
        console.log(links);
        links.forEach(link => {
            // Remove the active-link class from all links
            link.classList.remove('comm-navigation__top-level-item-link--active');

            // Add the active-link class if the href matches the current path
            if (path.endsWith(link.getAttribute('href'))) {
                link.classList.add('comm-navigation__top-level-item-link--active');
            }
            });
    }

    logout() {
        let hostname = location.hostname;

    loggedOutUser()
        .then(result => {
            console.log('User Logout Detail:', result);
            let redirectUrl = `https://${hostname}${communityPath}`;
            console.log('Redirecting to:', redirectUrl);
            window.location.href = redirectUrl;
        })
        .catch(error => {
            console.error('Logout error:', error);
        });

    }
    isiSection(){
        window.scrollTo(0, document.body.scrollHeight);
    }

}