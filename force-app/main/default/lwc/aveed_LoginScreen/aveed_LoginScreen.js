import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';


export default class Aveed_LoginScreen extends LightningElement {
    connectedCallback() {
        loadStyle(this, customHomeStyles); 
       
    }
    value = '';
    showInfoHCS = false;

    options = [
        { label: 'Healthcare Setting Authorized Representative', value: '1' },
        { label: 'Prescribing Healthcare Provider', value: '2' }
    ];

    fields = [
        { id: 'firstName', label: 'First Name', name: 'FirstName', value: '', required: true },
        { id: 'lastName', label: 'Last Name', name: 'LastName', value: '', required: true },
        { id: 'email', label: 'Email Address', name: 'PersonEmail', value: '', required: true },
        { id: 'phone', label: 'Phone Number', name: 'Phone', value: '', required: true }
    ];

    handleChange(event) {
        this.value = event.detail.value;
    }
    get isHealthcareRep() {
        return this.value === '1';
    }
    get isPrescribingProvider() {
        return this.value === '2';
    }
    handleConfirmClick() {
        this.showInfoHCS = true;
    }

    createAccount() {
        const fields = {};
        let nameVal = '';
        this.fields.forEach(field => {
          
            fields[field.name] = field.value;
        });

        const recordInput = {
            apiName: ACCOUNT_OBJECT.objectApiName,
            fields
        };
       
        createRecord(recordInput)
            .then(account => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Account created, with id: ' + account.id,
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating account',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    handleInput(event) {
        const { name, value } = event.target;
        
        this.fields = this.fields.map(field => {
            if (field.name === name) {
                return { ...field, value: value };
            }
            return field;
        });
    }
}