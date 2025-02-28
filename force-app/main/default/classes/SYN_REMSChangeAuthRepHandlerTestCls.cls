@isTest
public class SYN_REMSChangeAuthRepHandlerTestCls {
    
    public static testmethod void createAffRec() {
        //REMS Program Creation
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Test Program';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        //Record Types Retrive
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        //serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        
        // Case Creation
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS'+'-Change_Authorized_Representative';
        insert caseObj;
        
        //Create Affiliation
        String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = recordTypeAffId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj;       
        
        Test.startTest();
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Complete';
        // update serviceObj; 
        Test.stopTest();
        US_WSREMS__Affiliation__c affObjRec=[select id,US_WSREMS__REMSProgram__c,US_WSREMS__REMS_Service__c,US_WSREMS__isActive__c,US_WSREMS__UserType__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__c 
                                             from US_WSREMS__Affiliation__c where US_WSREMS__REMS_Service__c=:serviceObj.Id limit 1];
        System.assert(affObjRec.Id!=null);
        
        SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutFields('Case-SYNPharmacyParticipant');
        //   SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutforRequestorType(serviceObj.Id);
        // SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutforAffiliation(serviceObj.Id);
        
    }
    /* public static testmethod void createAffRec1(){
        //REMS Program Creation
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.REMS_Project_Code__c = 'BT6825';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        //Record Types Retrive
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_of_Information').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Distributor';
        // serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        //serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        
        // Case Creation
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.SYN_User_Type__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        insert caseObj;
        
        //Create Affiliation
        String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = recordTypeAffId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj;       
        
        Test.startTest();
        serviceObj.US_WSREMS__Status__c = 'Closed';
        serviceObj.US_WSREMS__Service_Outcome__c = 'Complete';
        update serviceObj; 
        Test.stopTest();
        US_WSREMS__Affiliation__c affObjRec=[select id,US_WSREMS__REMSProgram__c,US_WSREMS__REMS_Service__c,US_WSREMS__isActive__c,US_WSREMS__UserType__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__c 
                                             from US_WSREMS__Affiliation__c where US_WSREMS__REMS_Service__c=:serviceObj.Id limit 1];
        System.assert(affObjRec.Id!=null);
        
        SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutFields('Case-SYNPharmacyParticipant');
        //   SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutforRequestorType(serviceObj.Id);
        //  SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutforAffiliation(serviceObj.Id);
        
    } */
    public static testmethod void createAffRec2(){
        //REMS Program Creation
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        //Record Types Retrive
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_of_Information').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Distributor';
        // serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        //serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        
        // Case Creation
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS'+'-Change_Authorized_Representative';
        insert caseObj;
        
        //Create Affiliation
        String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = recordTypeAffId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj;       
        
        /*Test.startTest();
serviceObj.US_WSREMS__Status__c = 'Closed';
serviceObj.US_WSREMS__Service_Outcome__c = 'Complete';
update serviceObj; 
Test.stopTest();*/
        US_WSREMS__Affiliation__c affObjRec=[select id,US_WSREMS__REMSProgram__c,US_WSREMS__REMS_Service__c,US_WSREMS__isActive__c,US_WSREMS__UserType__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__c 
                                             from US_WSREMS__Affiliation__c where US_WSREMS__REMS_Service__c=:serviceObj.Id limit 1];
        System.assert(affObjRec.Id!=null);
        
        SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutFields('Case-SYNPharmacyParticipant');
        // SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutforAffiliation(serviceObj.Id);
        SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutNameAndRecordTypeIdForChangeAuthorizedRep(serviceObj.Id);
        //	SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutforRequestorType(serviceObj.Id);
        //SYN_REMSChangeAuthorizedRepCtrl.getRelatedFieldsForPharmacy('Pharmacy_Information',accPharmObj.id);
        SYN_REMSChangeAuthorizedRepCtrl.getObjectAPIName(affObjRec.Id);
        SYN_REMSChangeAuthorizedRepCtrl.getNameSpace();
    } 
    public static testmethod void createAffRec3(){
        //REMS Program Creation
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Abecma';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        //Record Types Retrive
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_of_Information').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Patient';
        // serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        //serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        
        // Case Creation
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS'+'-Change_Authorized_Representative';
        insert caseObj;
        
        //Create Affiliation
        String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = recordTypeAffId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj;       
        
        US_WSREMS__Affiliation__c affObjRec=[select id,US_WSREMS__REMSProgram__c,US_WSREMS__REMS_Service__c,US_WSREMS__isActive__c,US_WSREMS__UserType__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__c 
                                             from US_WSREMS__Affiliation__c where US_WSREMS__REMS_Service__c=:serviceObj.Id limit 1];
        System.assert(affObjRec.Id!=null);
        
        //SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutforAffiliation(serviceObj.Id);
        
    } 
    public static testmethod void createAffRec4(){
        //REMS Program Creation
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        //Record Types Retrive
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_of_Information').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Distributor';
        // serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        //serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        
        // Case Creation
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS'+'-Change_Authorized_Representative';
        insert caseObj;
        
        //Create Affiliation
        String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = recordTypeAffId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj;       
        
        US_WSREMS__Affiliation__c affObjRec=[select id,US_WSREMS__REMSProgram__c,US_WSREMS__REMS_Service__c,US_WSREMS__isActive__c,US_WSREMS__UserType__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__c 
                                             from US_WSREMS__Affiliation__c where US_WSREMS__REMS_Service__c=:serviceObj.Id limit 1];
        System.assert(affObjRec.Id!=null);
        
        SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutforRequestorType(serviceObj.Id);
        
    }
    public static testmethod void createAffRec5(){
        //REMS Program Creation
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Abecma';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        //Record Types Retrive
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_of_Information').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Patient';
        // serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        //serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        
        // Case Creation
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS'+'-Change_Authorized_Representative';
        insert caseObj;
        
        //Create Affiliation
        String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = recordTypeAffId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj;       
        
        US_WSREMS__Affiliation__c affObjRec=[select id,US_WSREMS__REMSProgram__c,US_WSREMS__REMS_Service__c,US_WSREMS__isActive__c,US_WSREMS__UserType__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__c 
                                             from US_WSREMS__Affiliation__c where US_WSREMS__REMS_Service__c=:serviceObj.Id limit 1];
        System.assert(affObjRec.Id!=null);
        
      //  SYN_REMSChangeAuthorizedRepCtrl.getPageLayoutforAffiliation(serviceObj.Id);
        
    } 
    public static testmethod void createAffRec6(){
        //REMS Program Creation
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        //Record Types Retrive
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_of_Information').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Distributor';
        // serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        //serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        
        // Case Creation
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS'+'-Change_Authorized_Representative';
        insert caseObj;
        
        //Create Affiliation
        String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = recordTypeAffId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj;       
        
        US_WSREMS__Affiliation__c affObjRec=[select id,US_WSREMS__REMSProgram__c,US_WSREMS__REMS_Service__c,US_WSREMS__isActive__c,US_WSREMS__UserType__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__c 
                                             from US_WSREMS__Affiliation__c where US_WSREMS__REMS_Service__c=:serviceObj.Id limit 1];
        System.assert(affObjRec.Id!=null);
        List<SYN_REMSChangeAuthorizedRepCtrl.LayoutField> s1 = new List<SYN_REMSChangeAuthorizedRepCtrl.LayoutField>();
        
        SYN_REMSChangeAuthorizedRepCtrl.LayoutField s = new SYN_REMSChangeAuthorizedRepCtrl.LayoutField();
        s.fieldName = 'FirstName';
        s.isRequired =false;
        s.isReadOnly  =true;
        s.fieldValue = 'Test';
        s.isInputReadOnly = true;
        s1.add(s);   
        SYN_REMSChangeAuthorizedRepCtrl.LayoutSection  l1 = new SYN_REMSChangeAuthorizedRepCtrl.LayoutSection();
        List<SYN_REMSChangeAuthorizedRepCtrl.LayoutSection>l2 = new List<SYN_REMSChangeAuthorizedRepCtrl.LayoutSection>();
        l1.label = 'SYNPharmacyParticipant';
        l1.totalColumns = 1;
        l1.onchange='';
        l1.lstFields = s1;
        l2.add(l1);
        
        // String s2 = '[{"label":"SYNPharmacyParticipant","lstFields":"'+ l2 +'"}]'; 
        SYN_REMSChangeAuthorizedRepCtrl.getRelatedFieldsForPharmacyUser(JSON.serialize(l2),accPharmUserObj.Id,false,serviceObj.Id);
        
    } 
    public static testmethod void createAffRec7(){
        //REMS Program Creation
        US_WSREMS__REMS_Program__c pgrmObj = new US_WSREMS__REMS_Program__c();
        pgrmObj.Name = 'Sodium Oxybate REMS';
        pgrmObj.US_WSREMS__Status__c ='Active';
        pgrmObj.US_WSREMS__Program_State_Date__c = System.today();
        pgrmObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert pgrmObj;
        
        //Record Types Retrive
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  pgrmObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;
        
        //Pharmacy user Account Creation
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        //accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = pgrmObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
        //REMS Service Creation
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_of_Information').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = pgrmObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Distributor';
        // serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
        //serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        
        // Case Creation
        String recordTypeCaseId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.US_WSREMS__REMS_Program__c = serviceObj.US_WSREMS__REMSProgram__c;
        CaseObj.US_WSREMS__REMS_Service_Summary__c=serviceObj.Id;
        caseObj.US_WSREMS__UserType__c='Pharmacy Staff;Authorized Representative';
        caseObj.US_WSREMS__Email__c= accPharmUserObj.PersonEmail;
        caseObj.US_WSREMS__Phone__c= accPharmUserObj.Phone;
        caseObj.US_WSREMS__Pharmacy_User__c = accPharmUserObj.Id;
        caseObj.US_WSREMS__Pharmacy_User_ar__c = accPharmUserObj.Id;
        caseObj.RecordTypeId = recordTypeCaseId;
        caseObj.US_WSREMS__Start_Date__c=System.today();
        caseObj.US_WSREMS__End_Date__c=System.today().addDays(20);
        caseObj.Program_Record_Type_Control__c = 'Sodium Oxybate REMS'+'-Change_Authorized_Representative';
        insert caseObj;
        
        //Create Affiliation
        String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = recordTypeAffId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj;       
        
        US_WSREMS__Affiliation__c affObjRec=[select id,US_WSREMS__REMSProgram__c,US_WSREMS__REMS_Service__c,US_WSREMS__isActive__c,US_WSREMS__UserType__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__c 
                                             from US_WSREMS__Affiliation__c where US_WSREMS__REMS_Service__c=:serviceObj.Id limit 1];
        System.assert(affObjRec.Id!=null);
        List<SYN_REMSChangeAuthorizedRepCtrl.LayoutField> s1 = new List<SYN_REMSChangeAuthorizedRepCtrl.LayoutField>();
        
        SYN_REMSChangeAuthorizedRepCtrl.LayoutField s = new SYN_REMSChangeAuthorizedRepCtrl.LayoutField();
        s.fieldName = 'FirstName';
        s.isRequired =false;
        s.isReadOnly  =true;
        s.fieldValue = 'Test';
        s.isInputReadOnly = true;
        s1.add(s);   
        SYN_REMSChangeAuthorizedRepCtrl.LayoutSection  l1 = new SYN_REMSChangeAuthorizedRepCtrl.LayoutSection();
        List<SYN_REMSChangeAuthorizedRepCtrl.LayoutSection>l2 = new List<SYN_REMSChangeAuthorizedRepCtrl.LayoutSection>();
        l1.label = 'SYNPharmacyParticipant';
        l1.totalColumns = 1;
        l1.onchange='';
        l1.lstFields = s1;
        l2.add(l1);
        
        // String s2 = '[{"label":"SYNPharmacyParticipant","lstFields":"'+ l2 +'"}]'; 
        SYN_REMSChangeAuthorizedRepCtrl.getRelatedFieldsForPharmacy(JSON.serialize(l2),accPharmUserObj.Id);
        
    }
    public static testmethod void createAffRec8() {
        SYN_REMSChangeAuthorizedRepUtilityCls.retrieveRecTypeNameId('REMS_Program__c');
    }
	
    
  
}