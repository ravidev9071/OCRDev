import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

//import Monitor_Participant_FIELD from '@salesforce/schema/Case.US_WSREMS__Patient__r.Monitor_Participant__c';
import CaseRecType_FIELD from '@salesforce/schema/Case.Case_Record_Type_Name__c';

const fields = [CaseRecType_FIELD];

export default class DisplayAlertCmp extends LightningElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    rdaCaseData;
    
    get caseRecTypeName(){
       if (getFieldValue(this.rdaCaseData.data, CaseRecType_FIELD) == 'Risk Management Report') {
           return true;
       }
       return false;
        // return getFieldValue(this.rdaCaseData.data, CaseRecType_FIELD);
  //  if CaseRecType_FIELD == 'REMS Dispense Authorization'
    }

}