/**
* @File Name          : SYN_KnowledgeAssessAnsValidation_Test.cls
* @Description        : This is a test class for SYN_KnowledgeAssessmentAnswerValidation.
* @Class    	      : SYN_KnowledgeAssessmentAnswerValidation
* @Author 			  : Wilcosource
* @Modification Log   :
* Ver       Date            Developer      		             Modification
* 1.0    04/19/2022        Chaitanya Nandamuri (Wilco)     Initial Implementation (Testing KnowledgeAssessmentResults)
**/
@isTest
public class SYN_KnowledgeAssessAnsValidation_Test {
    
    public static id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Knowledge_Assessment').getRecordTypeId();
    Public static Id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('SYN_Knowledge_Assessment_A').getRecordTypeId();
    @testSetUp
    static void createTestData(){
        
        
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.REMS_Project_Code__c = 'BT6825';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        Insert programObj;
        
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy Participant ';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;
        
        Case caseObj = new Case(RecordTypeId = caseRecordTypeId, Status = 'Draft',US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS', US_WSREMS__REMS_Service_Summary__c = serviceObj.id);
        insert caseObj;
    }
    
    @isTest
    static void KnowledgeAssessmentResults(){
        case cseObj = [select id from case where recordtypeId =:caseRecordTypeId limit 1];
        SYN_KnowledgeAssessmentAnswerValidation.KnowledgeAssessment(cseObj.id , caseRecordTypeId);
    }

}