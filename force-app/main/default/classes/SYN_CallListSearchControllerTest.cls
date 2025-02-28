@isTest(SeeAllData= true)
public class SYN_CallListSearchControllerTest {
    @isTest
    public static void testMethod1() {
     
        SYN_CallListSearchController.CallListFilterWrapper cw = new  SYN_CallListSearchController.CallListFilterWrapper(); 
        cw.isSupervisor = false;
        cw.isVeevaNetworkEnabled =false;
        cw.showAssignToMe = false;
        List<SYN_Utility.FilterWrapper> fwList = new List<SYN_Utility.FilterWrapper>();
        SYN_Utility.FilterWrapper fw = new SYN_Utility.FilterWrapper();
        fw = sendfilterWrapper('REMS Program','String','pickList');
        fwList.add(fw);
        cw.filterWrapperList = fwList; 
        test.startTest();
        SYN_CallListSearchController.CallListFilterWrapper getFilterWrap = new  SYN_CallListSearchController.CallListFilterWrapper();
        SYN_CallListSearchController.CallListFilterWrapper getIniFilterWrap = new  SYN_CallListSearchController.CallListFilterWrapper();
        SYN_CallListSearchController.CallListFilterWrapper handleProjChangeWrap = new  SYN_CallListSearchController.CallListFilterWrapper();
        getFilterWrap = SYN_CallListSearchController.getFilters();
        getIniFilterWrap = SYN_CallListSearchController.getInitialFilterValues(cw);
        handleProjChangeWrap = SYN_CallListSearchController.handleProjectChange(cw,'','',false);
        test.stopTest();
        system.assertEquals('REMS Program',getFilterWrap.filterWrapperList[0].filterName);
        system.assertEquals('String',getIniFilterWrap.filterWrapperList[0].fieldType);
        system.assertEquals('pickList',handleProjChangeWrap.filterWrapperList[0].filterType);
    }

    @isTest
     public static void testMethod2() {
        SYN_CallListSearchController.CallListFilterWrapper cw = new  SYN_CallListSearchController.CallListFilterWrapper(); 
        cw.isSupervisor = false;
        cw.isVeevaNetworkEnabled =false;
        cw.showAssignToMe = false;
        List<SYN_Utility.FilterWrapper> fwList = new List<SYN_Utility.FilterWrapper>();
        SYN_Utility.FilterWrapper fw = new SYN_Utility.FilterWrapper();
        fw = sendfilterWrapper('Time Zone','String','pickList');
        fwList.add(fw);
        cw.filterWrapperList = fwList; 
        test.startTest();
         SYN_CallListSearchController.CallListFilterWrapper handleProjChangeWrap = new  SYN_CallListSearchController.CallListFilterWrapper();
        handleProjChangeWrap = SYN_CallListSearchController.handleProjectChange(cw,'EST','',false); 
         test.stopTest();
         system.assertEquals('pickList',handleProjChangeWrap.filterWrapperList[0].filterType);
    } 

     @isTest
     public static void testMethod3() {
        SYN_CallListSearchController.CallListFilterWrapper cw = new  SYN_CallListSearchController.CallListFilterWrapper(); 
        cw.isSupervisor = false;
        cw.isVeevaNetworkEnabled =false;
        cw.showAssignToMe = false;
        List<SYN_Utility.FilterWrapper> fwList = new List<SYN_Utility.FilterWrapper>();
        SYN_Utility.FilterWrapper fw = new SYN_Utility.FilterWrapper();
        fw = sendfilterWrapper('Task Due Date','String','pickList');
        fwList.add(fw);
        cw.filterWrapperList = fwList; 
        test.startTest();
         SYN_CallListSearchController.CallListFilterWrapper handleProjChangeWrap = new  SYN_CallListSearchController.CallListFilterWrapper();
        handleProjChangeWrap = SYN_CallListSearchController.handleProjectChange(cw,'','',false); 
         test.stopTest();
         system.assertEquals('pickList',handleProjChangeWrap.filterWrapperList[0].filterType);
    }
    
    
     @isTest
     public static void testMethod4() {
        SYN_CallListSearchController.CallListFilterWrapper cw = new  SYN_CallListSearchController.CallListFilterWrapper(); 
        cw.isSupervisor = false;
        cw.isVeevaNetworkEnabled =false;
        cw.showAssignToMe = false;
        List<SYN_Utility.FilterWrapper> fwList = new List<SYN_Utility.FilterWrapper>();
        SYN_Utility.FilterWrapper fw = new SYN_Utility.FilterWrapper();
        fw = sendfilterWrapper('Task Type','String','pickList');
        fwList.add(fw);
        cw.filterWrapperList = fwList; 
        test.startTest();
         SYN_CallListSearchController.CallListFilterWrapper handleProjChangeWrap = new  SYN_CallListSearchController.CallListFilterWrapper();
        handleProjChangeWrap = SYN_CallListSearchController.handleProjectChange(cw,'','',true);
         test.stopTest();
         system.assertEquals('pickList',handleProjChangeWrap.filterWrapperList[0].filterType);
    }


 @isTest
     public static void testMethod5() {
        SYN_CallListSearchController.CallListFilterWrapper cw = new  SYN_CallListSearchController.CallListFilterWrapper(); 
        cw.isSupervisor = false;
        cw.isVeevaNetworkEnabled =false;
        cw.showAssignToMe = false;
        List<SYN_Utility.FilterWrapper> fwList = new List<SYN_Utility.FilterWrapper>();
        SYN_Utility.FilterWrapper fw = new SYN_Utility.FilterWrapper();
        fw = sendfilterWrapper('Include all Scheduled Calls till today','String','pickList');
        fwList.add(fw);
        cw.filterWrapperList = fwList; 
        SYN_CallListSearchController.handleProjectChange(cw,'All','',false); 
        test.startTest();
        SYN_CallListSearchController.CallListFilterWrapper handleProjChangeWrap = new  SYN_CallListSearchController.CallListFilterWrapper();
       handleProjChangeWrap = SYN_CallListSearchController.handleProjectChange(cw,'All','',false); 
        test.stopTest();
        system.assertEquals('pickList',handleProjChangeWrap.filterWrapperList[0].filterType);
   }
    
