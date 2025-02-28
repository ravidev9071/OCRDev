/**
* @File Name : piaSky_PrescriberEnrollmentForm_Test.cls
* @Description : This class is responsible for a test coverage of piaSky_PrescriberEnrollmentForm.
* @Author : Wilco
* @Last Modified By : Shaik Ismail
* @Last Modified On : Novomber 11, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | Novomber 11, 2024 |   | Initial Version
**/



@isTest
public class piaSky_PrescriberEnrollmentForm_Test {
    
    public static final String nameSpacePrefix = REMSAppLiterals.NAMESPACE_STRING.removeEnd('__');
    
    @testSetup
    static void setupTestData() {
        US_WSREMS__REMS_Program__c piaskeyProgram = new US_WSREMS__REMS_Program__c(Name = 'PiaSky REMS');
        piaskeyProgram.US_WSREMS__Status__c = 'Active';
        insert piaskeyProgram;
        
        
        List<Account> accList = new List<Account>();
        
        Account newAccount = new Account();
        newAccount.FirstName = 'Test Account';
        newAccount.MiddleName = 'Portal';
        newAccount.LastName = 'Tersting';
        newAccount.PersonEmail = 'test@testing.com';
        newAccount.US_WSREMS__Email__c = 'test@testing.com';
        newAccount.Phone = '6789098765';
        newAccount.US_WSREMS__Fax_Number__c = '89876';
        newAccount.US_WSREMS__Preferred_Contact_Method__c = 'Email';
        newAccount.RecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Pharmacy/HCS Participant').getRecordTypeId();
        newAccount.US_WSREMS__Channel__c = 'Email';
        newAccount.US_WSREMS__REMS_Program__c = piaskeyProgram.Id;
        newAccount.US_WSREMS__Program_Picklist__c = 'PiaSky REMS';
        
        accList.add(newAccount);
        insert accList;
    }
    
    @isTest
    static void getPicklistFieldValues() {
        Test.startTest();
        Map<String, Map<String, String>> result = piaSky_PrescriberEnrollmentForm.getPicklistFieldValues();
        Test.stopTest();
    }
    
    @isTest
    static void insertDataOnHCPSubmit1(){
        Map<String, String> inputRecords = new Map<String, String>{
            'recordDetails' => '{"FirstName":"Test","LastName":"Account","email":"test@testing.com","US_WSREMS__User_Type__c":"Pharmacy Staff"}',
                'programName' => 'PiaSky REMS',
                'participantType' => 'Pharmacy/HCS Participant'
                };  
                    Test.startTest();
        String result = piaSky_PrescriberEnrollmentForm.insertDataOnHCPSubmit(inputRecords);
        Test.stopTest();
    }
    
     @isTest
    static void insertDataOnHCPSubmit22(){
        Map<String, String> inputRecords = new Map<String, String>{
            'recordDetails' => '{"FirstName":"Test","LastName":"Account","email":"test@testing1.com","US_WSREMS__User_Type__c":"Pharmacy Staff"}',
                'programName' => 'PiaSky REMS',
                'participantType' => 'Pharmacy/HCS Participant'
                };  
                    Test.startTest();
        String result = piaSky_PrescriberEnrollmentForm.insertDataOnHCPSubmit(inputRecords);
        Test.stopTest();
    }
    
    
    @isTest
    static void insertDataOnHCPSubmit2() {
        try{
            String PATICIPANT_USER_PROFILE_NAME = 'Portal Stakeholder Profile';
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
                
                Map<String,String> inputRecords = new Map<String,String>();
                inputRecords.put('recordDetails',JSON.serialize(recordData));
                inputRecords.put('programName',programName);
                inputRecords.put('participantType',participantType);
                inputRecords.put('profileName',PATICIPANT_USER_PROFILE_NAME);
                inputRecords.put('permissionSet','PortalStakeholderPermissionSet');
                
                Test.startTest();
                String result = piaSky_PrescriberEnrollmentForm.insertDataOnHCPSubmit(inputRecords);
                piaSky_PrescriberEnrollmentForm.SavePrescriberSignature(accountObj.Id,'Paisky Rems','Testing Doc');
                
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
    static void insertDataOnHCPSubmit3() {
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriber('0909876545',12345678,'1234567896',true, programList[0].Id );
        piaSky_PrescriberEnrollmentForm.SavePrescriberSignature(accountObj.Id,'Paisky Rems','Testing Doc');
        
    }
    
    public static List<US_WSREMS__REMS_Program__c> createPrograms(integer noOfRecords,boolean isCreate){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = 'PiaSky REMS Program';
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