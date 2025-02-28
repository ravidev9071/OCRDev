import { LightningElement, track,wire,  api } from 'lwc';
import  getRecord  from '@salesforce/apex/OCR_ECMS_Controller.getData'; // Apex method to get JSON from the record;
import getJsonStringFromRecord from '@salesforce/apex/OCR_ECMS_Controller.getJsonStringFromRecord'; // Apex method to get JSON from the record

export default class ECMSReponse extends LightningElement {
    @track jsonData;
    @track columns = [];
    @track error;
    @track isLoading = true;
    @api recordId;

    @wire(getRecord)
    record({error, data}){
        console.log('wire '+this.recordId);
        
        if(this.recordId){
            console.log(this.recordId);
            console.log(data);
            this.fetchData();
        }else if(error){
            console.log(error);
        }
    }

    connectedCallback() {
       // if(this.recordId){
           // console.log('recordid '+this.recordId);
        console.log('Hello');
        console.log(this.recordId);
        
        
        // this.fetchData();
           // console.log('hello1 ');
       // }
    }

     fetchData() {
        try {
            
            getJsonStringFromRecord({Id:this.recordId})
            .then((result) => {
                console.log('hello2 '+result);
                /*const jsonResult = JSON.parse(result);
                this.jsonData = jsonResult;  */              
                this.isLoading = false;
                this.processJsonData(result);
            })
            .catch((error) => {
                this.error = error.body.message;
                console.log('Error '+this.error);
            });

            
        } catch (error) {
            this.error = error;
            this.isLoading = false;
        }
    }

    processJsonData(data) {
        // Assuming data is in JSON string format
        console.log('hello '+JSON.stringify(data.OCRECMSRepsonse__c));
        this.jsonData = JSON.parse(data.OCRECMSRepsonse__c);
        //console.log('hello '+JSON.stringify(jsonData));
        // Generating columns dynamically. 
        if (this.jsonData && this.jsonData.length > 0) {
            this.columns = Object.keys(this.jsonData[0]).map((key) => ({
                label: key,
                fieldName: key,
                type: 'text' // Adjust type as needed
            }));
        }
    }
}