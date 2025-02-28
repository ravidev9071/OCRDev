import { LightningElement,wire,api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Monitor_Participant_Acc from '@salesforce/schema/Account.Monitor_Participant__c';
import AccountUserTypeName from '@salesforce/schema/Account.US_WSREMS__User_Type__c';

const fields = [Monitor_Participant_Acc, AccountUserTypeName];

export default class DisplayAlertPortalAccounts extends LightningElement {   
    

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    account;

    get checkboxValue() {
        const value = getFieldValue(this.account.data, AccountUserTypeName);
        if (value !== 'Prescriber' && getFieldValue(this.account.data, Monitor_Participant_Acc)) {
            return true;
        } 
    }  
    get userTypeValue(){
        const value = getFieldValue(this.account.data, AccountUserTypeName);
        if (value === 'Prescriber' && getFieldValue(this.account.data, Monitor_Participant_Acc)) {
            return true;
        }
    }
}