/**************************************************************************
    * Name :   MaciPortalCustomController_Test
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  30/11/2022             Initial Version
    *********************************************************************************/

    @isTest
    public class SYN_PortalEnrollmentControllerTest {
        
        @isTest
        public static void createPrescriberEnrollment_MaciPortal_Test() {
             // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account acc;
            Test.StartTest();
            System.runAs (communitydefaulowner) {
            
                // Create Prescriber Account
                acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
                
                // Create a protal user 
                usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Prescriber');
            }
            
            system.runAs(usr){
            
                // Covering code coverage for MaciPortalCustomController method
                User u = SYN_PortalEnrollmentController.getCurrentUserType();
                System.Assert(U != null);
                
                // Covering code coverage for getCurrentUserAccountInfo method 
                Account acct = SYN_PortalEnrollmentController.getCurrentUserAccountInfo();
                System.Assert(acct != null);
                
                // Covering code coverage for reSendConfimarionEmail method
               SYN_PortalEnrollmentController.prescriberEnrollment(acc,'Signed','test');
                
                // Covering code coverage for getOCAssociatedPrescriberList method
               SYN_PortalEnrollmentController.getOCAssociatedPrescriberList(acc);
                
                // covering code coverage for getPrescriberAssociatedOCList method
               SYN_PortalEnrollmentController.getPrescriberAssociatedOCList();
                
                // covering code for calculateAge method
               SYN_PortalEnrollmentController.calculateAge(Date.today());
               
            }
               
            Test.StopTest();
        
        }
    
         @isTest
        public static void createOfficeContactEnrollment_MaciPortal_Test() {
             // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }        
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account acc;
            Test.StartTest();
            System.runAs (communitydefaulowner) {
            
                // Create Prescriber Account
                acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
                
                // Create a protal user 
                usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Office Contact');
            }
            
            system.runAs(usr){
            
                // Covering code coverage for MaciPortalCustomController method
                User u = SYN_PortalEnrollmentController.getCurrentUserType();
                System.Assert(U != null);
                
                // Covering code coverage for getCurrentUserAccountInfo method 
                Account acct = SYN_PortalEnrollmentController.getCurrentUserAccountInfo();
                System.Assert(acct != null);
                
                // Covering code coverage for reSendConfimarionEmail method
               SYN_PortalEnrollmentController.prescriberEnrollment(acc,'Signed','test');
                
                // Covering code coverage for getOCAssociatedPrescriberList method
               SYN_PortalEnrollmentController.getOCAssociatedPrescriberList(acc);
                
                // covering code coverage for getPrescriberAssociatedOCList method
               SYN_PortalEnrollmentController.getPrescriberAssociatedOCList();
                
                // covering code for calculateAge method
               SYN_PortalEnrollmentController.calculateAge(Date.today());
                
               SYN_PortalEnrollmentController.updateInPatientAuthorizedRepresentativeInfoOnAccount(acc);
               
                        // Creating Rems Program
            US_WSREMS__REMS_Program__c programObjs = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
                
                SYN_PortalEnrollmentController.getAllPatients(programObjs.Id,acc);
            }
               
            Test.StopTest();
        
        }
       
        
        @isTest
        public static void createPharmacyAccountAndPharmacyenrollment_MaciPortalTest() {
            
            Id RecordTypeIdPhPa = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy Participant').getRecordTypeId();
            Id pharmCOutPatCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Outpatient_Pharmacy').getRecordTypeId();
            Id pharmCAccCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Account').getRecordTypeId();
            // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account acc;
            
            Test.StartTest();
            
            System.runAs (communitydefaulowner) {
            
                // Create Prescriber Account
                acc = SYN_TestDataUtility.createPharmacyParticipantAccountTest(programObj.Id,RecordTypeIdPhPa);
                
                // Create a protal user 
                usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Pharmacy');
            }
            
            system.runAs(usr){
            
                // Covering code coverage for MaciPortalCustomController method
                User u = SYN_PortalEnrollmentController.getCurrentUserType();
                System.Assert(U != null);
                
                // Covering code coverage for getCurrentUserAccountInfo method 
                Account acct = SYN_PortalEnrollmentController.getCurrentUserAccountInfo();
                System.Assert(acct != null);
                //Case pharmcCase = SYN_PortalEnrollmentController.createOutPatientPharmacyInfoObj(Id programObjId,Id recordTypeId, String ProgramName);
                //Case pharmcCase = SYN_TestDataUtility.createPharmacyEnrollmentCaseInfo(programObj.Id,pharmCAccCaseRecTypeId,programObj.Name);
                 Case pharmcCase = New Case(RecordTypeId = pharmCAccCaseRecTypeId,US_WSREMS__NPI__c = '5454545656', US_WSREMS__Name__c ='Test PharmC',
                                           US_WSREMS__Program_Picklist__c = 'Macitentan REMS',US_WSREMS__Channel__c='Portal',
                                           US_WSREMS__REMS_Program__c = programObj.Id,Pharmacy_Type__c = 'Outpatient',US_WSREMS__Address_Line_1__c = 'Add1',
                                          US_WSREMS__City__c = 'NY',US_WSREMS__State__c='AL',US_WSREMS__REMS_Zip_Code__c='10004',US_WSREMS__Phone__c='9998888888',
                                          US_WSREMS__Fax__c='9998887777');
                // Covering code coverage for reSendConfimarionEmail method
               //SYN_PortalEnrollmentController.prescriberEnrollment(acc,'Signed','test');
               Test.setMock(HttpCalloutMock.class, new API_ResponseMock());
                SYN_PortalEnrollmentController.pharmacyAccountCreationAndEnrollment('SYN_Outpatient_Pharmacy',pharmcCase,acc,'Signed', 'test');
                          // covering code for getCaseRecord method
              // SYN_PortalEnrollmentController.getCaseRecord(pharmcCase.id);
               SYN_PortalEnrollmentController.createPatientReEnrollment(pharmcCase,programObj.Id);
            }
               
            Test.StopTest();
        
        }
        
       @isTest
        public static void createPatientEnrollment_MaciPortal_Test() {
             // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account acc;
            Test.StartTest();
            System.runAs (communitydefaulowner) {
            
                // Create Prescriber Account
                acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
                
                // Create a protal user 
                usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Prescriber');
          
                Case patientCase = SYN_TestDataUtility.createPatientEnrollmentCase(programObj.id,'Macitentan REMS');
            
                // Covering code coverage for MaciPortalCustomController method
                String recordId= SYN_PortalEnrollmentController.patientEnrollment(patientCase,patientCase,acc,acc.US_WSREMS__NPI__c,false);
                Map<String,String> stateMap = SYN_PortalEnrollmentController.getStates();
                System.Assert(!stateMap.isEmpty());
                String tempId=SYN_TestDataUtility.createEmailTemplate('subject','Body','text');
                EmailTemplate temp=[SELECT Id,Name,DeveloperName,Subject,Description,HtmlValue,Body FROM EmailTemplate WHERE Id =:tempId];
    
                SYN_PortalEnrollmentController.getCaseDetails(patientCase.id);
                SYN_PortalEnrollmentController.getAllPatients(programObj.id,acc);
                 SYN_PortalEnrollmentController.sendEmailToPresciberForSignature(patientCase.id,temp.name,'Patient');
                // SYN_PortalEnrollmentController.getSelectedPatientInfo('Macitentan REMS', acc.Id, acc);
            }
               
            Test.StopTest();
        
        }
        
        @isTest
        public static void createPatientEnrollment_ManagePatientTest() {
             // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account prescriberAccount;
            Account patientAccount;
            Case patietnEnrollmentCase;
            Test.StartTest();
            System.runAs (communitydefaulowner) {
            
                // Create Prescriber Account
                Test.setMock(HttpCalloutMock.class, new API_ResponseMock()); 
                prescriberAccount= SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
                id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
                patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
                
                patietnEnrollmentCase = SYN_TestDataUtility.createNewPatientEnrollmentCase(programObj.Id,'Macitentan REMS',prescriberAccount,patientAccount);
                
                List<Case> caselst = SYN_PortalEnrollmentController.getPatients(programObj.id,prescriberAccount);
                System.Assert(!caselst.isEmpty());
               
            }
               
            Test.StopTest();
        
        }
        
        @isTest
        public static void createPatientPregancyRecords_Test() {
            // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
            id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account prescriberAccount;
            Account patientAccount;
            Test.StartTest();
            System.runAs (communitydefaulowner) {
                
                // Create Prescriber and patient Account
                
                prescriberAccount= SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.id,recordTypeIdPrescriber);
                patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
                
               // String remsId =SYN_PortalEnrollmentController.createPatientPregancyRecords(programObj.id,patientAccount.id,prescriberAccount,programObj.Name,'Portal');
               // System.Assert(remsId != null);
                
            }
            
            Test.StopTest();
            
        }
        
        @isTest
        public static void attachPrescriberEnrollmentFormonAccount_Test() {
            // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
            id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account prescriberAccount;
            Account patientAccount;
            Test.StartTest();
            System.runAs (communitydefaulowner) {
                
                // Create Prescriber Account
                
                prescriberAccount= SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.id,recordTypeIdPrescriber);
                
                String attachId =SYN_PortalEnrollmentController.attachPrescriberEnrollmentFormonAccount(prescriberAccount);
                System.Assert(attachId != null);
            }
            Test.StopTest();
        }
        
        @isTest
        public static void attachInpatientEnrollmentFormonAccount_Test() {
            // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            id recordTypeIdPharmacy = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inpatient Pharmacy').getRecordTypeId();
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account prescriberAccount;
            Account patientAccount;
            Test.StartTest();
            System.runAs (communitydefaulowner) {
                
                // Create Inpatient case
                
                case inpatientPharmacyCase= SYN_TestDataUtility.createOutPatientPharmacyInfoObj(programObj.id,recordTypeIdPharmacy,programObj.Name);
                
                String attachId =SYN_PortalEnrollmentController.attachInpatientEnrollmentFormonAccount(inpatientPharmacyCase);
                System.Assert(attachId != null);
            }
            Test.StopTest();
        }
        
        @isTest
        public static void attachOutpatientEnrollmentFormonAccount_Test() {
            // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            id recordTypeIdPharmacy = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Outpatient Pharmacy').getRecordTypeId();
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account prescriberAccount;
            Account patientAccount;
            Test.StartTest();
            System.runAs (communitydefaulowner) {
                
                // Create Outpatient case
                
                case outpatientPharmacyCase= SYN_TestDataUtility.createOutPatientPharmacyInfoObj(programObj.id,recordTypeIdPharmacy,programObj.Name);
                
                String attachId =SYN_PortalEnrollmentController.attachOutpatientEnrollmentFormonAccount(outpatientPharmacyCase);
                System.Assert(attachId != null);
            }
            Test.StopTest();
        }
        
        @isTest
        public static void createChangeReproductiveStatusRecord_Test() {
            // Create admin user with Systm admin profile and role 
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            Map<String,Id> caseRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
           
            id caseRecordTypeId=caseRecordTypeMap.get('Change_in_Reproductive_Potential_Status_and_Pre_pubertal_Annual_Verification');
            id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
            id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account prescriberAccount;
            Account patientAccount;
            case prescriberCase;
            Test.StartTest();
            System.runAs (communitydefaulowner) {
                
                // Create Prescriber and patient Account
                
                prescriberAccount= SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.id,recordTypeIdPrescriber);
                patientAccount = SYN_TestDataUtility.createPatientAccountTest(programObj.Id,recordTypeIdPatient);
                prescriberCase =SYN_TestDataUtility.createChangeReproductiveCase(caseRecordTypeId,programObj.Id, prescriberAccount,patientAccount);
                String remsId =SYN_PortalEnrollmentController.createChangeReproductiveStatusRecord(programObj.id,patientAccount.id,prescriberAccount,programObj.Name,'Portal',prescriberCase);
                System.Assert(remsId != null);
                   // Covering code coverage for getProfessionalDesignationmethod
                    Map<String,String> profDegMap = SYN_PortalEnrollmentController.getProfessionalDesignation();  
                    System.Assert(!profDegMap.isEmpty());
                
                // Covering code coverage for getPharmacyCredentailsmethod
                    Map<String,String> credentailsValues = SYN_PortalEnrollmentController.getPharmacyCredentails();  
                    System.Assert(!credentailsValues.isEmpty());
                
                 // Covering code coverage for getPharmacyTitlemethod
                    Map<String,String> titleValues  = SYN_PortalEnrollmentController.getPharmacyTitle();  
                    System.Assert(!titleValues .isEmpty());
                
                // Covering code coverage for getDisEnrollmentReasonmethod
                    Map<String,String> disenrollmentValues  = SYN_PortalEnrollmentController.getDisEnrollmentReason();  
                    System.Assert(!disenrollmentValues .isEmpty());
                
                // Covering Code Coverage for updateAuthorizedRepAccount
                SYN_PortalEnrollmentController.updateAuthorizedRepAccount(prescriberAccount.id);
                
                 // Covering Code Coverage for getPatientPregnancyInfo
                SYN_PortalEnrollmentController.getPatientPregnancyInfo(programObj.name,patientAccount.id);
                
                // Covering Code Coverage for patientDisEnrollment
                SYN_PortalEnrollmentController.patientDisEnrollment(prescriberCase);
                
            }
            
            Test.StopTest(); 
        }
        @isTest
         public static void getOCAssociatedPrescriberList_Test() {
            id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
             id recordTypeIdOC = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Office_Contact').getRecordTypeId();
             id recordTypeIdPatient =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
             id PrecRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
            id ofAffRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Office_Contact_Affiliation').getRecordTypeId();
           
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
        //     // Profile Query for Inserting community user 
           Test.startTest();
             // Account Creation
            Account officeContact = SYN_TestDataUtility.createAccount(programObj.Id,recordTypeIdOC, 'TestAccount','Office');
            Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
             Account prescAcc1 = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
             //Rems Service Creation
             US_WSREMS__REMS_Service_Summary__c objService = SYN_TestDataUtility.createRemsServiceSummaryopen(createPatientAccount.Id,programObj.Id);
            //Enrollment Service creation  
             Case createPrescriberEnrollmentCase1= SYN_TestDataUtility.createaPrescriberEnrollmentCase(PrecRecordTypeId,'Test FirstName','Test LastName','Complete', programObj.Id,prescAcc1); 
             US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(
                 US_WSREMS__Prescriber__c = prescAcc1.Id,
                 Office_Contact__c =officeContact.Id,
                 US_WSREMS__REMSProgram__c= programObj.Id,
                 RecordTypeId=ofAffRecordTypeId,
                US_WSREMS__isActive__c = true);
            try {
                 insert affiliationRecord;
             } catch(Exception expObj) {
                system.debug('Exception');
             }
            
             SYN_PortalEnrollmentController.getOCAssociatedPrescriberList(officeContact) ;
            Test.StopTest();    
         }
        
        @isTest
        public static void miscTest() {
            
            String t = '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Nf2OyYOOdTyqJMHiomMkjXhxkJLUgYbmpok1FI3PKXcJA1k9zDlk6hWpKRkeEOedhsRdYUwHIwO3QpqcfWyLBf2jyK12HhMXrHOqJXa9XCVuNwMjvpUeiotYRTT4K60iQ9ZVTTHMuVNGk94tEg5SS4KgM8S4RNDxOgALDGPPu//cInHlNj4keTqK571r7xXOuRXTcgLgBiARP+Di74ORkb2OOPAczmtsTHEMO0SDUIvxfoek/wGT2vsJCmVuZHN0cmVhbQplbmRvYmoKMSAwIG9iajw8L1BhcmVudCAyIDAgUi9Db250ZW50cyAzIDAgUi9UeXBlL1BhZ2UvUmVzb3VyY2VzIDQgMCBSL01lZGlhQm94WzAgMCA2MTIgNzkyXT4+CmVuZG9iago4IDAgb2JqPDwvQmFzZUZvbnQvQ291cmllci1Cb2xkL1R5cGUvRm9udC9FbmNvZGluZy9XaW5BbnNpRW5jb2RpbmcvU3VidHlwZS9UeXBlMS9OYW1lL0YxMT4+CmVuZG9iago2IDAgb2JqPDwvQmFzZUZvbnQvSGVsdmV0aWNhL1R5cGUvRm9udC9FbmNvZGluZy9XaW5BbnNpRW5jb2RpbmcvU3VidHlwZS9UeXBlMS9OYW1lL0YxPj4KZW5kb2JqCjcgMCBvYmo8PC9CYXNlRm9udC9IZWx2ZXRpY2EtQm9sZC9UeXBlL0ZvbnQvRW5jb2RpbmcvV2luQW5zaUVuY29kaW5nL1N1YnR5cGUvVHlwZTEvTmFtZS9GMz4+CmVuZG9iagoyIDAgb2JqPDwvVHlwZS9QYWdlcy9Db3VudCAxL0tpZHNbMSAwIFJdPj4KZW5kb2JqCjkgMCBvYmo8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFI+PgplbmRvYmoKMTAgMCBvYmo8PC9Qcm9kdWNlcihpVGV4dDEuMy4xIGJ5IGxvd2FnaWUuY29tIFwoYmFzZWQgb24gaXRleHQtcGF1bG8tMTU0XCkpL01vZERhdGUoRDoyMDE3MDYyMjE0MTkyNi0wNicwMCcpL0NyZWF0aW9uRGF0ZShEOjIwMTcwNjIyMTQxOTI2LTA2JzAwJyk+PgplbmRvYmoKeHJlZgowIDExCjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwOTIwNCAwMDAwMCBuIAowMDAwMDA5NTkzIDAwMDAwIG4gCjAwMDAwMDAxMTkgMDAwMDAgbiAKMDAwMDAwMDAxNSAwMDAwMCBuIAowMDAwMDAzNzcwIDAwMDAwIG4gCjAwMDAwMDkzOTggMDAwMDAgbiAKMDAwMDAwOTQ5MyAwMDAwMCBuIAowMDAwMDA5Mjk5IDAwMDAwIG4gCjAwMDAwMDk2NDMgMDAwMDAgbiAKMDAwMDAwOTY4NyAwMDAwMCBuIAp0cmFpbGVyCjw8L1Jvb3QgOSAwIFIvSUQgWzw1MTk5ZTA2MmRlZjQ3ZThhMzEyZDVlNWMyOWMzN2YyMD48NTE5OWUwNjJkZWY0N2U4YTMxMmQ1ZTVjMjljMzdmMjA+XS9JbmZvIDEwIDAgUi9TaXplIDExPj4Kc3RhcnR4cmVmCjk4NDMKJSVFT0YK';
            id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
            id recordTypeIdOC = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Office_Contact').getRecordTypeId();
            id recordTypeIdPatient =SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Account', 'Patient');
            id PrecRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
            id ofAffRecordTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Office_Contact_Affiliation').getRecordTypeId();
           
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            // Account Creation
            Account officeContact = SYN_TestDataUtility.createAccount(programObj.Id,recordTypeIdOC, 'TestAccount','Office');
            Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
             Account prescAcc1 = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
            
            Test.startTest();
            SYN_PortalEnrollmentController.SavePrescriberSignature(prescAcc1.Id,'',t);
            SYN_PortalEnrollmentController.getCurrentUserPharmacyInfo(userInfo.getUserId());
            
            Test.StopTest();  
            
        }
    
        @IsTest
        static void SavePrescriberSignatureTest(){
            
            try {
                Test.startTest();
                SYN_PortalEnrollmentController.SavePrescriberSignature(null,'','');
                Test.stopTest();
            } catch (Exception expObj) {
                system.debug('Exception');
            }  
        }
        
        
         @IsTest() 
        static void getRelatedFilesByRecordTest() {
            
            Map<ID,ContentDistribution> mapContentDistribution=new Map<ID, ContentDistribution>();
            
            US_WSREMS__REMS_Program__c programObj =new US_WSREMS__REMS_Program__c();
            programObj.Name='Test0001';
            insert programObj;   
            
            Id idRTforParticipantFile =Schema.SObjectType.REMS_Participant_Files__c.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
            
            REMS_Participant_Files__c remsParticipantFileobj = new REMS_Participant_Files__c();
            remsParticipantFileobj.Name ='Test Participant';  
            remsParticipantFileobj.RecordTypeId=idRTforParticipantFile;
            remsParticipantFileobj.Portal_Role__c='Prescriber';
            remsParticipantFileobj.REMS_Program__c=programObj.id;
            insert remsParticipantFileobj;
            
            ContentVersion contentVersionObj=new Contentversion();
            contentVersionObj.title='ABC';
            contentVersionObj.PathOnClient ='test';
            Blob b=Blob.valueOf('Unit Test Attachment Body');
            contentVersionObj.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            insert contentVersionObj;
            
            ContentDocumentLink contentlinkObj=new ContentDocumentLink();
            contentlinkObj.LinkedEntityId=remsParticipantFileobj.id;
            contentlinkObj.contentdocumentid=[select contentdocumentid from contentversion where id =: contentVersionObj.id].contentdocumentid;
            contentlinkObj.ShareType = 'I';
            contentlinkObj.Visibility = 'AllUsers';         
            insert contentlinkObj;
            
            ContentDocumentLink contentDocumentList = [select contentdocument.id, contentdocument.title, contentdocument.filetype from contentdocumentlink 
                                                      where linkedentityid =:remsParticipantFileobj.id];
            ContentVersion cver = [select id from contentversion where contentdocumentid = :contentDocumentList.contentdocument.id];
            ContentDistribution contentDocumentObj = new ContentDistribution();
            contentDocumentObj.Name = 'Test';
            contentDocumentObj.ContentVersionId = cver.id;
            contentDocumentObj.PreferencesAllowViewInBrowser= true;
            contentDocumentObj.PreferencesLinkLatestVersion=true;
            contentDocumentObj.PreferencesNotifyOnVisit=false;
            contentDocumentObj.PreferencesPasswordRequired=false;
            contentDocumentObj.PreferencesAllowOriginalDownload= true;
            insert contentDocumentObj;
            
            List<REMS_Participant_Files__c> participantList = [SELECT Id,RecordType.DeveloperName,Portal_Role__c,REMS_Program__c FROM REMS_Participant_Files__c
                                                               WHERE RecordType.DeveloperName = 'Prescriber' LIMIT 1];
            
            
            Test.startTest();
            SYN_PortalEnrollmentController.getRelatedFilesByRecordId(participantList[0].RecordType.DeveloperName,
                                                                                         remsParticipantFileobj.REMS_Program__c, remsParticipantFileobj.Portal_Role__c);
           
            Test.stopTest();
            
        }
    
        @IsTest
        static void getOfficeContactAccountInfoTest(){
    
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            Id pharmCAccCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Account').getRecordTypeId();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account acc;
            String t = 'JVBERi0xLjQKJeLjz9MKNCAwIG9iajw8L1hPYmplY3Q8PC9JbTEgNSAwIFI+Pi9Qcm9jU2V0Wy9QREYvSW1hZ2VDL1RleHRdL0ZvbnQ8PC9GMSA2IDAgUi9GMyA3IDAgUi9GMTEgOCAwIFI+Pj4+CmVuZG9iagozIDAgb2JqIDw8L0xlbmd0aCAzNTgzL0ZpbHRlci9GbGF0ZURlY29kZT4+c3RyZWFtCnicxVttc6M2Hn+fT+HZvrhsp8YSiKd9c0Ns3HXrhxQ7e91ebm6IQxLP2ibFzm7z7SshQH+BAKWdm+tOJ8b+of/zkxBXm4twc/H7BUaegQbsH0aWYQ9M26TXjm3Y3mB7uBjNDngwSS9+ubjaXIymeMDQm4cLxP5sL9Dg8QLzuwfYdgwfD1z6h9jOYHMY/PtyEl4H0WYRLjfvB0PTZTdfrqbi88fVIpwHy4n4Zh2Ob6LZ5vP7wX8Gm59ykhhxmhUhYhm+P3CJbXgmpzNN7pMs3otlwkOSPSbH7av4ahEf48fkkBzP4rugwBS0rAYtzzFMxx64FjFsl9NabyjDQQR4ns5XK3D5MfhN+nkSbsJoMVsGm9lqCe5aRQtxdXu5nn6cTG/fA8E9mRfimoZjklxwExUaXi2uxCLj9HjOUqCGZWqIC+w4aIgQQQWJcl0bY8MldF3LEeuGfzzvsuT0AdyORhYeYa+4O/ceZn96Fxq4pkudxyZMfZj+nyWDB+40Amczx6JLmWYOodwYxPVUUNt1tLEWgHbTdyiHjE80sC2/k0+Kw3aBwJYaZrt6OE42h6nIMqer2dkkhErj0Jt8EUk0LmT3mYmPQ/FxvgogZsmcrPC7htVKtsxKhjZtONgppURIjTNtrAfMCXOcirDK75lmXQTSCgZePQ+XkzAarcPo02wcRsD3g0UIIh0mmWAyicL1WoRaM8nkRB2fRQanuWH3O7lUl1fx8csP4nJpBIa42iSns7gKttv0haUcKeT46h5NtaVELlgu+SYuwuPjPj7egy/+SLYv593XRHx1HWdflARowrA8TuDqJdvvjo/n9AgYXwTiM8IesmQv+fGCL2Nbhjs4DFy/utgPkOFiMvg2WHOzyXRtYhTJ8iqLj9un94OcBEsm2OTk6B+n7pOs9pROaZlWu1NqOxsPUi33NSugirTCLU3br/ulCfxyvJrPA5r4gzmsBOtxNLuWA/mW2ma3v6fGGS3Su90+AZUkPSSj6yx9TrLzKysNoFokALc7ns7Zy/a8S48n8e1DmtW8grPs+K5g+ZBm0kL0pkPMFjJgKWrGR7GU51YBgk0buGQQ/QyC4FOo5oRRLRhZhv8SN3xeRT/DAPssPlMTsmBRZLPCzG5fbrd9Gha8rpjEcJRVhaUmPWROugQqaLclNAcBK1g6CW0GMth3vbnL9oFpPIL8RrRhoDTSFW36uqBW1dUvVJuCuirgzIbeCNSbXPomtOmcTWdMgXVfQZ0V6C9Iw9OMnrcggVRRL4W1HLcurA2EDRarm7amutaOzpbrmyhYjkExjMJfbmZROFGGUcGcbXm0y/a7I4kuV0ici9KiGkKX0YBy6hynpq5qlmgGwpY1sD1al9zWZmmmFrWLWE1Ux6n47+gIc1H7oZw6x6mpV7HMxjHbRUK4ALgBnylgiek3/nW0+jEKpNFjOZ1dw/IyXi0WN8t8Ciu/+olOZevJbNzaS5ZS+25f+qUdRKke0pJxLKsT2JZTbdsVeoJNIhMQjkmHw8txdwbD4TI+JI0EyYa+Si6zI1P08VtPKa1AMQLgujhSb8Faytfby11yqqp0PcVwtj3bsLo8u5udCkjYrM1cu5dznrckzmFxW5/jc0PRhDh89VLVnuG0sdzPSTMee5kmDJEjAdvkTf7zcrhLsoYpcn+3kOEQXhbMtnLIHUgDyWOtACpiraMhYMOxRrM15nFfXLHCUg8LbV65e2nJTwBSEWq1wOgSpWkEXS4q39KyAxKrKqOsigifjvHEl5n+3IwBfdqVY2vJ5EjrKmKLu4xZcxk6+nqMa4tqr4pkBxFf3XwX62uVUuyVbPeW0n4op85x2l0Dr6qsn/QL0a7+91V1EmwC0MFNp6xLWf4ovrq6mc0n9JvRYnU1m4PF2TapWuuFfnqLLvGdylVaFMnjuh3YWnRZtvF7i+4ifm6my/I6zRTZdXgdH5N9S46VWUBYsHCrys9HWt9/AHPuA/gpBRvC5ycwDZ/ypqC8isFo/S541yy8RRIrTII6TNKnamE7gjuBtbQILWHqWaLQsTyc89WgUsOHh2TLdp1GUfJ1d0rugVsrKrpFTKEK0zI7c0KPjI2k0K8Oi/h1dcAmZHaSDA43QGIwTybns+SjDy0qHD/Fx8cERv58tRjfvv+nsh0gjmlg18vZpw5DLzs8RAubZ4IK2toT1BK8T1sheptL4fSvlN6rLUHkeS3lX5MzblpNiQnEKsKnck8H06FYZh35I2SPULM2VRw4JQeW4as5qPxLC23Z7HdC1YhJnhdb0y/TJfGo4KZXbEIaLm5Z038DFgNsk4Hc6L5sc8umoz29xzWcshP5tf15k+X4hkvRnoii5arp05wNbrZ+PbhW5Qu47QkB14IWEgNkk3hNEtcxsFVsiX0O1zBiYUF4TU6gVPDN92qPaTEWV/c0842O8BHbDmSW+Gu828d3e1h3kuO5UcEK5hxXMHefp1QlB9v4lMDaBYjfJfv02+17Q9kpdOWHWoKiybNSfOeA3oGUyjMbr5xSNjhWTfdpCmT7LT22DOFdaUGfqXpW6GefV0KJf7gLt0w7a6wyFUGijN+uRKSB5SajFdZ2ihGXFkfsdOhHC8t9poTq1hRMKTjsPo9m+VqC+WtscJ1pikcgtstT3rJsZQxNhk2wsrrzUaVaG+W+gYSf8bZq6HmWa7g27TKkwM8f7KvCvKCsM4cREwmJ+nouDSxnoAC+bRQjbOTHxaPKMcwQ4UR+hNY/iQWfgtk8oAOUtH9Jp4KnZPsFZNU9GC3OTzEYAuLn5/2rodpZ6xVQ1rBFhNa8FmCpYR1szkAJbNOwekojiAgN44bz2CxaCKuzdOWOKm47+VrIsOye/sSxdZGcNkfq9TG2x9oYdl7J9HrbGBfVxW+cFqrVodnx9MKeWyc9hR1617Y5cz7H2Xm33T3TQAZ3744t0ybfLmiGdX7ARcM0lqWtcYudMNGEWs5brWPRjKVvHj6rSfaJkseXfQxGr+ssfcziQ2PPjEvcrxpicXlxDuzqKEkRLBrIQt24hXgVfcSry6c4nFZJqJo2eWvR3PawaCNfLWqqY9ryLa2Ytugg0SdyHtI6QE65ALarJo9MSYi/GZnSVo5umN6nSdsSIILfHMCypZiopZBWi6XYoTcdS7EnLFqW0gByygWwz1JQiM4zK2rrQMWBfZZxGp/O0OZXcZbt4M5LlJzSl2wLzRRkSQztOr6KArjXCjcUV2yP59sOtk803M7J9gy3seorrq6D3JiVJ77dNQ/xa80ZuB4dLPQo+dtdonDfukPxNVhWqRomKvyI8gv25JLT7vGYn+ORN+o+wHMjtUzMTq9QJ5TX/m/xn7IX6m5Far2Q6Wl3mzpYzkABfFu3adEJpBJwAmxcO6mrkriToCyxSfVZSmF3HFBjEutgcwZKYM+pgTzpsCMupZgzsN3R85xB9Nbgue11OJ519OH1M89BFAYwmn5bLeGGy3i13ASzpfT0Y/MR0J6HG2oKcMe74B2IaHAq6t2ndzDwG5uuVLuGR+2Gc7V1DIXE9xiQDdqFIfwWmyFHD1iQLoDtG5rsAHbNXPn2VK1IUKfigvh0RuwQxKbdDieL/YI9drxbhaThoInkxDmyZTegFmo29Vc/lwqbjc3GRmDaxK3roNpsbJtpLATieNa6g/cgJ+pddw+RJb+/7DJYGe5AsyAV/FoFmOxOtJIlct/KyoyUhYMtSPiwy8O+aymbB9MnajGP6V+WUio7/2+Rq3v3SW138ww3TyVGst3pi3rRXBG0M2nr2KRRTir68Jf0uH+FGrp/2Sb3P9QUqLCVBzYysuSQfk3u1Ts13Ym8Vklo41fmGrPntIsOljNQADUqiemCjmUjafA+oeY/7Oq9BoTcxdLzQghL/ojpvZKxGi017KeepY15YKC/+wKQMPTX3Uk+Rn0Gm7y7c9uTgZwbhT84ptBcyhpR6JbVYWvgVwmV5F5NfZ9upUlEUtVd2ZAfag35k9SQp13Ti6TqFrft9BrZbbElmhqMvW6/1QLnLJTItzV9JttnqCZw6aD+gr2gJj0OWj0zq8T77jPwfF3aTFrIBMcfiqen33//vbjYfMwbsPKIVRixs8nj8o2w4utp3tcUF5NwsVquN1ENc30TXa/WIVhstZx/rlFV2K1baTW7sZe5NFt1HSxnoAC+zWrYAvEzhbUiYq8WhtE/gN36XncqWeh8t4RrABMhVedZzg5kW9uCMfBE9pYSyCnFm0ngm004D68/0vYZhOrN4gq+GHArdQW1LHN+ikHIz5MjTZRth0ZLBZlUkk4n6ZG86SXt2Eo1mNJ2XVk7k2AD5IaH3LtHtfytHzqpFa8PEtpVKttaLokW0hHAlheEmgnCR+zRDUa2yBDjNEvm6eNuC8K+6KmKy3WSfd3lmx1SOcHsLU174NuGY5bZBvvIFDdevWTHBLx6FqXxfWMRwhahTYpPikWCl9N5B18K2/wqPruea3v1NcxcKpe9GVsyMvQQGhLiDrHrmuoDmDpKLt1FzyBIrKp2WPlMsmQG5IxMcwTfuouB5pD5Afsg5y5A6p5sGs/v2eqeL+ySG3ScZGDF7z6Iz9hFDiLIdUzlSrQlrowj1ZD5bBoOV9Nh8aJLI+GzHOoatSMc9Jq2IGZ5gGMaLsBcPqX9h7hCnjNEQ4t5FK0WiGcWqijs5AO2h9l7QC6WBRh6+d765Yh+tPP9ycvNZDzchOsNpl8R7LDzo9jKJ4O8iVb3IsAgZUcF2rTSIGXyB+csc4MMXUSt62I6vPL3qMXvwzZxr2N4aAu3TCjCmf8E41mKKwoKZW5kc3RyZWFtCmVuZG9iago1IDAgb2JqIDw8L1R5cGUvWE9iamVjdC9TdWJ0eXBlL0ltYWdlL0NvbG9yU3BhY2UvRGV2aWNlUkdCL05hbWUvSW0xL1dpZHRoIDE0NC9CaXRzUGVyQ29tcG9uZW50IDgvTGVuZ3RoIDUyMzkvSGVpZ2h0IDEzOC9GaWx0ZXIvRmxhdGVEZWNvZGUvTWFza1syNTUgMjU1IDI1NSAyNTUgMjU1IDI1NV0+PnN0cmVhbQp4nO2dIZfcuBJGmwYHB4UGhy0MXrY4NCw0eNnA4GGhwcNC92/53eP7uo4i22rZkrvdnSkwx+2RZKk+ValUKknDcH/033///fz589u3b58/f/748eO7d+9OFfTmzZsPHz58+vTp69ev379///XrF+XcuimPSTAWDoPOX3/99f79+7dv387C8f5MgEhK0PHnUnqAJuXff/8N9HSAW7fy7unHjx9fvnyB7TAW9srktyPB53/++Qc+k6ZeTF5eXsQdjCznzZl4BlmkjwSvcreKgAAsQigUHOQFPfb8/Nz3WyD49PQEgvSKVAzpD3QGdGbfzz0SwTqkCUaFKPHMGzTVdTq82Cl6ooZc85OXV/j6HREqiO4deolnRKkeI1MiDl9GIi+c5w0P8WatYFIldKN62FpRzquehC0oOjszSg+9hDIspA8FBQRk/DgSuXgDS+EwqKFL4bPCwk/llDRw2/+S+N9//4X/JCibGWahWCVO1P5MywReheqDvbClnB4Oa+/BPVADrKzDU0gIEWlI7zNMjvegRi4eyP5pJMrk2QlCQXxAn2TWlgJRkn+OrCFTzpicENWMDqBJSju2f+EYksIz2SlwGPFSE2pSBj+BOKQycIzSgug8F2tCOTG6UXkq8Nio0V7aaC+tREoicTYAAQ18o89ToOXAcIWF8kO4ht/xIg36FkwBF+xAVqzTZNqKoUKnlbFL2Apypd96JEJG7JlL2g/mOCpBGZQpzyVNlJSfOi54AEGeZ/OShWfy8jImYhRCZwCgYRRbvg4ivPR5qTmhIR0ftXAeg+AGjArNPzupoZfyX1hNYp7hp8yX1H5pYpUqaeC5SJEmhMVyIq8PfJcsPCAdmihBpNeQMEFQavzMWphCr3p0ZLx3CrGa6rSU+BcND3lRfOK/clKHhnaCQwls15VUOY44ZgF3VhP1JC+p6mxGPgQis7Yrnw71SDl3PaLB2Ji8TP8Lwz+MpKXHQzoWqLvip6Z1OuL0IkpW7/G5qeLlv/YQ0ogyFZiOvOhDzV0ae48jGl1RRcHfWbGi+XRaOjwpgSZkx/9q7V/8StqZ7efBbfmcGoE1QGtbUhN4Tl5K06U/jH3PhlBhvcTTiZhiCGX69uAUOtCxe5pA7Rc/4YCzJ80ABiMfyl+RmSnTsm6fSQpdIirDw9JISjWARmWrwelEPu14oKl7Px1kp22/C91IF9W0mLYlHZ5S8VEZwnnY4jg121IVVy99CPPTr0z71fNIfteKRd9QdSvRw+9iPoz9hNZpCR/cGeL0CrCmXZ0e6xSJttNY2hLNVCVGyjTj95H2rjZcvTj5DV1BP0xtIVo6NfvVxkJW9rDdkKwhYE07FUgpbioxsNMX9HWkwtx5w0piuxbio1PloP6k8BQCfqInlypPltnee3Oi2moAKj/tTkhTTIKGUfOQDBR4T69G3FJdpFbcVg34DDO7+NKXph7Z3I1e50/SuxCQ6YewQA4FWYA1a13QinS2O8z5K4J+jrS2AtpsToKkbHbQQgXZd9IBUvQToeRN1mOdnR1HylSD6Ww3I2e7gUJmbAyjeG4WB9jlLG8pwKZ9+HDeMf2uWkLjdmmmL4HUQaRMFZ3NbYex76U/NdF1H015iPRtMCo0z2ZjaTLUUku+kdJ+ZSvSaaOUOTYlpey25kdI+qyBkfk00PCAtWrhuEDhuKuk2bnSBrLLpW8QmRQv+q1OLZqZSZNjmWup7TVZS9RcazDtMM6kqI92YEAGoJnRm5kZ9aTxX49UhtoeswODc2i7XilXyelOoJOlRB1ZjStPpVXI2RjqfDbFyOUhOZyN/huMAfqAXXQbWBLZw7PUixxDaSxAOLt0KXw6kA3jPO40ej86VuBi9Rw1Mp6HDrT+w9nvtGppconCz9OFurj4aOy017l4pG0fs5hUk6iCruljnO0hzqqM2VM/+B79E7V1bXft58B6swIsEx3gYtxImabN0V08jArfEdOg8SyXoapXMBepgwGc0wmU0pQtNaZEf1uFl17ZRgV4kTr6JIfzEtsw9mrgwDSdXX2WjXsPZLTLYWvJKHWo6iXpaZTvfuSCfmNVQSfjiXH7mamfta7LpwtkXFPZMNYyTNO0RDXruNgPrC5j6zCqgmxSU4OFen6nQAKk5lRn2FD56GyzvtOaElITzuiOvkgtrXr3ohofJlw6jQLeXSsa27BhrrdNuFS89I2007oI1QUp1NRBFhPrpWAVaRN2cRHUkHhNpQD4lryFlWRozX4111Ffn14/JC3qaPOg006jR7dXgRcp8JKykEXnOGtRq4n67kJr1xd0PsxOrreRvuVVHQA7vMWHkOEVopGWibBXqkeEdClY9yCkTZWtOm0j4zEKduksNe50m8XrNNlrYIB3GawsSuqYRA0VisZyjImd9cDvSkt4SZkzBxNoOqjVb6bYifT91qfX8Gicuipc6Wp+mXrpnDJeUgZH6ra62lBVplW2NBKhBd6impz11H/XPT6bPxdUg5dClNn8wLQUWHh8cqV+86xQCV07cnWhSrwCtcfYQEfHUzlsy+7u3e5b8mtoFV6nca5xWKMCka83rTUUNyhzJwXXXFZLqR6vvd1K7ZR65y4SKV3+WPsVLa56+6rL3CGoBq8skIYxK110O6y4XSS3Aa5Sa64g1ytSN/tsqt08XcQrC0x1i190S3cZH1zulsilsVWG/VozvjsV8Mq2DLtIGv/ypWEtasvj7MaqVFYKSyGec0py4IaRcrN4ZYHWblJIk03xOp1t/ptYTSm5A6IysVZHJb6MCKc13t09RooMr+k8azZSdBavwPqObH50wql6kUVlWKn8KXmPRZYULzpbag/T65bcvAW8AverLQk1kr2xJqUbB267aykCRVL2uvOxYIdcxOt0AL9iJenrqNlkSu9dNdjtQQZvRx14yIaqzXgFapmCvVq7Kg1p1xwvzpKcJt/EB7VEHmVT5v9avAK1K58pVD/x0f17cRFTn2Glkt97p6qnBNRwfhtekesIzvwpebBq2Xft4FXpkN97C3z9CnILXp6rs18rNpOxsoWhFuZ3WeXsSG5Ur/QlbtCH0zjPK1BlJ9eqLzg6GA1Po/3cr2p9yLDhjvaGiW9lJVau0KHlyi53bZLDns3iPp12vNxrfMOG1I/7xtgv/ddm1jjc6B63mngWtoDV4LV2z8VtyW0sS//VGKuZlaCgbugoWNpjXsDLaPbDHl2yRIbpLlXbI/TvxcnmOQMX/b2nQ1rslREmRustVX7byuZtKd13OYvXMc8hrzTqCiaiK9G3CgBoJFrkmpE/nQKgMw87VFVqZjewzIIrXpUzx6Opl2Gsf/TDVSEuRybU5mmc0U//peewEq/D2vwPRmjyJbw8g/GYnpk/mYyHn/3XqruZXuk6tO0AtFc6Dj0/Pz+tpFcxbCe02Vq2m3HDpuBXe6OR6PAbdtAL2Qa8Vh304QlmBqBO79roS9hLO4VN2vBepV3cZtgXr1NdTH4cO3wajdK42We/eAMP2tpDXXuxy8Vkv0a6mGzb8RQteC0ZmVkbT+PGupjOe/zmPeJVSU/jJXFlyGDCBoY34gWVg2at1cUgfBG0wCzW2gUvbxBII6v19J7OJ2mkzCnjFRlPc07g2KHphjKP542R2qtDIvHLy0uEbKXz1poD2ONKwSvjVR4panYLUgH1pBfeudwTWTwSM662FC+4YRaS6SdM3WsFvPyW2tgNEem2AiMe5by3cohF6ECbHKXJNC/mMHHluGzg003wKh93YxB+Ya7nWe5UPr0mw2OyzCVe2WaNdyOFTLkmHotxBbwEKDL6rYiM9b+pxrC/zeKlZKW1qjeijEC7CV6nYuTbxU0TKsxMSMVITeVzOsob0qCSdOJPE9I0S3gZmpJ527yNVHGeHs9l9WbxahklW7jdjldBJboIVZipyeoMcbnkyxQ7Kc6peJvQadSZZU4ufSvEZHrCTNYTAi/vdNh2HI3+9lvhVT70Jnib6UwvYx3O26uzXi3KVky80k84zSws9i3h5aabLKNqLW4gTXuXhw/P4jWMBkPhEMgytRwP2IjXxT4m87XEQn25EVKWOlLHErCLxfHfKV7DeaNuSAplpiaN18q7/hUkY2e/FearlxrYKFjqJoJTcjxCipfLviSLjkdLK+FzHeQmeNV4pTThQoO9+f26vRj0tSLe/H6a/SxecV6xLBXfEOEwyFOyX3mQZvatlMmev82/3MAiKFHVFK8huctGk6l+I6fq9Pp41YcBwxNtb4iHqUnpISdQdpuAS8ZL95N6D2yWhaI+TygdAf3WNOMwiYHRPkzv2s76p9XzyptVSx7bnFGNeB0wDLiF3AboNBlySrv56JIyOZheE69bnaOyH3kWt2f+q2l33Wq0TSVuxqvj4YpHo5eR9v6Kg+M2vNZifUe7gI9MG0TsMYK+XumV7oi8A7Qy8Wv8206EOQdva4y6VedNvWrUVcRkrdINotuqJrFehStE1Cwtnddb0bcN09rw9fppdf3G5EIM8FqieyDU/A0xTNtIl5gVz+zm8UI9I7s3+i0ly0ojMW8a94JNrzvseAitIlMfOKQXrn5GXOg2+t9omk4byoyLs71mVNT010H8jPhGUuq5fRovZuIhvSLNZ9J4CImBEz7rgNU3ZTiBifUgmYwHAy/5F3+tlVdF+12erdUwdi2ePYHKHmiB6U2pZOFnl50g+jnr+b/qvKlhVLZLvcv60yge6Ni0Om0gz3zreST+xV+5FC70cLDLbf5GdvlsLkhY+QQPHksiduayWBHnvbd1mwvyu1ErCgm8/JzfJa/XeYuXaIac2mGWFpq94LKGmd7mtsojESv1d3rQ9AGp3h4wYGDtjnjXC45z2OOfQyrDtcMrKmIa0tCLojJxo6WX4arNpnr755nS0QHZLygfx0r/bqsk5ZeDheK5o7/REIVt7lkdXPUixjCd2XvqeQcLw/sdsGKR19EnjA0pTlHWYPClY1lc4il2LmZZfkRpUri2hB91TCGXZxpYDcc1KD0wTZQduSL7MHZd753nDRWjkCjQZP5V4023S68aU7T0ts1qDRWrx1rpSN/w04uKHOW1u7wi3K4rc/So+CxGCoUnvgYPBUiPimEA3gVvmaHwSSDKmgT89GpdbVTNBl7aecIyNKPptf3MPoydKpDVwrS21sryrZj9M1tyrXcBuVu5Ze1DEdusUuzDm7/eiwB3er/kAcnjKVpsBiP07vTQgPsiOnZ6xME2MriFclaJWFkDqIUKCTQ8EIdZzb9WTNqnJKHfMl3h+17r7MaStS8sRuxWfRYH7tn3jgIO8TqUNAPgqqOG9qGYOpl1rHd8TyfOjvIRVB/uCEcoCvTZcrQ6zOvA50ttlTCKnHHbatNrDg3nK2vT7xoLBJ+n5oH3bNZzLM4rrs9SIAMGGuditFczIPAKJ4NBU/4NW1FLwCFeX5DGuTaDhQjNkPQEcxl6oXdIa0Sb0M/xXm7rqeAZhe8JZjzb0wQx3CPD2ZoyDX/5qbloo6btXSXX2gm9TjUJ9O9l2/J9rfJMtwm0kyFza7ea2j87VuP4tHa4dHvR5ujuvsWSq9DVkdZp63gzHcH16M5+2gGaopzVDtUcUxtPqzR9U69VaOzaBXejUvfYc712+nyRHGLSDaR6SLzRNeLeh7PBGWOZcfguq2kI+Rx+fp69XspRxpHLNDFCacM4GTevE+r4hKOkM/14qdnTiwPacr3MjCk5LPaK2dAm1Cy0D8s3La64CjPOMnWxKXUsaCoMI/M1UVxWEwKDrjUbwoOUfit8LKknKlwu4mveMCntYF2aT18yjH8/p7pasbyNaCljwb5t8TwUlNXVrCPnI2tzGfK9d8DS03iMGx1jLZMPexRhO22ww50dXydMOnZ1XeFbBSovdtjh1QPoWIcz9dvNTVbXqq55C3m2G3EVuSzSXgcnxXquYgjwcs/46UnvTpl/nKnL7GzzWXbu3ASva575GQPZNn9Xu88tlpwMptIG0IRIw660k3VM2ZlJHCZHC207bJbO09dmqye3Y9efO9GXVHculAzJnMuYxuCkHSNFZ9V8qjsZBXqrrXNuxW2BzAXNvrXajy4eNFSmOJ2pY5XWkpfPYi5uVnH3su8PqWy5xUM/BmDdPOTM+y67WDv35aetJ72v1zQIyxSb5RsZ7sJHr1q1k+G+jYUoWRtmrLuSUY5AdiiG35wcs7q737sQijE9SK2RPJW0vZxVxOASp6A0EuOd1iBj1mF9Ox4ak51d1qvknSaYMTXrSBSoS6Gws+Ag5BpB90Nfsx1ALT0WBqZTMFdVmir3O9EB4nTEjsXuR15f6CC7k8nnQkz6M5U+KpD26kw2I0h4D9K6uLubMuKk5es4yrKtmi5jxc+l0Li+hMiHdXGn+0TCAgG7e4nV2UbfzteQoVgOZbevJVSTHs6+p6zohz+C3QU62oGe0nzr6nQg1+gVtC6XSDo+etCxLOIND+50SI90y+5FNdig8espoUAUK0bqB5t4xh3K9sOWAQUIwviMk5kZO2LnURTuOdgxlmlmt7Xj/+TBm3p1Hvh2ElinretRn9tQ85TL9EjP2Ws4DP7/Nh4jn75pHElBKg6Q5+GuR6saCjtKNULn3MZAMoKa8wX1rUe5hp0fHhJFz5dk2ayQUadxI+39GoHbCIxUVsoaLK00HsyoYAKZ0xzeyL0Uenjr3R/8jZMneRm7Ler7CYWH1aTMrmnr45A7KONWC1CrOfcAmAIIhYWM7qL1LJThvPIe+16BKU7S8IRes5Q/5G7KOPjOc307Nf2OyYOOdTyqJMHiomMkjXhxkJLUgYbmpok1FI3PKXcJA1k9zDlk6hWpKRkeEOedhsRdYUwHIwO3QpqcfWyLBf2jyK12HhMXrHOqJXa9XCVuNwMjvpUeiotYRTT4K60iQ9ZVTTHMuVNGk94tEg5SS4KgM8S4RNDxOgALDGPPu//cInHlNj4keTqK571r7xXOuRXTcgLgBiARP+Di74ORkb2OOPAczmtsTHEMO0SDUIvxfoek/wGT2vsJCmVuZHN0cmVhbQplbmRvYmoKMSAwIG9iajw8L1BhcmVudCAyIDAgUi9Db250ZW50cyAzIDAgUi9UeXBlL1BhZ2UvUmVzb3VyY2VzIDQgMCBSL01lZGlhQm94WzAgMCA2MTIgNzkyXT4+CmVuZG9iago4IDAgb2JqPDwvQmFzZUZvbnQvQ291cmllci1Cb2xkL1R5cGUvRm9udC9FbmNvZGluZy9XaW5BbnNpRW5jb2RpbmcvU3VidHlwZS9UeXBlMS9OYW1lL0YxMT4+CmVuZG9iago2IDAgb2JqPDwvQmFzZUZvbnQvSGVsdmV0aWNhL1R5cGUvRm9udC9FbmNvZGluZy9XaW5BbnNpRW5jb2RpbmcvU3VidHlwZS9UeXBlMS9OYW1lL0YxPj4KZW5kb2JqCjcgMCBvYmo8PC9CYXNlRm9udC9IZWx2ZXRpY2EtQm9sZC9UeXBlL0ZvbnQvRW5jb2RpbmcvV2luQW5zaUVuY29kaW5nL1N1YnR5cGUvVHlwZTEvTmFtZS9GMz4+CmVuZG9iagoyIDAgb2JqPDwvVHlwZS9QYWdlcy9Db3VudCAxL0tpZHNbMSAwIFJdPj4KZW5kb2JqCjkgMCBvYmo8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFI+PgplbmRvYmoKMTAgMCBvYmo8PC9Qcm9kdWNlcihpVGV4dDEuMy4xIGJ5IGxvd2FnaWUuY29tIFwoYmFzZWQgb24gaXRleHQtcGF1bG8tMTU0XCkpL01vZERhdGUoRDoyMDE3MDYyMjE0MTkyNi0wNicwMCcpL0NyZWF0aW9uRGF0ZShEOjIwMTcwNjIyMTQxOTI2LTA2JzAwJyk+PgplbmRvYmoKeHJlZgowIDExCjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwOTIwNCAwMDAwMCBuIAowMDAwMDA5NTkzIDAwMDAwIG4gCjAwMDAwMDAxMTkgMDAwMDAgbiAKMDAwMDAwMDAxNSAwMDAwMCBuIAowMDAwMDAzNzcwIDAwMDAwIG4gCjAwMDAwMDkzOTggMDAwMDAgbiAKMDAwMDAwOTQ5MyAwMDAwMCBuIAowMDAwMDA5Mjk5IDAwMDAwIG4gCjAwMDAwMDk2NDMgMDAwMDAgbiAKMDAwMDAwOTY4NyAwMDAwMCBuIAp0cmFpbGVyCjw8L1Jvb3QgOSAwIFIvSUQgWzw1MTk5ZTA2MmRlZjQ3ZThhMzEyZDVlNWMyOWMzN2YyMD48NTE5OWUwNjJkZWY0N2U4YTMxMmQ1ZTVjMjljMzdmMjA+XS9JbmZvIDEwIDAgUi9TaXplIDExPj4Kc3RhcnR4cmVmCjk4NDMKJSVFT0YK';
    
            
            
            Test.startTest();
            
            System.runAs (communitydefaulowner) {
                
    
                // Create Prescriber Account
                acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
                
                // Create a protal user 
                usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Inpatient Pharmacy');
                
            }
    
            system.runAs(usr) {
                SYN_PortalEnrollmentController.getOfficeContactAccountInfo();
                SYN_PortalEnrollmentController.getPharmacyARInfo();
                SYN_PortalEnrollmentController.verifyUserResetPasswrod();
                SYN_PortalEnrollmentController.updatePharmacyPreference(acc, programObj.Id , 'Macitentan REMS', 'Portal');
                SYN_PortalEnrollmentController.updateIsResetPassword(usr.Id);
                SYN_PortalEnrollmentController.getActivePage();
                SYN_PortalEnrollmentController.createPatientPregnancyREMSService('Enrollment', acc.Id, programObj.Id, '',null);
    
                Case patientCase = SYN_TestDataUtility.createPatientEnrollmentCase(programObj.id,'Macitentan REMS');
                Case pharmcCase = SYN_TestDataUtility.createPharmacyEnrollmentCaseInfo(programObj.Id,pharmCAccCaseRecTypeId,programObj.Name);
                SYN_PortalEnrollmentController.savePrescriberAccountInfo(patientCase, programObj.Id , 'Macitentan REMS', 'Portal');
    
                
                
                
                try {
                    SYN_PortalEnrollmentController.getPrescriberAndPatientPregnancyInfo(programObj.Id,'');
                }catch(Exception expObj) {
                    system.debug('error');
                }
            }
    
            Test.stopTest();
            
        }
    
        @IsTest
        static void createPatientPregancyRecordsTest(){
            
            Test.startTest();
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            Account acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            try {
                    SYN_PortalEnrollmentController.createPatientPregancyRecords(programObj.Id, '',acc,'Macitentan REMS', 'Portal');
                }catch(Exception expObj) {
                    system.debug('error');
                }
            Test.stopTest();
            
        }
    
         @IsTest
        static void updatePharmacyParticipantAffiliationTest(){
            
            Test.startTest();
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            Account acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            try {
                    SYN_PortalEnrollmentController.updatePharmacyParticipantAffiliation(acc, acc.Id);
                }catch(Exception expObj) {
                    system.debug('error');
                }
            Test.stopTest();
            
        }
    
     
    
        @IsTest
        static void getPharmacyEnrollmentInfoTest(){
            
    
            Test.startTest();
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            Account acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
            Case patientCase = SYN_TestDataUtility.createPatientEnrollmentCase(programObj.id,'Macitentan REMS');
            try {
                    SYN_PortalEnrollmentController.getPharmacyEnrollmentInfo('',patientCase, acc, acc.Id);
                }catch(Exception expObj) {
                    system.debug('error');
                }
            Test.stopTest();
            
        }
    
        @IsTest
        static void insertPharmacyInfoTest(){
    
            User communitydefaulowner = SYN_TestDataUtility.communitydefaultUser();
            Id pharmCAccCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Account').getRecordTypeId();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert communitydefaulowner;
            }
            
            // Creating Rems Program
            US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
            // Profile Query for Inserting community user 
            Profile prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess' limit 1];
            User usr;
            Account acc;
            String t = 'JVBERi0xLjQKJeLjz9MKNCAwIG9iajw8L1hPYmplY3Q8PC9JbTEgNSAwIFI+Pi9Qcm9jU2V0Wy9QREYvSW1hZ2VDL1RleHRdL0ZvbnQ8PC9GMSA2IDAgUi9GMyA3IDAgUi9GMTEgOCAwIFI+Pj4+CmVuZG9iagozIDAgb2JqIDw8L0xlbmd0aCAzNTgzL0ZpbHRlci9GbGF0ZURlY29kZT4+c3RyZWFtCnicxVttc6M2Hn+fT+HZvrhsp8YSiKd9c0Ns3HXrhxQ7e91ebm6IQxLP2ibFzm7z7SshQH+BAKWdm+tOJ8b+of/zkxBXm4twc/H7BUaegQbsH0aWYQ9M26TXjm3Y3mB7uBjNDngwSS9+ubjaXIymeMDQm4cLxP5sL9Dg8QLzuwfYdgwfD1z6h9jOYHMY/PtyEl4H0WYRLjfvB0PTZTdfrqbi88fVIpwHy4n4Zh2Ob6LZ5vP7wX8Gm59ykhhxmhUhYhm+P3CJbXgmpzNN7pMs3otlwkOSPSbH7av4ahEf48fkkBzP4rugwBS0rAYtzzFMxx64FjFsl9NabyjDQQR4ns5XK3D5MfhN+nkSbsJoMVsGm9lqCe5aRQtxdXu5nn6cTG/fA8E9mRfimoZjklxwExUaXi2uxCLj9HjOUqCGZWqIC+w4aIgQQQWJcl0bY8MldF3LEeuGfzzvsuT0AdyORhYeYa+4O/ceZn96Fxq4pkudxyZMfZj+nyWDB+40Amczx6JLmWYOodwYxPVUUNt1tLEWgHbTdyiHjE80sC2/k0+Kw3aBwJYaZrt6OE42h6nIMqer2dkkhErj0Jt8EUk0LmT3mYmPQ/FxvgogZsmcrPC7htVKtsxKhjZtONgppURIjTNtrAfMCXOcirDK75lmXQTSCgZePQ+XkzAarcPo02wcRsD3g0UIIh0mmWAyicL1WoRaM8nkRB2fRQanuWH3O7lUl1fx8csP4nJpBIa42iSns7gKttv0haUcKeT46h5NtaVELlgu+SYuwuPjPj7egy/+SLYv593XRHx1HWdflARowrA8TuDqJdvvjo/n9AgYXwTiM8IesmQv+fGCL2Nbhjs4DFy/utgPkOFiMvg2WHOzyXRtYhTJ8iqLj9un94OcBEsm2OTk6B+n7pOs9pROaZlWu1NqOxsPUi33NSugirTCLU3br/ulCfxyvJrPA5r4gzmsBOtxNLuWA/mW2ma3v6fGGS3Su90+AZUkPSSj6yx9TrLzKysNoFokALc7ns7Zy/a8S48n8e1DmtW8grPs+K5g+ZBm0kL0pkPMFjJgKWrGR7GU51YBgk0buGQQ/QyC4FOo5oRRLRhZhv8SN3xeRT/DAPssPlMTsmBRZLPCzG5fbrd9Gha8rpjEcJRVhaUmPWROugQqaLclNAcBK1g6CW0GMth3vbnL9oFpPIL8RrRhoDTSFW36uqBW1dUvVJuCuirgzIbeCNSbXPomtOmcTWdMgXVfQZ0V6C9Iw9OMnrcggVRRL4W1HLcurA2EDRarm7amutaOzpbrmyhYjkExjMJfbmZROFGGUcGcbXm0y/a7I4kuV0ici9KiGkKX0YBy6hynpq5qlmgGwpY1sD1al9zWZmmmFrWLWE1Ux6n47+gIc1H7oZw6x6mpV7HMxjHbRUK4ALgBnylgiek3/nW0+jEKpNFjOZ1dw/IyXi0WN8t8Ciu/+olOZevJbNzaS5ZS+25f+qUdRKke0pJxLKsT2JZTbdsVeoJNIhMQjkmHw8txdwbD4TI+JI0EyYa+Si6zI1P08VtPKa1AMQLgujhSb8Faytfby11yqqp0PcVwtj3bsLo8u5udCkjYrM1cu5dznrckzmFxW5/jc0PRhDh89VLVnuG0sdzPSTMee5kmDJEjAdvkTf7zcrhLsoYpcn+3kOEQXhbMtnLIHUgDyWOtACpiraMhYMOxRrM15nFfXLHCUg8LbV65e2nJTwBSEWq1wOgSpWkEXS4q39KyAxKrKqOsigifjvHEl5n+3IwBfdqVY2vJ5EjrKmKLu4xZcxk6+nqMa4tqr4pkBxFf3XwX62uVUuyVbPeW0n4op85x2l0Dr6qsn/QL0a7+91V1EmwC0MFNp6xLWf4ovrq6mc0n9JvRYnU1m4PF2TapWuuFfnqLLvGdylVaFMnjuh3YWnRZtvF7i+4ifm6my/I6zRTZdXgdH5N9S46VWUBYsHCrys9HWt9/AHPuA/gpBRvC5ycwDZ/ypqC8isFo/S541yy8RRIrTII6TNKnamE7gjuBtbQILWHqWaLQsTyc89WgUsOHh2TLdp1GUfJ1d0rugVsrKrpFTKEK0zI7c0KPjI2k0K8Oi/h1dcAmZHaSDA43QGIwTybns+SjDy0qHD/Fx8cERv58tRjfvv+nsh0gjmlg18vZpw5DLzs8RAubZ4IK2toT1BK8T1sheptL4fSvlN6rLUHkeS3lX5MzblpNiQnEKsKnck8H06FYZh35I2SPULM2VRw4JQeW4as5qPxLC23Z7HdC1YhJnhdb0y/TJfGo4KZXbEIaLm5Z038DFgNsk4Hc6L5sc8umoz29xzWcshP5tf15k+X4hkvRnoii5arp05wNbrZ+PbhW5Qu47QkB14IWEgNkk3hNEtcxsFVsiX0O1zBiYUF4TU6gVPDN92qPaTEWV/c0842O8BHbDmSW+Gu828d3e1h3kuO5UcEK5hxXMHefp1QlB9v4lMDaBYjfJfv02+17Q9kpdOWHWoKiybNSfOeA3oGUyjMbr5xSNjhWTfdpCmT7LT22DOFdaUGfqXpW6GefV0KJf7gLt0w7a6wyFUGijN+uRKSB5SajFdZ2ihGXFkfsdOhHC8t9poTq1hRMKTjsPo9m+VqC+WtscJ1pikcgtstT3rJsZQxNhk2wsrrzUaVaG+W+gYSf8bZq6HmWa7g27TKkwM8f7KvCvKCsM4cREwmJ+nouDSxnoAC+bRQjbOTHxaPKMcwQ4UR+hNY/iQWfgtk8oAOUtH9Jp4KnZPsFZNU9GC3OTzEYAuLn5/2rodpZ6xVQ1rBFhNa8FmCpYR1szkAJbNOwekojiAgN44bz2CxaCKuzdOWOKm47+VrIsOye/sSxdZGcNkfq9TG2x9oYdl7J9HrbGBfVxW+cFqrVodnx9MKeWyc9hR1617Y5cz7H2Xm33T3TQAZ3744t0ybfLmiGdX7ARcM0lqWtcYudMNGEWs5brWPRjKVvHj6rSfaJkseXfQxGr+ssfcziQ2PPjEvcrxpicXlxDuzqKEkRLBrIQt24hXgVfcSry6c4nFZJqJo2eWvR3PawaCNfLWqqY9ryLa2Ytugg0SdyHtI6QE65ALarJo9MSYi/GZnSVo5umN6nSdsSIILfHMCypZiopZBWi6XYoTcdS7EnLFqW0gByygWwz1JQiM4zK2rrQMWBfZZxGp/O0OZXcZbt4M5LlJzSl2wLzRRkSQztOr6KArjXCjcUV2yP59sOtk803M7J9gy3seorrq6D3JiVJ77dNQ/xa80ZuB4dLPQo+dtdonDfukPxNVhWqRomKvyI8gv25JLT7vGYn+ORN+o+wHMjtUzMTq9QJ5TX/m/xn7IX6m5Far2Q6Wl3mzpYzkABfFu3adEJpBJwAmxcO6mrkriToCyxSfVZSmF3HFBjEutgcwZKYM+pgTzpsCMupZgzsN3R85xB9Nbgue11OJ519OH1M89BFAYwmn5bLeGGy3i13ASzpfT0Y/MR0J6HG2oKcMe74B2IaHAq6t2ndzDwG5uuVLuGR+2Gc7V1DIXE9xiQDdqFIfwWmyFHD1iQLoDtG5rsAHbNXPn2VK1IUKfigvh0RuwQxKbdDieL/YI9drxbhaThoInkxDmyZTegFmo29Vc/lwqbjc3GRmDaxK3roNpsbJtpLATieNa6g/cgJ+pddw+RJb+/7DJYGe5AsyAV/FoFmOxOtJIlct/KyoyUhYMtSPiwy8O+aymbB9MnajGP6V+WUio7/2+Rq3v3SW138ww3TyVGst3pi3rRXBG0M2nr2KRRTir68Jf0uH+FGrp/2Sb3P9QUqLCVBzYysuSQfk3u1Ts13Ym8Vklo41fmGrPntIsOljNQADUqiemCjmUjafA+oeY/7Oq9BoTcxdLzQghL/ojpvZKxGi017KeepY15YKC/+wKQMPTX3Uk+Rn0Gm7y7c9uTgZwbhT84ptBcyhpR6JbVYWvgVwmV5F5NfZ9upUlEUtVd2ZAfag35k9SQp13Ti6TqFrft9BrZbbElmhqMvW6/1QLnLJTItzV9JttnqCZw6aD+gr2gJj0OWj0zq8T77jPwfF3aTFrIBMcfiqen33//vbjYfMwbsPKIVRixs8nj8o2w4utp3tcUF5NwsVquN1ENc30TXa/WIVhstZx/rlFV2K1baTW7sZe5NFt1HSxnoAC+zWrYAvEzhbUiYq8WhtE/gN36XncqWeh8t4RrABMhVedZzg5kW9uCMfBE9pYSyCnFm0ngm004D68/0vYZhOrN4gq+GHArdQW1LHN+ikHIz5MjTZRth0ZLBZlUkk4n6ZG86SXt2Eo1mNJ2XVk7k2AD5IaH3LtHtfytHzqpFa8PEtpVKttaLokW0hHAlheEmgnCR+zRDUa2yBDjNEvm6eNuC8K+6KmKy3WSfd3lmx1SOcHsLU174NuGY5bZBvvIFDdevWTHBLx6FqXxfWMRwhahTYpPikWCl9N5B18K2/wqPruea3v1NcxcKpe9GVsyMvQQGhLiDrHrmuoDmDpKLt1FzyBIrKp2WPlMsmQG5IxMcwTfuouB5pD5Afsg5y5A6p5sGs/v2eqeL+ySG3ScZGDF7z6Iz9hFDiLIdUzlSrQlrowj1ZD5bBoOV9Nh8aJLI+GzHOoatSMc9Jq2IGZ5gGMaLsBcPqX9h7hCnjNEQ4t5FK0WiGcWqijs5AO2h9l7QC6WBRh6+d765Yh+tPP9ycvNZDzchOsNpl8R7LDzo9jKJ4O8iVb3IsAgZUcF2rTSIGXyB+csc4MMXUSt62I6vPL3qMXvwzZxr2N4aAu3TCjCmf8E41mKKwoKZW5kc3RyZWFtCmVuZG9iago1IDAgb2JqIDw8L1R5cGUvWE9iamVjdC9TdWJ0eXBlL0ltYWdlL0NvbG9yU3BhY2UvRGV2aWNlUkdCL05hbWUvSW0xL1dpZHRoIDE0NC9CaXRzUGVyQ29tcG9uZW50IDgvTGVuZ3RoIDUyMzkvSGVpZ2h0IDEzOC9GaWx0ZXIvRmxhdGVEZWNvZGUvTWFza1syNTUgMjU1IDI1NSAyNTUgMjU1IDI1NV0+PnN0cmVhbQp4nO2dIZfcuBJGmwYHB4UGhy0MXrY4NCw0eNnA4GGhwcNC92/53eP7uo4i22rZkrvdnSkwx+2RZKk+ValUKknDcH/033///fz589u3b58/f/748eO7d+9OFfTmzZsPHz58+vTp69ev379///XrF+XcuimPSTAWDoPOX3/99f79+7dv387C8f5MgEhK0PHnUnqAJuXff/8N9HSAW7fy7unHjx9fvnyB7TAW9srktyPB53/++Qc+k6ZeTF5eXsQdjCznzZl4BlmkjwSvcreKgAAsQigUHOQFPfb8/Nz3WyD49PQEgvSKVAzpD3QGdGbfzz0SwTqkCUaFKPHMGzTVdTq82Cl6ooZc85OXV/j6HREqiO4deolnRKkeI1MiDl9GIi+c5w0P8WatYFIldKN62FpRzquehC0oOjszSg+9hDIspA8FBQRk/DgSuXgDS+EwqKFL4bPCwk/llDRw2/+S+N9//4X/JCibGWahWCVO1P5MywReheqDvbClnB4Oa+/BPVADrKzDU0gIEWlI7zNMjvegRi4eyP5pJMrk2QlCQXxAn2TWlgJRkn+OrCFTzpicENWMDqBJSju2f+EYksIz2SlwGPFSE2pSBj+BOKQycIzSgug8F2tCOTG6UXkq8Nio0V7aaC+tREoicTYAAQ18o89ToOXAcIWF8kO4ht/xIg36FkwBF+xAVqzTZNqKoUKnlbFL2Apypd96JEJG7JlL2g/mOCpBGZQpzyVNlJSfOi54AEGeZ/OShWfy8jImYhRCZwCgYRRbvg4ivPR5qTmhIR0ftXAeg+AGjArNPzupoZfyX1hNYp7hp8yX1H5pYpUqaeC5SJEmhMVyIq8PfJcsPCAdmihBpNeQMEFQavzMWphCr3p0ZLx3CrGa6rSU+BcND3lRfOK/clKHhnaCQwls15VUOY44ZgF3VhP1JC+p6mxGPgQis7Yrnw71SDl3PaLB2Ji8TP8Lwz+MpKXHQzoWqLvip6Z1OuL0IkpW7/G5qeLlv/YQ0ogyFZiOvOhDzV0ae48jGl1RRcHfWbGi+XRaOjwpgSZkx/9q7V/8StqZ7efBbfmcGoE1QGtbUhN4Tl5K06U/jH3PhlBhvcTTiZhiCGX69uAUOtCxe5pA7Rc/4YCzJ80ABiMfyl+RmSnTsm6fSQpdIirDw9JISjWARmWrwelEPu14oKl7Px1kp22/C91IF9W0mLYlHZ5S8VEZwnnY4jg121IVVy99CPPTr0z71fNIfteKRd9QdSvRw+9iPoz9hNZpCR/cGeL0CrCmXZ0e6xSJttNY2hLNVCVGyjTj95H2rjZcvTj5DV1BP0xtIVo6NfvVxkJW9rDdkKwhYE07FUgpbioxsNMX9HWkwtx5w0piuxbio1PloP6k8BQCfqInlypPltnee3Oi2moAKj/tTkhTTIKGUfOQDBR4T69G3FJdpFbcVg34DDO7+NKXph7Z3I1e50/SuxCQ6YewQA4FWYA1a13QinS2O8z5K4J+jrS2AtpsToKkbHbQQgXZd9IBUvQToeRN1mOdnR1HylSD6Ww3I2e7gUJmbAyjeG4WB9jlLG8pwKZ9+HDeMf2uWkLjdmmmL4HUQaRMFZ3NbYex76U/NdF1H015iPRtMCo0z2ZjaTLUUku+kdJ+ZSvSaaOUOTYlpey25kdI+qyBkfk00PCAtWrhuEDhuKuk2bnSBrLLpW8QmRQv+q1OLZqZSZNjmWup7TVZS9RcazDtMM6kqI92YEAGoJnRm5kZ9aTxX49UhtoeswODc2i7XilXyelOoJOlRB1ZjStPpVXI2RjqfDbFyOUhOZyN/huMAfqAXXQbWBLZw7PUixxDaSxAOLt0KXw6kA3jPO40ej86VuBi9Rw1Mp6HDrT+w9nvtGppconCz9OFurj4aOy017l4pG0fs5hUk6iCruljnO0hzqqM2VM/+B79E7V1bXft58B6swIsEx3gYtxImabN0V08jArfEdOg8SyXoapXMBepgwGc0wmU0pQtNaZEf1uFl17ZRgV4kTr6JIfzEtsw9mrgwDSdXX2WjXsPZLTLYWvJKHWo6iXpaZTvfuSCfmNVQSfjiXH7mamfta7LpwtkXFPZMNYyTNO0RDXruNgPrC5j6zCqgmxSU4OFen6nQAKk5lRn2FD56GyzvtOaElITzuiOvkgtrXr3ohofJlw6jQLeXSsa27BhrrdNuFS89I2007oI1QUp1NRBFhPrpWAVaRN2cRHUkHhNpQD4lryFlWRozX4111Ffn14/JC3qaPOg006jR7dXgRcp8JKykEXnOGtRq4n67kJr1xd0PsxOrreRvuVVHQA7vMWHkOEVopGWibBXqkeEdClY9yCkTZWtOm0j4zEKduksNe50m8XrNNlrYIB3GawsSuqYRA0VisZyjImd9cDvSkt4SZkzBxNoOqjVb6bYifT91qfX8Gicuipc6Wp+mXrpnDJeUgZH6ra62lBVplW2NBKhBd6impz11H/XPT6bPxdUg5dClNn8wLQUWHh8cqV+86xQCV07cnWhSrwCtcfYQEfHUzlsy+7u3e5b8mtoFV6nca5xWKMCka83rTUUNyhzJwXXXFZLqR6vvd1K7ZR65y4SKV3+WPsVLa56+6rL3CGoBq8skIYxK110O6y4XSS3Aa5Sa64g1ytSN/tsqt08XcQrC0x1i190S3cZH1zulsilsVWG/VozvjsV8Mq2DLtIGv/ypWEtasvj7MaqVFYKSyGec0py4IaRcrN4ZYHWblJIk03xOp1t/ptYTSm5A6IysVZHJb6MCKc13t09RooMr+k8azZSdBavwPqObH50wql6kUVlWKn8KXmPRZYULzpbag/T65bcvAW8AverLQk1kr2xJqUbB267aykCRVL2uvOxYIdcxOt0AL9iJenrqNlkSu9dNdjtQQZvRx14yIaqzXgFapmCvVq7Kg1p1xwvzpKcJt/EB7VEHmVT5v9avAK1K58pVD/x0f17cRFTn2Glkt97p6qnBNRwfhtekesIzvwpebBq2Xft4FXpkN97C3z9CnILXp6rs18rNpOxsoWhFuZ3WeXsSG5Ur/QlbtCH0zjPK1BlJ9eqLzg6GA1Po/3cr2p9yLDhjvaGiW9lJVau0KHlyi53bZLDns3iPp12vNxrfMOG1I/7xtgv/ddm1jjc6B63mngWtoDV4LV2z8VtyW0sS//VGKuZlaCgbugoWNpjXsDLaPbDHl2yRIbpLlXbI/TvxcnmOQMX/b2nQ1rslREmRustVX7byuZtKd13OYvXMc8hrzTqCiaiK9G3CgBoJFrkmpE/nQKgMw87VFVqZjewzIIrXpUzx6Opl2Gsf/TDVSEuRybU5mmc0U//peewEq/D2vwPRmjyJbw8g/GYnpk/mYyHn/3XqruZXuk6tO0AtFc6Dj0/Pz+tpFcxbCe02Vq2m3HDpuBXe6OR6PAbdtAL2Qa8Vh304QlmBqBO79roS9hLO4VN2vBepV3cZtgXr1NdTH4cO3wajdK42We/eAMP2tpDXXuxy8Vkv0a6mGzb8RQteC0ZmVkbT+PGupjOe/zmPeJVSU/jJXFlyGDCBoY34gWVg2at1cUgfBG0wCzW2gUvbxBII6v19J7OJ2mkzCnjFRlPc07g2KHphjKP542R2qtDIvHLy0uEbKXz1poD2ONKwSvjVR4panYLUgH1pBfeudwTWTwSM662FC+4YRaS6SdM3WsFvPyW2tgNEem2AiMe5by3cohF6ECbHKXJNC/mMHHluGzg003wKh93YxB+Ya7nWe5UPr0mw2OyzCVe2WaNdyOFTLkmHotxBbwEKDL6rYiM9b+pxrC/zeKlZKW1qjeijEC7CV6nYuTbxU0TKsxMSMVITeVzOsob0qCSdOJPE9I0S3gZmpJ527yNVHGeHs9l9WbxahklW7jdjldBJboIVZipyeoMcbnkyxQ7Kc6peJvQadSZZU4ufSvEZHrCTNYTAi/vdNh2HI3+9lvhVT70Jnib6UwvYx3O26uzXi3KVky80k84zSws9i3h5aabLKNqLW4gTXuXhw/P4jWMBkPhEMgytRwP2IjXxT4m87XEQn25EVKWOlLHErCLxfHfKV7DeaNuSAplpiaN18q7/hUkY2e/FearlxrYKFjqJoJTcjxCipfLviSLjkdLK+FzHeQmeNV4pTThQoO9+f26vRj0tSLe/H6a/SxecV6xLBXfEOEwyFOyX3mQZvatlMmev82/3MAiKFHVFK8huctGk6l+I6fq9Pp41YcBwxNtb4iHqUnpISdQdpuAS8ZL95N6D2yWhaI+TygdAf3WNOMwiYHRPkzv2s76p9XzyptVSx7bnFGNeB0wDLiF3AboNBlySrv56JIyOZheE69bnaOyH3kWt2f+q2l33Wq0TSVuxqvj4YpHo5eR9v6Kg+M2vNZifUe7gI9MG0TsMYK+XumV7oi8A7Qy8Wv8206EOQdva4y6VedNvWrUVcRkrdINotuqJrFehStE1Cwtnddb0bcN09rw9fppdf3G5EIM8FqieyDU/A0xTNtIl5gVz+zm8UI9I7s3+i0ly0ojMW8a94JNrzvseAitIlMfOKQXrn5GXOg2+t9omk4byoyLs71mVNT010H8jPhGUuq5fRovZuIhvSLNZ9J4CImBEz7rgNU3ZTiBifUgmYwHAy/5F3+tlVdF+12erdUwdi2ePYHKHmiB6U2pZOFnl50g+jnr+b/qvKlhVLZLvcv60yge6Ni0Om0gz3zreST+xV+5FC70cLDLbf5GdvlsLkhY+QQPHksiduayWBHnvbd1mwvyu1ErCgm8/JzfJa/XeYuXaIac2mGWFpq94LKGmd7mtsojESv1d3rQ9AGp3h4wYGDtjnjXC45z2OOfQyrDtcMrKmIa0tCLojJxo6WX4arNpnr755nS0QHZLygfx0r/bqsk5ZeDheK5o7/REIVt7lkdXPUixjCd2XvqeQcLw/sdsGKR19EnjA0pTlHWYPClY1lc4il2LmZZfkRpUri2hB91TCGXZxpYDcc1KD0wTZQduSL7MHZd753nDRWjkCjQZP5V4023S68aU7T0ts1qDRWrx1rpSN/w04uKHOW1u7wi3K4rc/So+CxGCoUnvgYPBUiPimEA3gVvmaHwSSDKmgT89GpdbVTNBl7aecIyNKPptf3MPoydKpDVwrS21sryrZj9M1tyrXcBuVu5Ze1DEdusUuzDm7/eiwB3er/kAcnjKVpsBiP07vTQgPsiOnZ6xME2MriFclaJWFkDqIUKCTQ8EIdZzb9WTNqnJKHfMl3h+17r7MaStS8sRuxWfRYH7tn3jgIO8TqUNAPgqqOG9qGYOpl1rHd8TyfOjvIRVB/uCEcoCvTZcrQ6zOvA50ttlTCKnHHbatNrDg3nK2vT7xoLBJ+n5oH3bNZzLM4rrs9SIAMGGuditFczIPAKJ4NBU/4NW1FLwCFeX5DGuTaDhQjNkPQEcxl6oXdIa0Sb0M/xXm7rqeAZhe8JZjzb0wQx3CPD2ZoyDX/5qbloo6btXSXX2gm9TjUJ9O9l2/J9rfJMtwm0kyFza7ea2j87VuP4tHa4dHvR5ujuvsWSq9DVkdZp63gzHcH16M5+2gGaopzVDtUcUxtPqzR9U69VaOzaBXejUvfYc712+nyRHGLSDaR6SLzRNeLeh7PBGWOZcfguq2kI+Rx+fp69XspRxpHLNDFCacM4GTevE+r4hKOkM/14qdnTiwPacr3MjCk5LPaK2dAm1Cy0D8s3La64CjPOMnWxKXUsaCoMI/M1UVxWEwKDrjUbwoOUfit8LKknKlwu4mveMCntYF2aT18yjH8/p7pasbyNaCljwb5t8TwUlNXVrCPnI2tzGfK9d8DS03iMGx1jLZMPexRhO22ww50dXydMOnZ1XeFbBSovdtjh1QPoWIcz9dvNTVbXqq55C3m2G3EVuSzSXgcnxXquYgjwcs/46UnvTpl/nKnL7GzzWXbu3ASva575GQPZNn9Xu88tlpwMptIG0IRIw660k3VM2ZlJHCZHC207bJbO09dmqye3Y9efO9GXVHculAzJnMuYxuCkHSNFZ9V8qjsZBXqrrXNuxW2BzAXNvrXajy4eNFSmOJ2pY5XWkpfPYi5uVnH3su8PqWy5xUM/BmDdPOTM+y67WDv35aetJ72v1zQIyxSb5RsZ7sJHr1q1k+G+jYUoWRtmrLuSUY5AdiiG35wcs7q737sQijE9SK2RPJW0vZxVxOASp6A0EuOd1iBj1mF9Ox4ak51d1qvknSaYMTXrSBSoS6Gws+Ag5BpB90Nfsx1ALT0WBqZTMFdVmir3O9EB4nTEjsXuR15f6CC7k8nnQkz6M5U+KpD26kw2I0h4D9K6uLubMuKk5es4yrKtmi5jxc+l0Li+hMiHdXGn+0TCAgG7e4nV2UbfzteQoVgOZbevJVSTHs6+p6zohz+C3QU62oGe0nzr6nQg1+gVtC6XSDo+etCxLOIND+50SI90y+5FNdig8espoUAUK0bqB5t4xh3K9sOWAQUIwviMk5kZO2LnURTuOdgxlmlmt7Xj/+TBm3p1Hvh2ElinretRn9tQ85TL9EjP2Ws4DP7/Nh4jn75pHElBKg6Q5+GuR6saCjtKNULn3MZAMoKa8wX1rUe5hp0fHhJFz5dk2ayQUadxI+39GoHbCIxUVsoaLK00HsyoYAKZ0xzeyL0Uenjr3R/8jZMneRm7Ler7CYWH1aTMrmnr45A7KONWC1CrOfcAmAIIhYWM7qL1LJThvPIe+16BKU7S8IRes5Q/5G7KOPjOc307Nf2OyYOOdTyqJMHiomMkjXhxkJLUgYbmpok1FI3PKXcJA1k9zDlk6hWpKRkeEOedhsRdYUwHIwO3QpqcfWyLBf2jyK12HhMXrHOqJXa9XCVuNwMjvpUeiotYRTT4K60iQ9ZVTTHMuVNGk94tEg5SS4KgM8S4RNDxOgALDGPPu//cInHlNj4keTqK571r7xXOuRXTcgLgBiARP+Di74ORkb2OOPAczmtsTHEMO0SDUIvxfoek/wGT2vsJCmVuZHN0cmVhbQplbmRvYmoKMSAwIG9iajw8L1BhcmVudCAyIDAgUi9Db250ZW50cyAzIDAgUi9UeXBlL1BhZ2UvUmVzb3VyY2VzIDQgMCBSL01lZGlhQm94WzAgMCA2MTIgNzkyXT4+CmVuZG9iago4IDAgb2JqPDwvQmFzZUZvbnQvQ291cmllci1Cb2xkL1R5cGUvRm9udC9FbmNvZGluZy9XaW5BbnNpRW5jb2RpbmcvU3VidHlwZS9UeXBlMS9OYW1lL0YxMT4+CmVuZG9iago2IDAgb2JqPDwvQmFzZUZvbnQvSGVsdmV0aWNhL1R5cGUvRm9udC9FbmNvZGluZy9XaW5BbnNpRW5jb2RpbmcvU3VidHlwZS9UeXBlMS9OYW1lL0YxPj4KZW5kb2JqCjcgMCBvYmo8PC9CYXNlRm9udC9IZWx2ZXRpY2EtQm9sZC9UeXBlL0ZvbnQvRW5jb2RpbmcvV2luQW5zaUVuY29kaW5nL1N1YnR5cGUvVHlwZTEvTmFtZS9GMz4+CmVuZG9iagoyIDAgb2JqPDwvVHlwZS9QYWdlcy9Db3VudCAxL0tpZHNbMSAwIFJdPj4KZW5kb2JqCjkgMCBvYmo8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFI+PgplbmRvYmoKMTAgMCBvYmo8PC9Qcm9kdWNlcihpVGV4dDEuMy4xIGJ5IGxvd2FnaWUuY29tIFwoYmFzZWQgb24gaXRleHQtcGF1bG8tMTU0XCkpL01vZERhdGUoRDoyMDE3MDYyMjE0MTkyNi0wNicwMCcpL0NyZWF0aW9uRGF0ZShEOjIwMTcwNjIyMTQxOTI2LTA2JzAwJyk+PgplbmRvYmoKeHJlZgowIDExCjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwOTIwNCAwMDAwMCBuIAowMDAwMDA5NTkzIDAwMDAwIG4gCjAwMDAwMDAxMTkgMDAwMDAgbiAKMDAwMDAwMDAxNSAwMDAwMCBuIAowMDAwMDAzNzcwIDAwMDAwIG4gCjAwMDAwMDkzOTggMDAwMDAgbiAKMDAwMDAwOTQ5MyAwMDAwMCBuIAowMDAwMDA5Mjk5IDAwMDAwIG4gCjAwMDAwMDk2NDMgMDAwMDAgbiAKMDAwMDAwOTY4NyAwMDAwMCBuIAp0cmFpbGVyCjw8L1Jvb3QgOSAwIFIvSUQgWzw1MTk5ZTA2MmRlZjQ3ZThhMzEyZDVlNWMyOWMzN2YyMD48NTE5OWUwNjJkZWY0N2U4YTMxMmQ1ZTVjMjljMzdmMjA+XS9JbmZvIDEwIDAgUi9TaXplIDExPj4Kc3RhcnR4cmVmCjk4NDMKJSVFT0YK';
    
            
            
            Test.startTest();
            
            System.runAs (communitydefaulowner) {
                
    
                // Create Prescriber Account
                acc = SYN_TestDataUtility.createPrescriberPersonAccount(programObj.id);
                
                // Create a protal user 
                usr = SYN_TestDataUtility.CreateCommunityUser(acc,prf.id,programObj.Name,'Inpatient Pharmacy');
                
            }
    
            system.runAs(usr) {
                Case patientCase = SYN_TestDataUtility.createPatientEnrollmentCase(programObj.id,'Macitentan REMS');
                Case pharmcCase = SYN_TestDataUtility.createPharmacyEnrollmentCaseInfo(programObj.Id,pharmCAccCaseRecTypeId,programObj.Name);
                SYN_PortalEnrollmentController.saveOfficeContactAccountCaseInfo(patientCase, programObj.Id , 'Macitentan REMS', 'Portal');
                SYN_PortalEnrollmentController.getUserDefaultPharmacyInfo(UserInfo.getUserId());
                SYN_PortalEnrollmentController.saveSignatureAttachment(acc,'Closed', t, null);   
                
                SYN_PortalEnrollmentController.insertPharmacyEnrollmentCase(pharmcCase,patientCase, acc.Id ,'Closed', t);
    
                SYN_PortalEnrollmentController.insertPharmacyInfo('Enrollment',pharmcCase,acc);
                SYN_PortalEnrollmentController.insertPharmacyInfo('Enrollment',pharmcCase,acc);
            }
    
            Test.stopTest();
            
        }
       
    }