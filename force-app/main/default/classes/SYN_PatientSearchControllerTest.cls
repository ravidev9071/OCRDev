@isTest
public  class SYN_PatientSearchControllerTest {
    
    public static testMethod void testMethod1() {
        
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Syneos Phase2';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        List<Account> accountList = new List<Account>();
        
        
        for(Integer i = 0; i<10;i++){
            Account acc=new Account();
            acc.LastName='TestAccount';
            acc.FirstName='TestAccountFN';
            acc.Phone ='1234567890';
            acc.US_WSREMS__REMS_Program__c = programObj.Id;
            acc.recordTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            accountList.add(acc);
        }
        insert accountList;
        
        US_WSREMS__REMS_Program__c rp=new US_WSREMS__REMS_Program__c();
        rp.name='Sodium Oxybate REMS';
        rp.REMS_Project_Code__c = 'BT6825';
        insert rp;
        
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  programObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;   
        
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
       // serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        Id patientAffiliationRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Patient_Affiliation').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = programObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
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
        
        // String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = patientAffiliationRecordTypeId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj; 
        
        SYN_PatientSearchController.searchAccounts(true,false,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
       // SYN_PatientSearchController.searchAccounts(true,true,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
      // SYN_PatientSearchController.searchAccounts(false,true,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
        SYN_PatientSearchController.accountDataForCompactLayout(accPharmUserObj.Id);
        SYN_PatientSearchController.displayCaseRecs('','Createddate','asc','Patient');
    }
     public static testMethod void testMethod2() {
        
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Syneos Phase2';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        List<Account> accountList = new List<Account>();
        
        
        for(Integer i = 0; i<10;i++){
            Account acc=new Account();
            acc.LastName='TestAccount';
            acc.FirstName='TestAccountFN';
            acc.Phone ='1234567890';
            acc.US_WSREMS__REMS_Program__c = programObj.Id;
            acc.recordTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            accountList.add(acc);
        }
        insert accountList;
        
        US_WSREMS__REMS_Program__c rp=new US_WSREMS__REMS_Program__c();
        rp.name='Sodium Oxybate REMS';
        insert rp;
        
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  programObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;   
        
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
       // serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        Id patientAffiliationRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Patient_Affiliation').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = programObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
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
        
        // String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = patientAffiliationRecordTypeId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj; 
        
        SYN_PatientSearchController.searchAccounts(true,false,'','test','31/07/1990','1234567890','560100','FirstName','asc');
       // SYN_PatientSearchController.searchAccounts(true,true,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
      // SYN_PatientSearchController.searchAccounts(false,true,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
        SYN_PatientSearchController.accountDataForCompactLayout(accPharmUserObj.Id);
        SYN_PatientSearchController.displayCaseRecs('','Createddate','asc','Patient');
    }
      public static testMethod void testMethod3() {
        
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Syneos Phase2';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        List<Account> accountList = new List<Account>();
        
        
        for(Integer i = 0; i<10;i++){
            Account acc=new Account();
            acc.LastName='TestAccount';
            acc.FirstName='TestAccountFN';
            acc.Phone ='1234567890';
            acc.US_WSREMS__REMS_Program__c = programObj.Id;
            acc.recordTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            accountList.add(acc);
        }
        insert accountList;
        
        US_WSREMS__REMS_Program__c rp=new US_WSREMS__REMS_Program__c();
        rp.name='Sodium Oxybate REMS';
        insert rp;
        
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  programObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;   
        
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
       // serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        Id patientAffiliationRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Patient_Affiliation').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = programObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
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
        
        // String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = patientAffiliationRecordTypeId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj; 
        
        SYN_PatientSearchController.searchAccounts(true,false,'','','31/07/1990','1234567890','560100','FirstName','asc');
       // SYN_PatientSearchController.searchAccounts(true,true,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
      // SYN_PatientSearchController.searchAccounts(false,true,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
        SYN_PatientSearchController.accountDataForCompactLayout(accPharmUserObj.Id);
        SYN_PatientSearchController.displayCaseRecs('','Createddate','asc','Patient');
    }
      public static testMethod void testMethod4() {
        
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Syneos Phase2';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        List<Account> accountList = new List<Account>();
        
        
        for(Integer i = 0; i<10;i++){
            Account acc=new Account();
            acc.LastName='TestAccount';
            acc.FirstName='TestAccountFN';
            acc.Phone ='1234567890';
            acc.US_WSREMS__REMS_Program__c = programObj.Id;
            acc.recordTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            accountList.add(acc);
        }
        insert accountList;
        
        US_WSREMS__REMS_Program__c rp=new US_WSREMS__REMS_Program__c();
        rp.name='Sodium Oxybate REMS';
        insert rp;
        
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  programObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;   
        
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
       // serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        Id patientAffiliationRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Patient_Affiliation').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = programObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
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
        
        // String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = patientAffiliationRecordTypeId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj; 
        
        SYN_PatientSearchController.searchAccounts(true,false,'','','','1234567890','560100','FirstName','asc');
       // SYN_PatientSearchController.searchAccounts(true,true,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
      // SYN_PatientSearchController.searchAccounts(false,true,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
        SYN_PatientSearchController.accountDataForCompactLayout(accPharmUserObj.Id);
        SYN_PatientSearchController.displayCaseRecs('','Createddate','asc','Patient');
    }
    
     public static testMethod void testMethod5() {
        
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Syneos Phase2';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        List<Account> accountList = new List<Account>();
        
        
        for(Integer i = 0; i<10;i++){
            Account acc=new Account();
            acc.LastName='TestAccount';
            acc.FirstName='TestAccountFN';
            acc.Phone ='1234567890';
            acc.US_WSREMS__REMS_Program__c = programObj.Id;
            acc.recordTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            accountList.add(acc);
        }
        insert accountList;
        
        US_WSREMS__REMS_Program__c rp=new US_WSREMS__REMS_Program__c();
        rp.name='Sodium Oxybate REMS';
        insert rp;
        
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  programObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;   
        
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
       // serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        Id patientAffiliationRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Patient_Affiliation').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = programObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
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
        
        // String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = patientAffiliationRecordTypeId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj; 
        
        SYN_PatientSearchController.searchAccounts(true,false,'','','','','560100','FirstName','asc');
       // SYN_PatientSearchController.searchAccounts(true,true,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
      // SYN_PatientSearchController.searchAccounts(false,true,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
        SYN_PatientSearchController.accountDataForCompactLayout(accPharmUserObj.Id);
        SYN_PatientSearchController.displayCaseRecs('','Createddate','asc','Patient');
    }
    
    /* public static testMethod void testMethod2() {
        
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Syneos Phase2';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        List<Account> accountList = new List<Account>();
        
        
        for(Integer i = 0; i<10;i++){
            Account acc=new Account();
            acc.LastName='TestAccount';
            acc.FirstName='TestAccountFN';
            acc.Phone ='1234567890';
            acc.US_WSREMS__REMS_Program__c = programObj.Id;
            acc.recordTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            accountList.add(acc);
        }
        insert accountList;
        
        US_WSREMS__REMS_Program__c rp=new US_WSREMS__REMS_Program__c();
        rp.name='Sodium Oxybate REMS';
        insert rp;
        
        String recordTypePharmacyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        
        //Pharmacy Account Creation
        Account accPharmObj = new Account();
        accPharmObj.Name = 'Test Pharmacy'; 
        //accPharmObj.US_WSREMS__Status__c = 'Active'; 
        accPharmObj.US_WSREMS__REMS_Program__c =  programObj.Id;
        accPharmObj.RecordTypeId = recordTypePharmacyId;      
        insert accPharmObj;   
        
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_Authorized_Representative').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.Id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Pharmacy';
        serviceObj.US_WSREMS__Participant__c = accPharmObj.Id;
       // serviceObj.US_WSREMS__Status__c = 'In Progress';
        serviceObj.recordTypeId = recordTypeId;
        insert serviceObj;
        Id patientAffiliationRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Patient_Affiliation').getRecordTypeId();
        String recordTypePharmacyUserId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy_User').getRecordTypeId();
        
        Account accPharmUserObj = new Account();
        accPharmUserObj.FirstName= 'Test';
        accPharmUserObj.LastName = 'Pharmacy User';
        accPharmUserObj.US_WSREMS__Status__c = 'Active'; 
        accPharmUserObj.PersonEmail= 'abc@gmail.com';
        accPharmUserObj.Phone='9685748572';
        accPharmUserObj.US_WSREMS__REMS_Program__c = programObj.Id;
        accPharmUserObj.RecordTypeId = recordTypePharmacyUserId;
        insert accPharmUserObj;
        
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
        insert caseObj;
        
        // String recordTypeAffId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c affObj = new US_WSREMS__Affiliation__c();
        affObj.US_WSREMS__REMS_Service__c = serviceObj.Id;
        affObj.US_WSREMS__REMSProgram__c = serviceObj.US_WSREMS__REMSProgram__c;
        affObj.RecordTypeId = patientAffiliationRecordTypeId;
        affObj.US_WSREMS__isActive__c=True;
        affObj.US_WSREMS__End_Date__c = null;
        affObj.US_WSREMS__Start_Date__c = System.today();
        affObj.US_WSREMS__Pharmacy__c = serviceObj.US_WSREMS__Participant__c;
        affObj.US_WSREMS__Pharmacy_User__c = caseObj.US_WSREMS__Pharmacy_User_ar__c;
        affObj.US_WSREMS__UserType__c = caseObj.US_WSREMS__UserType__c;
        insert affObj; 
        
       // SYN_PatientSearchController.searchAccounts(true,false,'test','test','31/07/1990','1234567890','560100','FirstName','asc');
                SYN_PatientSearchController.searchAccounts(true,false,'','','','','','FirstName','asc');

    }*/
}