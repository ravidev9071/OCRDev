@IsTest
public class UpdatePrescriberEnrollmentTest {
    @TestSetup
    static void makeData(){
        Id accRectypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Office_Contact').getRecordTypeId();
        Id affRectypeId = Schema.getGlobalDescribe().get('US_WSREMS__Affiliation__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Office_Contact_Affiliation').getRecordTypeId();
        Id casRecTypeId= Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('Office_Contact').getRecordTypeId();
        Account acc = new Account(FirstName = 'Test', LastName = 'Account', Phone = '1234567890', RecordTypeId = accRectypeId, US_WSREMS__Email__c = 'test@gmail.com');
        insert acc;
        Case cs = new Case(First_Name_ar2__c = 'Test', Last_Name_ar2__c = 'Account', office_contact_phone_Secondary_Office__c = '1234567890', 
                           Email_Secondary_Office__c = 'test@gmail.com', SYN_Prescriber__c = acc.Id, 
                           Fax_Secondary_Office__c = '1234567890', US_WSREMS__Program_Picklist__c = 'Macitentan REMS', Phone_Secondary_Office__c = '1234567890', 
                           US_WSREMS__Channel__c = 'Fax', RecordTypeId = casRecTypeId);
        insert cs;
    }
    @IsTest
    static void testUpdateOCLookup(){
        Case cs = [SELECT id,First_Name_ar2__c,Last_Name_ar2__c,office_contact_phone_Secondary_Office__c,
                  Email_Secondary_Office__c,US_WSREMS__REMS_Program__c,SYN_Prescriber__c,Fax_Secondary_Office__c,
                	US_WSREMS__Program_Picklist__c,
                   Phone_Secondary_Office__c,US_WSREMS__Channel__c
                  FROM Case LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        list<UpdatePrescriberEnrollment.updateOCLookups> caseList = new list<UpdatePrescriberEnrollment.updateOCLookups>();
        UpdatePrescriberEnrollment.updateOCLookups caseRecord = new UpdatePrescriberEnrollment.updateOCLookups();
        caseRecord.caseId = cs.Id;
        caseList.add(caseRecord);
        UpdatePrescriberEnrollment.updateOCLookup(caseList);
    }
}