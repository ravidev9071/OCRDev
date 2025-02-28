/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MapLocatorSearchController_Test {

    @isTest
    public static void  getAccounts(){
        Test.startTest();
        SYN_TestDataUtility.insertAppSettingData('AZURE_MAPS', 'AzureMapsMapProvider');
        SYN_TestDataUtility.insertAppSettingData('AZURE_MAPS_ENDPOINTURL', 'AzureMapsMapProvider;encodedQuery;subscriptionKey');
        SYN_TestDataUtility.insertAppSettingData('AZURE_MAPS_ACCESSTOKEN', 'AzureMapsMapProvider;ENCODED_QUERY;SUBSCRIPTION_KEY');
        US_WSREMS__REMS_Program__c programRec = SYN_TestDataUtility.createProgram('TRYVIO REMS','Active');
       
        account pharmacyAcc = SYN_TestDataFactory.createPharmacyAccount('741258963','7458269301',False,programRec.Id);
        pharmacyAcc.US_WSREMS__Status__c = 'Certified';
        pharmacyAcc.Program__c = 'TRYVIO REMS';//programObj[0].Name;
        insert pharmacyAcc;
        List<Account> certifiedAccTest = MapLocatorSearchController.searchRecords(pharmacyAcc.name,'Healthcare', 'Lookup', '5', 'Tryvio', 'Azure');
        System.assert(certifiedAccTest != null);
        certifiedAccTest = MapLocatorSearchController.searchRecords(pharmacyAcc.name,'Prescribers', 'Locator', '5', 'Tryvio','Azure');
        System.assert(certifiedAccTest != null);
        Test.stopTest();
    }


}