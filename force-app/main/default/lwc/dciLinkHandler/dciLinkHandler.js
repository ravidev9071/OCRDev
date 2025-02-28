import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import DCI_OBJECT from '@salesforce/schema/DocumentChecklistItem';
import RECEIVED_DOCUMENT_OBJECT from '@salesforce/schema/ReceivedDocument';
import OWNER_FIELD from '@salesforce/schema/DocumentChecklistItem.OwnerId';
import STATUS_FIELD from '@salesforce/schema/ReceivedDocument.Status';

export default class DciLinkHandler extends LightningElement {
    @api recordId;

    handleLinkClick() {
        const fields = {};
        fields[OWNER_FIELD.fieldApiName] = '0dd8N000000GqPMQA0'; // Replace with the current user's ID
        const recordInput = { fields, apiName: DCI_OBJECT.objectApiName, id: this.recordId };

        updateRecord(recordInput)
            .then(() => {
                // Update parent record
                const parentFields = {};
                parentFields[OWNER_FIELD.fieldApiName] = '0io8N000000CaUuQAK'; // Replace with the current user's ID
                parentFields[STATUS_FIELD.fieldApiName] = 'Assigned';
                const parentRecordInput = { fields: parentFields, apiName: RECEIVED_DOCUMENT_OBJECT.objectApiName, id: this.parentRecordId };

                return updateRecord(parentRecordInput);
            })
            .catch(error => {
                console.error('Error updating records: ', error);
            });
    }
}