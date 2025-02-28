/*********************************************************************************
Class Name      : SharingUtility
Description     : Apex class for Sharing to records 
Modification Log:
----------------------------------------------------------------------------------
Developer                   Date                   Description
-----------------------------------------------------------------------------------
Rajadurai                  10/07/2021            Initial Version
*********************************************************************************/

public without sharing class SYN_SharingUtility{
    

    /****************************************************************************************
    * Method Name     : getProgramGroupMap
    * Description     : Fetches program-Group Map          
    *****************************************************************************************/    
    public static Map<String,Id> getProgramGroupMap() {
        
        try{
        
            Map<string,id> programGroupMap = new Map<string,id>();
            for(group grup: [Select Name,Id, DeveloperName From Group LIMIT 50000]){
                programGroupMap.put(grup.DeveloperName,grup.Id);       
            }
            return programGroupMap;
        }catch(Exception e){
            
            return null;
        }
    }   
    
    /****************************************************************************************
    * Method Name     : getSharingConfiguration
    * Description     : Fetches program-Group Map          
    *****************************************************************************************/    
    public static Map<String, Map<String, List<Manage_Date_Sharing__mdt>>> getSharingConfiguration() {
        
        Map<String, Map<String, List<Manage_Date_Sharing__mdt>>> apexSharingConfigMap = new Map<String, Map<String, List<Manage_Date_Sharing__mdt>>>();
        List<Manage_Date_Sharing__mdt> manageDataShareList = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, 
            REMS_Program__c, Object_API_Name__c, Access__c, Active__c FROM Manage_Date_Sharing__mdt WHERE Active__c = TRUE
        ];
              
        for(Manage_Date_Sharing__mdt dataShare : manageDataShareList){
        
            if(!apexSharingConfigMap.containsKey(dataShare.REMS_Program__c)){
                
                Map<String, List<Manage_Date_Sharing__mdt>> objMap = new Map<String, List<Manage_Date_Sharing__mdt>>{
                    dataShare.Object_API_Name__c => new List<Manage_Date_Sharing__mdt>()
                };
                    objMap.get(dataShare.Object_API_Name__c).add(dataShare);
                apexSharingConfigMap = new Map<String, Map<String, List<Manage_Date_Sharing__mdt>>>{
                    dataShare.REMS_Program__c => objMap
                };
                  
            }else{
                
                Map<String, List<Manage_Date_Sharing__mdt>> objMap =  apexSharingConfigMap.get(dataShare.REMS_Program__c);                   
                if(!objMap.containsKey(dataShare.Object_API_Name__c)){
                    
                    objMap.put(dataShare.Object_API_Name__c, new List<Manage_Date_Sharing__mdt>());
                }
                
                objMap.get(dataShare.Object_API_Name__c).add(dataShare);
                apexSharingConfigMap.put(dataShare.REMS_Program__c, objMap);
            }
        }
        
      
        return apexSharingConfigMap;
    }
    
    /****************************************************************************************
    * Method Name     : createShareRecord
    * Description     : Fetches program-Group Map          
    *****************************************************************************************/    
    public static Sobject createShareRecord(String shareObjectAPIName, String UserOrGroupId, String accessLevel, String recId) {
        
        Sobject objshare = Schema.getGlobalDescribe().get(shareObjectAPIName).newSobject();
        objshare.put('ParentID',recId);                   
        objshare.put('RowCause', 'Manual');
        objShare.put('UserOrGroupId', UserOrGroupId);               
        objshare.put('AccessLevel', (accessLevel == 'Read Write'? 'Edit':'Read'));  
        return  objshare; 
       
    }
    
    /****************************************************************************************
    * Method Name     : createShareRecord
    * Description     : Dynamic method to create share record          
    *****************************************************************************************/    
    public static void createShareRecordsList(List<sObject> sObjectList, String shareObjectAPIName, String objectAPIName){
        
        Map<String, Id> publicGroupMap = SYN_SharingUtility.getProgramGroupMap();
        List<Sobject> apexSharingList = new List<Sobject>();
        Map<String, Map<String, List<Manage_Date_Sharing__mdt>>> apexSharingConfigMap = new Map<String, Map<String, List<Manage_Date_Sharing__mdt>>>();        
        apexSharingConfigMap = SYN_SharingUtility.getSharingConfiguration();        
        
        for(Sobject recordVal : sObjectList){ 
                         
            if(String.isNotBlank((String)recordVal.get('Program_Name__c')) && apexSharingConfigMap.containsKey((String)recordVal.get('Program_Name__c'))){
                
                Map<String, List<Manage_Date_Sharing__mdt>> objMap =  apexSharingConfigMap.get((String)recordVal.get('Program_Name__c'));
               
                if(objMap.containsKey(objectAPIName)){
                    
                    List<Manage_Date_Sharing__mdt> dataSharingList = objMap.get(objectAPIName);
                    for(Manage_Date_Sharing__mdt mds : dataSharingList){
                        
                        Sobject objshare = SYN_SharingUtility.createShareRecord(shareObjectAPIName, publicGroupMap.get(mds.Label), mds.Access__c, (String)recordVal.Id);
                        apexSharingList.add(objshare);
                    }                    
                }               
                
            }            
        }
            
        try{ 
            if(!apexSharingList.isEmpty()){
            
                insert apexSharingList; 
                
                     
            } 
        }catch(Exception e){
        
            System.debug('Error--->'+e);
        }
        
       
    }
	
	/****************************************************************************************
    * Method Name     : createAccountSharingRecs
    * Description     : this method to create share record for Account.       
    *****************************************************************************************/    
    public static void createAccountSharingRecs(List<Account> accountList){
        Map<String, US_WSREMS__Apexsharingconfig__c> programSharingMap = getProgramSharingMap();
        List<AccountShare> aShareList = new List<AccountShare>();
        try {
        if(programSharingMap != null){
        
            for(Account acc: accountList){
                if(acc.US_WSREMS__REMS_Program__c != null && programSharingMap.containsKey(acc.US_WSREMS__REMS_Program__c+acc.Program_Name__c+'-Read')){
                    AccountShare accountShare = new AccountShare(AccountId = acc.Id,UserOrGroupId = programSharingMap.get(acc.US_WSREMS__REMS_Program__c+acc.Program_Name__c+'-Read').US_WSREMS__Group_ID__c,
                                                                AccountAccessLevel = 'Read',CaseAccessLevel = 'None',OpportunityAccessLevel = 'None');
                    aShareList.add(accountShare); 
                }
                
                if(acc.US_WSREMS__REMS_Program__c != null && programSharingMap.containsKey(acc.US_WSREMS__REMS_Program__c+acc.Program_Name__c+'-Read/Edit')){
                   AccountShare accountShareEdt = new AccountShare(AccountId = acc.Id,UserOrGroupId = programSharingMap.get(acc.US_WSREMS__REMS_Program__c+acc.Program_Name__c+'-Read/Edit').US_WSREMS__Group_ID__c,
                                                                AccountAccessLevel = 'Edit',CaseAccessLevel = 'None',OpportunityAccessLevel = 'None');
                    aShareList.add(accountShareEdt);
                }
            }
        }
        // DML statement
        if(!aShareList.isEmpty()){
             Database.insert(aShareList, false);  
        }
        }catch (Exception e) {
            System.debug('Exception while creating sharing records.'+e.getMessage());
        } 
        
    } 
    
    /****************************************************************************************
    * Method Name     : createCaseSharingRecs
    * Description     : this method to create share record for Case.         
    *****************************************************************************************/    
    public static void createCaseSharingRecs(List<Case> caseList){
    
        Map<String, US_WSREMS__Apexsharingconfig__c> programSharingMap = getProgramSharingMap();
        List<CaseShare> cShareList = new List<CaseShare>();
        try {
            if(programSharingMap != null){
                for(Case cs: caseList){
                    if(cs.US_WSREMS__REMS_Program__c != null && programSharingMap.containsKey(cs.US_WSREMS__REMS_Program__c+cs.US_WSREMS__Program_Name__c+'-Read')){
                        CaseShare caseShare = new CaseShare(CaseId = cs.Id,UserOrGroupId = programSharingMap.get(cs.US_WSREMS__REMS_Program__c+cs.US_WSREMS__Program_Name__c+'-Read').US_WSREMS__Group_ID__c,
                                                                    CaseAccessLevel = 'Read');
                        cShareList.add(caseShare);
                    }
                    
                    if(cs.US_WSREMS__REMS_Program__c != null && programSharingMap.containsKey(cs.US_WSREMS__REMS_Program__c+cs.US_WSREMS__Program_Name__c+'-Read/Edit')){
                       CaseShare caseShareEdt = new CaseShare(CaseId = cs.Id,UserOrGroupId = programSharingMap.get(cs.US_WSREMS__REMS_Program__c+cs.US_WSREMS__Program_Name__c+'-Read/Edit').US_WSREMS__Group_ID__c,
                                                                    CaseAccessLevel = 'Edit');
                        cShareList.add(caseShareEdt);
                    }
                }
            }
            // DML statement
            if(!cShareList.isEmpty()){
                 Database.insert(cShareList, false);  
            }
        }catch (Exception e) {
            System.debug('Exception while creating sharing records.'+e.getMessage());
        } 
     
    } 
    
    /****************************************************************************************
    * Method Name     : createRemsServiceSharingRecs
    * Description     : this method to create share record for REMS Service      
    *****************************************************************************************/    
    public static void createRemsServiceSharingRecs(List<US_WSREMS__REMS_Service_Summary__c> serviceList){
    
        Map<String, US_WSREMS__Apexsharingconfig__c> programSharingMap = getProgramSharingMap();
        List<US_WSREMS__REMS_Service_Summary__Share > rsShareList = new List<US_WSREMS__REMS_Service_Summary__Share >();
        try {
            if(programSharingMap != null){
                for(US_WSREMS__REMS_Service_Summary__c rs: serviceList){
                    if(rs.US_WSREMS__REMSProgram__c != null && programSharingMap.containsKey(rs.US_WSREMS__REMSProgram__c+rs.Program_Name__c+'-Read')){
                        US_WSREMS__REMS_Service_Summary__Share sShare = new US_WSREMS__REMS_Service_Summary__Share (ParentId = rs.Id,UserOrGroupId = programSharingMap.get(rs.US_WSREMS__REMSProgram__c+rs.Program_Name__c+'-Read').US_WSREMS__Group_ID__c,
                                                                    AccessLevel= 'Read');
                        rsShareList.add(sShare);
                    }
                    
                    if(rs.US_WSREMS__REMSProgram__c != null && programSharingMap.containsKey(rs.US_WSREMS__REMSProgram__c+rs.Program_Name__c+'-Read/Edit')){
                       US_WSREMS__REMS_Service_Summary__Share rsShareEdt = new US_WSREMS__REMS_Service_Summary__Share (ParentId = rs.Id,UserOrGroupId = programSharingMap.get(rs.US_WSREMS__REMSProgram__c+rs.Program_Name__c+'-Read/Edit').US_WSREMS__Group_ID__c,
                                                                    AccessLevel= 'Edit');
                        rsShareList.add(rsShareEdt);
                    }
                }
            }
            // DML statement
            if(!rsShareList.isEmpty()){
                 Database.insert(rsShareList, false);  
            }
        }catch (Exception e) {
            System.debug('Exception while creating sharing records.'+e.getMessage());
        } 
     
    } 
    
    
    /****************************************************************************************
    * Method Name     : getProgramSharingMap
    * Description     : collect groups based on program      
    *****************************************************************************************/  
    Public Static Map<String,US_WSREMS__Apexsharingconfig__c> getProgramSharingMap(){
    
        Map<String, US_WSREMS__Apexsharingconfig__c> programSharingMap = new Map<String,US_WSREMS__Apexsharingconfig__c>();
        
        for(US_WSREMS__Apexsharingconfig__c csr : US_WSREMS__Apexsharingconfig__c.getAll().values()){
            //programSharingMap.put(csr.US_WSREMS__Program_Id__c,csr);
            programSharingMap.put(csr.US_WSREMS__Program_Id__c+csr.US_WSREMS__Group_Name__c,csr);
        }
        return  programSharingMap;      
    }

}