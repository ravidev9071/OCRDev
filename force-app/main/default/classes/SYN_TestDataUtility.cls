/**************************************************************************
    * Name :   SYN_TestDataUtility 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Praveen Vellanki       9/13/2022             Initial Version
    Dindu Thandavakrishna  14/09/2022            Clean up the class and Added Extra Methods 
    *********************************************************************************/
    @isTest
    public class SYN_TestDataUtility {
        Private Static String frp='Female of Reproductive Potential (FRP)';
        Private Static String open='Open';
        Private Static String unsuccessful='Unsuccessful';
        Private Static String patient='Patient';
        Private Static String closed='Closed';
        Private Static String successful='Successful';
        Private Static String prescriber='Prescriber';
        Private Static String Distributor='Distributor';
        Private Static String Pharmacy='Pharmacy';
        
        
       Public static final String ServiceEnrollmentActionName= 'Enrollment';
    
        // Create Rems Program
        public static US_WSREMS__REMS_Program__c createProgram(String Name, String Status) {
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c(Name = Name,
                                                                                   US_WSREMS__Status__c = Status,
                                                                                   US_WSREMS__Program_State_Date__c = System.today(),
                                                                                   US_WSREMS__Program_End_Date__c = System.today().addDays(20),
                                                                                   REMS_Project_Code__c = '7433'
                                                                                   );
            Insert programObj;
            return programObj;
        }
        
        // Create Rems Service Summary 
        public static US_WSREMS__REMS_Service_Summary__c createService(Id RemsRecordTypeId,Id ProgramId, String requestorType, String pathStageName) {
       
            US_WSREMS__REMS_Service_Summary__c serviceObj = New US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__REMSProgram__c = ProgramId,
                US_WSREMS__Requestor_Type__c = requestorType,
                US_WSREMS__Path_Stage_Name__c = pathStageName,
                recordTypeId = RemsRecordTypeId
            );
            Insert serviceObj;
            return serviceObj;
        }
    
        
        // Create Rems Service Summary with PatientAccount  
        public static US_WSREMS__REMS_Service_Summary__c createRemsServiceSummary(Id patientAccountId,Id programObjId){
            US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__Participant__c=patientAccountId,
                US_WSREMS__REMSProgram__c = programObjId,
                US_WSREMS__Service_Outcome__c=unsuccessful,
                US_WSREMS__Status__c =open, 
                RecordTypeId=SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Enrollment'),
                US_WSREMS__Requestor_Type__c=patient
            );
            Insert objService;
            return objService;
        }
        public static US_WSREMS__REMS_Service_Summary__c createRemsServiceSummaryDisenrollment(Id patientAccountId,Id programObjId){
             US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__Participant__c = patientAccountId,
                US_WSREMS__REMSProgram__c = programObjId,
                US_WSREMS__Status__c =open, 
                RecordTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Disenrollment'),
                US_WSREMS__Requestor_Type__c=patient,
                US_WSREMS__Service_Outcome__c = unsuccessful
            );
            Insert objService;
            return objService;
        }
        public static US_WSREMS__REMS_Service_Summary__c createRemsServiceSummarypatientclosed(Id patientAccountId,Id programObjId){
            US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__Participant__c=patientAccountId,
                US_WSREMS__Requestor_Type__c = patient,	
                US_WSREMS__REMSProgram__c = programObjId,
                US_WSREMS__Service_Outcome__c=successful,
                US_WSREMS__Status__c =closed, 
                RecordTypeId=SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'PAE_PC_MI')
            );
            Insert objService; 
            return objService;
        }
         public static US_WSREMS__REMS_Service_Summary__c createRemsServiceSummaryopen(Id patientAccountId,Id programObjId){
            US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__Participant__c=patientAccountId,
                US_WSREMS__REMSProgram__c = programObjId,
                US_WSREMS__Service_Outcome__c='',
                US_WSREMS__Status__c =open, 
                RecordTypeId=SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Enrollment'),
                US_WSREMS__Requestor_Type__c=patient
            );
            Insert objService;
            return objService;
        }
        
        // create Rems Service Summary for Distributor
        
        public static US_WSREMS__REMS_Service_Summary__c createRemsServiceSummaryDistropen(Id distAccountId,Id programObjId){
            US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__Participant__c=distAccountId,
                US_WSREMS__REMSProgram__c = programObjId,
                US_WSREMS__Service_Outcome__c='',
                US_WSREMS__Status__c =open, 
                RecordTypeId=SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Enrollment'),
                US_WSREMS__Requestor_Type__c=Distributor
            );
            Insert objService;
            return objService;
        }
        
        // create Rems Service Summary Pharmacy
        
        public static US_WSREMS__REMS_Service_Summary__c createRemsServiceSummaryPharmropen(Id pharmAccountId,Id programObjId){
            US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__Participant__c=pharmAccountId,
                US_WSREMS__REMSProgram__c = programObjId,
                US_WSREMS__Service_Outcome__c='',
                US_WSREMS__Status__c =open, 
                RecordTypeId=SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Enrollment'),
                US_WSREMS__Requestor_Type__c=Pharmacy
            );
            Insert objService;
            return objService;
        }
        
         public static US_WSREMS__REMS_Service_Summary__c createRemsServiceSummaryprescriberopen(Id PrescriberAccountId,Id programObjId){
            US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__Participant__c=PrescriberAccountId,
                US_WSREMS__REMSProgram__c = programObjId,
                US_WSREMS__Service_Outcome__c='',
                US_WSREMS__Status__c =open, 
                RecordTypeId=SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'Enrollment'),
                US_WSREMS__Requestor_Type__c=prescriber
            );
            Insert objService;
            return objService;
        }
        public static US_WSREMS__REMS_Service_Summary__c createRemsServiceSummaryprescriberclosed(Id PrescriberAccountId,Id programObjId){
            US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__Participant__c=PrescriberAccountId,
                US_WSREMS__Requestor_Type__c = prescriber,	
                US_WSREMS__REMSProgram__c = programObjId,
                US_WSREMS__Service_Outcome__c=successful,
                US_WSREMS__Status__c =closed, 
                RecordTypeId=SYN_CommonUtility.getRecordTypeIdbyDeveloperName('REMS_Service_Summary__c', 'PAE_PC_MI')
            );
            Insert objService;
            return objService;
        }
        
        //Create a case 
        public static Case createCase(Id caseRecordTypeId,Id serviceObjId,String FirstName, String LastName, String Status){
          Case caseObj = new Case(RecordTypeId = caseRecordTypeId, US_WSREMS__First_Name__c = FirstName,
                                  US_WSREMS__Last_Name__c = LastName,  US_WSREMS__Phone__c = '1234567890',
                                  US_WSREMS__Fax__c = '8785968578',Status = Status,US_WSREMS__Program_Picklist__c ='Macitentan REMS', SYN_Prescriber_Signature__c = 'Yes' ,
                                  US_WSREMS__REMS_Service_Summary__c = serviceObjId,Program_Record_Type_Control__c ='Sodium Oxybate REMS-Prescriber_Person_Account');  
            Insert caseObj;
            return caseObj;
        }
       
        // Create personAccount 
        public static Account createAccount(Id programObjId,Id recordTypeId,String FirstName, String LastName){
            Account accountObj = new Account(FirstName = FirstName,LastName = LastName,US_WSREMS__Email__c='test123@ypmail.com',
                                             US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                            Industry = 'Banking',Ownership = 'Public',Phone = '1234567890',AccountNumber = '4567',
                                            Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                            ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                            ShippingPostalCode = '12345',SYN_Shipping_Address_2__c ='Test');
            insert accountObj;
            return accountObj;
        }
        
        // Create Prescribing Institution Account
        public static Account createPrescribingInstitutionAccount(Id programObjId,Id recordTypeId){
            Account accountObj = new Account(Name='Test',
                                             US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                            Industry = 'Banking',Ownership = 'Public',Phone = '1234567890',AccountNumber = '4567',
                                            Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                            ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                            ShippingPostalCode = '12345',SYN_Shipping_Address_2__c ='Test');
            insert accountObj;
            return accountObj;
        }
        
        // Create a case without Rems Service
        public static Case createaNewCase(Id caseRecordTypeId,String FirstName, String LastName, String Status, Id programId){
            String strRecordDevName = Schema.SObjectType.Case.getRecordTypeInfosById().get(caseRecordTypeId).getDeveloperName();  
            Case caseObj = new Case(RecordTypeId = caseRecordTypeId,Program_Record_Type_Control__c ='Macitentan REMS-Prescriber_Person_Account', US_WSREMS__First_Name__c = FirstName,
                                    US_WSREMS__Last_Name__c = LastName,US_WSREMS__Channel__c = 'Fax',  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(2016, 12, 9),
                                    US_WSREMS__Fax__c = '8785968578',Status = Status,US_WSREMS__REMS_Program__c = programId,US_WSREMS__Program_Picklist__c ='Macitentan REMS' ,SYN_Prescriber_Fax__c = '9876543210', SYN_Prescriber_Signature__c = 'Yes',SYN_Prescriber_Signature_Date__c = Date.newInstance(2016, 12, 9)); 
              
              Insert caseObj;
              return caseObj;
          }
    
    
        // Create a case without Rems Service
        public static Case createPrescriberCase(Id caseRecordTypeId,String FirstName, String LastName, String Status, Id programId, String accountID){
            Case caseObj = new Case(RecordTypeId = caseRecordTypeId, US_WSREMS__First_Name__c = FirstName,
                                    US_WSREMS__Last_Name__c = LastName,  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(2016, 12, 9),
                                    US_WSREMS__Fax__c = '8785968578',Status = Status,US_WSREMS__REMS_Program__c = programId,US_WSREMS__Status__c='Initiated',US_WSREMS__Program_Picklist__c ='Macitentan REMS',SYN_Prescriber_Signature__c = 'Yes' ,US_WSREMS__Facility__c=accountID,Account_Name_Secondary_Office__c=accountID,Program_Record_Type_Control__c ='Sodium Oxybate REMS-Prescriber_Person_Account'); 
              
              Insert caseObj;
              return caseObj;
          }
    
          public static Case createCaseMACI_Veeva(Id caseRecordTypeId,Id programId,Id serviceObjId,Id presAccId){
            String strRecordDevName = Schema.SObjectType.Case.getRecordTypeInfosById().get(caseRecordTypeId).getDeveloperName();
            Case caseObj = new Case(RecordTypeId = caseRecordTypeId, US_WSREMS__First_Name__c = 'FirstName',
                                    US_WSREMS__Last_Name__c = 'LastName',  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(2016, 12, 9),
                                    US_WSREMS__Fax__c = '8785968578',Status = 'Draft',US_WSREMS__REMS_Program__c = programId,US_WSREMS__Program_Picklist__c ='Macitentan REMS', 
                                    US_WSREMS__REMS_Service_Summary__c = serviceObjId,US_WSREMS__Participant__c = presAccId,US_WSREMS__Call_Notes__c = 'test',
                                   US_WSREMS__DEA__c = 'AW9292765',US_WSREMS__NPI__c='2222222222',Program_Record_Type_Control__c = 'Macitentan REMS'+'-'+strRecordDevName); 
              
              Insert caseObj;
              return caseObj;
          }
           public static Case createCaseSOX_Veeva(Id caseRecordTypeId,Id programId,Id serviceObjId,Id presAccId){
            String strRecordDevName = Schema.SObjectType.Case.getRecordTypeInfosById().get(caseRecordTypeId).getDeveloperName();
            Case caseObj = new Case(RecordTypeId = caseRecordTypeId, US_WSREMS__First_Name__c = 'FirstName',
                                    US_WSREMS__Last_Name__c = 'LastName',  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(2016, 12, 9),
                                    US_WSREMS__Fax__c = '8785968578',Status = 'Draft',US_WSREMS__REMS_Program__c = programId,US_WSREMS__Program_Picklist__c ='Macitentan REMS', 
                                    US_WSREMS__REMS_Service_Summary__c = serviceObjId,US_WSREMS__Participant__c = presAccId,US_WSREMS__Call_Notes__c = 'test',
                                   US_WSREMS__DEA__c = 'AW9292765',US_WSREMS__NPI__c='2222222222',Program_Record_Type_Control__c = 'Sodium Oxybate REMS'+'-'+strRecordDevName); 
              
              Insert caseObj;
              return caseObj;
          }
        
        // Create a Program user
        public static US_WSREMS__Program_Users__c createProgramUser(Id userId,Id ProgramId){
            US_WSREMS__Program_Users__c  puser= new US_WSREMS__Program_Users__c(US_WSREMS__REMS_Program__c = ProgramId,US_WSREMS__User__c =userId,US_WSREMS__Is_Active__c = true);
            insert puser;
            return puser;
        }
        
        public static US_WSREMS__REMS_Service_Summary__c createService(boolean isCreate,Id programId,Id recordTypeId, String RequestorType ){
    
            US_WSREMS__REMS_Program_Service_Config__c remsServiceConfigObj = new US_WSREMS__REMS_Program_Service_Config__c();
            remsServiceConfigObj.US_WSREMS__REMS_Program__c = programId;
            remsServiceConfigObj.US_WSREMS__Service_API_Name__c = recordTypeId;
            remsServiceConfigObj.US_WSREMS__Stage_Names__c = 'Intake;Verification;Assessment';
            remsServiceConfigObj.US_WSREMS__Stages__c = 'Intake;Verification;Assessment';
            insert remsServiceConfigObj;
    
            
    
            US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
            serviceObj.US_WSREMS__REMSProgram__c = programId;
            serviceObj.US_WSREMS__Requestor_Type__c = RequestorType;
            serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
            serviceObj.recordTypeId = recordTypeId;
            serviceObj.US_WSREMS__Expiration_Date__c = system.today();
            if(isCreate){
                insert serviceObj;
            }
            return serviceObj;
    
        } 
        
         public static void createProgramServiceConfig(ID ProgramID, string recordtypeDeveloperName, string serviceName){
            List<US_WSREMS__REMS_Program_Service_Config__c> programServiceConfigList = new List<US_WSREMS__REMS_Program_Service_Config__c>();
            Id servicerecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get(recordtypeDeveloperName).getRecordTypeId();
            US_WSREMS__REMS_Program_Service_Config__c  pscObj = new US_WSREMS__REMS_Program_Service_Config__c ();
            pscObj.US_WSREMS__Service_Name__c = serviceName;
            pscObj.US_WSREMS__REMS_Program__c = ProgramID;
            pscObj.US_WSREMS__Service_API_Name__c = servicerecordTypeId ;
            insert pscObj;
       
        } 
        
        
        //Prescriber Person Account
        public static Account createPrescriberPersonAccount(Id programId){
            id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
            Account accountObj = new Account();
            accountObj.FirstName= 'TestUser';
            accountObj.LastName = 'Program';
            accountObj.RecordTypeId = recordTypeId;
            accountObj.US_WSREMS__Channel__c  = 'fax';
            accountObj.US_WSREMS__Program_Picklist__c = 'Macitentan REMS';
            accountObj.US_WSREMS__SLN_State__c  ='Alabama';
            accountObj.Phone = '9999999999';
            accountObj.US_WSREMS__NPI__c  = '9999999999';
            accountObj.US_WSREMS__Phone_Type__c  = 'mobile';
            accountObj.US_WSREMS__EXT__c  = '123';
            accountObj.US_WSREMS__Status__c  = 'Initiated';
            accountObj.Fax = '9999999999';
            accountObj.US_WSREMS__Email__c  ='testmaci@test.com';
            accountObj.US_WSREMS__Preferred_Contact_Method__c  = 'email';
            accountObj.US_WSREMS__REMS_Program__c = programId;
           insert accountObj;
            
            return accountObj;
        }
        
        //Prescriber Person Account - DG 
        public static Account createPrescriberAccount(Id programObjId, Id recordTypeId){
            Account accountObj = new Account();
            accountObj.FirstName= 'TestUser';
            accountObj.LastName = 'Program';
            accountObj.RecordTypeId = recordTypeId;
            accountObj.US_WSREMS__Channel__c  = 'fax';
            accountObj.Phone = '9999999999';
            accountObj.US_WSREMS__NPI__c  = '9999999999';
            accountObj.US_WSREMS__Phone_Type__c  = 'mobile';
            accountObj.Fax = '9999999999';
            accountObj.US_WSREMS__Email__c  ='testmaci@test.com';
            accountObj.US_WSREMS__REMS_Program__c = programObjId;
            insert accountObj;
            return accountObj;
        }
        
        // Create Patient Account
        public static Account createPatientAccount(Id programObjId,Id recordTypeId){
            Account accountObj = new Account(FirstName='Test', LastName='LastName',
                                             US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                            Industry = 'Banking',Ownership = 'Public',Phone = '1234567890',AccountNumber = '4567',
                                            Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                            ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                            ShippingPostalCode = '12345',SYN_Shipping_Address_2__c ='Test',
                                            US_WSREMS__Patient_Risk_Category__c='Female of Reproductive Potential (FRP)',Patient_Reproductive_Status_Date__c=Date.newInstance(1988, 12, 9),
                                            US_WSREMS__Channel__c = 'Fax');
                                          
            insert accountObj;
            return accountObj;
        } 
        // Create Patient Account
        public static Account createDistributorAccount(Id programObjId,Id recordTypeId){
            Account accountObj = new Account(Name='Test',
                                             US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                            Industry = 'Banking',Ownership = 'Public',Phone = '1234567890',AccountNumber = '4567',
                                            Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                            ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                            ShippingPostalCode = '12345',SYN_Shipping_Address_2__c ='Test',
                                            US_WSREMS__Patient_Risk_Category__c='Female of Reproductive Potential (FRP)',Patient_Reproductive_Status_Date__c=Date.newInstance(1988, 12, 9));
                                          
            insert accountObj;
            return accountObj;
        } 
         public static Account createPatientAccountEnrolled(Id programObjId,Id recordTypeId){
            Account accountObj = new Account(FirstName='Test', LastName='LastName',US_WSREMS__Status__c='Enrolled',
                                             US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                            Industry = 'Banking',Ownership = 'Public',Phone = '1234567890',AccountNumber = '4567',
                                            Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                            ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                            ShippingPostalCode = '12345',SYN_Shipping_Address_2__c ='Test',US_WSREMS__DOB__c= System.Today().addYears(-8).adddays(30) ,
                                            US_WSREMS__Patient_Risk_Category__c='Female of Reproductive Potential (FRP)',Patient_Reproductive_Status_Date__c=System.Today().adddays(-30));
                                          
            insert accountObj;
            return accountObj;
        } 
        
        // Create Patient Account with Patient Risk
        public static Account createPatientAccountREMSservice(Id programObjId,Id recordTypeId){
            Account accountObj = new Account(FirstName='Test', LastName='LastName',
                                             US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                            Industry = 'Banking',Ownership = 'Public',Phone = '1234567890',AccountNumber = '4567',
                                            Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                            ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                            ShippingPostalCode = '12345',SYN_Shipping_Address_2__c ='Test',
                                            US_WSREMS__Patient_Risk_Category__c='Female of Reproductive Potential (FRP)');
            insert accountObj;
            return accountObj;
        } 
        
        // Create a patient enrollment case
        public static Case createaPatientEnrollmentCase(Id caseRecordTypeId,String FirstName, String LastName, String Status, Id programId, Account acc){
          Case caseObj = new Case(RecordTypeId = caseRecordTypeId, US_WSREMS__First_Name__c = FirstName,
                                  US_WSREMS__Last_Name__c = LastName,  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                                  US_WSREMS__Fax__c = '8785968578',Status = Status,US_WSREMS__REMS_Program__c = programId, US_WSREMS__Patient__c  = acc.id,
                                  US_WSREMS__Program_Picklist__c = 'Macitentan REMS',US_WSREMS__Patient_Risk_Category__c='FNRP (Patient is pre-pubertal)',US_WSREMS__Channel__c='Fax',US_WSREMS__Signature__c = 'No',
                                  SYN_Patient_REMS_ID_Number__c = '0052237', Prescriber_REMS_ID_Number__c = '0052238'); 
            
            Insert caseObj;
            return caseObj;
        }
        
        // Create a Prescriber enrollment case for Maci
        public static Case createaPrescriberEnrollmentCase(Id PrecRecordTypeId,String FirstName, String LastName, String Status, Id programObjId, Account acc){
          Case caseObj = new Case(RecordTypeId = PrecRecordTypeId, US_WSREMS__First_Name__c = FirstName,
                                  US_WSREMS__Last_Name__c = LastName,  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                                  US_WSREMS__Fax__c = '8785968578',Status = Status,US_WSREMS__REMS_Program__c = programObjId, SYN_Prescriber__c = acc.id,
                                  US_WSREMS__Program_Picklist__c = 'Macitentan REMS',US_WSREMS__Channel__c='Fax',
                                  SYN_Patient_REMS_ID_Number__c = '0052237', Prescriber_REMS_ID_Number__c = '0052238',US_WSREMS__Signature__c='Yes',US_WSREMS__Date__c=system.today(),SYN_Prescriber_Signature__c='Yes',SYN_Prescriber_Signature_Date__c=system.today()); 
            
            Insert caseObj;
            return caseObj;
        }
        
        // Create a Distributor enrollment case for Maci
        public static Case createaDistributorEnrollmentCase(Id DistRecordTypeId,String FirstName, String Status, Id programObjId, Account acc){
          Case caseObj = new Case(RecordTypeId = DistRecordTypeId, SYN_Distributor_Name__c = FirstName,	SYN_DEA__c='RS1234867',US_WSREMS__DEA__c = 'RS1234567',
                                  Status = Status,US_WSREMS__REMS_Program__c = programObjId, US_WSREMS__Channel__c='Fax', US_WSREMS__Program_Picklist__c = 'Macitentan REMS',
                                  US_WSREMS__Distributor__c= acc.id, X1_Participant_REMS_ID__c='0052237',US_WSREMS__Signature__c='Yes',US_WSREMS__Date__c=system.today()
                                 ); 
            
            Insert caseObj;
            return caseObj;
        }
        
        // Create Pharmacy enrollment case for Maci
        public static Case createPharmacyEnrollmentCase(Id PharmRecordTypeId,String Status, Id programObjId, Account acc){
          Case caseObj = new Case(RecordTypeId = PharmRecordTypeId,US_WSREMS__REMS_Program__c = programObjId,US_WSREMS__Program_Picklist__c='Macitentan REMS',
                                  US_WSREMS__Channel__c = 'Fax', US_WSREMS__Pharmacy__c = acc.Id, SYN_Pharmacy__c = acc.id, US_WSREMS__Signature__c='Yes',US_WSREMS__Date__c=system.today()
                                  ); 
              
              Insert caseObj;
              return caseObj;
        }
        
        //Create a Patient Enrollment Case with PatientAccount
        public static Case createaPatientEnrollmentPatientCase(Id caseRecordTypeId,Id programObjId,String FirstName, String LastName,Id remsServiceId , Id patientAccountId){
            Case caseObj = new Case(RecordTypeId=caseRecordTypeId,US_WSREMS__REMS_Program__c =programObjId, US_WSREMS__First_Name__c = FirstName,
                                   US_WSREMS__Last_Name__c =LastName,  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                                   US_WSREMS__Fax__c = '8785968578',Status = 'Draft', US_WSREMS__Channel__c='Fax', US_WSREMS__Program_Picklist__c = 'Macitentan REMS',
                                   US_WSREMS__Patient_Risk_Category__c=FRP,Negative_Pregnancy_Test_Completed__c='Yes',
                                   US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Patient__c=patientAccountId); 
            insert caseObj;
            return caseObj; 
        }
    
        public static Case createaPatientEnrollmentPatientCaseFRP(Id caseRecordTypeId,Id programObjId,String FirstName, String LastName,Id remsServiceId , Id patientAccountId){
            Case caseObj = new Case(RecordTypeId=caseRecordTypeId,US_WSREMS__REMS_Program__c =programObjId, US_WSREMS__First_Name__c = FirstName,
                                   US_WSREMS__Last_Name__c =LastName,  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                                   US_WSREMS__Fax__c = '8785968578',Status = 'Draft', US_WSREMS__Channel__c='Fax', US_WSREMS__Program_Picklist__c = 'Macitentan REMS',
                                   US_WSREMS__Patient_Risk_Category__c='Female of Reproductive Potential (FRP)',Negative_Pregnancy_Test_Completed__c='No',
                                   US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Patient__c=patientAccountId); 
            insert caseObj;
            return caseObj; 
        }
    
         public static Account createPrescriberAccountWithNPIcuba(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(FirstName='TestA', LastName='Cuba',Email_address__c='test@test.com',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567899',AccountNumber = '4567',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',US_WSREMS__Preferred_Contact_Method__c='Email',
                                                ShippingPostalCode = '12300',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='1588932628',US_WSREMS__Status__c='Certified');
                insert accountObj;
                return accountObj;
            } 
        //created to get prescriber Account with Fax Contact method--(TT)
        public static Account createPrescriberAccountWithNPIcubaFAX(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(FirstName='TestA', LastName='Cuba',Email_address__c='test@test.com',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567899',AccountNumber = '4567',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',fax='7947594434',
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',US_WSREMS__Preferred_Contact_Method__c='Fax',
                                                ShippingPostalCode = '12300',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='1588932628',US_WSREMS__Status__c='Certified');
                insert accountObj;
                return accountObj;
            } 
        
             // Create Patient Account With NPI
             public static Account createPrescriberAccountWithNPI(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(FirstName='TestA', LastName='LastNameA',Email_address__c='test@test.com',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567899',AccountNumber = '4567',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',US_WSREMS__Preferred_Contact_Method__c='Email',
                                                ShippingPostalCode = '12300',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='8989800000',US_WSREMS__Status__c='Certified');
                insert accountObj;
                return accountObj;
            } 
         public static Account createPrescriberAccountWithNPIemail(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(FirstName='TestA', LastName='Cuba',Email_address__c='test@test.com',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567899',AccountNumber = '4567',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',US_WSREMS__Preferred_Contact_Method__c='Email',
                                                ShippingPostalCode = '12300',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='1588932628',US_WSREMS__Status__c='Initiated');
                insert accountObj;
                return accountObj;
            } 
        public static Account createPrescriberAccountWithNPIprefcontasFax(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(FirstName='TestA', LastName='LastNameA',Email_address__c='test@test.com',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567899',AccountNumber = '4567',fax='7947594434',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',US_WSREMS__Preferred_Contact_Method__c='Fax',
                                                ShippingPostalCode = '12300',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='8989800000',US_WSREMS__Status__c='Initiated');
                insert accountObj;
                return accountObj;
            } 
            // Create Patient Account With NPI
            public static Account createPatientAccountTest(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(FirstName='Test - P', LastName='LastName-Patient',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567888',AccountNumber = '4567',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                                ShippingPostalCode = '12399',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='8980000000',US_WSREMS__Status__c='Enrolled');
                insert accountObj;
                return accountObj;
            } 
        
        // Create Patient Account to get Patient DOB Check as true
            public static Account createPatientAccountDOBCheckTest(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(FirstName='Test', LastName='LastName',
                                             US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                            Industry = 'Banking',Ownership = 'Public',Phone = '1234567890',AccountNumber = '4567',
                                            Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                            ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                            ShippingPostalCode = '12345',SYN_Shipping_Address_2__c ='Test',US_WSREMS__DOB__c = System.Today().addYears(-8).adddays(30),
                                            US_WSREMS__Patient_Risk_Category__c='FNRP (Patient is pre-pubertal)',Patient_Reproductive_Status_Date__c=Date.newInstance(1988, 12, 9));
                insert accountObj;
                return accountObj;
            } 
        
        // Create Patient Account With NPI (status=Initiated)
            public static Account createPatientAccountTest1(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(FirstName='Test - P', LastName='LastName-Patient',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567888',AccountNumber = '4567',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                                ShippingPostalCode = '12399',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='8980000000',US_WSREMS__Status__c='Initiated');
                insert accountObj;
                return accountObj;
            } 
            // Create Patient Account With NPI
            public static Account createPharmacyAccountTest(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(Name='PharmacyAccountC',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567888',AccountNumber = '4567',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                                ShippingPostalCode = '12377',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='8981111111',US_WSREMS__Status__c='Certified',
                                                Pharmacy_Type__c = 'Inpatient');
                insert accountObj;
                return accountObj;
            } 
        
        // Create Outpatient Pharmacy Account With NPI - Maci (status=Initiated)
            public static Account createPharmacyOutpatientAccountTest(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(Name='PharmacyAccountC',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567888',AccountNumber = '4567',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                                ShippingPostalCode = '12377',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='8981111111',US_WSREMS__Status__c='Initiated',
                                                Pharmacy_Type__c = 'Outpatient',US_WSREMS__Channel__c = 'Fax');
                insert accountObj;
                return accountObj;
            } 
        
        // Create Inpatient Pharmacy Account With NPI - Maci (status=Initiated)
            public static Account createPharmacyInpatientAccountTest(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(Name='PharmacyAccountC',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567888',AccountNumber = '4567',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                                ShippingPostalCode = '12377',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='8981111111',US_WSREMS__Status__c='Initiated',
                                                Pharmacy_Type__c = 'Inpatient',US_WSREMS__Channel__c = 'Fax');
                insert accountObj;
                return accountObj;
            }
        
        
            // Create Patient Account With NPI
            public static Account createPharmacyParticipantAccountTest(Id programObjId,Id recordTypeId){
                Account accountObj = new Account(FirstName='PharmacyPartD',LastName='Account',
                                                 US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                                Industry = 'Banking',Ownership = 'Public',Phone = '1234567855',AccountNumber = '4567',
                                                Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                                ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                                ShippingPostalCode = '12344',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='8982222222',US_WSREMS__Status__c='Active');
                insert accountObj;
                return accountObj;
            } 
            
             // Create a patient enrollment case with NPI
            public static Case createaRDACase(Id caseRecordTypeId,Id programId, Account prescAccount, Account patientAccount,Account pharmCAccount,Account pharmCParticipanAccount,US_WSREMS__REMS_Service_Summary__c serviceObj){
            Case caseObj = new Case(RecordTypeId = caseRecordTypeId,US_WSREMS__REMS_Program__c = programId,US_WSREMS__Program_Picklist__c='Macitentan REMS',US_WSREMS__Channel__c = 'Phone',US_WSREMS__Pharmacy__c = pharmCAccount.Id,
                                    Pharmacy_Participant__c=pharmCParticipanAccount.Id,Participant_FirstName__c='PharmacyPartD',US_WSREMS__Last_Name__c='LastNameA',US_WSREMS__First_Name__c='TestA',Participant_LastName__c='Account',SYN_Prescriber__c=prescAccount.Id,US_WSREMS__Patient__c=patientAccount.Id,
                                   SYN_Date__c=Date.today(),Manufacturer__c='Actelion Pharmaceuticals',NDC_Code__c='66215-501-15, 10 mg blister of 15 tablets',SYN_Days_Supply__c=21,Days_of_Interruption__c=2,US_WSREMS__Outcome__c='Approved',
                                   US_WSREMS__Participant__c=pharmCAccount.Id,US_WSREMS__REMS_Service_Summary__c=serviceObj.Id,Counseling_Recorded__c=true,Status='Complete',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),US_WSREMS__REMS_Zip_Code__c='12342',US_WSREMS__NPI__c='1232525252',
                                   Prescriber_NPI__c='5252525252',SYN_Zip_Code__c='56565',Prescriber_REMS_ID_Number__c='767676',SYN_Patient_REMS_ID_Number__c='987878',SYN_Pharmacy_REMS_ID_Number__c='987678',US_WSREMS__Patient_Risk_Category__c='FNRP (Patient is pre-pubertal)',Monthly_Pregnancy_Test_Recorded__c =True, Recent_Patient_Reproductive_Status_Date__c=Date.today()); 
              
              Insert caseObj;
              return caseObj;
            }
          
           // Create a shipping and tracking record...
            public static US_WSREMS__Shipping_and_Tracking__c createShippingAndTrackingRecordForRDACase(Id caseRecId,Id patientId){
              Date d = Date.today().addDays(-50);
              US_WSREMS__Shipping_and_Tracking__c cs = new US_WSREMS__Shipping_and_Tracking__c();
              cs.REMS_Program__c='Macitentan REMS';
              cs.Pharmacy_REMS_ID__c='12345';
              cs.Patient_REMS_ID__c=5656;
              cs.Prescriber_NPI__c = 12321;
              cs.RDA_Code__c='25252525';
              cs.Dispense_Reversal_Code__c='Not Reversed';
              cs.Dispense_Date__c=Date.today();
              cs.NDC__c = 25415;
              cs.Days_Supply__c=70;
              cs.New_Refill__c='New'; 
              cs.US_WSREMS__Case__c = caseRecId;
              cs.US_WSREMS__Patient__c = patientId;
                  
                  Insert cs;
              return cs;
            }
    
            // Create Prescribing Institution Case
        public static Case createPrimaryOfficeObj(Id programObjId,Id recordTypeId, String ProgramName){
            Case pcase= new Case();
            pcase.US_WSREMS__REMS_Program__c = programObjId;
            pcase.US_WSREMS__Program_Picklist__c = ProgramName;
            pcase.US_WSREMS__Status__c = 'Initiated';
            pcase.US_WSREMS__Name__c = 'Primary Office';
            pcase.US_WSREMS__Address_Line_1__c = 'Test';
            pcase.US_WSREMS__City__c = 'New York';
            pcase.US_WSREMS__REMS_Zip_Code__c ='00000';
            pcase.US_WSREMS__Phone__c = '1234567898';
            pcase.US_WSREMS__Email__c = 'test@test.com';
            pcase.US_WSREMS__Address_Line_2__c ='test';
            pcase.US_WSREMS__State__c = 'AL';
            pcase.US_WSREMS__REMS_Country__c = 'Test';
            pcase.SYN_Ext__c = '12345';
            pcase.US_WSREMS__Fax__c = '1234567896';
            pcase.Status = 'Draft';
            pcase.US_WSREMS__Preferred_Contact_Method__c ='Fax';
            pcase.RecordTypeId = recordTypeId;
         return pcase;
     }
     
     // Create Secondary Office Institution Case
     public static Case createSecondaryOfficeObj(Id programObjId,Id recordTypeId, String ProgramName){
            Case scase= new Case();
            scase.US_WSREMS__REMS_Program__c = programObjId;
            scase.US_WSREMS__Program_Picklist__c = ProgramName;
            scase.US_WSREMS__Status__c = 'Initiated';
            scase.US_WSREMS__Name__c = 'Secondary Office';
            scase.US_WSREMS__Address_Line_1__c = 'Test';
            scase.US_WSREMS__City__c = 'New York';
            scase.US_WSREMS__REMS_Zip_Code__c ='00000';
            scase.US_WSREMS__Phone__c = '1234567898';
            scase.US_WSREMS__Email__c = 'test@test.com';
            scase.US_WSREMS__Address_Line_2__c ='test';
            scase.US_WSREMS__State__c = 'AK';
            scase.US_WSREMS__REMS_Country__c = 'Test';
            scase.SYN_Ext__c = '12345';
            scase.US_WSREMS__Fax__c = '1234567896';
            scase.Status = 'Draft';
            scase.US_WSREMS__Preferred_Contact_Method__c ='Fax';
            scase.RecordTypeId = recordTypeId;
         return scase;
     }
     
      // Create Secondary Office Institution Case
     public static Case createPrescriberInfoObj(Id programObjId,Id recordTypeId, String ProgramName){
            Case prcase= new Case();
            prcase.US_WSREMS__REMS_Program__c = programObjId;
            prcase.US_WSREMS__Program_Picklist__c = ProgramName;
            prcase.US_WSREMS__Status__c = 'Initiated';
            prcase.US_WSREMS__First_Name__c ='FirstNameii';
            prcase.US_WSREMS__Last_Name__c ='lastNameii';
            prcase.Email_address__c ='test1234@test.com';
            prcase.RecordTypeId = recordTypeId;
         return prcase;
     }
     // create community default owner 
     public static User communityDefaultUser(){
         // Get the profile details
         UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
         Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
         // Create a new user with following users and return
         User commUser = new User(
             UserRoleId = portalRole.Id,
             ProfileId = profileId,
             Username = 'communityuser_test@test.eversana.com' + Math.random() + '.com',
             CommunityNickname = 'test' + Math.random(),
             Alias = 'batman',
             Email = System.now().millisecond() + 'communitydefaultowner@test.com',
             EmailEncodingKey = 'UTF-8',
             Firstname = 'Admin',
             Lastname = 'User'+System.now().millisecond(),
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             TimeZoneSidKey = 'America/Chicago'
         );
         //insert cumntyuser;
         return commUser;
        }
     
        
     //Physician Account
     public static User CreateCommunityUser(Account acc, String profileId, String communityProgram, String communityRole) {
       
         //Create contact
         Contact con = [SELECT Id FROM Contact WHERE AccountId = : acc.id LIMIT 1];             
        
         // Create Community User 
         User newCommUser = new User();
         newCommUser.FirstName= 'Elsa';
         newCommUser.LastName = 'Arendelle';
         newCommUser.Email = 'elsa@test.com';
         newCommUser.Alias = 'eversana';
         newCommUser.Username = 'comunityiser_hcp@test.test.com' + Math.random() + '.com'; 
         newCommUser.CommunityNickname = 'usr' + Math.random();
         newCommUser.LocaleSidKey= 'en_US';
         newCommUser.TimeZoneSidKey = 'GMT';
         newCommUser.LanguageLocaleKey = 'en_US';
         newCommUser.EmailEncodingKey  = 'UTF-8';
         newCommUser.ProfileId = profileId;
         newCommUser.ContactId = con.Id;
         newCommUser.Program__c = communityprogram;
         newCommUser.Role__c = communityrole;
         try{
         insert newCommUser;  
         }catch (exception e){
             system.debug('--Error----'+e.getMessage());
         } 
         return newCommUser;
        }  
    
        public static User CreateCommunityUser(Account acc, String profileId, String communityProgram, String communityRole,Boolean isInsert) {
            //Create contact
            Contact con = [SELECT Id FROM Contact WHERE AccountId = : acc.id LIMIT 1];             
            // Create Community User 
            User newCommUser = new User(
                FirstName= 'Elsa',
                LastName = 'Arendelle',
                Email = 'elsa@test.com',
                Alias = 'eversana',
                Username = 'comunityiser_hcp@test.test.com' + Math.random() + '.com', 
                CommunityNickname = 'usr' + Math.random(),
                LocaleSidKey= 'en_US',
                TimeZoneSidKey = 'GMT',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey  = 'UTF-8',
                ProfileId = profileId,
                ContactId = con.Id,
                Program__c = communityprogram,
                Role__c = communityrole);
            if(isInsert){
                try{
                    insert newCommUser;  
                }catch (exception e){
                    system.debug('--Error----'+e.getMessage());
                }
            }
            return newCommUser;
        }
         // Create Pharmacy participant Case
        public static Case createOutPatientPharmacyInfoObj(Id programObjId,Id recordTypeId, String ProgramName){
               Case prcase= new Case();
               prcase.US_WSREMS__REMS_Program__c = programObjId;
               prcase.US_WSREMS__Program_Picklist__c = ProgramName;
               prcase.US_WSREMS__Status__c = 'Initiated';
               prcase.US_WSREMS__First_Name__c ='FirstNameii';
               prcase.US_WSREMS__Last_Name__c ='lastNameii';
               prcase.Email_address__c ='test1234@test.com'+ Math.random();
               prcase.RecordTypeId = recordTypeId;
            return prcase;
        }
        
         // Create Pharmacy participant Case
        public static Case createPharmacyEnrollmentCaseInfo(Id programObjId,Id pharmCAccCaseRecTypeId, String ProgramName){
               Case pharmcCase = New Case(RecordTypeId = pharmCAccCaseRecTypeId,US_WSREMS__NPI__c = '5454545656', US_WSREMS__Name__c ='Test PharmC',
                                           US_WSREMS__Program_Picklist__c = ProgramName,US_WSREMS__Channel__c='Portal',
                                           US_WSREMS__REMS_Program__c = programObjId,Pharmacy_Type__c = 'Outpatient',US_WSREMS__Address_Line_1__c = 'Add1',
                                          US_WSREMS__City__c = 'NY',US_WSREMS__State__c='AL',US_WSREMS__REMS_Zip_Code__c='10004',US_WSREMS__Phone__c='9998888888',
                                          US_WSREMS__Fax__c='9998887777');
            return pharmcCase;
        }
        
        
          // Create Prescribing Institution Case
        public static Case createPatientEnrollmentCase(Id programObjId, String ProgramName){
            Id PatietnEnrollmentRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
            Case pcase= new Case();
            pcase.US_WSREMS__REMS_Program__c = programObjId;
            pcase.US_WSREMS__Program_Picklist__c = ProgramName;
            pcase.US_WSREMS__First_Name__c ='Test';
            pcase.US_WSREMS__Last_Name__c ='test';
            pcase.US_WSREMS__Address_Line_1__c = 'New Line1';
            pcase.US_WSREMS__Name__c = 'Test test';
            pcase.US_WSREMS__Address_Line_1__c = 'Test';
            pcase.US_WSREMS__City__c = 'New York';
            pcase.US_WSREMS__REMS_Zip_Code__c ='00000';
            pcase.US_WSREMS__Phone__c = '1234567898';
            pcase.US_WSREMS__Email__c = 'test@test.com';
            pcase.US_WSREMS__Address_Line_2__c ='test';
            pcase.US_WSREMS__State__c = 'AK';
            pcase.US_WSREMS__REMS_Country__c = 'Test';
            pcase.SYN_Ext__c = '12345';
            pcase.US_WSREMS__Fax__c = '1234567896';
            pcase.US_WSREMS__DOB__c=Date.newInstance(2001, 12, 9);
            pcase.Status = 'Draft';
         return pcase;
         }
     
          // Create Prescribing Institution Case
        public static Case createNewPatientEnrollmentCase(Id programObjId, String ProgramName,Account prescriberAcc, Account patientAcc){
            Id PatietnEnrollmentRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_Enrollement').getRecordTypeId();
    
            Case pcase= new Case();
            pcase.US_WSREMS__REMS_Program__c = programObjId;
            pcase.US_WSREMS__Program_Picklist__c = ProgramName;
            pcase.US_WSREMS__First_Name__c ='Test';
            pcase.US_WSREMS__Last_Name__c ='test';
            pcase.US_WSREMS__Address_Line_1__c = 'New Line1';
            pcase.US_WSREMS__Name__c = 'Test test';
            pcase.US_WSREMS__Address_Line_1__c = 'Test';
            pcase.US_WSREMS__City__c = 'New York';
            pcase.US_WSREMS__REMS_Zip_Code__c ='00000';
            pcase.US_WSREMS__Phone__c = '1234567898';
            pcase.US_WSREMS__Email__c = 'test@test.com';
            pcase.US_WSREMS__Address_Line_2__c ='test';
            pcase.US_WSREMS__State__c = 'AL';
            pcase.US_WSREMS__REMS_Country__c = 'Test';
            pcase.SYN_Ext__c = '12345';
            pcase.US_WSREMS__Fax__c = '1234567896';
            pcase.US_WSREMS__DOB__c=Date.newInstance(2001, 12, 9);
            pcase.Status = 'Draft';
            pcase.recordTypeId = PatietnEnrollmentRecTypeId;
            pcase.SYN_Prescriber__c = prescriberAcc.id;
            pcase.US_WSREMS__Patient__c = patientAcc.Id;
            insert pcase;
         return pcase;
     }
     
      //Patient Pregnancy Test Service Case Record
         public static Case createCasePatientPregnancyTest(Id caseRecordTypeId,Id programId,Id PatientId,Id participantId){
            Case caseObj = new Case(RecordTypeId = caseRecordTypeId, US_WSREMS__First_Name__c = 'FirstName',
                                    US_WSREMS__Last_Name__c = 'LastName', US_WSREMS__Channel__c ='Phone',
                                    Status = 'Draft',US_WSREMS__REMS_Program__c = programId,US_WSREMS__Program_Picklist__c ='Macitentan REMS', 
                                    Pharmacy_Participant__c = participantId, US_WSREMS__Participant__c =participantId,  SYN_Patient_REMS_ID_Number__c='12303',US_WSREMS__Patient__c=PatientId,Monthly_Pregnancy_Test_Recorded__c=True,Date_of_Confirmation__c=Date.newInstance(2001, 12, 9)
                                   ); 
              
              Insert caseObj;
              return caseObj;
          }
          public static Case createPatientCounselingChecklistTest(Id caseRecordTypeId,Id programId,Id PatientId,Id participantId,Id Pharmacyid){
            Case caseObj = new Case(RecordTypeId = caseRecordTypeId, US_WSREMS__First_Name__c = 'FirstName',
                                    US_WSREMS__Last_Name__c = 'LastName', US_WSREMS__Channel__c ='Phone',
                                    Status = 'Draft',US_WSREMS__REMS_Program__c = programId,US_WSREMS__Program_Picklist__c ='Macitentan REMS', 
                                     SYN_Patient_REMS_ID_Number__c='12303',US_WSREMS__Patient__c=PatientId,Monthly_Pregnancy_Test_Recorded__c=True,Date_of_Confirmation__c=Date.newInstance(2001, 12, 9)
                                   ); 
              
              Insert caseObj;
              return caseObj;
          }
        //Create Affiliation Record
         public static US_WSREMS__Affiliation__c createAffiliation(Id programId,Id participantId,Id PharmacyId){
          Id recordTypeIdPharmacy = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Pharmacy_User_Affiliation').getRecordTypeId();
             
                US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(           
                US_WSREMS__Pharmacy__c = PharmacyId,
                US_WSREMS__Pharmacy_User__c =participantId,
                US_WSREMS__REMSProgram__c= programId,
                RecordTypeId=recordTypeIdPharmacy,
                AR_Category__c='Primary',
                Default__c = true,
                US_WSREMS__isActive__c = true);
             
              Insert affiliationRecord;      
              return affiliationRecord;
        }
        public static US_WSREMS__Affiliation__c createPrescAffiliation(Id programId,Id prescriberId,Id patientid){
            Map<String,Id> affRecordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Affiliation__c'); 
            Id recordTypeIdPharmacy = affRecordTypeMap.get('Prescriber_Affiliation');
                   US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(           
                    US_WSREMS__Patient__c = patientid,
                    US_WSREMS__Prescriber__c =prescriberId,
                  US_WSREMS__REMSProgram__c= programId,
                  RecordTypeId=recordTypeIdPharmacy,
                
                  US_WSREMS__isActive__c = true);
               
                Insert affiliationRecord;      
                return affiliationRecord;
          }
        //Create Case Pharmacy Record
        public static Case createCasePharmacyTest(Id caseRecordTypeId,Id programId,Id accountId){
        Case caseObj = new Case(RecordTypeId = caseRecordTypeId, US_WSREMS__First_Name__c = 'PharmacyPartD',
                                US_WSREMS__Last_Name__c = 'Account',Status = 'Draft',
                                US_WSREMS__REMS_Program__c = programId,US_WSREMS__Program_Picklist__c ='Macitentan REMS', 
                                SYN_Authorized_Rep__c = accountId,SYN_Pharmacy__c=accountId
                               ); 
          
          Insert caseObj;
          return caseObj;
        }
        
        //Create Pharmacy participant account with pharmacy and user type
        public static Account createPharmacyParticipantAccountAuthrepTest(Id programObjId,Id recordTypeId,Id accountId){
            Account accountObj = new Account(FirstName='PharmacyPartD',LastName='Account',
                                             US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                            Industry = 'Banking',Ownership = 'Public',Phone = '1234567855',AccountNumber = '4567',
                                            Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                            ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                            ShippingPostalCode = '12344',SYN_Shipping_Address_2__c ='Test',SYN_User_Type__c='Authorized Representative',
                                            SYN_Pharmacy__c=accountId,US_WSREMS__NPI__c='8982222222',US_WSREMS__Status__c='Active');
            insert accountObj;
            return accountObj;
        } 
        
        // Create Change in Reproductive Status case
        public static Case createChangeReproductiveCase(Id caseRecordTypeId,Id programId, Account prescAccount, Account patientAccount){
            Case caseObj = new Case(RecordTypeId = caseRecordTypeId,US_WSREMS__REMS_Program__c = programId,US_WSREMS__Program_Picklist__c='Macitentan REMS',US_WSREMS__Channel__c ='Portal',Annual_Verification__c=true,Please_specify__c='test',
                                    US_WSREMS__Last_Name__c='LastNameA',US_WSREMS__First_Name__c='TestA',Reason_for_change_in_classification__c='Other',SYN_Prescriber__c=prescAccount.Id,US_WSREMS__Patient__c=patientAccount.Id,
                                    US_WSREMS__Participant__c=prescAccount.Id,US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),US_WSREMS__NPI__c='1232525252',US_WSREMS__Patient_Risk_Category__c='FNRP (Patient is pre-pubertal)'); 
              
              Insert caseObj;
              return caseObj;
        }
        
         // Create Rems Service Summary with PatientAccount  
        public static US_WSREMS__REMS_Service_Summary__c createRemsServiceSummary_PatientRecord(Id prescriberaccID,Id programObjId,Id  patientAccountID,String RequestorType, String recordTypeId){
            US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
                US_WSREMS__Participant__c=prescriberaccID,
                US_WSREMS__REMSProgram__c = programObjId,
                US_WSREMS__Service_Outcome__c=unsuccessful,
                US_WSREMS__Status__c =open, 
                Patient__c=patientAccountID,
                RecordTypeId=recordTypeId,
                US_WSREMS__Requestor_Type__c=RequestorType
            );
            Insert objService;
            return objService;
        }
        
        // Create Patient Account With NPI
        public static Account createTestPharmacyAccount(Id programObjId,Id recordTypeId){
            Account accountObj = new Account(Name='TestPharmacy',
                                             US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                            Industry = 'Banking',Ownership = 'Public',Phone = '4445551234',AccountNumber = '4567',
                                            Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                            ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                            ShippingPostalCode = '12377',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='4445551234',US_WSREMS__Status__c='Certified',Pharmacy_Type__c='Inpatient');
            insert accountObj;
            return accountObj;
        } 
        
        // Create Patient Account With NPI
        public static Account createPharmacyAccount(Id programObjId,Id recordTypeId){
            Account accountObj = new Account(Name='TestNewPharmacy',
                                             US_WSREMS__REMS_Program__c = programObjId,Rating = 'Hot',Type = 'Prospect',
                                            Industry = 'Banking',Ownership = 'Public',Phone = '4445551234',AccountNumber = '4567',
                                            Sic = 'Test Site',RecordTypeId = recordTypeId,ShippingCountry = 'United States',
                                            ShippingState = 'Alabama',ShippingStreet = 'Test Street',ShippingCity = 'Test City',
                                            ShippingPostalCode = '12377',SYN_Shipping_Address_2__c ='Test',US_WSREMS__NPI__c='4445553214',US_WSREMS__Status__c='Certified',Pharmacy_Type__c='Inpatient');
            insert accountObj;
            return accountObj;
        } 
    
        // create multiple patient accounts
        public static List<Account> createPatientAccounts(Id programId,Integer numberofRecords){
            List<Account> accountList=new List<Account>();
            Id patientrecordId=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            for(Integer i = 0; i<numberofRecords;i++){
                Account acc=new Account();
                acc.LastName='TestAccount';
                acc.FirstName='TestAccount';
                acc.Phone ='1234567890';
                acc.PersonEmail='Test@gmail.com';
                acc.US_WSREMS__DEA__c='123457895';
                acc.US_WSREMS__NPI__c='123456787'+i;
                acc.US_WSREMS__DOB__c=System.today();
                acc.US_WSREMS__REMS_Program__c =programId;
                acc.recordTypeId =patientrecordId;
                accountList.add(acc);
            }
            insert accountList;
            return accountList;
        }
           public static Case createaPatientEnrollmentPatientCasewithemailasprefcontact(Id caseRecordTypeId,Id programObjId,String FirstName, String LastName,Id remsServiceId , Id patientAccountId,id precriberAccountid){
            Case caseObj = new Case(RecordTypeId=caseRecordTypeId,US_WSREMS__REMS_Program__c =programObjId, US_WSREMS__First_Name__c = FirstName,
                                   US_WSREMS__Last_Name__c =LastName,  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                                   US_WSREMS__Fax__c = '8785968578',Status = 'draft', US_WSREMS__Channel__c='Fax', US_WSREMS__Program_Picklist__c = 'Macitentan REMS',
                                   US_WSREMS__Patient_Risk_Category__c='FNRP (Patient is pre-pubertal)',SYN_Prescriber__c=precriberAccountid,Email_address__c='abc@gmail.com',
                                   US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Patient__c=patientAccountId); 
            insert caseObj;
            return caseObj; 
        }
        public static Case createaPatientEnrollmentPatientCasewithFaxasprefcontact(Id caseRecordTypeId,Id programObjId,String FirstName, String LastName,Id remsServiceId , Id patientAccountId,id precriberAccountid){
            Case caseObj = new Case(RecordTypeId=caseRecordTypeId,US_WSREMS__REMS_Program__c =programObjId, US_WSREMS__First_Name__c = FirstName,
                                   US_WSREMS__Last_Name__c =LastName,  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                                   US_WSREMS__Fax__c = '8785968578',Status = 'draft', US_WSREMS__Channel__c='Fax', US_WSREMS__Program_Picklist__c = 'Macitentan REMS',
                                   US_WSREMS__Patient_Risk_Category__c='FNRP (Patient is pre-pubertal)',SYN_Prescriber__c=precriberAccountid,Email_address__c='abc@gmail.com',
                                   US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Patient__c=patientAccountId); 
            insert caseObj;
            return caseObj; 
        }
        
        public static Case createaPatientEnrollmentPatientCasewithChannel(Id caseRecordTypeId,Id programObjId,String FirstName, String LastName,Id remsServiceId , Id patientAccountId,id precriberAccountid){
            Case caseObj = new Case(RecordTypeId=caseRecordTypeId,US_WSREMS__REMS_Program__c =programObjId, US_WSREMS__First_Name__c = FirstName,
                                   US_WSREMS__Last_Name__c =LastName,  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                                   US_WSREMS__Fax__c = '8785968578',Status = 'draft', US_WSREMS__Channel__c='Fax', US_WSREMS__Program_Picklist__c = 'Macitentan REMS',
                                   US_WSREMS__Patient_Risk_Category__c='FNRP (Patient is pre-pubertal)',SYN_Prescriber__c=precriberAccountid,Email_address__c='abc@gmail.com',
                                   US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Patient__c=patientAccountId); 
            insert caseObj;
            return caseObj; 
        }
        
        public static Case createaPatientEnrollmentPatientCasewithFaxasprefcontactcomplete(Id caseRecordTypeId,Id programObjId,String FirstName, String LastName,Id remsServiceId , Id patientAccountId,id precriberAccountid){
            Case caseObj = new Case(RecordTypeId=caseRecordTypeId,US_WSREMS__REMS_Program__c =programObjId, US_WSREMS__First_Name__c = FirstName,
                                   US_WSREMS__Last_Name__c =LastName,  US_WSREMS__Phone__c = '1234567890',US_WSREMS__DOB__c = Date.newInstance(1988, 12, 9),
                                   US_WSREMS__Fax__c = '1588932628',Status = 'Draft', US_WSREMS__Channel__c='Fax', US_WSREMS__Program_Picklist__c = 'Macitentan REMS',
                                   US_WSREMS__Patient_Risk_Category__c='FNRP (Patient is pre-pubertal)',SYN_Prescriber__c=precriberAccountid,Email_address__c='abc@gmail.com',SYN_Prescriber_First_Name__c='FAC CR Phone Martin',SYN_Prescriber_Last_Name__c='Martin',
                                   US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Patient__c=patientAccountId,SYN_Street_Address__c='test',US_WSREMS__Email__c='GHDSKGFK@GMAIL.COM',US_WSREMS__Shipping_Street__c='TEST',SYN_Shipping_State__c='CA',
                                  US_WSREMS__Shipping_City__c='TEST',US_WSREMS__City__c='test',US_WSREMS__State__c='CA',SYN_Zip_Code__c='46306',SYN_Prescriber_Fax__c='1588932628',US_WSREMS__Shipping_Zip_Postal_Code__c='54755',SYN_Prescriber_Phone__c='7463643234',US_WSREMS__Signature__c='Yes',US_WSREMS__Date__c=system.today(),
                                    SYN_Prescriber_Signature__c='Yes',SYN_Prescriber_Signature_Date__c=system.today(),US_WSREMS__Address_Line_1__c='test'); 
            insert caseObj;
            return caseObj; 
        }
         public static Case createaPresciberEnrollmentPatientCasedraftpcfax(Id caseRecordTypeId,Id programObjId,String FirstName, String LastName,Id remsServiceId , Id patientAccountId,id precriberAccountid){
            Case caseObj = new Case(RecordTypeId=caseRecordTypeId,US_WSREMS__REMS_Program__c =programObjId, US_WSREMS__First_Name__c = FirstName,
                                   US_WSREMS__Last_Name__c =LastName,  US_WSREMS__Phone__c = '1234567890',
                                   US_WSREMS__Fax__c = '8785968578',Status = 'draft', US_WSREMS__Channel__c='Fax', US_WSREMS__Program_Picklist__c = 'Macitentan REMS',SYN_Prescriber_First_Name__c=FirstName,SYN_Prescriber_Last_Name__c=LastName,
                                  SYN_Prescriber__c=precriberAccountid,Email_address__c='abc@gmail.com',US_WSREMS__Preferred_Contact_Method__c='fax',Incomplete_Reasons__c='kjsdfgk',
                                   US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Patient__c=patientAccountId); 
            insert caseObj;
            return caseObj; 
        }
        public static Case createaPresciberEnrollmentPatientCasedraftpcemail(Id caseRecordTypeId,Id programObjId,String FirstName, String LastName,Id remsServiceId , Id patientAccountId,id precriberAccountid){
            Case caseObj = new Case(RecordTypeId=caseRecordTypeId,US_WSREMS__REMS_Program__c =programObjId, US_WSREMS__First_Name__c = FirstName,SYN_Prescriber_First_Name__c=FirstName,
                                   US_WSREMS__Last_Name__c =LastName,  US_WSREMS__Phone__c = '1234567890',SYN_Prescriber_Last_Name__c=LastName,
                                   US_WSREMS__Fax__c = '9999999999',Status = 'draft', US_WSREMS__Channel__c='Fax', US_WSREMS__Program_Picklist__c = 'Macitentan REMS',US_WSREMS__Participant__c=precriberAccountid,
                                  SYN_Prescriber__c=precriberAccountid,Email_address__c='abc@gmail.com',US_WSREMS__Preferred_Contact_Method__c='Email',
                                   US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__Patient__c=patientAccountId,Incomplete_Reasons__c='jhfkhd'); 
            insert caseObj;
            return caseObj; 
    }
    public static Case createacaseforpatient(Id caseRecordTypeId,Id programObjId,Id remsServiceId , Id patientAccountId,id precriberAccountid){
        Case caseObj = New Case(RecordTypeid=caseRecordTypeId, US_WSREMS__REMS_Program__c=programObjId,US_WSREMS__Program_Picklist__c='Macitentan REMS',
        US_WSREMS__Channel__c='Phone',SYN_Type_of_Report__c='Pregnancy',SYN_Sponsor_Responsible__c='Actelion Pharmaceuticals US, Inc., a Johnson & Johnson Company',US_WSREMS__DOB__c=System.Today().addYears(-8).adddays(30),
        US_WSREMS__Phone__c='9878887777',SYN_Reporter__c=patientAccountId,Date_Voicemail_or_Fax_received__c=Date.Today(),Program_Record_Type_Control__c='Macitentan REMS-PAE_PC_MI',
        SYN_Prescriber__c=precriberAccountid,US_WSREMS__Patient__c=patientAccountId,Sponsor_Responsible_1__c='Actelion Pharmaceuticals US, Inc., a Johnson & Johnson Company',
        SYN_Event_Description__c='test',status='Complete',US_WSREMS__Outcome__c='Acknowledgment Pending',US_WSREMS__Participant__c=patientAccountId,US_WSREMS__REMS_Service_Summary__c = remsServiceId,
        SYN_Reporter_First_Name__c='Test', SYN_Reporter_Last_Name__c='testt',US_WSREMS__First_Name__c='test',US_WSREMS__Last_Name__c='testt');
       insert caseObj;
        return caseObj; 
    }
    public static Case createaPresciberEnrollmentPatientCase(Id patientEnrollCaseRecTypeId,Id programObjId,Id remsServiceId , Id patientAccountId,id precriberAccountid){
        Case caseObj = New Case(RecordTypeid=patientEnrollCaseRecTypeId, US_WSREMS__REMS_Program__c=programObjId,US_WSREMS__Program_Picklist__c='Macitentan REMS',
        US_WSREMS__DOB__c= System.today() - 365,SYN_Prescriber_Signature__c ='Yes', US_WSREMS__Signature__c='Yes',US_WSREMS__Date__c =System.today(),SYN_Prescriber_Signature_Date__c =System.today(),
        US_WSREMS__Phone__c='9878887777',SYN_Reporter__c=patientAccountId,Date_Voicemail_or_Fax_received__c=Date.Today(), SYN_Prescriber__c=precriberAccountid,US_WSREMS__Patient__c=patientAccountId,Sponsor_Responsible_1__c='Actelion Pharmaceuticals US, Inc., a Johnson & Johnson Company',
        SYN_Event_Description__c='test',status='Complete',US_WSREMS__Outcome__c='Acknowledgment Pending',US_WSREMS__Participant__c=patientAccountId,US_WSREMS__REMS_Service_Summary__c = remsServiceId,
        SYN_Reporter_First_Name__c='Test', SYN_Reporter_Last_Name__c='testt',US_WSREMS__First_Name__c='test',US_WSREMS__Last_Name__c='testt');
    
    insert caseObj;
        return caseObj;
    }
        public static Case createaPatientEnrollmentCase(Id patientEnrollCaseRecTypeId,Id programObjId,Id remsServiceId , Id patientAccountId,id precriberAccountid){
        Case caseObj = New Case(RecordTypeid=patientEnrollCaseRecTypeId,US_WSREMS__REMS_Program__c=programObjId,US_WSREMS__Program_Picklist__c='Macitentan REMS',US_WSREMS__Channel__c='Fax',US_WSREMS__Patient__c=patientAccountId,Primary_Language__c='English',US_WSREMS__Email__c='testp99@gmail.com',US_WSREMS__Phone__c='4563434567',SYN_Street_Address__c='Alabama street',US_WSREMS__City__c='Alabama',US_WSREMS__State__c='AK',SYN_Zip_Code__c='34526',
                               US_WSREMS__Signature__c='Yes',US_WSREMS__Date__c=system.today(),SYN_Prescriber__c=precriberAccountid,US_WSREMS__REMS_Service_Summary__c = remsServiceId,US_WSREMS__DOB__c=System.Today().addYears(-8).adddays(30),SYN_Prescriber_First_Name__c='KSENIA',SYN_Prescriber_Middle_Name__c='AVIELLA',SYN_Prescriber_Last_Name__c='AARON',
                               Email_address__c='ksenia@gmail.com',US_WSREMS__NPI__c='1891176582',Office_contact_name_Primary_Office__c='KIMS',SYN_Prescriber_Phone__c='4568668651',SYN_Prescriber_Fax__c='3451243561',US_WSREMS__Shipping_Street__c='Street 150',US_WSREMS__Shipping_City__c='Texas',Legal_Guardian_Name__c='test name' ,Legal_Guardian_Phone__c='5678943673' ,Legal_Guardian_Relationship__c='Father' ,Legal_Guardian_Email__c='gsjdgdf@yopmail.com', 
                               SYN_Shipping_State__c='TX',US_WSREMS__Shipping_Zip_Postal_Code__c='45781',US_WSREMS__Patient_Risk_Category__c='FNRP (Patient is pre-pubertal)',SYN_Prescriber_Signature__c='Yes',SYN_Prescriber_Signature_Date__c=system.today(),Status='Complete',US_WSREMS__Outcome__c='Complete');
    
    insert caseObj;
        return caseObj; 
    }
    
    public static id createEmailTemplate(string subject,string Body,string TemplateType) {
        Integer len = 5;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        EmailTemplate et = new EmailTemplate();
        et.isActive = true;
        et.Name = 'Test_Template';
        et.FolderId = UserInfo.getUserId();
        et.DeveloperName = 'Test_Template'+randStr;
        et.TemplateType = TemplateType;
        et.Subject = subject;
        et.Body = Body;
        // Insert the EmailTemplate record
        insert et;
        return et.id;
    }
        //to get fake Id by passing Object
        public static String getSobjectId(Schema.SObjectType sot) {
            Integer s_num = 1;
            String prefix;
            String result = String.valueOf(s_num++);
            prefix = sot.getDescribe().getKeyPrefix();
            return prefix + '0'.repeat(12 - result.length()) + result;
        }
        
        /**
     *
     * This method create test data for AppSetting custom setting for code coverage.
     *
     * @param strName The value is holding record name value.
     * 
     * @param strValue The value is holding record value.
     *
     */
    public static void insertAppSettingData(String strName, String strValue){
        AppSetting__c setting = new AppSetting__c();
        setting.Name = strName;
        setting.Value__c = strValue;
        insert setting;
    }

    }