     @isTest
     public static void testMethod6() {
        SYN_CallListSearchController.CallListFilterWrapper cw = new  SYN_CallListSearchController.CallListFilterWrapper(); 
        cw.isSupervisor = false;
        cw.isVeevaNetworkEnabled =false;
        cw.showAssignToMe = false;
        List<SYN_Utility.FilterWrapper> fwList = new List<SYN_Utility.FilterWrapper>();
        SYN_Utility.FilterWrapper fw = new SYN_Utility.FilterWrapper();
        fw = sendfilterWrapper('Associated Service','String','pickList');
        fwList.add(fw);
        cw.filterWrapperList = fwList;
         Test.startTest();
         SYN_CallListSearchController.CallListFilterWrapper handleProjChangeWrap = new  SYN_CallListSearchController.CallListFilterWrapper();
         handleProjChangeWrap = SYN_CallListSearchController.handleProjectChange(cw,'','',false);
          Test.stopTest();
          system.assertEquals('pickList',handleProjChangeWrap.filterWrapperList[0].filterType);
     }

     @isTest
     public static void testMethod7() {
        SYN_CallListSearchController.CallListFilterWrapper cw = new  SYN_CallListSearchController.CallListFilterWrapper(); 
        cw.isSupervisor = false;
        cw.isVeevaNetworkEnabled =false;
        cw.showAssignToMe = false;
        List<SYN_Utility.FilterWrapper> fwList = new List<SYN_Utility.FilterWrapper>();
        SYN_Utility.FilterWrapper fw = new SYN_Utility.FilterWrapper();
        fw = sendfilterWrapper('AssignedTo','String','pickList');
        fwList.add(fw);
        cw.filterWrapperList = fwList; 
        test.startTest();
         SYN_CallListSearchController.CallListFilterWrapper handleProjChangeWrap = new  SYN_CallListSearchController.CallListFilterWrapper();
        handleProjChangeWrap = SYN_CallListSearchController.handleProjectChange(cw,'All','',false);
         SYN_CallListSearchController.fetchFilteredCallList(cw,'ProgramName','ASC'); 
         test.stopTest();
         system.assertEquals('pickList',handleProjChangeWrap.filterWrapperList[0].filterType);
    }
    
     @isTest
     public static void testMethod8() {
        SYN_CallListSearchController.CallListFilterWrapper cw = new  SYN_CallListSearchController.CallListFilterWrapper(); 
        cw.isSupervisor = false;
        cw.isVeevaNetworkEnabled =false;
        cw.showAssignToMe = false;
        List<SYN_Utility.FilterWrapper> fwList = new List<SYN_Utility.FilterWrapper>();
        SYN_Utility.FilterWrapper fw = new SYN_Utility.FilterWrapper();
        fw = sendfilterWrapper('AssignedTo','Date','Date');
        fw.selectedValue = String.valueOf(system.today());
        fwList.add(fw);
        cw.filterWrapperList = fwList;
        SYN_CallListSearchController.handleProjectChange(cw,'All','',false);
        SYN_CallListSearchController.fetchFilteredCallList(cw,'status','ASC');
        
        List<US_WSREMS__REMS_Program__c> remsProgramList = SYN_TestDataFactory.createSOXPrograms(1,true);
         
         String strRecordTypeId = [Select Id From RecordType Where SobjectType ='Account' and Name ='Pharmacy'].Id;
        
         Account actobj = new Account();
        actobj.Name='test001';
        actobj.phone = '8888888888';
        actobj.RecordTypeId =strRecordTypeId;
        actobj.US_WSREMS__REMS_Program__c =remsProgramList[0].id;
        insert actobj;
         
        task tsk = new Task();
         tsk.Subject = 'Test Task';
         tsk.whatId = actobj.id;
         tsk.ActivityDate = System.today();
       insert tsk;
       
        List<SYN_CallListSearchController.CallListWrapper> clwList = new List< SYN_CallListSearchController.CallListWrapper>();
        SYN_CallListSearchController.CallListWrapper clw = new SYN_CallListSearchController.CallListWrapper();
        clw.TaskId = tsk.Id;
        clwList.add(clw); 
        SYN_CallListSearchController.assignCallsToMe(clwList,cw,String.valueOf(UserInfo.getUserId()));
    }
    
    
    public static SYN_Utility.FilterWrapper sendfilterWrapper(String filterName,string fieldType, string filterType){
        SYN_Utility.FilterWrapper fw = new SYN_Utility.FilterWrapper();
        fw.isVisible  =false;
        fw.fieldName= 'Program_Name__c';
        fw.fieldType= fieldType;
        fw.filterName= filterName;
        fw.filterType= filterType;
        fw.selectedValue = 'All';
        List<SYN_Utility.ListOption> opList = new List<SYN_Utility.ListOption>();
        SYN_Utility.ListOption lo = new SYN_Utility.ListOption();
        lo.label= 'All';
        lo.value= 'All';
		opList.add(lo);
        fw.filterValues= opList;
        fw.isVisible= true;
        fw.labelValuePair= 'Status:ActivityDate';//String.ValueOf(System.today())+'Phone:ActivityDate';
        fw.order= 1;
        fw.query = 'Select id,ActivityDate,Status from task limit 1';
        return fw;
    }
}