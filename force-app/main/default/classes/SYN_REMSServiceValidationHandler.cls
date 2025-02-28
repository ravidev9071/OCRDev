/**
* @File Name          : SYN_RemsServiceValidationHandler.cls
* @Description        : This is used as a Hanlder for RemsService trigger.
* @Trigger            : SYN_RemsServiceSummaryTrigger
* @TestClass          : 
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date              Developer                         Modification
* 2.0       02/02/2023        Rajadurai                 KA Service Validations
**/

public class SYN_REMSServiceValidationHandler{
    
   

    public static void validateServices(List<US_WSREMS__REMS_Service_Summary__c> oldList, List<US_WSREMS__REMS_Service_Summary__c> newList, Map<Id, US_WSREMS__REMS_Service_Summary__c> oldMap, Map<Id, US_WSREMS__REMS_Service_Summary__c> newMap, Boolean isBefore, Boolean isAfter, Boolean isDelete, Boolean isInsert, Boolean isUpdate){
        
        String soxProgram = 'Sodium Oxybate REMS';
        String RSSkaRecordType = 'Knowledge_Assessment';
        List<US_WSREMS__REMS_Service_Summary__c> kaRSSList = new List<US_WSREMS__REMS_Service_Summary__c>();
        
        Map<String, Map<Id, List<US_WSREMS__REMS_Service_Summary__c>>> prgmRTAndCaseListMap = filterServicesByPrgm(newList); 
        Map<Id, String> rectypeIdAndNameMap = SYN_CommonUtility.getsObjectRecordTypeMap('US_WSREMS__REMS_Service_Summary__c');
        
        if(prgmRTAndCaseListMap.containsKey(soxProgram)){
            
            Map<Id, List<US_WSREMS__REMS_Service_Summary__c>> recTypeAndRSSList = prgmRTAndCaseListMap.get(soxProgram);
            //Added as part of BT6825-945 user story added by surekha.
            if(isBefore && isInsert){
                if(!Test.isRunningTest()){
                    if( UserInfo.getUserType() != 'PowerCustomerSuccess'){
                        SYN_ProgramConfigHandler.validateBusinessRule(recTypeAndRSSList,rectypeIdAndNameMap);
                    }
                }
                
            }
            for(Id recTypeId : recTypeAndRSSList.keySet()){
                
                String recordTypeName = rectypeIdAndNameMap.get(recTypeId);    
                if(recordTypeName ==  RSSkaRecordType){
                    
                    kaRSSList = recTypeAndRSSList.get(recTypeId);
                }
               
            }
            
            if(!kaRSSList.isEmpty()){
               
                SYN_KAServiceHandler.validateKAServiceClosure(kaRSSList, oldMap, isBefore, isAfter, isInsert, isUpdate);
            }
        }   
        
    }      
       
    
    public static List<US_WSREMS__REMS_Service_Summary__c> filterByStatusAndOutCome(List<US_WSREMS__REMS_Service_Summary__c> records, Map<Id, US_WSREMS__REMS_Service_Summary__c> oldMap,String outcome, String status, Boolean isInsert, Boolean isUpdate){
        
        List<US_WSREMS__REMS_Service_Summary__c> rssList = new List<US_WSREMS__REMS_Service_Summary__c>();
        for(US_WSREMS__REMS_Service_Summary__c rss : records){
                
            if(rss.US_WSREMS__Service_Outcome__c == outcome && rss.US_WSREMS__Status__c == status){
                
                if(isInsert){
                
                    rssList.add(rss);
                }else{
                
                    US_WSREMS__REMS_Service_Summary__c rssOldRec = oldMap.get(rss.Id);
                    if(((rss.US_WSREMS__Service_Outcome__c != rssOldRec.US_WSREMS__Service_Outcome__c) || (rss.US_WSREMS__Status__c != rssOldRec.US_WSREMS__Status__c) )){
                        rssList.add(rss);
                    }
                }
            }
        }
        
        return rssList;
    }
    
    public static Map<String, Map<Id, List<US_WSREMS__REMS_Service_Summary__c>>> filterServicesByPrgm(List<US_WSREMS__REMS_Service_Summary__c> newList){
        
        Map<String, Map<Id, List<US_WSREMS__REMS_Service_Summary__c>>> prgmRTAndRSSMap = new Map<String, Map<Id, List<US_WSREMS__REMS_Service_Summary__c>>>();  
        prgmRTAndRSSMap = new Map<String, Map<Id, List<US_WSREMS__REMS_Service_Summary__c>>>();
        for(US_WSREMS__REMS_Service_Summary__c RSSRec : newList){
            
            if(!prgmRTAndRSSMap.containsKey(RSSRec.Program_Name__c)){
                
                prgmRTAndRSSMap.put(RSSRec.Program_Name__c, new Map<Id, List<US_WSREMS__REMS_Service_Summary__c>>());    
            }
            
            Map<Id, List<US_WSREMS__REMS_Service_Summary__c>> existingRTAndRSSMap = prgmRTAndRSSMap.get(RSSRec.Program_Name__c);
            
            if(!existingRTAndRSSMap.containsKey(RSSRec.RecordTypeId)){
                
                existingRTAndRSSMap.put(RSSRec.RecordTypeId,new List<US_WSREMS__REMS_Service_Summary__c>{});
            }            
            existingRTAndRSSMap.get(RSSRec.RecordTypeId).add(RSSRec);
            prgmRTAndRSSMap.put(RSSRec.Program_Name__c, existingRTAndRSSMap);            
        }           
        return prgmRTAndRSSMap; 
    }

}