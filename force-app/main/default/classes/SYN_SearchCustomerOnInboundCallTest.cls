@isTest
public class SYN_SearchCustomerOnInboundCallTest {
    
    public static testMethod void method1() {
        SYN_SearchCustomerOnInboundCall ss = new SYN_SearchCustomerOnInboundCall();
        //  account acc = SYN_TestDataFactory.createAccount();
        List<Account> accList = getAccounts(1);
        
        Contact c = new Contact();
        c.lastName = 'lastName';
        insert c;
        // update acc;
        ss.searchKeyPhone = '1234567890';
        ss.searchKeyName = 'TestAccount';
        ss.searchKeyEmail='Test@gmail.com';
        ss.searchKeyDEA='123457895';
        apexpages.currentpage().getparameters().put('ANI' , accList[0].Phone);
                 ApexPages.currentPage().getParameters().put('c__contactid',c.id);

        System.currentPagereference().getparameters().put('conId' , accList[0].Id);
        System.currentPagereference().getparameters().put('index' ,'1');
       // ss.searchAccount();
        ss.searchAccount1();
        ss.createService();
        //ss.getContactId(c.Id);
        //ss.getselectedContact();
        ss.selectedAcc = accList[0].Id;
        ss.contactId_incontact = c.Id;
        ss.showSelected();
        ss.createAccount();
        //  ss.retrieveAccessToken();
        ss.search();
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new SYN_InboundAPIMock());
       // ss.retrieveAccessToken();
        test.stopTest();
        
        
    }
     public static testMethod void method2() {
        SYN_SearchCustomerOnInboundCall ss = new SYN_SearchCustomerOnInboundCall();
        //  account acc = SYN_TestDataFactory.createAccount();
        List<Account> accList = getAccounts(5);
        Contact c = new Contact();
        c.lastName = 'lastName';
        insert c;
        // update acc;
        apexpages.currentpage().getparameters().put('ANI' , accList[0].Phone);
         ApexPages.currentPage().getParameters().put('c__contactid',c.id);

         ss.selectedAccAuto=accList[0].Id;
       ss.contactId_incontact=c.Id;
        ss.searchAccount1();
        ss.createService();
       // ss.getContactId(c.Id);
        //  ss.retrieveAccessToken();
        ss.search();
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new SYN_InboundAPIMock());
       // ss.retrieveAccessToken();
        test.stopTest();
    }
     public static testMethod void method3() {
        SYN_SearchCustomerOnInboundCall ss = new SYN_SearchCustomerOnInboundCall();
          SYN_SearchCustomerOnInboundCall ss1 = new SYN_SearchCustomerOnInboundCall();
          SYN_SearchCustomerOnInboundCall ss2 = new SYN_SearchCustomerOnInboundCall();
        //  account acc = SYN_TestDataFactory.createAccount();
        List<Account> accList = getAccounts(5);
        Contact c = new Contact();
        c.lastName = 'lastName';
        insert c;
         ss.searchKeyPhone = '1234567890';
         ss1.searchKeyEmail='Test@gmail.com';
            ss2.searchKeyDEA='123457895';
        // update acc;
       // apexpages.currentpage().getparameters().put('ANI' , accList[0].Phone);
       // ss.searchAccount();
         //ss.retrieveAccountDetail();
       //  ss.createREMSService(accList[0]);
          System.currentPagereference().getparameters().put('conId' , accList[0].Id);
        System.currentPagereference().getparameters().put('index' ,'2');
      //  ss.searchKey = '1234567890';
        // ss.callerId ='2163763950'
           ss.search();
           ss1.search();
           ss2.search();
        // ss.selectcon();
       
       
    }
    public static testMethod void method4() {
        SYN_SearchCustomerOnInboundCall ss = new SYN_SearchCustomerOnInboundCall();
          SYN_SearchCustomerOnInboundCall ss1 = new SYN_SearchCustomerOnInboundCall();
          SYN_SearchCustomerOnInboundCall ss2 = new SYN_SearchCustomerOnInboundCall();
        //  account acc = SYN_TestDataFactory.createAccount();
        List<Account> accList = getAccounts(5);
        Contact c = new Contact();
        c.lastName = 'lastName';
        insert c;
        // ss.searchKeyPhone = '1234567890';
        // ss1.searchKeyEmail='Test@gmail.com';
          //  ss2.searchKeyDEA='123457895';
        // update acc;
       // apexpages.currentpage().getparameters().put('ANI' , accList[0].Phone);
       // ss.searchAccount();
         //ss.retrieveAccountDetail();
       //  ss.createREMSService(accList[0]);
          System.currentPagereference().getparameters().put('conId' , accList[0].Id);
        System.currentPagereference().getparameters().put('index' ,'2');
      //  ss.searchKey = '1234567890';
        // ss.callerId ='2163763950'
           ss.search();
           ss1.search();
           ss2.search();
        // ss.selectcon();
       
       
    }
    
    
    public static List<Account> getAccounts(Integer noofRecords) {
        List<Account> accountList = new List<Account>();
         US_WSREMS__REMS_Program__c remobj = new US_WSREMS__REMS_Program__c();
        remobj.Name ='synprogram2';
        remobj.Toll_Free_Number_1__c ='123456';
        remobj.US_WSREMS__Status__c ='Active';
        insert remobj;
        for(Integer i = 0; i<noofRecords;i++){
            Account acc=new Account();
            acc.LastName='TestAccount';
            acc.FirstName='TestAccount';
            acc.Phone ='1234567890';
            acc.PersonEmail='Test@gmail.com';
            acc.US_WSREMS__DEA__c='123457895';
            acc.US_WSREMS__DOB__c=System.today();
             acc.US_WSREMS__REMS_Program__c =remobj.id;
            acc.recordTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Patient').getRecordTypeId();
            accountList.add(acc);
        }
        insert accountList;
        return accountList;
    }
 
}