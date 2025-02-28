@istest
public class SYN_lookupfieldController_Test {
       @testSetup
    public static void createTestData()
    {
      List<US_WSREMS__REMS_Program__c> createSOXProgram = SYN_TestDataFactory.createSOXPrograms(1,True);
      Account prescriberAcc = SYN_TestDataFactory.createPersonAccountforPrescriber('7458963204', 85477126,'7744558899',True, createSOXProgram[0].id);  
    }

    @istest static void execute1(){
        List<String> values = new List<String>{'Name'}; 
        SYN_lookupfieldController.GetRecentRecords('Account',values,10);
    }
    @istest static void execute2(){
        //account acc = [select id ,lastname from Account where lastname!=null];
        List<String> values = new List<String>{'Name'}; 
            List<String> fields = new List<String>{'lastName'};
            //SearchRecords(String ObjectName, List<String> ReturnFields, List<String> QueryFields, String SearchText, String SortColumn, String SortOrder, Integer MaxResults, String Filter, String RecordTyDevName)
            SYN_lookupfieldController.SearchRecords('Account',values ,fields, '7458963204' ,null, 'ASC', 5 , null , 'Business' );
    }
    @istest static void execute3(){
        List<String> Returnfields = new List<String>{'Name'};
      SYN_lookupfieldController.GetRecord('Account',Returnfields, 'Id') ;
    }
    @istest static void execute4(){
        SYN_lookupfieldController.findObjectIcon('Account');
    }
    @istest static void execute5(){
       SYN_lookupfieldController.getObjectDetails('Account');
    }
    
    @istest static void execute7(){
       SYN_lookupfieldController.getRecordTypeId('Account', 'Pharmacy');
    }
    
}