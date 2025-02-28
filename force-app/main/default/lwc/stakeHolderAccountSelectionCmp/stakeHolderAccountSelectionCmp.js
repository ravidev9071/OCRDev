import { LightningElement, track, api } from 'lwc';
import getAccountRecordTypeList from '@salesforce/apex/OCRFormCtrl.getAccountRecordTypeList';
import getCurrentUserProgram from '@salesforce/apex/OCRFormCtrl.getCurrentUserProgram';
import ProgramsEnrolledMsg from '@salesforce/label/c.ProgramsEnrolledMsg';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class StakeHolderAccountSelectionCmp extends LightningElement {
    @track accountRecordTypeList = [];
    @api selectedValue;
    showAccountOption = true;
    programUserName;
    @api recordTypeName;

    label = {
        ProgramsEnrolledMsg
    }

    connectedCallback() {
        this.handleGetCurrentUserProgram();
    }

    handleGetCurrentUserProgram() {
        getCurrentUserProgram()
            .then(result => {
                this.programUserName = result[0].US_WSREMS__REMS_Program__r.Name;
                this.handleAccountRecordTypeList();
                if (result === null) {
                    this.showToastNotification('Warning:', this.label.ProgramsEnrolledMsg, 'warning');
                }
            })
            .catch(error => {
                this.showToastNotification('Something went wrong', this.label.accountErrorMsg, 'Error');
            });
    }

    handleAccountRecordTypeList() {
        getAccountRecordTypeList({ programName: this.programUserName })
            .then(result => {
                let tempArr1 = [];
                for (let i = 0; i < result.length; i++) {
                    let record = result[i];
                    tempArr1.push({ label: record.Label, value: record.Id, recordType: record.US_WSREMS__RecordType_Name__c });
                }
                this.accountRecordTypeList = tempArr1;
            })
            .catch(error => {
                this.showToastNotification('Something went wrong', this.label.accountErrorMsg, 'Error');
            });
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;
        let selectedRecord = this.accountRecordTypeList.find(item => item.value === this.selectedValue);
        let selectedRecordType = selectedRecord ? selectedRecord.recordType : null;
        this.recordTypeName = selectedRecordType;
        const selectedEvent = new CustomEvent('selected', { detail: this.selectedValue });
        const recordTypeEvent = new CustomEvent('recordtype', { detail: this.recordTypeName });
        this.dispatchEvent(selectedEvent);
        this.dispatchEvent(recordTypeEvent);
    }

    showToastNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
        });
    this.dispatchEvent(evt);
    }

}