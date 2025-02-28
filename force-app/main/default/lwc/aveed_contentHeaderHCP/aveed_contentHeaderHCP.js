import { LightningElement, wire,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import aveed_logo from "@salesforce/resourceUrl/aveed_logo";
import aveed_iconcreateDown from "@salesforce/resourceUrl/aveed_iconcreateDown";
import navStyles from '@salesforce/resourceUrl/aveed_navcss';
import { CurrentPageReference } from 'lightning/navigation';
import loggedinUserDetails from '@salesforce/apex/Aveed_MyProfileController.loggedinUserDetails';
import loggedOutUser from '@salesforce/apex/Aveed_MyProfileController.loggedOutUser';
import communityPath from "@salesforce/community/basePath";
 // RT 21-10-24 851-changes
import { subscribe,MessageContext } from 'lightning/messageService'; 
import aveedMessageChannel from '@salesforce/messageChannel/AveedProfileUpdateChannel__c';
 


export default class Aveed_contentHeaderHCP extends LightningElement {
    logo = aveed_logo;
    downarrow = aveed_iconcreateDown;
    currentPageName;
    userName ; 
    isLogined;
    currentUrl;
    homeUrl;
    @track selectedValue = '';
    options = [
        { label: 'Logout', value: 'logout' },
       
    ];
    @wire(MessageContext)
    messageContext;
    subscription = null;
 

    @wire(CurrentPageReference)
    getCurrentPageRef(pageRef) {
        if (pageRef) {
            // Get the current URL
            console.log(pageRef.attributes);
            this.currentPageName = pageRef.attributes.name;
        }
    }
    connectedCallback() {
        loadStyle(this, customHomeStyles);
        loadStyle(this, navStyles);
        this.loggeduserDetailsJS();
        this.currentUrl = window.location.href;
        this.homeUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s';     
         // RT 21-10-24 851-changes
         this.subscription = subscribe(this.messageContext, aveedMessageChannel, (message) => this.updateProfile(message));
    }

    // RT 21-10-24 851-changes
    updateProfile(message) {
        if(message?.MessageContext == 'Profile Updated'){
            this.loggeduserDetailsJS();
        }
    }

    get manage_hcs_CSS() {
        if (this.currentPageName === 'managehcp__c')
            return this.currentPageName === 'managehcp__c' ? 'highlightpanel' : 'aveedcss';
        else if (this.currentPageName === 'Home') {
            return this.currentPageName === 'Home' ? 'highlightpanel' : 'aveedcss';
        }
    }

    get formsandResourcesCSS() {
        return this.currentPageName === 'HCP_resources__c' ? 'highlightpanel ' : 'aveedcss';
    }
    get myprofileCSS() {
        return this.currentPageName === 'myprofile__c' ? 'highlightpanel' : 'aveedcss';
    }
    handleChange(event) {
        this.selectedValue = event.detail.value;
        if(event.detail.value=='logout') {
            this.logout();
        }
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
                window.location =  `https://${hostname}${communityPath}/login-signup ` ;
            })
            .catch(error => {
                
            });

    }

    loggeduserDetailsJS() {
        loggedinUserDetails()
            .then(result => {
                this.userName = result.userName;
                this.isLogined = true;
            })
            .catch(error => {
                
            });
    }
    

}