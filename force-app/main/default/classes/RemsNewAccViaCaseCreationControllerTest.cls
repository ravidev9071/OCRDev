/**************************************************************************
    * Name :   RemsNewAccViaCaseCreationControllerTest 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  14/09/2022             Initial Version
    *********************************************************************************/


@isTest
public class RemsNewAccViaCaseCreationControllerTest {
     
     public static testMethod void GeneralContactAccountCreation_Test() {
     
         id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescribing Institution').getRecordTypeId();
         id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();

         US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
         Account accountObj = SYN_TestDataUtility.createPrescribingInstitutionAccount(programObj.Id,recordTypeId);
         Case caseObj = SYN_TestDataUtility.createaNewCase(caseRecordTypeId,'FirstName','LastName', 'Draft',programObj.id);
         US_WSREMS__Program_Users__c programUser = SYN_TestDataUtility.createProgramUser(UserInfo.getUserId(),programObj.id);

         Test.StartTest();
             List<US_WSREMS__Program_Users__c> userList = RemsNewAccViaCaseCreationController.getCurrentUserProgram();
              System.assert(userList.size()>0);
             List<RemsNewAccViaCaseCreationController.RCtypeAndRelatedInfoWrapper> rcTypeWrapper = RemsNewAccViaCaseCreationController.getRecordTypeInfo('Macitentan REMS','Case');
             System.assert(rcTypeWrapper.size()>0);
             List<LightningRecordEditFormController.LayoutSection> Pgfields = REMSPagelayoutConfigComponentController.getPGfileds('Case-MACI General Contact Person Account');
             System.assert(Pgfields.size()>0);
             List<String> lookupfields = REMSPagelayoutConfigComponentController.getlookupfields('Case','Macitentan REMS');
             System.assert(lookupfields.size()>0);
             Map<String,String> TargetFieldToValueMap = REMSPagelayoutConfigComponentController.getPrepopFields(accountObj.id,'Case',caseRecordTypeId ,'Macitentan REMS','US_WSREMS__Facility__c');
             System.assert(!TargetFieldToValueMap.isEmpty());
             //REMSPagelayoutConfigComponentController.checkAccountDuplicates(caseRecordTypeId,'');
             REMSPagelayoutConfigComponentController.AccountCreationDetails creat = REMSPagelayoutConfigComponentController.createAccountOnCaseCreation(caseObj.id);
             System.assert(creat.AccountCreate = true);
         Test.StopTest();
                                         
     }
     
     public static testMethod void GeneralContactAccountCreation_NegativeTest() {
 
         id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescribing Institution').getRecordTypeId();
         id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();

         US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('Macitentan REMS','Active');
         Account accountObj = SYN_TestDataUtility.createPrescribingInstitutionAccount(programObj.Id,recordTypeId);
         Case caseObj = SYN_TestDataUtility.createaNewCase(caseRecordTypeId,'FirstName','LastName', 'Draft',null);

         Test.StartTest();
             REMSPagelayoutConfigComponentController.createAccountOnCaseCreation(caseObj.id);
         Test.StopTest();
                                         
     }

}