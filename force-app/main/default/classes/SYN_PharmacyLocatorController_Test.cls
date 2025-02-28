/**************************************************************************
    * Name :   SYN_PharmacyLocatorController_Test 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  08/11/2022             Initial Version
    *********************************************************************************/
    
 @isTest()
public class SYN_PharmacyLocatorController_Test {
 
   public static testMethod void getPharmacyList_Test() {
     
         id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Pharmacy').getRecordTypeId();

         US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
         Account accountObj = SYN_TestDataUtility.createPharmacyAccountTest(programObj.Id,recordTypeId); 
         US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);
 
        Test.StartTest();
           List<Account> PharmacyAccountList = SYN_PharmacyLocatorController.getPharmacyList(programObj.Id);
           System.Assert(!PharmacyAccountList.isEmpty());
        Test.StopTest();
                                                 
     }
}