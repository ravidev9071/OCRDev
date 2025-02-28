@isTest
public class SYN_TrackHistoryControllerTest {
    
    @testSetup
    static void createTestData()
    {
        US_WSREMS__REMS_Program__c  programObj = new US_WSREMS__REMS_Program__c ();
        programObj.Name = 'Sodium Oxybate REMS 1';
        programObj.US_WSREMS__Status__c  ='Active';
        programObj.US_WSREMS__Program_State_Date__c  = System.today();
        programObj.US_WSREMS__Program_End_Date__c  = System.today().addDays(20);
        insert programObj;
        
        Account acc=new Account();
        acc.Name='AccountTest';
        acc.US_WSREMS__REMS_Program__c = programObj.id;
        acc.Phone='8888888888';
        acc.Fax ='8888888888';
        insert acc;
        
        DocumentChecklistItem doc = new DocumentChecklistItem() ;
        doc.Name='DocumentChecklistTest';
        doc.ParentRecordId=acc.Id;
        doc.Status='Pending';
        insert doc; 
        
        
    }
    
    static testMethod void testDocCheckListItemHistory() {
        DocumentChecklistItem dci = [SELECT ID FROM DocumentChecklistItem WHERE Name =: 'DocumentChecklistTest'];
        Test.startTest();
        List<SYN_TrackHistoryController.DocumentHistoryWrapper> testFetchHistoryData = SYN_TrackHistoryController.fetchHistoryData(String.ValueOf(dci.Id));
        SYN_TrackHistoryController.dateformatechanged(System.now());
        Test.stopTest();
        for(SYN_TrackHistoryController.DocumentHistoryWrapper hc : testFetchHistoryData)
        {
            if(hc.Field_Label == 'Status')
            {
                system.assertEquals('status', hc.item.Field);
            }
            if(hc.Field_Label == 'Last Status Change Date')
            {
                system.assertEquals('Last_Status_Change__c', hc.item.Field);
            }
            if(hc.Field_Label == 'DocumentType Id')
            {
                system.assertEquals('DocumentTypeId', hc.item.Field);
            }
        }
    }
    
}