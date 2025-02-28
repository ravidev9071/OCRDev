@isTest
public class Tryvio_IPFormCnrtler_Test {
        
    public static testMethod void getPharmacyAccountData() {

        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c(
            Name = 'TRYVIO REMS',
            US_WSREMS__Status__c ='Active',
            US_WSREMS__Program_State_Date__c = System.today(),
            US_WSREMS__Program_End_Date__c = System.today().addDays(20)
        );
        insert programObj;
        String accountRecordTypeId;
        String caseRecordTypeId;
        for(RecordType rT : [SELECT Id, DeveloperName FROM RecordType WHERE NamespacePrefix = 'US_WSREMS' AND ((SObjectType = 'Account' AND DeveloperName = 'Inpatient_Pharmacy_Account') OR (SobjectType = 'Case' AND DeveloperName = 'Inpatient_Pharmacy_Enrollment'))]) {
            accountRecordTypeId = (rT.DeveloperName == 'Inpatient_Pharmacy_Account') ? rT.Id : accountRecordTypeId;
            caseRecordTypeId = (rT.DeveloperName == 'Inpatient_Pharmacy_Enrollment') ? rT.Id : caseRecordTypeId;
        }
        
        System.debug('#### accountRecordTypeId :: '+accountRecordTypeId);
        System.debug('#### caseRecordTypeId :: '+caseRecordTypeId);

        Account accountIns = new Account(
            Name = 'Test',
            US_WSREMS__REMS_Program__c = programObj.id,
            US_WSREMS__National_Provider_Identifier__c ='2173940290',
            US_WSREMS__NPI__c = '2173940290',
            RecordTypeId = accountRecordTypeId,
            US_WSREMS__Program_Picklist__c = programObj.Name
            
        );
        insert accountIns;
		ApexPages.currentPage().getParameters().put('Id', accountIns.Id);
        Tryvio_InpatientPharmacyFormController cntrller1 = new Tryvio_InpatientPharmacyFormController();
        Case caseIns = new Case(
            RecordTypeId = caseRecordTypeId,
            Program_Record_Type_Control__c = 'TRYVIO REMS-Inpatient_Pharmacy_Enrollment',
            US_WSREMS__Channel__c = 'Fax',
            US_WSREMS__First_Name__c = 'Test',
            US_WSREMS__Last_Name__c = 'Test',
            US_WSREMS__MI__c = 'Test', 
            US_WSREMS__Email__c = 'test@test.com',
            US_WSREMS__Participant__c = accountIns.Id
        );
        insert caseIns;
        System.debug('caseIns:::'+caseIns);
        
        Tryvio_InpatientPharmacyFormController cntrller = new Tryvio_InpatientPharmacyFormController();
        cntrller.getCaseRec();
    }
}