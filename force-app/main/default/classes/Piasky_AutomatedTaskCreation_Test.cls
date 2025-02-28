@isTest
public class Piasky_AutomatedTaskCreation_Test {
    
    public static final String nameSpacePrefix = REMSAppLiterals.NAMESPACE_STRING.removeEnd('__');
    
    @isTest
    static void nonComplianceCaseInsert(){
        Id recordTypeId = [SELECT Id FROM RecordType WHERE NamespacePrefix =:nameSpacePrefix AND SobjectType = :REMSAppLiterals.ACCOUNT_OBJECT AND DeveloperName = 'Prescriber' LIMIT 1].Id;       
        
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
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
            
            US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
            serviceObj.US_WSREMS__REMSProgram__c = programList[0].Id;
            serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
            serviceObj.recordTypeId = SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('PAE_PC_MI').getRecordTypeId();
            serviceObj.US_WSREMS__Participant__c  = accountObj.Id;
            insert serviceObj;
            
            Case caseRec = new Case();
            caseRec.recordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
            caseRec.US_WSREMS__First_Name__c = recordData.firstName;
            caseRec.US_WSREMS__Last_Name__c = recordData.lastName;
            caseRec.US_WSREMS__Fax__c = recordData.fax;
            caseRec.US_WSREMS__Phone__c = recordData.phone;
            caseRec.US_WSREMS__NPI__c = recordData.npi;
            caseRec.US_WSREMS__REMS_ID__c = accountObj.US_WSREMS__REMS_ID__c;
            caseRec.Status = 'Draft';
            caseRec.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
            caseRec.US_WSREMS__Participant__c = accountObj.Id;
            caseRec.US_WSREMS__Program_Picklist__c = programList.size() > 0 ? programList[0].Name : null;
            caseRec.US_WSREMS__REMS_Service_Summary__c = serviceObj.Id;
            
            insert caseRec;
            
            caseRec.US_WSREMS__Outcome__c = 'Suspected Non-compliance activity';
            update caseRec;
            
            caseRec.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
            update caseRec;
            
        }
        
    }
    
    @isTest
    static void paeCaseInsert(){
        Id recordTypeId = [SELECT Id FROM RecordType WHERE NamespacePrefix =:nameSpacePrefix AND SobjectType = :REMSAppLiterals.ACCOUNT_OBJECT AND DeveloperName = 'Prescriber' LIMIT 1].Id;       
        
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
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
            
            US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
            serviceObj.US_WSREMS__REMSProgram__c = programList[0].Id;
            serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
            serviceObj.recordTypeId = SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('PAE_PC_MI').getRecordTypeId();
            serviceObj.US_WSREMS__Participant__c  = accountObj.Id;
            insert serviceObj;
            
            Case caseRec = new Case();
            caseRec.recordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PAE').getRecordTypeId();
            caseRec.US_WSREMS__First_Name__c = recordData.firstName;
            caseRec.US_WSREMS__Last_Name__c = recordData.lastName;
            caseRec.US_WSREMS__Fax__c = recordData.fax;
            caseRec.US_WSREMS__Phone__c = recordData.phone;
            caseRec.US_WSREMS__NPI__c = recordData.npi;
            caseRec.US_WSREMS__REMS_ID__c = accountObj.US_WSREMS__REMS_ID__c;
            caseRec.Status = 'Draft';
            caseRec.US_WSREMS__Outcome__c = null;
            caseRec.US_WSREMS__Participant__c = accountObj.Id;
            caseRec.US_WSREMS__Program_Picklist__c = programList.size() > 0 ? programList[0].Name : null;
            caseRec.US_WSREMS__REMS_Service_Summary__c = serviceObj.Id;
            caseRec.US_WSREMS__Channel__c = 'Fax';
            caseRec.Program_Record_Type_Control__c = 'AVEED-PAE';
            
            insert caseRec;
            
            caseRec.Status = 'Sent to Sponsor';
            update caseRec;
           
        }
        
    }
    
     @isTest
    static void Deactivationcaseinsert(){ 
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        programList[0].Name = 'AVEED REMS';
        update programList;
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
            
            US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
            serviceObj.US_WSREMS__REMSProgram__c = programList[0].Id;
            serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
            serviceObj.recordTypeId = SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Deactivation').getRecordTypeId();
            serviceObj.US_WSREMS__Participant__c  = accountObj.Id;
            insert serviceObj;
            
            Case caseRec = new Case();
            caseRec.recordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deactivation').getRecordTypeId();
            caseRec.US_WSREMS__First_Name__c = recordData.firstName;
            caseRec.US_WSREMS__Last_Name__c = recordData.lastName;
            caseRec.US_WSREMS__Fax__c = recordData.fax;
            caseRec.US_WSREMS__Phone__c = recordData.phone;
            caseRec.US_WSREMS__NPI__c = recordData.npi;
            caseRec.US_WSREMS__REMS_ID__c = accountObj.US_WSREMS__REMS_ID__c;
            caseRec.Status = 'Draft';
            caseRec.US_WSREMS__Outcome__c = null;
            caseRec.US_WSREMS__Participant__c = accountObj.Id;
            caseRec.US_WSREMS__Program_Picklist__c = programList.size() > 0 ? programList[0].Name : null;
            caseRec.US_WSREMS__REMS_Service_Summary__c = serviceObj.Id;
           caseRec.Program_Record_Type_Control__c = 'AVEED-PAE';
            caseRec.US_WSREMS__Channel__c = 'Fax'; 
            insert caseRec;
        }
    }
    
    public static List<US_WSREMS__REMS_Program__c> createPrograms(integer noOfRecords,boolean isCreate){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = 'PiaSky REMS';
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
    
     @isTest
    static void checkDeactivatedAcc(){
        Test.startTest();
        List<Case> newCaseList = New List<Case>();
        Map<Id, Case> mappedCase = New Map<Id, Case>();
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        
        //Record Types Retrive
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inpatient_Pharmacy_Account').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  programList[0].Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.Name = 'Test 123';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.Phone='9685748572';
        //accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj[0].Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;        
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
            US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
            serviceObj.US_WSREMS__REMSProgram__c = programList[0].Id;
            serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
            serviceObj.recordTypeId = SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('PAE_PC_MI').getRecordTypeId();
            serviceObj.US_WSREMS__Participant__c  = accountObj.Id;
            insert serviceObj;
            
            //Create Affiliation
            
            String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Prescriber_Affiliation').getRecordTypeId();
            US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
            affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
            affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
            affObj.RecordTypeId = recordTypeAffId;
            affObj.US_WSREMS__isActive__c=True;
            affObj.US_WSREMS__End_Date__c = null;
            affObj.US_WSREMS__Start_Date__c = System.today();
            //affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
            //affObj.US_WSREMS__Pharmacy_User__c = caseRec.US_WSREMS__Pharmacy_User_ar__c;
            //affObj.US_WSREMS__UserType__c = caseRec.US_WSREMS__UserType__c;
            affObj.US_WSREMS__Office_Contact__c = accPharmUserObj.Id;
            affObj.US_WSREMS__Health_Care_Setting__c = accPharmUserObj.Id;
            affObj.RecordTypeId = recordTypeAffId;
            insert affObj; 
            
            Case caseRec = new Case();
            caseRec.recordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
            caseRec.US_WSREMS__First_Name__c = recordData.firstName;
            caseRec.US_WSREMS__Last_Name__c = recordData.lastName;
            caseRec.US_WSREMS__Fax__c = recordData.fax;
            caseRec.US_WSREMS__Phone__c = recordData.phone;
            caseRec.US_WSREMS__NPI__c = recordData.npi;
            caseRec.US_WSREMS__REMS_ID__c = accountObj.US_WSREMS__REMS_ID__c;
            caseRec.Status = 'Draft';
            caseRec.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
            caseRec.US_WSREMS__Participant__c = accountObj.Id;
            caseRec.US_WSREMS__Program_Picklist__c = programList.size() > 0 ? programList[0].Name : null;
            caseRec.US_WSREMS__REMS_Service_Summary__c = serviceObj.Id;
            insert caseRec;
            caseRec.US_WSREMS__Outcome__c = 'Suspected Non-compliance activity';
            update caseRec;
            caseRec.US_WSREMS__Outcome__c = 'Confirmed Non-compliance activity';
            update caseRec;
        
           
                         
            newCaseList.add(caseRec);
            mappedCase.put(accPharmUserObj.id, caseRec);
            
            Piasky_AutomatedTaskCreation.checkDeactivatedAcc(mappedCase,'Prescriber Affiliation','PiaSky REMS');
        	String recordTypeAffph = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_Affiliation').getRecordTypeId();
       		affObj.RecordTypeId = recordTypeAffph;
        	update affObj;
        	Piasky_AutomatedTaskCreation.checkDeactivatedAcc(mappedCase,'Pharmacy Affiliation','PiaSky REMS');
        }
        
        Test.stopTest();
    }
 
    
}