import { LightningElement,api } from 'lwc';
import { subscribe,unsubscribe} from 'lightning/empApi';
import Id from "@salesforce/user/Id";
import { NavigationMixin } from 'lightning/navigation';
import makeacall from '@salesforce/apex/Piasky_Makeacall.CreateREMSService';

export default class PiaSky_CustomListener extends NavigationMixin(LightningElement) {
    @api channelName = '/event/US_WSREMS__Outbound_Call__e';
    userId = Id;
    @api recordId;
    participantID;
    phone;
    programId;
    displaySpinner = false;
    uniqueID='';
    connectedCallback() {
        // Subscribe to the platform event
        this.handleSubscribe();
    }
    handleSubscribe() {
        const self = this;
        this.uniqueID = Math.random().toString(36).substr(2, 9);
        const messageCallback = function (response) {
            if(response.data.payload.CreatedById == self.userId){
                
                self.participantID = response.data.payload.US_WSREMS__Participant__c;
                self.phone = response.data.payload.US_WSREMS__Phone_Number__c;
                self.programId = response.data.payload.US_WSREMS__ProgramId__c;
                if(window.sessionStorage.getItem('evenSubscription') == self.uniqueID){
                    self.displaySpinner = true;
                    self.handleMakeACall();
                }
            }
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {
            window.sessionStorage.setItem('evenSubscription',this.uniqueID)
            this.subscription = response;
        });
    }
    handleMakeACall() {
        makeacall({ accountRecordId: this.participantID,phone:this.phone,programID:this.programId})
            .then(result => {
                this.displaySpinner = false;
                this.handleRoute(result);

                // Handle the result
            })
            .catch(error => {
                this.displaySpinner = false;
                console.error('Error making call: ', error);
                // Handle the error
            });
    }
    handleRoute(id) {
        window.sessionStorage.removeItem('evenSubscription');
        let caseId = id; 

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.buildUrl(caseId)
            }
        }, false); // true for opening in a new tab
    }

    buildUrl(caseId) {
        let url = new URL(window.location.origin + '/lightning/n/Outbound_Call');
        url.searchParams.set('c__caseId', caseId);
        url.searchParams.set('ws', '/lightning/r/Account/' + this.recordId + '/view');
        return url.toString();
    }
    disconnectedCallback() {
        // Unsubscribe from the platform event
        this.handleUnsubscribe();
        window.sessionStorage.removeItem('evenSubscription');

    }
    handleUnsubscribe() {
        // Check if subscription object is not empty
        if (this.subscription && this.subscription.channel) {
            unsubscribe(this.subscription, response => {
            });
        }
    }
}