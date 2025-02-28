import { LightningElement,wire ,api, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import knowledgeAssessment from '@salesforce/apex/SYN_KnowledgeAssessmentAnswerValidation.KnowledgeAssessment';

import CaseRCtypeID_Field from '@salesforce/schema/Case.RecordTypeId';

const fields = [CaseRCtypeID_Field];
export default class Syn_knowledgeAssessmentAnswerValidation extends LightningElement {

    @api recordId;
    @track KAvalidationList;
    questionCount = 1 ; 
    @wire(getRecord, { recordId: '$recordId', fields })
    getCase({ error, data }){
        
    if(data){
        console.log('getCase', this.recordId);
        var result = JSON.parse(JSON.stringify(data));
        console.log('acc data: ', result);
        let recordTypeId = result.fields.RecordTypeId.value;
        this.handleLoad(recordTypeId);
        }else if(error) {
            var result = JSON.parse(JSON.stringify(error));
            console.log('error: ', result);
        }
    }

    handleLoad(recordTypeId) {
       
        knowledgeAssessment({ caseId: this.recordId , caseRecordTypeId: recordTypeId  })
        .then((result) => {
            this.KAvalidationList = result.map(item=>{
                let AnswerColor = item.fail == true ? "slds-text-color_error":"slds-text-color_success";
                let IconName =  item.fail == true ? "utility:close":"utility:check";
                let variant = item.fail == true ? "error":"success";
                this.questionCount += 1;
                let InitialAnswercopy = item.InitialAnswerStr;
                if (!item.InitialAnswerStr) {
                    InitialAnswercopy = 'Not Answered';
                    IconName = "utility:warning";
                    variant = "warning";
                    AnswerColor = "slds-text-color_inverse-weak";
                  
                   console.log('N/A*',item.InitialAnswerStr)
                }
                return {...item, 
                    "AnswerColor":AnswerColor,
                    "AnswerIconName":IconName,
                    "variant":variant,
                    "InitialAnswercopy":InitialAnswercopy,
                }
            })
           console.log('result *** ', JSON.stringify(this.KAvalidationList) );
        })
        .catch((error) => {
            console.log('error *** ',error);
        });
    }

    closeButton() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}