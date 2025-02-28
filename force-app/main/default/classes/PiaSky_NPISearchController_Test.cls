@isTest
public class PiaSky_NPISearchController_Test {

    public static final String nameSpacePrefix = REMSAppLiterals.NAMESPACE_STRING.removeEnd('__');
    
    @isTest
    static void caseInsert(){
        String PATICIPANT_USER_PROFILE_NAME = 'Portal Stakeholder Profile';
        Id recordTypeId = [SELECT Id FROM RecordType WHERE NamespacePrefix =:nameSpacePrefix AND SobjectType = :REMSAppLiterals.ACCOUNT_OBJECT AND DeveloperName = 'Prescriber' LIMIT 1].Id;       
            
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true, 'PiaSky REMS');
        if (programList != null && programList.size() > 0) {
            Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriber('0909876545',12345678,'1234567896',true, programList[0].Id );
            PiaSky_NPISearchControllerPortal.RecordDataWrapper recordData = new PiaSky_NPISearchControllerPortal.RecordDataWrapper();
            recordData.npi = '1234567890';
            recordData.fax = '1234567890';
            recordData.phone = '1234567890';
            recordData.email = 'testsa1233@abc.com';
            recordData.lastName = 'testLast';
            recordData.middleName = 'middle';
            recordData.firstName = 'first';
            String programName = programList[0].Name;
            String participantType = 'Prescriber';
            
            List<Case> caseList = new List<Case>();
            
            Case caseRec = new Case();
            caseRec.recordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
            caseRec.US_WSREMS__First_Name__c = recordData.firstName;
            caseRec.US_WSREMS__Middle_Name__c = recordData.middleName;
            caseRec.US_WSREMS__Last_Name__c = recordData.lastName;
            caseRec.US_WSREMS__Fax__c = recordData.fax;
            caseRec.US_WSREMS__Participant_Fax__c = recordData.fax;
            caseRec.US_WSREMS__REMS_Alternate_Phone__c = recordData.phone;
            caseRec.US_WSREMS__Email__c = recordData.email;
            caseRec.US_WSREMS__Email_ar__c = recordData.email;
            caseRec.US_WSREMS__Phone__c = recordData.phone;
            caseRec.US_WSREMS__NPI__c = recordData.npi;
            caseRec.US_WSREMS__REMS_ID__c = accountObj.US_WSREMS__REMS_ID__c;
            caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
            caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            caseRec.US_WSREMS__Participant__c = accountObj.Id;
            caseRec.US_WSREMS__Program_Picklist__c = programList.size() > 0 ? programList[0].Name : null;
            caseRec.Program_Record_Type_Control__c='PiaSky REMS-Inpatient_Pharmacy_Enrollment';
            caseList.add(caseRec);
            insert caseList;
            
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new SYN_VeevaAPIAuthJSON_MockCall());
            Map<Id,Case> oldmap = new Map<Id,Case>();
            PiaSky_NPISearchController.NPIvalidationPiasky(caseList,oldmap,false);
            Test.StopTest();            
            caseRec.US_WSREMS__NPI__c = '2874256782';
            update caseRec;     
        }
    }

    @isTest
    static void caseInsertTryvio(){
        String PATICIPANT_USER_PROFILE_NAME = 'Portal Stakeholder Profile';
        Id recordTypeId = [SELECT Id FROM RecordType WHERE NamespacePrefix =:nameSpacePrefix AND SobjectType = :REMSAppLiterals.ACCOUNT_OBJECT AND DeveloperName = 'Prescriber' LIMIT 1].Id;       
            
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true, 'TRYVIO REMS');
        if (programList != null && programList.size() > 0) {
            Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriber('0909876545',12345678,'1234567896',true, programList[0].Id );
            PiaSky_NPISearchControllerPortal.RecordDataWrapper recordData = new PiaSky_NPISearchControllerPortal.RecordDataWrapper();
            recordData.npi = '1234567890';
            recordData.fax = '1234567890';
            recordData.phone = '1234567890';
            recordData.email = 'testsa1233@abc.com';
            recordData.lastName = 'testLast';
            recordData.middleName = 'middle';
            recordData.firstName = 'first';
            String programName = programList[0].Name;
            String participantType = 'Prescriber';
            
            List<Case> caseList = new List<Case>();
            
            Case caseRec = new Case();
            caseRec.recordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
            caseRec.US_WSREMS__First_Name__c = recordData.firstName;
            caseRec.US_WSREMS__Middle_Name__c = recordData.middleName;
            caseRec.US_WSREMS__Last_Name__c = recordData.lastName;
            caseRec.US_WSREMS__Fax__c = recordData.fax;
            caseRec.US_WSREMS__Participant_Fax__c = recordData.fax;
            caseRec.US_WSREMS__REMS_Alternate_Phone__c = recordData.phone;
            caseRec.US_WSREMS__Email__c = recordData.email;
            caseRec.US_WSREMS__Email_ar__c = recordData.email;
            caseRec.US_WSREMS__Phone__c = recordData.phone;
            caseRec.US_WSREMS__NPI__c = recordData.npi;
            caseRec.US_WSREMS__REMS_ID__c = accountObj.US_WSREMS__REMS_ID__c;
            caseRec.Status = REMSAppLiterals.CASE_STATUS_COMPLETED;
            caseRec.US_WSREMS__Outcome__c = REMSAppLiterals.CASE_OUTCOME;
            caseRec.US_WSREMS__Participant__c = accountObj.Id;
            caseRec.US_WSREMS__Channel__c = '';
            caseRec.US_WSREMS__Program_Picklist__c = programList.size() > 0 ? programList[0].Name : null;
            caseRec.Program_Record_Type_Control__c='TRYVIO REMS-Prescriber_enrollment';
            caseList.add(caseRec);
            insert caseList;
            
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new SYN_VeevaAPIAuthJSON_MockCall());
            Map<Id,Case> oldmap = new Map<Id,Case>();
            PiaSky_NPISearchController.NPIvalidationPiasky(caseList,oldmap,false);
            Test.StopTest();            
            caseRec.US_WSREMS__NPI__c = '2874256782';
            update caseRec;     
        }
    }
    
    public static List<US_WSREMS__REMS_Program__c> createPrograms(integer noOfRecords,boolean isCreate, String ProgramName){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = ProgramName; //'PiaSky REMS';
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