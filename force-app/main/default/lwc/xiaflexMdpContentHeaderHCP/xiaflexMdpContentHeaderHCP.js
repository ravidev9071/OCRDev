import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflexMDP_customcss';
import customNavStyles from '@salesforce/resourceUrl/xiaflexMDP_navcss';
import xiaflex_Logo from "@salesforce/resourceUrl/xiaflexMDP_HeaderLogo";
import xiaflexIconCaretDown from "@salesforce/resourceUrl/xiaflexMDP_IconCaretDown";
import loggedinUserDetails from '@salesforce/apex/SYN_PiaSkyRDAList.loggedinUserDetails';
import loggedOutUser from '@salesforce/apex/SYN_PiaSkyRDAList.loggedOutUser';
import communityPath from "@salesforce/community/basePath";

export default class XiaflexMdpContentHeaderHCP extends LightningElement {
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
                console.log('User Detail' ,result );
                this.userName = result.userName;
                this.isLogined = true;
                console.log('username',this.userName);
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

    logout() {
        let hostname = location.hostname;
    console.log('Hostname:', hostname);
    console.log('Community Path:', communityPath);

    loggedOutUser()
        .then(result => {
                window.location =  `https://${hostname}${communityPath}/login-Signup ` ;
        })
        .catch(error => {
                //this.isLoading = false;
            });

    }

    handleClickLogout(){
        this.isLogined = true;
    }
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
    isiSection(){
        window.scrollTo(0, document.body.scrollHeight);
    }

}