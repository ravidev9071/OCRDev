import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";

 const fieldsArray = [
       // "Account.Name",
        //"Account.BillingStreet",
        "Account.US_WSREMS__City__c",
        "Account.US_WSREMS__State__c",
        "Account.US_WSREMS__Zip__c",
       // "Account.BillingCountry"
        ];
export default class TryvioMapLocator extends LightningElement {
    accountLocation;
 // billingStreet;
  billingCity;
  billingPostalCode;
  billingState;
  //accountName;  
  @track center;
  @api recordId;
  @api paramMapMarkers;
  @api markerTitle;
  @api mapMarkers = [];
  @api selectedvalue;
  @api listViewType;
  @api zoomType;

  connectedCallback() {
    console.log('selectedvalue::', this.selectedvalue);
  }

  @wire(getRecord, { recordId: "$recordId", fields: fieldsArray })
  wiredAccount({ error, data }) {
    if (data) {
     // this.billingStreet = data.fields.BillingStreet.value;
      this.billingCity = data.fields.US_WSREMS__City__c.value;
      this.billingPostalCode = data.fields.US_WSREMS__Zip__c.value;
      this.billingState = data.fields.US_WSREMS__State__c.value;
     // this.accountName = data.fields.Name.value;

      console.log('this.billingCity '+this.billingCity);
      //account information is stored here
      this.accountLocation = {
        location: {
        //  Street: this.billingStreet !== null ? this.billingStreet : "",
          City: this.billingCity !== null ? this.billingCity : "",
          PostalCode:
            this.billingPostalCod !== null ? this.billingPostalCod : "",
          State: this.billingState !== null ? this.billingState : "",
          //Country: this.billingCountry !== null ? this.billingCountry : ""
        },
        title: this.accountName !== null ? this.accountName : ""
      };

      this.mapMarkers = [this.accountLocation];

      this.center = {
        location: {
          //Street: this.billingStreet !== null ? this.billingStreet : "",
          PostalCode:
            this.billingPostalCod !== null ? this.billingPostalCod : ""
        }
      };
      this.error = undefined;
    } else if (error) {
      console.log('dsadsd',this.paramMapMarkers);
      this.error = error;
      this.mapMarkers = undefined;
      console.error("ERROR => ", error);
    }
  }
}