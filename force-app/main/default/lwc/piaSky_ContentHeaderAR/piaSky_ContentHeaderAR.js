import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Id from "@salesforce/user/Id";
import PiaSky_HeaderLogo from "@salesforce/resourceUrl/PiaSky_HeaderLogo"
import PiaSky_IconDown from "@salesforce/resourceUrl/PiaSky_IconDown"
import customHomeStyles from '@salesforce/resourceUrl/piasky_customSecure'
import getAffiliationRec from '@salesforce/apex/piasky_ManagePharmacies.getAffiliationRec';
import checkLoggedinUserDetails from '@salesforce/apex/SYN_PiaSkyRDAList.checkLoggedinUserDetails';
import loggedinUserDetails from '@salesforce/apex/SYN_PiaSkyRDAList.loggedinUserDetails';
import loggedOutUser from '@salesforce/apex/SYN_PiaSkyRDAList.loggedOutUser';
import communityPath from "@salesforce/community/basePath";

export default class PiaSky_ContentHeaderAR extends LightningElement {
    piaskylogo = PiaSky_HeaderLogo;
    piaskyIconDown = PiaSky_IconDown;
    @track showManageHCS = false;
    @track showRdaHistory = true;
    userName ; 
    isLogined;
 
    connectedCallback() {
        this.isLogined = false;
        loadStyle(this, customHomeStyles);
        this.loggeduserDetailsJS();
        this.handleAccount();
        this.checkLoggeduserDetailsJS();
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
                console.log('User Logout Detail' ,result );
                window.location =  `https://${hostname}${communityPath}/login-page ` ;
            })
            .catch(error => {
                //this.isLoading = false;
            });

    }

    renderedCallback(){
        const path = window.location.pathname;
        const links = this.template.querySelectorAll('a');
        const remsVerification = 'remsverification'
        const disAuthLinks = ['rems-verification-not-certified','remsverification-success']
        links.forEach(link => {
            // Remove the active-link class from all links
            link.classList.remove('comm-navigation__top-level-item-link--active');
            const isMatch = disAuthLinks.some(val => path.endsWith(val));

            // Add the active-link class if the href matches the current path
            if (path.endsWith(link.getAttribute('href'))) {
                link.classList.add('comm-navigation__top-level-item-link--active');
            }
            if (isMatch && link.getAttribute('href') == remsVerification){
                link.classList.add('comm-navigation__top-level-item-link--active');
            }
            });
    }

    handleAccount(){
        getAffiliationRec({userId: Id})
        .then(element =>{
            if(element.US_WSREMS__User_Role__c != null && element.US_WSREMS__User_Role__c != undefined && ((element.US_WSREMS__User_Role__c).includes('Secondary AR') || (element.US_WSREMS__User_Role__c).includes('Primary AR'))){
                this.showManageHCS = true;
            }
        })
        .catch(error =>{
        })
    }
     checkLoggeduserDetailsJS() {
        checkLoggedinUserDetails()
            .then(result => {
                if (result === true) {
                    this.showRdaHistory = true;
                } else {
                    this.showRdaHistory = false;
                }


            })
            .catch(error => {
                //this.isLoading = false;
            });
    }
    loggeduserDetailsJS() {
        loggedinUserDetails()
            .then(result => {
                console.log('User Detail' ,result );
                this.userName = result.userName;
                this.isLogined = true;
            })
            .catch(error => {
                //this.isLoading = false;
            });
    }


}