/**
* @File Name : PiaskyReportableEventFormCtrTest.cls
* @Description : This class is responsible for a test coverage of PiaskyReportableEventFormCtr.
* @Author : Wilco
* @Last Modified By : Shaik Aneesha
* @Last Modified On : Novomber 11, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | Novomber 11, 2024 |   | Initial Version
**/

@IsTest
private class PiaskyReportableEventFormCtrTest {
    @IsTest
    static void piaskyReportableEventFormCtr_Test() {
        
        id recordTypeIdPAEServiceId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByName().get('PAE/PC/MI').getRecordTypeId();
         id recordTypeIdPatient = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('PAE').getRecordTypeId();
        id recordTypeIdPrescriber = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram('PiaSky REMS','Active');
        Account createPatientAccount= SYN_TestDataUtility.createPatientAccount(programObj.Id,recordTypeIdPatient);
        Account prescAcc = SYN_TestDataUtility.createPrescriberAccountWithNPI(programObj.Id,recordTypeIdPrescriber);
        
        US_WSREMS__REMS_Service_Summary__c objService = new US_WSREMS__REMS_Service_Summary__c(
            US_WSREMS__Participant__c=createPatientAccount.Id,
            US_WSREMS__REMSProgram__c = programObj.Id,
            US_WSREMS__Service_Outcome__c='Successful',
            US_WSREMS__Status__c ='Closed', 
            RecordTypeId=recordTypeIdPAEServiceId,
            US_WSREMS__Requestor_Type__c='Patient'
        );
        Insert objService;
        
        
        Case cs = New Case(RecordTypeid=caseRecordTypeId, US_WSREMS__REMS_Program__c=programObj.Id,US_WSREMS__Program_Picklist__c='piaSky REMS',
                           US_WSREMS__Channel__c='Phone',US_WSREMS__Type_of_Report__c='Potential Adverse Event (PAE)',SYN_Sponsor_Responsible__c='Genentech Inc.',
                           US_WSREMS__Phone__c='9878887777',SYN_Reporter__c=createPatientAccount.Id,Date_Voicemail_or_Fax_received__c=Date.Today(),
                           SYN_Prescriber__c=prescAcc.ID,US_WSREMS__Patient__c=createPatientAccount.Id,Program_Record_Type_Control__c='PiaSky REMS-PAE',US_WSREMS__Product_Type__c ='PiaSky (crovalimab)',
                           SYN_Event_Description__c='test',status='Complete',US_WSREMS__Outcome__c='Acknowledgment Pending',US_WSREMS__Participant__c=createPatientAccount.Id,US_WSREMS__REMS_Service_Summary__c = objService.Id,
                           SYN_Reporter_First_Name__c='Test', SYN_Reporter_Last_Name__c='testt',US_WSREMS__First_Name__c='test',US_WSREMS__Last_Name__c='testt');
        
        
        insert cs;
        
        PageReference pageRef = Page.Piasky_reportable_Form; // Replace with your Visualforce page name
        Test.setCurrentPage(pageRef);
        // Set parameters on the page
        ApexPages.currentPage().getParameters().put('Id', cs.Id);
        
        PiaskyReportableEventFormCtr p = new PiaskyReportableEventFormCtr();
        p.getcs();
            
    }
}