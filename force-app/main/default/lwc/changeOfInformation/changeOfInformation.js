import { LightningElement, wire ,api, track} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { publish, MessageContext } from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/US_WSREMS__ReviewDocumentChannel__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pageLayoutFields from '@salesforce/apex/REMSchangeOfInformation.getPageLayoutFields';
import updateParticipant from '@salesforce/apex/REMSchangeOfInformation.updateParticipant';
import fetchAccountDetails from '@salesforce/apex/REMSchangeOfInformation.fetchAccountDetails';
import fetchPageLoadParams from '@salesforce/apex/REMSchangeOfInformation.fetchPageLoadParams';
import { NavigationMixin } from 'lightning/navigation';




export default class ChangeOfInformation extends LightningElement {

   @api recordId;
   @track columnList = ["Id","CaseNumber","Status"];
   @track layoutSections;
   @api calledByFaxTransfo;
   @api docDetailIdVal;
   @api caseId;
   isLoaded = true;
   @api isexistingcase;
   size ;
   multiplerows;
   sobjectRTId;
   sobjectRecordCreated;
   createdCaseId;
   participantId;
   stage;
   mappingFields;
   activeSections;
   @track dynamicFieldMapping;
   accountId;
   @wire(MessageContext)
   messageContext;
   progName;
   caseStatus;
   caseOutcome;
   /*
   @wire(pageLayoutFields , { remsServiceId : '$recordId' })
   fieldsOnLayout({ error, data }){       
       if(data){
            this.layoutSections = data;
          console.log('this.layoutSections===>'+this.layoutSections);
            this.size =  Math.floor(12/data[0].totalColumns);
            this.isLoaded = false;
            this.sobjectRTId = data[0].caseRTId;
            this.participantId = data[0].participantId;
            this.mappingFields = JSON.stringify(data[0].mappingFieldsMap);
            this.activeSections = data[0].label;
            if(data[0].totalColumns > 1){
                this.multiplerows = true;
            }else {
                this.multiplerows = flase;
            }           
            
       }else if (error){
            console.log('error ',error);
       }

   }
*/
   connectedCallback(){
    if(this.calledByFaxTransfo && this.isexistingcase ){
      //  var columnList = ["Id","CaseNumber","Status"];
      this.isexistingcase=false;
        const message = {
            "DocDetailId": this.docDetailIdVal,
            "Source":"CaseColumns",
            "CaseColumns":this.columnList
        };
       
        publish(this.messageContext, recordSelected, message);
    }
       
        setTimeout(() => {
            this.callPageLoadMethod();
          }, 5);
   }
   callPageLoadMethod() {
        fetchPageLoadParams({ remsServiceId: this.recordId,
            SourceObj : 'Account', 
            TarObj : 'Case', 
            SourceRCtyName : 'Prescribing_Institution', 
            TarRCtypeName : 'Prescriber_COI', 
            SectionLabel :''})
    .then((result) => {
        var data = result.layoutSection;
        this.layoutSections = data;
        this.dynamicFieldMapping = result.fieldMappings;
            this.size =  Math.floor(12/data[0].totalColumns);
            this.isLoaded = false;
            this.sobjectRTId = data[0].caseRTId;
            this.participantId = data[0].participantId;
            this.mappingFields = JSON.stringify(data[0].mappingFieldsMap);
            this.activeSections = data[0].label;
            if(data[0].totalColumns > 1){
                this.multiplerows = true;
            }else {
                this.multiplerows = flase;
            }     
            let allFieldSet;
            let layoutSection = this.layoutSections;
            let tempAccountId;
            layoutSection.forEach(function(section){
                if(section.label == 'Contact Information') {
                    allFieldSet = section.fieldsList;
                }
            });            
            allFieldSet.forEach(function(section){
                if(section.fieldName == 'US_WSREMS__Facility__c'){
                     tempAccountId = section.fieldValue;
                }
            });
            this.accountId = tempAccountId;
            if(this.accountId) {
                this.callFetchAccountMethod(this.accountId);
            }
    })
    .catch((error) => {
        console.log('Error in Page Load==>'+error);
    });
   }
   handleSubmit(event){
    event.preventDefault();
	this.isLoaded = true;
    const fields = event.detail.fields;
    fields.US_WSREMS__REMS_Service_Summary__c = this.recordId;
    fields.US_WSREMS__Participant__c = this.participantId;
    this.progName = fields.US_WSREMS__Program_Picklist__c;
    this.caseStatus = fields.Status;
    this.caseOutcome = fields.US_WSREMS__Outcome__c;
    this.sobjectRecordCreated = JSON.stringify(fields);
    this.template.querySelector('lightning-record-edit-form').submit(fields);
      

   }

