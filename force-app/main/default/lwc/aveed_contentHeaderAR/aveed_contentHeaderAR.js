import { LightningElement, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import aveed_logo from "@salesforce/resourceUrl/aveed_logo";
import aveed_iconcreateDown from "@salesforce/resourceUrl/aveed_iconcreateDown";
import navStyles from '@salesforce/resourceUrl/aveed_navcss';
import { CurrentPageReference } from 'lightning/navigation';
import getCurrentUserAccount from '@salesforce/apex/Aveed_HCPEnrollmentCtrl.getCurrentUserAccount';
import isCertifiedAR from '@salesforce/apex/Aveed_ManageHCSProviderCtrl.isCertifiedAR';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import loggedinUserDetails from '@salesforce/apex/Aveed_MyProfileController.loggedinUserDetails';
import loggedOutUser from '@salesforce/apex/Aveed_MyProfileController.loggedOutUser';
import communityPath from "@salesforce/community/basePath";
import { NavigationMixin } from 'lightning/navigation';
 // RT 21-10-24 851-changes
import { subscribe,MessageContext } from 'lightning/messageService';
import aveedMessageChannel from '@salesforce/messageChannel/AveedProfileUpdateChannel__c';

export default class Aveed_contentHeaderHCP extends NavigationMixin(LightningElement) {
    logo = aveed_logo;
    downarrow = aveed_iconcreateDown;
    currentPageName;
    showContentHeaders = false;
    @track userName;
    isLogined;
    currentUrl;
    homeUrl;
    @track selectedValue = '';
    options = [
        { label: 'Logout', value: 'logout' },

    ];
    // RT 21-10-24 851-changes
    @wire(MessageContext)
    messageContext;
    subscription = null;

    get manage_hcs_CSS() {
        if (this.currentPageName === 'managehcp__c')
            return this.currentPageName === 'managehcp__c' ? 'highlightpanel' : 'aveedcss';
        else if (this.currentPageName === 'Home') {
            return this.currentPageName === 'Home' ? 'highlightpanel' : 'aveedcss';
        }
    }

    get manage_hcp_CSS() {
        return this.currentPageName === 'AR_Manage_HCP__c' ? 'highlightpanel ' : 'aveedcss';
    }

    get formsandResourcesCSS() {
        return this.currentPageName === 'HCP_resources__c' ? 'highlightpanel ' : 'aveedcss';
    }

    get myprofileCSS() {
        return this.currentPageName === 'myprofile__c' ? 'highlightpanel' : 'aveedcss';
    }

    @wire(CurrentPageReference)
    getCurrentPageRef(pageRef) {
        if (pageRef) {
            // Get the current URL
           
            this.currentPageName = pageRef.attributes.name;
            
        }
    }

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        loadStyle(this, navStyles);
        this.checkIfARCertified();
        this.loggeduserDetailsJS();
        this.currentUrl = window.location.href;
        this.homeUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s';
        this.showContentHeaders = this.currentPageName == 'HCP_resources__c' ? true : this.showContentHeaders;
        // RT 21-10-24 851-changes
        this.subscription = subscribe(this.messageContext, aveedMessageChannel, (message) => this.updateProfile(message));
    }

    // RT 21-10-24 851-changes
    updateProfile(message) {
        if(message?.MessageContext == 'Profile Updated'){
            this.loggeduserDetailsJS();
        }
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;
        if (event.detail.value == 'logout') {
            this.logout();
        }
    }

    handleOnselect(event) {
        if (event.detail.value == 'logout') {
            this.logout();
        }
    }

    logout() {
        let hostname = location.hostname;
        loggedOutUser()
            .then(result => {
               
                window.location = `https://${hostname}${communityPath}/login-signup `;
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


    async checkIfARCertified() {
        try {
            const result = await isCertifiedAR({});
            if (result && result === true) {
                if (this.currentPageName === 'Home') {
                    this[NavigationMixin.GenerateUrl]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'managehcp__c'
                        }
                    }).then(generatedUrl => {
                        window.open(generatedUrl, '_self');
                    });
                }
                this.showContentHeaders = true;
            } else {
                //this.showContentHeaders = false;
            }
        } catch (error) {
            console.log(error);
        }
    }

    showError(error) {
        let errorMsg = error;
        if (error.body != null && error.body.message != null) {
            errorMsg = error.body.message;
        }
        this.showSpinner = false;
        console.error(error);
        this.showToast('Error', JSON.stringify(errorMsg), 'error');
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}