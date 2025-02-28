@isTest
public class NPISearchControllerPortalTest {

  public static final String nameSpacePrefix = REMSAppLiterals.NAMESPACE_STRING.removeEnd('__');


    @isTest
    static void testGetNpisNonEmptySearchKey() {
        String searchKey = '2345678900';

        HealthcareProviderNpi oHealth = new HealthcareProviderNpi();
        oHealth.Name = 'test';
        oHealth.US_WSREMS__Email__c = 'test@gmail.com';
        oHealth.US_WSREMS__Phone__c = 'test';
        oHealth.US_WSREMS__First_Name__c = 'test';
        oHealth.US_WSREMS__Last_Name__c = 'testt';
        oHealth.NPI = searchKey;
        
        insert oHealth;


        String result = NPISearchControllerPortal.getNpis(searchKey,'AVEED REMS');
        // Add assertions for the getNpis method
        Assert.areNotEqual(result,'BothFound','Only one NPI record should be found');
    } 

    @isTest
    static void testGetNpisNonEmptySearchKeyBoth() {
        String searchKey = '2341678900';

        HealthcareProviderNpi oHealth = new HealthcareProviderNpi();
        oHealth.Name = 'test';
        oHealth.US_WSREMS__Email__c = 'test@gmail.com';
        oHealth.US_WSREMS__Phone__c = 'test';
        oHealth.US_WSREMS__First_Name__c = 'test';
        oHealth.US_WSREMS__Last_Name__c = 'testt';
        oHealth.NPI = searchKey;
        
        insert oHealth;
		//NPISearchControllerPortal.getNameSpace();
		List<US_WSREMS__REMS_Program__c> programList = SYN_TestDataFactory.createPrograms(1, true);
        Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriberAveed(searchKey,12345678,'1234567896',true,programList[0].Id);
      
        String result = NPISearchControllerPortal.getNpis(searchKey,'AVEED REMS');
        
    } 
    
    @isTest
    static void getOrgNpisTest() {
        String searchKey = '2345678900';

        HealthcareProviderNpi oHealth = new HealthcareProviderNpi();
        oHealth.Name = 'test';
        oHealth.US_WSREMS__Email__c = 'test@gmail.com';
        oHealth.US_WSREMS__Phone__c = 'test';
        oHealth.US_WSREMS__First_Name__c = 'test';
        oHealth.US_WSREMS__Last_Name__c = 'testt';
        oHealth.NPI = searchKey;
        oHealth.NpiType = 'Organization';
        
        insert oHealth;
		
		List<US_WSREMS__REMS_Program__c> programList = SYN_TestDataFactory.createPrograms(1, true);
        Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriberAveed(searchKey,12345678,'1234567896',true,programList[0].Id);

        
        
        String result = NPISearchControllerPortal.getOrgNpis(searchKey,'AVEED REMS');
        
		
    }
    @isTest
    static void getOrgNpisTest1() {
        String searchKey = '2345678900';

        HealthcareProviderNpi oHealth = new HealthcareProviderNpi();
        oHealth.Name = 'test';
        oHealth.US_WSREMS__Email__c = 'test@gmail.com';
        oHealth.US_WSREMS__Phone__c = 'test';
        oHealth.US_WSREMS__First_Name__c = 'test';
        oHealth.US_WSREMS__Last_Name__c = 'testt';
        oHealth.NPI = searchKey;
        oHealth.NpiType = 'Organization';
        
        insert oHealth;
		
               
        String result = NPISearchControllerPortal.getOrgNpis(searchKey,'AVEED REMS');
        
    }

    @isTest
    static void testCreateRecordOnSubmit() {
        try{
            String searchKey = '2345678900';
        String PATICIPANT_USER_PROFILE_NAME = 'AVEED Portal';
        Id recordTypeId = [SELECT Id FROM RecordType WHERE NamespacePrefix =:nameSpacePrefix AND SobjectType = :REMSAppLiterals.ACCOUNT_OBJECT AND DeveloperName = 'Prescriber' LIMIT 1].Id;       
            
        List<US_WSREMS__REMS_Program__c> programList = SYN_TestDataFactory.createPrograms(1, true);
        Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriberAveed(searchKey,12345678,'1234567896',true,programList[0].Id);

        if (programList != null && programList.size() > 0) {
            NPISearchControllerPortal.RecordDataWrapper recordData = new NPISearchControllerPortal.RecordDataWrapper();
            recordData.npi = '1234567890';
            recordData.fax = '1234567890';
            recordData.phone = '1234567890';
            recordData.email = 'testsa1233@abc.com';
            recordData.lastName = 'testLast';
            recordData.middleName = 'middle';
            recordData.firstName = 'first';
            String programName = programList[0].Name;
            String participantType = 'Prescriber';

            Map<String,String> inputRecords = new Map<String,String>();
            inputRecords.put('recordDetails',JSON.serialize(recordData));
            inputRecords.put('programName',programName);
            inputRecords.put('participantType',participantType);
            inputRecords.put('profileName',PATICIPANT_USER_PROFILE_NAME);
            inputRecords.put('permissionSet','AVEED_PortalPermissionSet');

            Test.startTest();
          
            String result = NPISearchControllerPortal.createRecordOnSubmit(inputRecords,'Account Exists');
            Test.stopTest();

            User oUser = [SELECT Id FROM User WHERE UserName = :recordData.email];

            // Add assertions for the createRecordOnSubmit method
            Assert.areNotEqual(oUser, null, 'User should be retrieved'); 
           Assert.areEqual(oUser.Id, result, 'NPI search conrtoller should retrun the created user'); 
        }
        }catch(exception e)  {
             system.debug('Exception occured '+e.getMessage());
         }
    }
   
   

