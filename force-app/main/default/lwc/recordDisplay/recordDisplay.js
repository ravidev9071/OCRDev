import { LightningElement, api } from 'lwc';

export default class RecordDisplay extends LightningElement {
    @api recordId; // This will hold the Record Id passed from the record page

    handleClick() {
        // Here you can add any logic you want to perform on button click
        console.log('Button clicked! Record ID:', this.recordId);
        alert('Record ID: ' + this.recordId); // Example action
    }
}