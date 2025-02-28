public class SYN_SearchCustomerOnInboundCall {
    
    public String callerId{get;set;}
    public String accountId{get;set;}
    public List<AccountWrapperCls> accountList{get;set;}
    public Account accObj{get;set;}
    public String selectedValue{get;set;}
    public String access_token_incontact{get;set;} 
    public String contactId_incontact{get;set;}
    public list <Account> acc {get;set;}
    public String searchKeyName {get;set;}
    public String searchKeyPhone {get;set;} 
    public String searchKeyEmail {get;set;}
   // public Date searchKeyDOB {get;set;}
    public String searchKeyDEA {get;set;}
    public String searchKeyNPI {get;set;}
    public Boolean hasRecords {get;set;}
    public String selectedAcc{get;set;}
    public String selectedAccAuto{get;set;} 
    public Integer selectedRowNum{get;set;}
    public string   projectPhonenumber{get;set;}
    public String caseId{get;set;} 
    public String serviceId{get;set;}
    
    public String caseNumber{get;set;}
    public String serviceNumber{get;set;}
    
    public String caseIdSec{get;set;} 
    public String serviceIdSec{get;set;}
    
    public String caseNumberSec{get;set;}
    public String serviceNumberSec{get;set;}
    public String loggedInUserProgram{get;set;}
    
    public List<accWrapper> accwrapperList  {get;set;}
    Map<String,Account> allAccountsMap = new Map<String,Account>();
    Map<String,Account> allAccountsMap_Auto = new Map<String,Account>();
    public SYN_SearchCustomerOnInboundCall(){
        accObj= new Account();
        accountList =new List<AccountWrapperCls>();
        hasRecords = false;
        
        List<Account> account_List = new List<Account>();
        callerId = ApexPages.currentPage().getParameters().get('c__ANI');   
        contactId_incontact=ApexPages.currentPage().getParameters().get('c__contactid');
       // c__DNIS
       projectPhonenumber=ApexPages.currentPage().getParameters().get('c__DNIS');
        for(String keyStr:ApexPages.currentPage().getParameters().keyset()){
            
        }
        
        account_List = [Select Id,IsPersonAccount,Name,RecordType.Name,US_WSREMS__REMS_Program__r.Name,FirstName,LastName,Phone,US_WSREMS__DOB__c,US_WSREMS__DEA__c,US_WSREMS__SLN_State__c,Address_Text__pc from Account WHERE Phone =:callerId and IsPersonAccount=true];
        List<User> userList = [select id,name,Program__c,icAgentConsole__incCustomScreenpop__c 
                               FROM User Where Id =:UserInfo.getUserId()];
        //loggedInUserProgram = userList[0].Program__c;
        List<US_WSREMS__Program_Users__c> programUserList = [SELECT Id, US_WSREMS__User__c,US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.Name FROM US_WSREMS__Program_Users__c WHERE US_WSREMS__User__c =: UserInfo.getUserId() AND US_WSREMS__REMS_Program__c != null AND US_WSREMS__REMS_Program__r.Name ='Macitentan REMS'];
        if(!programUserList.isEmpty()){
            loggedInUserProgram = programUserList[0].US_WSREMS__REMS_Program__r.Name;
        }
    }
    
    
    
    
    public pagereference searchAccount1(){
       
        accountList = new List<AccountWrapperCls>();
        callerId = ApexPages.currentPage().getParameters().get('c__ANI');
        
        for(Account acc: [Select Id,IsPersonAccount,Name,RecordType.Name,US_WSREMS__Status__c,US_WSREMS__REMS_Program__r.Name,FirstName,LastName,Phone,US_WSREMS__DOB__c,US_WSREMS__DEA__c,US_WSREMS__SLN_State__c,Address_Text__pc,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,SYN_Date_of_Birth__c from Account WHERE Phone =:callerId and IsPersonAccount=true and US_WSREMS__REMS_Program__r.Toll_Free_Number_1__c=:projectPhonenumber]){
            accountList.add(new AccountWrapperCls(acc));
            allAccountsMap_Auto.put(acc.Id,acc);
        }
        
        
        
        return null;        
    }
    public pagereference createService(){
        
        SYN_InboundUtility.servicecasewrapper wrapper;
      
        if(String.isNotBlank(contactId_incontact)){
            wrapper =SYN_InboundUtility.createREMS_Service(selectedAccAuto,'Inbound_Communication','','Account',contactId_incontact,null);
            
        }
        if(wrapper !=null && wrapper.status){
            
            Pagereference pageRef = new PageReference('/lightning/cmp/c__SYN_CreateServiceCmp'); 
            pageRef.getParameters().put('c__caseId',wrapper.CaseId);
            pageRef.getParameters().put('c__serviceId',wrapper.ServiceId);
            caseId = wrapper.CaseId;
            serviceId = wrapper.ServiceId;
            List<Case> caseList = [SELECT Id,CaseNumber FROM Case Where Id =:caseId];
            List<US_WSREMS__REMS_Service_Summary__c> serviceList = [SELECT Id,Name from US_WSREMS__REMS_Service_Summary__c Where Id =:serviceId];
            caseNumber = caseList[0].CaseNumber;
            serviceNumber = serviceList[0].Name;
            return pageRef;
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Server Error')); 
        }
        
        return null;
    }
    
    
    
    public void search(){
        accwrapperList = new List<accWrapper>();
        string queryString='select Id,Name,RecordType.name,US_WSREMS__Status__c,Phone,US_WSREMS__REMS_Program__r.Name,FirstName,LastName,US_WSREMS__DOB__c,US_WSREMS__DEA__c,US_WSREMS__SLN_State__c,Address_Text__pc,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,SYN_Date_of_Birth__c from account WHERE  ';
        String filterCriteria='';
        if(String.isBlank(searchKeyName) && String.isBlank(searchKeyPhone) && String.isBlank(searchKeyEmail) &&  String.isBlank(searchKeyDEA) && String.isBlank(searchKeyNPI) && String.IsBlank(String.valueOf(accObj.US_WSREMS__DOB__c))){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Enter any key for search'));
        }else{
            if(String.isBlank(filterCriteria)){
                if(String.isNotBlank(searchKeyName)) {
                    
                    filterCriteria +=' Name like\''+ '%'+searchKeyName+'%\' '; 
                }   
            }
            
            
            if(String.isNotBlank(filterCriteria)){
                if(String.isNotBlank(searchKeyPhone)) {
                    
                    filterCriteria += ' AND '+' Phone like\''+ '%'+searchKeyPhone+'%\' '; 
                }
            }else{
                if(String.isNotBlank(searchKeyPhone)) {
                    
                    filterCriteria += ' Phone like\''+ '%'+searchKeyPhone+'%\' '; 
                } 
            }
            if(String.isNotBlank(filterCriteria)){
                if(accObj.US_WSREMS__DOB__c!=null) {
                    // Date dt ;
                    
                    // dt= date.valueOf(searchKeyDOB);
                    Date dt=(accObj.US_WSREMS__DOB__c);
                    List<Date> date_list=new List<Date>();
                    date_list.add(dt);
                    filterCriteria +=' AND '+ ' ( US_WSREMS__DOB__c IN :date_list  ) '; 
                }
            }else{
                if(accObj.US_WSREMS__DOB__c!=null) {
                    // Date dt ;
                     Date dt=accObj.US_WSREMS__DOB__c;
                    // dt= date.valueOf(searchKeyDOB);
                     List<Date> date_list1=new List<Date>();
                    date_list1.add(dt);
                    filterCriteria +=' ( US_WSREMS__DOB__c IN :date_list1 ) '; 
                }
            }
            if(String.isNotBlank(filterCriteria)){
                if(String.isNotBlank(searchKeyEmail)) {
                    
                    filterCriteria +=' AND '+' PersonEmail like\''+ '%'+searchKeyEmail+'%\' '; 
                }
            }else{
                if(String.isNotBlank(searchKeyEmail)) {
                    
                    filterCriteria +=' PersonEmail like\''+ '%'+searchKeyEmail+'%\' '; 
                }
            }
            if(String.isNotBlank(filterCriteria)){
                if(String.isNotBlank(searchKeyDEA)) {
                    
                    filterCriteria +=' AND '+ ' US_WSREMS__DEA__c like\''+ '%'+searchKeyDEA+'%\' '; 
                }
            }else{
                if(String.isNotBlank(searchKeyDEA)) {
                    
                    filterCriteria += ' US_WSREMS__DEA__c like\''+ '%'+searchKeyDEA+'%\' '; 
                }
            }
            
            if(String.isNotBlank(filterCriteria)){
                if(String.isNotBlank(searchKeyNPI)) {
                    
                    filterCriteria +=' AND '+ ' US_WSREMS__NPI__c like\''+ '%'+searchKeyNPI+'%\' '; 
                }
            }else{
                if(String.isNotBlank(searchKeyNPI)) {
                    
                    filterCriteria += ' US_WSREMS__NPI__c like\''+ '%'+searchKeyNPI+'%\' '; 
                }
            }
            if(string.isNotBlank(filterCriteria)){
                //queryString = queryString+filterCriteria+' AND '+ ' IsPersonAccount = true';
                queryString = queryString+filterCriteria;
            }else{
                //queryString = queryString+ ' IsPersonAccount = true';
                queryString = queryString;
            }
            
            
            //queryString = queryString.removeEnd('AND');
            List<Account> account_searchList=Database.query(queryString);
            for(Account acc : account_searchList) {
                accWrapper accWrap = new accWrapper();
                accWrap.selected = false;
                accWrap.accRecord = acc;
                accwrapperList.add(accWrap);
                allAccountsMap.put(acc.Id,acc);
            }
            if(accwrapperList.size() >0){
                hasRecords = true;
            }else{
               hasRecords = false; 
            }
                
        }
    }
    
   
    public pagereference showSelected() {
        SYN_InboundUtility.servicecasewrapper wrapper;
      
        if(selectedAcc!=null &&  String.isNotBlank(contactId_incontact)) {
            wrapper =SYN_InboundUtility.createREMS_Service(selectedAcc,'Inbound_Communication','','Account',contactId_incontact,null);
            
            if(wrapper !=null && wrapper.status){
                
                Pagereference pageRef = new PageReference('/lightning/cmp/c__SYN_CreateServiceCmp'); 
                pageRef.getParameters().put('c__caseId',wrapper.CaseId);
                pageRef.getParameters().put('c__serviceId',wrapper.ServiceId);
                 caseIdSec = wrapper.CaseId;
            serviceIdSec = wrapper.ServiceId;
            List<Case> caseList = [SELECT Id,CaseNumber FROM Case Where Id =:caseIdSec];
            List<US_WSREMS__REMS_Service_Summary__c> serviceList = [SELECT Id,Name from US_WSREMS__REMS_Service_Summary__c Where Id =:serviceIdSec];
            caseNumberSec = caseList[0].CaseNumber;
            serviceNumberSec = serviceList[0].Name;
                return null;
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, wrapper.status_message)); 
            }
            
        }
        return null;
    }
    
      public pagereference createAccount() {
          Pagereference pageRef;
          if (loggedInUserProgram == SYN_Utilitycls.MACI_PROGRAM_NAME) {
              pageRef = new PageReference('/lightning/cmp/c__ProgramSelectionComp'); 
          } else {
              pageRef = new PageReference('/lightning/cmp/c__NewAccountCreation_Incontact'); 
              pageRef.getParameters().put('c__callerId',callerId);
              pageRef.getParameters().put('c__contactId_incontact',contactId_incontact);
          }          
          pageRef.setRedirect(true);
          return pageRef;
    }
    
    
    
    public class accWrapper {
        public boolean selected {get;set;}
        public Account accRecord {get;set;}
        
    }
    public class AccountWrapperCls {
        public Boolean isSelected {get;set;}
        public Account cAccount {get;set;}
        
        public AccountWrapperCls(Account cAccount){
            this.cAccount = cAccount;
        }
    }
}