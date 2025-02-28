/*****************************************************************************************************************
    * Class Name           : xiaflex_NPISearchControllerPortal_Test
    * @Description         : This is the test class for the vlass xiaflex_NPISearchControllerPortal
	* @Author              : Krishnababu Mullapudi
    * @CreatedDate         : 31-07-2024
******************************************************************************************************************/

@isTest
public class xiaflex_NPISearchControllerPortal_Test {
    @isTest
    static void testGetNpis() {
        // Setup test data
        String searchKey = '1234567890';
        String programName = 'XIAFLEX';
        
        // Create a test HealthcareProviderNpi record
        HealthcareProviderNpi npiRec = new HealthcareProviderNpi(
            US_WSREMS__First_Name__c = 'Test',
            US_WSREMS__Last_Name__c = 'Portal',
            Npi = searchKey,
            Name = 'Test NPI',
            US_WSREMS__Email__c = 'test@example.com',
            US_WSREMS__Phone__c = '1234567890',
            US_WSREMS__Fax__c = '123-456-7891',
            NpiType = 'Individual'
        );
        insert npiRec;
        
        // Call the method under test
        String result = xiaflex_NPISearchControllerPortal.getNpis(searchKey, programName);
         // Add assertions
        System.assert(result != null, 'Result should not be null');
        System.assert(result != '', 'Result should not be empty');
       
    }
    @isTest
    static void testCreateRecordOnSubmit() {
        // Creating Rems Program
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('XIAFLEX','Active');
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Pharmacy').getRecordTypeId();
        Account acc = SYN_TestDataUtility.createPharmacyAccountTest(programObj.id,recordTypeId);
        // Setup test data
        xiaflex_NPISearchControllerPortal.RecordDataWrapper recordData = new xiaflex_NPISearchControllerPortal.RecordDataWrapper();
        recordData.firstName = 'Test';
        recordData.lastName = 'Portal';
        recordData.email = 'TestPortal@example.com';
        recordData.phone = '1234567890';
        recordData.fax = '123-456-7891';
        recordData.npi = '1234567890';
        recordData.participantType = 'Prescriber';
        recordData.PMC = 'Email';
        recordData.hcsEmail = 'test@example.com';
        recordData.name = 'TestPortal';
        recorddata.DEA='';
        Map<String, String> inputRecord = new Map<String, String>{
            'recordDetails' => JSON.serialize(recordData),
            'pharmacyId' => '12345',
            'programName' => 'XIAFLEX',
            'profileName' => 'XIAFLEX Portal',
            'permissionSet' => 'XIAFLEX_Portal_PermissionSet'
        };
        string inputRecords = JSON.serialize(inputRecord);   

		string phAcc = String.valueOf(acc.id);        
        // Call the method under test
        String userId = xiaflex_NPISearchControllerPortal.createRecordOnSubmit(inputRecords, phAcc, 'Authorized Representative Affiliation');
        System.assert([SELECT Id FROM Account WHERE Id = :acc.Id].size() > 0, 'Account record should be inserted');
    }
}