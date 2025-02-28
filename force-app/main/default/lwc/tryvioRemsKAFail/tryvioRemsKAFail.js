import { LightningElement,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import {CurrentPageReference} from 'lightning/navigation';
export default class TryvioRemsKAFail extends LightningElement {   
    iconPrescriber = tryvioIconPrescriber;
    name;
    npi;
    recordId;
    @wire(CurrentPageReference)
    CurrentPageReference(pageRef){
    if(pageRef){
    this.presname=pageRef.state.c__name;
    this.presnpi=pageRef.state.c__npi;
    this.recordId=pageRef.state.c_id;
    console.log('recordid',this.recordId);
    }
    }
    connectedCallback() {
        loadStyle(this, customStyles);
        /*let url = new URL(window.location.href);
        this.name = url.searchParams.get('name');
        this.npi = url.searchParams.get('npi');
        console.log(this.name);
        console.log(this.npi);*/
    }
}