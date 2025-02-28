import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_resources';
import aveed_adobeReader from "@salesforce/resourceUrl/aveed_adobeReader";
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import Redirect_URLs from '@salesforce/label/c.Redirect_URLs';
import { NavigationMixin } from 'lightning/navigation';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import aveed_check from "@salesforce/resourceUrl/aveed_Iconcheck";
import validateAssessment from "@salesforce/apex/KAController.validateAssessment";
import communityPath from '@salesforce/community/basePath';
import customHomeStyles_secure from '@salesforce/resourceUrl/aveed_customcssSecure';
import updatePortalStageForAccount from "@salesforce/apex/Aveed_HCPEnrollmentCtrl.updatePortalStageForAccount";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import USER_ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import USER_ACCOUNT_PORTAL_STAGE from '@salesforce/schema/User.Account.US_WSREMS__PortalStage__c';

import USER_ID from '@salesforce/user/Id';

const PATH_MAP = new Map([[0, ".educationProgram"], [1, ".knowledgeProgram"], [2, ".completeProgram"]]);

export default class Aveed_EducationProgramScreen1 extends NavigationMixin(LightningElement) {
    iconCheck = aveed_check;
    @api recordId;
    @api recordTypeDeveloperName;
    @api requestortype;
    @api programId;
    @api portalRole;
    @api progId;
    @track isDisplayFiles = false;
    filesList = [];
    filename = "AVEED REMS Education Program for Healthcare Providers";
    filename_educationprogram;
    @api fileURL;
    showNext = false;
    showConfirmationmsg = false;
    showKAQuestions = false;
    showEducation = true;
    redirectUrls = [];
    iconAdobeReader = aveed_adobeReader;
    currentPath = 0;
    completedPath = 0;
    userAccountPortalStage;
    displaySpinner = false;

    userId = USER_ID;

    @wire(getRecord, { recordId: "$userId", fields: [USER_ACCOUNT_ID, USER_CONTACT_ID] })
    user;

    get userAccountId() {
        return getFieldValue(this.user.data, USER_ACCOUNT_ID);
    }

    get userContactId() {
        return getFieldValue(this.user.data, USER_CONTACT_ID);
    }

    @wire(getRecord, { recordId: "$userId", fields: [USER_ACCOUNT_PORTAL_STAGE] })
    userDetails({ error, data }) {
        if (error) {
            console.log(error);
        } else if (data) {
            if (data.fields.Account.value != null && data.fields.Account.value.fields != null) {
                this.userAccountPortalStage = data.fields.Account.value.fields.US_WSREMS__PortalStage__c.value;
            }
        }
    }

    async connectedCallback() {
        try {
            this.displaySpinner = true;
            loadStyle(this, customHomeStyles);
            loadStyle(this, customHomeStyles_secure);
            getProgramId({ programName: this.programId }).then(res => {
                this.progId = res;
                getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName, programId: this.progId, portalRole: this.portalRole })
                    .then(result => {
                        const relatedFileResponse = result;
                        const urls = Redirect_URLs.split(';');
                        if (relatedFileResponse) {
                            this.filesList = Object.keys(relatedFileResponse).map(item => ({
                                "label": relatedFileResponse[item].Name,
                                "value": item,
                                "url": relatedFileResponse[item].ContentDownloadUrl,
                                "previewurl": relatedFileResponse[item].DistributionPublicUrl,
                            }));
                            this.isDisplayFiles = true;
                        }
                        this.redirectUrls = urls.map(url => ({ label: url.split('|')[0], url: url.split('|')[1] }));
                        for (var i = 0; i < this.filesList.length; i++) {
                            if (this.filesList[i].label === this.filename) {
                                this.filename_educationprogram = this.filename;
                                this.fileURL = this.filesList[i].previewurl;
                            }
                        }
                        this.displaySpinner = false;
                    }).catch(error => {
                        console.log(error);
                        this.displaySpinner = false;
                    })
            }).catch(error => {
                console.log(error);
                this.displaySpinner = false;
            })

        } catch (error) {
            console.log('error>>', error);
            this.isDisplayFiles = false;
            this.displaySpinner = false;
        }
    }

    renderedCallback() {
        setTimeout(() => {
            for (let i = 0; i < this.completedPath; i++) {
                let element = this.template.querySelector(PATH_MAP.get(i));
                this.completePathHandler(element);
            }
        }, 100);

        this.handleProgressPath();
    }

    handleProgressPath() {
        for (let key in PATH_MAP) {
            if (PATH_MAP[key] === this.userAccountPortalStage) {
                this.currentPath = key;
                this.completedPath = key;
                break;
            }
        }
        let element = this.template.querySelector(PATH_MAP.get(this.currentPath));
        this.completePathHandler(element);
        if (this.userAccountPortalStage === '.knowledgeProgram') {
            this.displaySpinner = true;
            this.startKA(new CustomEvent());
        } else if (this.userAccountPortalStage === '.completeProgram') {
            this.displaySpinner = true;
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'hcp_enrollmnet__c'
                }
            });
        }else if(this.userAccountPortalStage ==='.completedEnrollment'){
            this.displaySpinner = true;
            this[NavigationMixin.GenerateUrl]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'managehcp__c'
                }
            }).then(generatedUrl => {
                window.open(generatedUrl, '_self');
            });
        }
    }

    previewHandler(event) {
        this.showNext = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.fileURL
            }
        }, false
        )
    }

    showConfirmation(event) {
        this.currentPath++;
        this.completedPath++;
        this.showConfirmationmsg = true;
        this.showEducation = false;
    }

    completePathHandler(element) {
        element.classList.remove('slds-is-current');
        element.classList.add('slds-is-complete');
        element.classList.remove('slds-is-incomplete');
    }

    currentPathHandler(element) {
        element.classList.add('slds-is-current');
        element.classList.remove('slds-is-complete');
        element.classList.add('slds-is-incomplete');
    }

    async startKA(event) {
        this.displaySpinner = true;
        try {
            let element = this.template.querySelector(PATH_MAP.get(this.currentPath));
            this.currentPathHandler(element);
            let hostname = location.hostname;
            let portalStage = PATH_MAP.get(this.currentPath);
            const Records = await validateAssessment({ 'remsProgram': this.programId, 'participantType': this.requestortype.trim() });

            if (Records.caseRecord) {
                const statusResult = await updatePortalStageForAccount({ 'accountId': this.userAccountId, 'portalStage': '.knowledgeProgram' });
                this.recordId = Records.caseRecord.Id;
                this.showConfirmationmsg = false;
                event.preventDefault();
                event.stopPropagation();
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'KAQuestions__c'
                    }, state: {
                        c_recordId: this.recordId,
                        c_programName: this.programId,
                        c_requestorType: this.requestortype,
                        c_fileURL: this.fileURL
                    }
                });

            } else {
                this.displaySpinner = false;
                
            }
        } catch (error) {
            this.displaySpinner = false;
            console.log('error --' + error.message);
        }
    }
}