   handleError(event) {
    event.preventDefault();    
     this.isLoaded = false;	
     if(event.detail.detail){
        let title = 'Case creation error';
        let variant = 'error';
        let errorMessage = event.detail.detail;
        this.showNotification(title,errorMessage,variant);
     }
   }

   handleSuccess(event){
    //alert(this.calledByFaxTransfo);
	this.isLoaded = false;
    if(this.calledByFaxTransfo){
        const message = {
            "DocDetailId": this.docDetailIdVal,
            "REMSServiceId": this.recordId,
            "Source":"NewCase"
        };
        this.createdCaseId = event.detail.id;
        if (this.progName =='Macitentan REMS'){
             if (this.caseStatus == 'Complete'){
                this.participantUpdate();
             }
        }
        publish(this.messageContext, recordSelected, message); 


       
}else{
    eval("$A.get('e.force:refreshView').fire();");   
    this.createdCaseId = event.detail.id;
    if (this.progName =='Macitentan REMS'){
        //alert('Maci');
         if (this.caseStatus == 'Complete'){
            //alert('Complete');
            this.participantUpdate(); 
         }
         this.dispatchEvent(new CloseActionScreenEvent());
    }else{
        //alert('Non Maci');
        if (this.caseStatus == 'Complete' && this.caseOutcome == 'Complete')
        {
            this.participantUpdate();
        }
        this.dispatchEvent(new CloseActionScreenEvent());
    }  
    this.caseCreatedToaster();
}
   }

   participantUpdate(){
       
    updateParticipant({ caseId: this.createdCaseId , parId : this.participantId , fieldMappingStr : this.mappingFields })
            .then((result) => {
              if(result.length > 0){
                this.accountUpdatedToaster();
               }
            
               this.dispatchEvent(new CloseActionScreenEvent());
               
            })
            .catch((error) => {
                this.dispatchEvent(new CloseActionScreenEvent());
               
            });

          /*  setTimeout(() => {
                window.location.reload(false);
          }, 2000); */
            
          
   }
   
   caseCreatedToaster(){
    let title = 'Case was created';
    let variant = 'success';
    this.showNotification(title,'',variant);
   }

   accountUpdatedToaster(){

    let title = 'Participant was updated';
    let variant = 'success';
    this.showNotification(title,'',variant);
   }

   showNotification(title , message , variant) {
     const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
    });
    this.dispatchEvent(evt);
}
handleInputChange(event) {
   if(event.target.fieldName == 'US_WSREMS__Facility__c' && event.target.value != '') {
        this.callFetchAccountMethod(event.target.value);
   } else if(event.target.fieldName == 'US_WSREMS__Facility__c' && event.target.value == '') {
    const inputFields = this.template.querySelectorAll('[data-type="user-input"]');
            if (inputFields) {
                inputFields.forEach(input => {
                    if (this.dynamicFieldMapping[input.fieldName]){
                        input.value = '';
                    }
                });
            }
        }    
    }
    callFetchAccountMethod(accountId) {
        let currAccount;
        fetchAccountDetails({ accId:  accountId})
            .then((result) => {
                currAccount = result[0];
                const inputFields = this.template.querySelectorAll('[data-type="user-input"]');
                if (inputFields) {
                    inputFields.forEach(input => {
                        if (this.dynamicFieldMapping[input.fieldName]){
                          input.value = currAccount[this.dynamicFieldMapping[input.fieldName]];
                        }
                    });
                }
            })
            .catch((error) => {
                console.log('Error in Contact Fetch' + error);
               
            });
    }
}