@IsTest
public class SYN_BatchToDeleteDupReceivedDocTest {
     static testMethod void testDeleteReceivedDocumentBatch() {
       SYN_TestDataFactory.createDuplicateReceivedDocument();
         Test.startTest();
        SYN_SchedulerToDeleteDupReceivedDoc testsche = new SYN_SchedulerToDeleteDupReceivedDoc();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
       //Database.executeBatch(new SYN_BatchToDeleteDupReceivedDoc());
    }

}