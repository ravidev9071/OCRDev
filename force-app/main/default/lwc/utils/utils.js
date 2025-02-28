import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { api, LightningElement } from 'lwc';
import casevalMessages from "@salesforce/apex/REMSRecordFormController.getCaseStatusValidations";
import getDatacalConfigs from "@salesforce/apex/REMSRecordFormController.getDataPopulationConfigs";
import { createRecord, updateRecord } from "lightning/uiRecordApi";
import callPAESendEmail from "@salesforce/apex/PAESendEmailJob.invokeSenEmail";

export default class UtilsClass extends LightningElement {

    @api showSuccess(message) {
        this.ShowToastMessage('Success', message);
    }

    @api showError(message) {
        this.ShowToastMessage('Error', message);
    }

    ShowToastMessage(type, message){
        const toastEvent = new ShowToastEvent({
            title: type,
            message: message,
            variant: type,
            mode: 'sticky'
        });
     
        this.dispatchEvent(toastEvent);
       
    }
}

export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter(error => !!error)
            // Extract an error message
            .map(error => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map(e => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    if(error.body.message.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                        let retError = error.body.message.replace(/[^a-zA-Z ]/g, "")?.split('FIELDCUSTOMVALIDATIONEXCEPTION')[1];
                        return retError;
                    }
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {

                    return error.message;
                }


                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter(message => !!message)
    );

    
}

export function doDataCals(page,referenceField,refFldValue){
    if(page.datacalMappingConfigs && page.datacalMappingConfigs.has(referenceField)){
       let logicType = page.datacalMappingConfigs.get(referenceField).logicType;
       let sourceTargetLocalMap = new Map(Object.entries(page.datacalMappingConfigs.get(referenceField).sourceTargetMap));
       let inputFldMap = new Map();
       let targetMap = new Map();

      if(logicType == 'Copy Data'){
        page.template.querySelectorAll('lightning-input-field').forEach(ele => {
          inputFldMap.set(ele.fieldName,ele.value);
        });
        sourceTargetLocalMap.forEach((value, key) => {
          let fieldName = key;
          let targetfield = value;
          if(refFldValue){
            targetMap.set(targetfield,inputFldMap.get(fieldName));
          }else{
            targetMap.set(targetfield,null);
          }
        });
        page.template.querySelectorAll('lightning-input-field').forEach(ele => {
          if(targetMap.has(ele.fieldName)){
            ele.value = targetMap.get(ele.fieldName);
          }
        });
      }

      if(logicType == 'Time Difference In Hours'){
        let fldKey = sourceTargetLocalMap.keys().next().value;

        if(fldKey && fldKey.includes(';')){
          let primeTimeFld = fldKey.split(';')[0];
          let secTimeFld = fldKey.split(';')[1];
          let targetFld = sourceTargetLocalMap.get(fldKey);
          let primeTime = page.template.querySelector(
            `lightning-input-field[data-field="${primeTimeFld}"]`
          );
          let secondTime = page.template.querySelector(
            `lightning-input-field[data-field="${secTimeFld}"]`
          );
          if(primeTime && secondTime && primeTime.value && secondTime.value){
            var timediff =(new Date(primeTime.value).getTime() - new Date(secondTime.value).getTime()) / (1000*3600);
            let inputFld = page.template.querySelector(
              `lightning-input-field[data-field="${targetFld}"]`
            );
            if(inputFld){
              if(timediff<24){
                inputFld.value = 'Yes';
              }else{
                inputFld.value = 'No';
              }
            }
          }

        } 
      }
   }
  }

  export function getCaseIncompleteValidationConfigs (page,currentUserProgramName,serviceConfig){
    casevalMessages({
      recordTypeName:serviceConfig,
      programName:currentUserProgramName
    })
    .then(result => {
        page.validationMsgMap = new Map(Object.entries(result));
    })
    .catch(error => {
    })
    }

    export function getdataMappingConfigs(page,progName, reqType, caseRecordTypeName){
        getDatacalConfigs({
          programName:progName,
          participantType:reqType,
          recordTypeName:caseRecordTypeName,
          objectName: 'Case'
        })
        .then(result => {
            page.datacalMappingConfigs = new Map(Object.entries(result));
        })
        .catch(error => {
        })
}

      export function reSubmitChildObjects(page,caseId,accountId){
        let nameSpace = page.namespaceVar;
        page.template.querySelectorAll(
            'lightning-record-edit-form'
        ).forEach(element=>{
            if(element.dataset.object && element.dataset.object != 'Case'){
              let objinputFields={};
              if(element.dataset.object == `${nameSpace}CaseProgram__c` && page.caseProgMap.has(element.dataset.recordtype)){
                objinputFields['Id'] = page.caseProgMap.get(element.dataset.recordtype);
                page.caseProgId = objinputFields['Id'];
              }
                
              page.template.querySelectorAll(
                    `lightning-input-field[data-objectkey="${element.dataset.object}"]`
                ).forEach(element=>{
                  if(element && element.fieldName && (element.fieldName!='CreatedById' && element.fieldName!='LastModifiedById')){
                    objinputFields[element.fieldName]= element.value;
                  }
                });
                if(page.objectParentFieldAPIMap[element.dataset.object+element.dataset.recordtype]){
                  var caseApiName;
                  var accountApiName;
                  var progApiName;
                  if(page.objectParentFieldAPIMap[element.dataset.object+element.dataset.recordtype]['Case']){
                    caseApiName = page.objectParentFieldAPIMap[element.dataset.object+element.dataset.recordtype]['Case'];
                    objinputFields[caseApiName] = caseId;
                  }
                  if(page.objectParentFieldAPIMap[element.dataset.object+element.dataset.recordtype]['Account']){
                    accountApiName = page.objectParentFieldAPIMap[element.dataset.object+element.dataset.recordtype]['Account'];
                    objinputFields[accountApiName] = accountId;
                  }
                  if(page.objectParentFieldAPIMap[element.dataset.object+element.dataset.recordtype]['Program']){
                    progApiName = page.objectParentFieldAPIMap[element.dataset.object+element.dataset.recordtype]['Program'];
                    objinputFields[progApiName] = page.programId;
                  }
                  
                  
                }
                page.stopHandleSuccessExec =true;
                if(page.caseProgId){
                  page.caseProgId = null;
                  const recordInput = {
                  fields: objinputFields
                };
                  updateRecord(recordInput)
                  .then(() => {
    
                  })
                  .catch(error => {
                    console.error('Error updating record', error);
                  });
                }else{
                  element.submit(objinputFields);
                }
            }
        });
        let fields = {
          Id: caseId,
          [`${page.namespaceVar}Incomplete_Reasons__c`]: null,
        };
       updateRecord({ fields })
          .then(() => {
    
          })
          .catch(error => {
            console.error('Error updating record', error);
          });
        
      }

      export async function sendPaeEmail(page,caseId){
        if(page.serviceConfigRecord[`${page.namespaceVar}Case_Record_Type__c`] === 'PAE' ){
          await callPAESendEmail({
            caseRecId:caseId
          });
        }
      }