    @isTest
    static void testCreateRecordOnSubmitEmpty() {
        String PATICIPANT_USER_PROFILE_NAME = 'AVEED Portal';
        String recordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.ACCOUNT_OBJECT).get('Prescriber');
        List<US_WSREMS__REMS_Program__c> programList = SYN_TestDataFactory.createPrograms(1, true);
        Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriberAveed('0909876545',12345678,'1234567896',true,programList[0].Id);
       
        if (!programList.isEmpty()) {
            String programName = programList[0].Name;
            String participantType = 'Prescriber';
            
            Map<String,String> inputRecords = new Map<String,String>();
            inputRecords.put('recordDetails','');
            inputRecords.put('programName',programName);
            inputRecords.put('participantType',participantType);
            inputRecords.put('profileName',PATICIPANT_USER_PROFILE_NAME);

            Test.startTest();
           
            String result = NPISearchControllerPortal.createRecordOnSubmit(inputRecords,'Account Exists');
            Test.stopTest();

            // Add assertions for the createRecordOnSubmit method
           Assert.areEqual('Failed', result, 'Failed warning should be returned for blank inputs'); 

        } 
    }
    
     @isTest static void testUser() {
        try{
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.assertNotEquals(null, thisUser, 'Test user not found');
           
            System.runAs(thisUser) {
                // startTest/stopTest block to run future method synchronously
                Test.startTest();    
                NPISearchControllerPortal.updateActiveUser(thisUser.Id);
                NPISearchControllerPortal.updateInactiveUser(thisUser.Id);
                Test.stopTest();
			
            }
        }catch(Exception ex){
            System.debug('Exception occured: ' +ex.getMessage());
        }
        
    }
    
    @isTest
        static void tesNpiNotFound(){
         String searchKey = '2345678900';

        HealthcareProviderNpi oHealth = new HealthcareProviderNpi();
        oHealth.Name = 'test';
        oHealth.US_WSREMS__Email__c = 'test@gmail.com';
        oHealth.US_WSREMS__Phone__c = 'test';
        oHealth.US_WSREMS__First_Name__c = 'test';
        oHealth.US_WSREMS__Last_Name__c = 'testt';
        oHealth.NPI = searchKey;
        
        insert oHealth;

        try{
            Test.startTest();
            String result = NPISearchControllerPortal.getNpis(searchKey,'');
            String result1 = NPISearchControllerPortal.getOrgNpis(searchKey,'');
            Test.stopTest();
                    

            
        }catch(Exception ex){
            System.debug('Exception occured: ' +ex.getMessage());
        }        
    }
    
    @isTest
    static void updateServiceSummaryFail(){
        try{
            Test.startTest();
            US_WSREMS__REMS_Service_Summary__c summary = new US_WSREMS__REMS_Service_Summary__c();
            NPISearchControllerPortal.updateServiceSummary(summary);
            Test.stopTest();
        }catch(Exception ex){
            System.debug('Exception occured: ' +ex.getMessage());
        }            
    }
    @isTest
    static void insertServiceSummaryFail(){
        try{
            Test.startTest();
            NPISearchControllerPortal.insertServiceSummary(null,null,null,'');
            Test.stopTest();
        }catch(Exception ex){
            System.debug('Exception occured: ' +ex.getMessage());
        }            
    }    
    @isTest
    static void insertCaseFail(){
        try{
            Test.startTest();
            NPISearchControllerPortal.insertCase(null,null,null,null,'','' ,'');
            Test.stopTest();
        }catch(Exception ex){
            System.debug('Exception occured: ' +ex.getMessage());
        }            
    } 


    @isTest
    static void getNPIOrgNpisTest() {
        String searchKey = '2345678900';

        HealthcareProviderNpi oHealth = new HealthcareProviderNpi();
        oHealth.Name = 'test';
        oHealth.US_WSREMS__Email__c = 'test@gmail.com';
        oHealth.US_WSREMS__Phone__c = 'test';
        oHealth.US_WSREMS__First_Name__c = 'test';
        oHealth.US_WSREMS__Last_Name__c = 'testt';
        oHealth.NPI = searchKey;
        
        insert oHealth;


        String result = NPISearchControllerPortal.getNPIOrgNpis(searchKey,'Test ');
        // Add assertions for the getNpis method
        Assert.areNotEqual(result,'BothFound','Only one NPI record should be found');
    }


    @isTest
    static void testCreateRecordOnSubmitOutpatient() {
        try{
             String searchKey = '2345678900';
        String PATICIPANT_USER_PROFILE_NAME = 'AVEED Portal';
        Id recordTypeId = [SELECT Id FROM RecordType WHERE NamespacePrefix =:nameSpacePrefix AND SobjectType = :REMSAppLiterals.ACCOUNT_OBJECT AND DeveloperName = 'Prescriber' LIMIT 1].Id;            
        List<US_WSREMS__REMS_Program__c> programList = SYN_TestDataFactory.createPrograms(1, true);
            Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriberAveed(searchKey,12345678,'1234567896',true,programList[0].Id);
            if (programList != null && programList.size() > 0) {
            NPISearchControllerPortal.RecordDataWrapper recordData = new NPISearchControllerPortal.RecordDataWrapper();
            recordData.npi = '1234567890';
            recordData.fax = '1234567890';
            recordData.phone = '1234567890';
            recordData.email = 'testsa1233@abc.com';
            recordData.lastName = 'testLast';
            recordData.middleName = 'middle';
            recordData.firstName = 'first';
            recordData.name = 'test';
            String programName = programList[0].Name;

            Map<String,String> inputRecords = new Map<String,String>();
            inputRecords.put('recordDetails',JSON.serialize(recordData));
            inputRecords.put('programName',programName);
            inputRecords.put('participantType',REMSAppLiterals.REQUESTORTYPE_OUTPATIENT);
            inputRecords.put('profileName',PATICIPANT_USER_PROFILE_NAME);
            inputRecords.put('permissionSet','AVEED_PortalPermissionSet');


            Account personAccountFields = new Account(US_WSREMS__Email__c='test@test.com',US_WSREMS__Middle_Name__c='Test',LastName='sample');
            Account businessAccountFields = new Account(US_WSREMS__Email__c='test@test.com',US_WSREMS__Middle_Name__c='Test',Name='Test');     
            
            inputRecords.put('businessAccount',JSON.serialize(businessAccountFields));
            inputRecords.put('personAccount',JSON.serialize(personAccountFields));

            Test.startTest();
          
            String result = NPISearchControllerPortal.createRecordOnSubmit(inputRecords,'Account Exists');
            NPISearchControllerPortal.checkARduplicate(inputRecords);
            Test.stopTest();
        }
        }catch(exception e)  {
             system.debug('Exception occured '+e.getMessage());
        }            
    }  

    @isTest
    private static void insertCommunityUserTest(){
        String searchKey = '2345678900';
        String PATICIPANT_USER_PROFILE_NAME = 'AVEED Portal';
        String role = 'Prescriber';
        List<US_WSREMS__REMS_Program__c> programList = SYN_TestDataFactory.createPrograms(1, true);
        NPISearchControllerPortal.RecordDataWrapper recordData = new NPISearchControllerPortal.RecordDataWrapper();
        recordData.npi = '1234567890';
        recordData.fax = '1234567890';
        recordData.phone = '1234567890';
        recordData.email = 'testsa1233@abc.com';
        recordData.lastName = 'testLast';
        recordData.middleName = 'middle';
        recordData.firstName = 'testName';
        String programName = programList[0].Name;
        String participantType = 'Prescriber';

        Account personAccount = new Account();
        personAccount.Phone = '123456789';
        personAccount.Fax = '123456789';
        personAccount.FirstName = 'test';
        personAccount.LastName = 'one';
        personAccount.US_WSREMS__REMS_Program__c = programList[0].Id;
        personAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        insert personAccount; 

         List<Account> accList = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAccount.Id];
        Test.startTest();
            String result = NPISearchControllerPortal.insertCommunityUser(recordData, programList, accList ,PATICIPANT_USER_PROFILE_NAME, 'AVEED_PortalPermissionSet', role);
        Test.stopTest();

        System.assert(result != null);
    }
}