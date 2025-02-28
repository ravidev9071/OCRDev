/**
* @File Name          : REMSchangeOfInformation_Test.cls
* @Description        : Provides test class coverage for REMSchangeOfInformation
* @ApexClass		   : REMSchangeOfInformation
* @Author 			   : Wilcosource
* @Modification Log   :
* Ver       Date            Developer      		    Modification
* 1.0    06/29/2021   Chaitanya Nandamuri (Wilco)     Initial Implementation.
**/

@isTest
public class REMSchangeOfInformation_Test {
    
    @testSetUp
    static void createTestData(){
        List<US_WSREMS__REMS_Program__c > remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
        
        Id remsRTId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_of_Information').getRecordTypeId();
        
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        PrescriberObj.US_WSREMS__REMS_Program__c = remsProgramList[0].id;
        insert PrescriberObj;
        
        US_WSREMS__REMS_Service_Summary__c remsServiceObject = SYN_TestDataFactory.createService(false, remsProgramList[0].Id, remsRTId);
        remsServiceObject.US_WSREMS__Participant__c = PrescriberObj.id;
        insert remsServiceObject;
    	
        case caseObj = SYN_TestDataFactory.CreateCase(false,remsServiceObject.id);
        
    
    }
    
    @isTest
    static void testgetPageLayoutName(){
        List<US_WSREMS__REMS_Service_Summary__c> remsServiceList = [SELECT Id, Name FROM US_WSREMS__REMS_Service_Summary__c WHERE RecordType.DeveloperName = 'Change_of_Information' LIMIT 1];
        list<Account> testAccList = [Select Id from Account Where US_WSREMS__NPI__c =: '5648603245'];
        Test.startTest();
        REMSchangeOfInformation.getPageLayoutFields(remsServiceList[0].Id);
        REMSchangeOfInformation.updateAccount(testAccList);
        Test.stopTest();
        System.assertEquals(REMSchangeOfInformation.casePageLayoutDetails.pageLayoutName , 'Case-SOXPrescriberCOI');      
    }
    @isTest
    static void testupdatedPrescriber(){
        String caseFields='';
        String caseQuery  ;
        string accountFields='';
        String accountQuery;
        
        Test.startTest(); 
        List<US_WSREMS__REMS_Service_Summary__c> remsServiceList = [SELECT Id, Name FROM US_WSREMS__REMS_Service_Summary__c WHERE RecordType.DeveloperName = 'Change_of_Information' LIMIT 1];
        List<REMSchangeOfInformation.LayoutSection> layoutInformationList =  REMSchangeOfInformation.getPageLayoutFields(remsServiceList[0].Id);
        Id parId = layoutInformationList[0].participantId;
        Map<String, String> FieldMap = layoutInformationList[0].mappingFieldsMap;
        
        
        for (String field : FieldMap.keyset()){
            caseFields += ','+field;
            accountFields += ','+ FieldMap.get(field);
            
        }
        
        caseQuery = 'Select Id  '+ caseFields+' from Case limit 1';
        accountQuery ='Select Id '+ accountFields +' from account limit 1';
        case caseCOI = new Case();
        
        for (REMSchangeOfInformation.LayoutSection sec :  layoutInformationList){
            for (REMSchangeOfInformation.LayoutField field : sec.fieldsList ){
                if (field.fieldName != null && field.fieldName !='CaseNumber' && field.fieldName != 'REMS_Project_Code__c' && field.fieldName !='CreatedById' && field.fieldName !='LastModifiedById' && field.fieldName != 'US_WSREMS__Role__c' && field.fieldName !='US_WSREMS__User_Type__c'){
                    caseCOI.put(field.fieldName , field.fieldValue);
                    caseCOI.put('OwnerId',userInfo.getUserId());
                }
                
            }
        }
        Insert caseCOI;
        
        REMSchangeOfInformation.updateParticipant(  caseCOI.id , parId ,JSON.serialize(FieldMap) );
        
        List<Account> participantObjectList = Database.query(accountQuery);
        List<Case> caseRecordList = Database.query(caseQuery ); 
        Test.stopTest();
        
    } 
}