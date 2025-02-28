@isTest
public class SYN_InboundUtilityTest {
    public static testMethod void method1() {
        List<Account> accList = getAccounts(1);
        task tsk = new Task();
        tsk.Subject = 'Test Task';
        tsk.ActivityDate = System.today();
        tsk.whatId = accList[0].id;
        insert tsk;
        
        contact con = new contact();
        con.LastName = 'Test contact';
        insert con;
        
        US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
        remobj.Name ='synprogram2';
        remobj.US_WSREMS__Status__c ='Active';
        insert remobj;
        
        
        US_WSREMS__REMS_Service_Summary__c remsobj = new US_WSREMS__REMS_Service_Summary__c();
        remsobj.US_WSREMS__REMSProgram__c = remobj.id;
        remsobj.US_WSREMS__Requestor_Type__c ='Pharmacy';
        remsobj.US_WSREMS__StageName__c='Intake';
        insert remsobj;
        
        //SYN_InboundUtility.createREMS_Service(accList[0].Id,'Test_Service',tsk.Id,'Task',con.Id,null);
        //SYN_InboundUtility.createREMS_Service(accList[0].Id,'Test_Service',remsobj.Id,'US_WSREMS__REMS_Service_Summary__c',con.Id,null);
        SYN_InboundUtility.createREMS_Service(accList[0].Id,'Outbound_Communication',remsobj.Id,'US_WSREMS__REMS_Service_Summary__c',con.Id,null);
             
    }
    
    
    public static List<Account> getAccounts(Integer noofRecords) {
        List<Account> accountList = new List<Account>();
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
        programObj.Name = 'Syneos Phase2';
        programObj.US_WSREMS__Status__c ='Active';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
       
        for(Integer i = 0; i<noofRecords;i++){
            Account acc=new Account();
            acc.LastName='TestAccount';
             acc.FirstName='TestAccountFN';
            acc.Phone ='1234567890';
            acc.US_WSREMS__REMS_Program__c = programObj.Id;
            acc.recordTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            accountList.add(acc);
        }
        insert accountList;
        return accountList;
    }
}