import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/piasky_customSecure'
import PiaSky_IconCheck from "@salesforce/resourceUrl/PiaSky_IconCheck"
import getCaseRDA from '@salesforce/apex/SYN_PiaSkyRDAList.createCaseandService';
import { NavigationMixin } from 'lightning/navigation';
import checkLoggedinUserDetails from '@salesforce/apex/SYN_PiaSkyRDAList.checkLoggedinUserDetails';

export default class Piasky_remsVerification_success extends NavigationMixin(LightningElement) {

    PiaSkyIconCheck = PiaSky_IconCheck;
    @track prescriber;
    @track error;
    @track showBtn = true;
    @track showMsg = false;
    @track msg = '';
    @track isLoading = false;

    connectedCallback() {
        loadStyle(this, customHomeStyles);
        const prescriberData = sessionStorage.getItem('prescriberAcc') || sessionStorage.getItem('selectedPrescriber');
        this.checkLoggeduserDetailsJS();
        if (prescriberData) {
            this.prescriber = JSON.parse(prescriberData);
        } else {
            this.error = 'No Prescriber Data Found';
        }

    }
    handlechange() {
        this.isLoading = true;
        getCaseRDA({ prescriberId: this.prescriber.Id, PrescriberFName: this.prescriber.FirstName, PrescriberLName: this.prescriber.LastName, prescriberNPI: this.prescriber.US_WSREMS__National_Provider_Identifier__c, remsId: this.prescriber.US_WSREMS__REMS_ID__c })
            .then(result => {
                this.showBtn = false;
                this.showMsg = true;
                this.msg = result.replace(/\n/g, '<br>');
                this.isLoading = false;

            })
            .catch(error => {
                this.isLoading = false;
                // Handle any errors
                console.error(error);
            });
    }
    handleCancel() {
        window.history.back();
    }


    checkLoggeduserDetailsJS() {
        checkLoggedinUserDetails()
            .then(result => {
                if (result === true) {
                    this.showBtn = true;
                } else {
                    this.showBtn = false;
                }


            })
            .catch(error => {
                this.isLoading = false;
            });
    }


}