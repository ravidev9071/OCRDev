@isTest
public class SYN_AccountsDuplicateCheck_Test {
   
    public static testMethod void createTestData()
    {
       Id accRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Distributor_Account').getRecordTypeId();
        List<US_WSREMS__REMS_Program__c > remsProgramList = SYN_TestDataFactory.createSOXPrograms1(1,true, Label.Macitentan_REMS_Program_Name);
        US_WSREMS__Program_Users__c programUserData = SYN_TestDataUtility.createProgramUser(userInfo.getUserId(),remsProgramList[0].Id);
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        String payload = '{"data": [{"Id":'+PrescriberObj.Id+',"Name":'+PrescriberObj.Name+'}]}';
        SYN_AccountsDuplicateCheck.checkDuplicate(accRecTypeId,payload);
        
    }
    public static testMethod void createTestData1()
    {
       Id accRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution_Account').getRecordTypeId();
        List<US_WSREMS__REMS_Program__c > remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        String payload = '{"data": [{"Id":'+PrescriberObj.Id+',"Name":'+PrescriberObj.Name+'}]}';
        SYN_AccountsDuplicateCheck.checkDuplicate(accRecTypeId,payload);
        
    }
    public static testMethod void createTestData2()
    {
       Id accRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Account').getRecordTypeId();
        List<US_WSREMS__REMS_Program__c > remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        String payload = '{"data": [{"Id":'+PrescriberObj.Id+',"Name":'+PrescriberObj.Name+'}]}';
        SYN_AccountsDuplicateCheck.checkDuplicate(accRecTypeId,payload);
        
    }
    public static testMethod void createTestData3()
    {
       Id accRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
        List<US_WSREMS__REMS_Program__c > remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        //String payload = '{"data": [{"Id":'+PrescriberObj.Id+',"FirsUS_WSREMS__Program_Users__ctName":'+PrescriberObj.Name+'}]}';
         String payload = '{"Id":"","US_WSREMS__First_Name__c":"Test 1","US_WSREMS__Last_Name__c":"Test 2"}';

        SYN_AccountsDuplicateCheck.checkDuplicate(accRecTypeId,payload);
        
    }
     public static testMethod void createTestData4()
    {
       Id accRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SYN_Patient_Person_Account').getRecordTypeId();
        List<US_WSREMS__REMS_Program__c > remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
       // String payload = '{"data": [{"Id":'+PrescriberObj.Id+',"Name":'+PrescriberObj.Name+'}]}';
        String payload = '{"Id":"","FirstName":"Test 1","US_WSREMS__Last_Name__c":"Test 2","US_WSREMS__Phone__c":"1234567890"}';

        SYN_AccountsDuplicateCheck.checkDuplicate(accRecTypeId,payload);
        
    }
     public static testMethod void createTestData5()
    {
       Id accRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant_Account').getRecordTypeId();
        List<US_WSREMS__REMS_Program__c > remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        //String payload = '{"Id":'+PrescriberObj.Id+',"FirstName":'+PrescriberObj.Name+',"LastName":'+PrescriberObj.Name+'}';
         String payload = '{"Id":"","US_WSREMS__First_Name__c":"Test 1","US_WSREMS__Last_Name__c":"Test 2","US_WSREMS__Phone__c":"1234567890"}';

        SYN_AccountsDuplicateCheck.checkDuplicate(accRecTypeId,payload);
      
    } 
       public static testMethod void createTestData6()
    {
       Id accRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();
        List<US_WSREMS__REMS_Program__c > remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        //String payload = '{"Id":'+PrescriberObj.Id+',"FirstName":'+PrescriberObj.Name+',"LastName":'+PrescriberObj.Name+'}';
         String payload = '{"Id":"","US_WSREMS__First_Name__c":"Test 1","US_WSREMS__Last_Name__c":"Test 2","US_WSREMS__Phone__c":"1234567890"}';

        SYN_AccountsDuplicateCheck.checkDuplicate(accRecTypeId,payload);
      
    }
}