import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";

const fieldsArray = [
    "Account.US_WSREMS__City__c",
    "Account.US_WSREMS__State__c",
    "Account.US_WSREMS__Zip__c",
];
export default class AveedMapLocator extends LightningElement {
    accountLocation;
    billingCity;
    billingPostalCode;
    billingState;
    @track center;
    @api recordId;
    @api paramMapMarkers;
    @api markerTitle;
    @api mapMarkers = [];
    @api selectedvalue;
    @api listViewType;
    @api zoomType;

    connectedCallback() {

    }

    @wire(getRecord, { recordId: "$recordId", fields: fieldsArray })
    wiredAccount({ error, data }) {
        if (data) {
            this.billingCity = data.fields.US_WSREMS__City__c.value;
            this.billingPostalCode = data.fields.ShippingPostalCode.value;
            this.billingState = data.fields.ShippingState.value;
            //account information is stored here
            this.accountLocation = {
                location: {
                    City: this.billingCity !== null ? this.billingCity : "",
                    PostalCode: this.billingPostalCod !== null ? this.billingPostalCod : "",
                    State: this.billingState !== null ? this.billingState : ""
                },
                title: this.accountName !== null ? this.accountName : ""
            };

            this.mapMarkers = [this.accountLocation];

            this.center = {
                location: {
                    PostalCode:
                        this.billingPostalCod !== null ? this.billingPostalCod : ""
                }
            };
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.mapMarkers = undefined;
            console.error("ERROR => ", error);
        }
    }
}