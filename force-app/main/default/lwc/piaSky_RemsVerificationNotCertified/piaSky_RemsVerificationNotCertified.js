import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/piasky_customSecure'
import PiaSky_IconFail from "@salesforce/resourceUrl/PiaSky_IconFail"


export default class PiaSky_RemsVerificationNotCertified extends LightningElement {
    PiaSkyIconFail = PiaSky_IconFail;
  @track prescriber;
  @track error;

    connectedCallback() {
	     loadStyle(this, customHomeStyles);
         const prescriberData = sessionStorage.getItem('prescriberAcc') || sessionStorage.getItem('selectedPrescriber') || sessionStorage.getItem('nonExistingPrescriberVal');
        if(prescriberData){
            this.prescriber = JSON.parse(prescriberData);
        }else{
            this.error = 'No Prescriber Data Found';
        }
    }

    RedirectToREMSVerificationPage(){
         this.currentUrl = window.location.href;
        this.contactusUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s/remsverification';
        window.open(this.contactusUrl,'_self');
    }
}