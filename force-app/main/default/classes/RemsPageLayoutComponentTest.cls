@isTest(SeeAllData = false)
public class RemsPageLayoutComponentTest {
   
    
   public static testMethod void  method1() {
 id RemsRecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Enrollment').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Sodium Oxybate REMS';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.REMS_Project_Code__c = 'BT6825';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        Insert programObj;
        
        US_WSREMS__REMS_Service_Summary__c serviceObj = new US_WSREMS__REMS_Service_Summary__c();
        serviceObj.US_WSREMS__REMSProgram__c = programObj.id;
        serviceObj.US_WSREMS__Requestor_Type__c = 'Prescriber';
        serviceObj.US_WSREMS__Path_Stage_Name__c ='Intake';
        serviceObj.recordTypeId = RemsRecordTypeId;
        Insert serviceObj;
        
        Case caseObj = new Case(RecordTypeId = caseRecordTypeId,Program_Record_Type_Control__c = programObj.Name+'-Prescriber_Person_Account', US_WSREMS__First_Name__c = 'FirstName', US_WSREMS__Last_Name__c ='LastName', US_WSREMS__Phone__c = '1234567890',US_WSREMS__Fax__c = '8785968578', Status = 'Complete', US_WSREMS__REMS_Service_Summary__c = serviceObj.id);
        test.startTest();
        insert caseObj;
        test.stopTest();
       
     //   id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescribing Institution').getRecordTypeId();
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
                 
        Account accountObj = new Account();
       accountObj.FirstName = 'TestFirstName';
       accountObj.LastName = 'TestLastName';
      // accountObj.Name = 'Test Facility';
        accountObj.US_WSREMS__REMS_Program__c = programObj.id;
        accountObj.Rating = 'Hot';
        accountObj.Type = 'Prospect';
        accountObj.Industry = 'Banking';
        accountObj.Ownership = 'Public';
        accountObj.Phone = '1234567890';
        accountObj.AccountNumber = '4567';
        accountObj.Sic = 'Test Site';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.ShippingCountry = 'United States';
        accountObj.ShippingState = 'Alabama';
        accountObj.ShippingStreet = 'Test Street';
        accountObj.ShippingCity = 'Test City';
        accountObj.ShippingPostalCode = '12345';
        accountObj.SYN_Shipping_Address_2__c ='Test';
        insert accountObj;
       
        String payload = '{"data": [{"Id":'+accountObj.Id+',"Name":'+accountObj.Name+'}]}';
        
        //SYN_FieldMapping_Config__mdt[] prgfax = [SELECT MasterLabel,Section_Name__c,Source_Field__c,Source_Object__c,Source_RecordType_Name__c,Target_Field__c,Target_Object__c,Target_RecordType_Name__c, Account_Creation__c ,Requestor_Type__c FROM SYN_FieldMapping_Config__mdt];
        //System.debug(prgfax);
        SYN_FieldMapping_Config__mdt supportTier = new SYN_FieldMapping_Config__mdt();
        supportTier.DeveloperName = 'Test Record';
        supportTier.Source_Object__c ='Account' ;
        supportTier.Source_Field__c='US_WSREMS__Account_Type__c';
        supportTier.Section_Name__c ='Prescriber Information	';
        supportTier.Source_RecordType_Name__c='Prescribing_Institution';
        supportTier.Target_Field__c='US_WSREMS__Account_Type__c';
        supportTier.Target_Object__c ='Case';
        supportTier.Target_RecordType_Name__c = 'Prescriber_Person_Account';
        supportTier.Account_Creation__c =true;
        supportTier.Requestor_Type__c ='';
            try {
            RemsPagelayoutComponent.getAllRecordTypeDetailsById('Case');
            RemsPagelayoutComponent.getAllRecordTypeDetailsByName('Case');
        //    RemsPagelayoutComponent.caseAccountAssociation(caseObj.Id, accountObj.Id);
            RemsPagelayoutComponent.AccountCreationDetails AccountCreationDetailsObj = RemsPagelayoutComponent.createAccountOnCaseCreation(caseObj.Id);
            RemsPagelayoutComponent.getPGfileds('case-case Layout');
        RemsPagelayoutComponent.updateAccountOnCaseCreation(caseObj.id,accountObj.id);
                //RemsPagelayoutComponent.checkAccountDuplicates(caseRecordTypeId,payload);
       RemsPagelayoutComponent.getPrepopFields(accountObj.Id,'Account',caseRecordTypeId);
            RemsPagelayoutComponent.createAccountOnCaseCreation(caseObj.Id);
        // test Oct 12    
           
       }catch(exception e){
            system.debug(e);
        }
    }
  
}