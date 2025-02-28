import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customcss';
import xiaflex_Logo from "@salesforce/resourceUrl/xiaflex_HeaderLogo";
import xiaflex_iconCaretDown from "@salesforce/resourceUrl/xiaflex_iconCaretDown"; 
import loggedinUserDetails from '@salesforce/apex/SYN_PiaSkyRDAList.loggedinUserDetails';
import loggedOutUser from '@salesforce/apex/SYN_PiaSkyRDAList.loggedOutUser';
import communityPath from "@salesforce/community/basePath";
export default class Xiaflex_contentHeaderPreCert extends LightningElement {
    xiaflexlogo = xiaflex_Logo;
    xiaflexIconCaretDown = xiaflex_iconCaretDown;
        userName ; 
    isLogined = false;
    connectedCallback() {
        this.loggeduserDetailsJS();
        loadStyle(this, customHomeStyles);
    }
    loggeduserDetailsJS() {
        loggedinUserDetails()
            .then(result => {
                this.userName = result.userName;
                this.isLogined = true;
            })
            .catch(error => {
                console.log(error);
            });
    }
    handleOnselect(event) {
        if(event.detail.value=='logout') {
            this.logout();
        }
    }

     logout() {
        let hostname = location.hostname;

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
}