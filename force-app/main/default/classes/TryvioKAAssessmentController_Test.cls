@isTest
public with sharing class TryvioKAAssessmentController_Test {
    @isTest
    static void getQuestions(){
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        US_WSREMS__Assessment__c  assessment = new US_WSREMS__Assessment__c();
        assessment.US_WSREMS__REMS_Program__c=programList[0].id;
        assessment.US_WSREMS__Maximum_Attempts__c=3;
        assessment.US_WSREMS__Participant_Type__c='Prescriber';
        assessment.US_WSREMS__Pass_Percentage__c=100;
        assessment.US_WSREMS__Show_Wrong_Answers_Only__c=true;
        assessment.name='Knowledge Assessment';
        insert assessment;
        
        US_WSREMS__Assessment_Question__c ques = new 	US_WSREMS__Assessment_Question__c();
        ques.US_WSREMS__Active__c=true;
        ques.US_WSREMS__Assessment__c=assessment.id;
        ques.US_WSREMS__Correct_Response__c='2';
        ques.US_WSREMS__Question_Text__c='test';
        ques.US_WSREMS__Response_Values__c='1. True;;2. False';
        ques.US_WSREMS__Response_Data_Type__c='Radio Option';
        ques.US_WSREMS__Serial__c=1;
        insert ques;
        
        US_WSREMS__Assessment_Question__c ques1 = new 	US_WSREMS__Assessment_Question__c();
        ques1.US_WSREMS__Active__c=true;
        ques1.US_WSREMS__Assessment__c=assessment.id;
        ques1.US_WSREMS__Correct_Response__c='2';
        ques1.US_WSREMS__Question_Text__c='test2';
        ques1.US_WSREMS__Response_Values__c='1. True;;2. False';
        ques1.US_WSREMS__Response_Data_Type__c='Radio Option';
        ques1.US_WSREMS__Serial__c=1;
        
        insert ques1;
        
        
        case caseRec = new case();
        caseRec.Program_Record_Type_Control__c = 'TRYVIO REMS-Knowledge_Assessment';
        caseRec.US_WSREMS__REMS_Program__c = programList[0].Id;
        caseRec.Status = 'Draft';
        caseRec.US_WSREMS__First_Name__c = 'test';
        caseRec.US_WSREMS__Last_Name__c = 'test';
        caseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByName().get('Knowledge Assessment').getRecordTypeId();
        caseRec.US_WSREMS__Program_Picklist__c = programList[0].Name;
        caseRec.US_WSREMS__Channel__c = 'Portal';
        insert caseRec;
        
        list<US_WSREMS__Assessment_Response__c> reslist= new list<US_WSREMS__Assessment_Response__c>();
        US_WSREMS__Assessment_Response__c res= new US_WSREMS__Assessment_Response__c();
        res.US_WSREMS__Assessment_Question__c=ques.id;
        res.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res.US_WSREMS__Answer__c='1';
        res.US_WSREMS__Response__c='true';
        reslist.add(res);
        US_WSREMS__Assessment_Response__c res1= new US_WSREMS__Assessment_Response__c();
        res1.US_WSREMS__Assessment_Question__c=ques1.id;
        res1.US_WSREMS__Question__c=ques1.US_WSREMS__Question_Text__c;
        res1.US_WSREMS__Answer__c='1';
        res1.US_WSREMS__Response__c='true';
        reslist.add(res1);
        
        
        US_WSREMS__Assessment_Submission__c sub = new US_WSREMS__Assessment_Submission__c();
        sub.US_WSREMS__Assessment__c=assessment.id;
        sub.US_WSREMS__Case__c=caseRec.id;
        sub.US_WSREMS__Assessment_Result__c='Failed';
        insert sub;
        
        
        US_WSREMS__Assessment_Response__c res3= new US_WSREMS__Assessment_Response__c();
        res3.US_WSREMS__Assessment_Question__c=ques.id;
        res3.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res3.US_WSREMS__Answer__c='1';
        res3.US_WSREMS__Response__c='true';
        res3.US_WSREMS__Assessment_Submission__c=sub.id;
        insert res3;
        
        US_WSREMS__Assessment_Response__c res4= new US_WSREMS__Assessment_Response__c();
        res4.US_WSREMS__Assessment_Question__c=ques1.id;
        res4.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res4.US_WSREMS__Answer__c='1';
        res4.US_WSREMS__Response__c='true';
        res4.US_WSREMS__Assessment_Submission__c=sub.id;
        insert res4;
        
        string response=TryvioKAAssessmentController.getSubmitResponse(caseRec.id,assessment.id,reslist,100,'1');
        
        TryvioKAAssessmentController.CaseAndRelatedDataWrapper wrap= new TryvioKAAssessmentController.CaseAndRelatedDataWrapper();
        
        wrap=TryvioKAAssessmentController.getCaseAndRelatedData(caseRec.id,false);
        
        List<US_WSREMS__Assessment__c> asselist= TryvioKAAssessmentController.getQuestions();
    }
    @isTest
    static void getKaQuestions(){
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        Account acc = new Account();
        acc.lastname = 'test acc';
        acc.FirstName = 'test';
        acc.US_WSREMS__REMS_Program__c = programList[0].id;
        acc.recordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        acc.US_WSREMS__Program_Picklist__c = programList[0].Name;
        insert acc;
        US_WSREMS__Assessment__c  assessment = new US_WSREMS__Assessment__c();
        assessment.US_WSREMS__REMS_Program__c=programList[0].id;
        assessment.US_WSREMS__Maximum_Attempts__c=3;
        assessment.US_WSREMS__Participant_Type__c='Prescriber';
        assessment.US_WSREMS__Pass_Percentage__c=100;
        assessment.US_WSREMS__Show_Wrong_Answers_Only__c=true;
        assessment.name='Knowledge Assessment';
        insert assessment;
        
        US_WSREMS__Assessment_Question__c ques = new 	US_WSREMS__Assessment_Question__c();
        ques.US_WSREMS__Active__c=true;
        ques.US_WSREMS__Assessment__c=assessment.id;
        ques.US_WSREMS__Correct_Response__c='1';
        ques.US_WSREMS__Question_Text__c='test';
        ques.US_WSREMS__Response_Values__c='1. True;;2. False';
        ques.US_WSREMS__Response_Data_Type__c='Radio Option';
        ques.US_WSREMS__Serial__c=1;
        insert ques;
        
        US_WSREMS__Assessment_Question__c ques1 = new 	US_WSREMS__Assessment_Question__c();
        ques1.US_WSREMS__Active__c=true;
        ques1.US_WSREMS__Assessment__c=assessment.id;
        ques1.US_WSREMS__Correct_Response__c='1';
        ques1.US_WSREMS__Question_Text__c='test2';
        ques1.US_WSREMS__Response_Values__c='1. True;;2. False';
        ques1.US_WSREMS__Response_Data_Type__c='Radio Option';
        ques1.US_WSREMS__Serial__c=1;
        
        insert ques1;
        
        
        case caseRec = new case();
        caseRec.Program_Record_Type_Control__c = 'TRYVIO REMS-Knowledge_Assessment';
        caseRec.US_WSREMS__REMS_Program__c = programList[0].Id;
        caseRec.Status = 'Draft';
        caseRec.US_WSREMS__First_Name__c = 'test';
        caseRec.US_WSREMS__Last_Name__c = 'test';
        caseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByName().get('Knowledge Assessment').getRecordTypeId();
        caseRec.US_WSREMS__Program_Picklist__c = programList[0].Name;
        caseRec.US_WSREMS__Prescriber__c=acc.id;    
        caseRec.US_WSREMS__Channel__c = 'Portal';
        insert caseRec;
        
        
        list<US_WSREMS__Assessment_Response__c> reslist= new list<US_WSREMS__Assessment_Response__c>();
        US_WSREMS__Assessment_Response__c res= new US_WSREMS__Assessment_Response__c();
        res.US_WSREMS__Assessment_Question__c=ques.id;
        res.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res.US_WSREMS__Answer__c='1';
        res.US_WSREMS__Response__c='true';
        res.US_WSREMS__Response_Result__c=true;
        reslist.add(res);
        US_WSREMS__Assessment_Response__c res1= new US_WSREMS__Assessment_Response__c();
        res1.US_WSREMS__Assessment_Question__c=ques1.id;
        res1.US_WSREMS__Question__c=ques1.US_WSREMS__Question_Text__c;
        res1.US_WSREMS__Answer__c='1';
        res1.US_WSREMS__Response__c='true';
        res1.US_WSREMS__Response_Result__c=true;
        reslist.add(res1);
        
        
        US_WSREMS__Assessment_Submission__c sub = new US_WSREMS__Assessment_Submission__c();
        sub.US_WSREMS__Assessment__c=assessment.id;
        sub.US_WSREMS__Case__c=caseRec.id;
        sub.US_WSREMS__Assessment_Result__c='Failed';
        insert sub;
        
        
        US_WSREMS__Assessment_Response__c res3= new US_WSREMS__Assessment_Response__c();
        res3.US_WSREMS__Assessment_Question__c=ques.id;
        res3.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res3.US_WSREMS__Answer__c='1';
        res3.US_WSREMS__Response__c='true';
        res3.US_WSREMS__Assessment_Submission__c=sub.id;
        res3.US_WSREMS__Response_Result__c=true;
        insert res3;
        
        US_WSREMS__Assessment_Response__c res4= new US_WSREMS__Assessment_Response__c();
        res4.US_WSREMS__Assessment_Question__c=ques1.id;
        res4.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res4.US_WSREMS__Answer__c='1';
        res4.US_WSREMS__Response__c='true';
        res4.US_WSREMS__Response_Result__c=true;
        res4.US_WSREMS__Assessment_Submission__c=sub.id;
        insert res4;
        
        string response=TryvioKAAssessmentController.getSubmitResponse(caseRec.id,assessment.id,reslist,100,'1');
        //string result=TryvioKAAssessmentController.saveAssessmentResult(caseRec.id,sub.id,100,1);
        
        TryvioKAAssessmentController.CaseAndRelatedDataWrapper wrap= new TryvioKAAssessmentController.CaseAndRelatedDataWrapper();
        
        wrap=TryvioKAAssessmentController.getCaseAndRelatedData(caseRec.id,true);
        
        List<US_WSREMS__Assessment__c> asselist= TryvioKAAssessmentController.getQuestions();
    }
    public static List<US_WSREMS__REMS_Program__c> createPrograms(integer noOfRecords,boolean isCreate){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = 'TRYVIO REMS';
            programObj.US_WSREMS__Status__c ='Active';
            programObj.US_WSREMS__Program_State_Date__c = System.today();
            programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
            programList.add(programObj);
        }
        
        if(isCreate && programList.size()>0){
            insert programList;
        }
        return programList; 
    }
}