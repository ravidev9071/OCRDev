/**
* @File Name          : SYN_KAServiceUtil
* @Description        : This is used as a Hanlder for KA Service
* @Trigger            : SYN_RemsServiceSummaryTrigger
* @TestClass          : 
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date              Developer                         Modification
* 2.0       02/02/2023        Rajadurai                 KA Service Validations
**/

public class SYN_KAServiceHandler{
    
    public static Map<String, Map<String, Set<String>>> requesterAndRequiredQA = new Map<String, Map<String, Set<String>>>{        
        'Sodium Oxybate REMS' => new Map<String, Set<String>>{
            'Authorized Representative' => new Set<String>{'SYN_Knowledge_Assessment_A','SYN_Knowledge_Assessment_B'},
            'Pharmacist' => new Set<String>{'SYN_Knowledge_Assessment_A','SYN_Knowledge_Assessment_B'},
            'Pharmacy Staff' => new Set<String>{'SYN_Knowledge_Assessment_A'}
         }    
    };
    public static String authRep = 'Authorized Representative';
    public static String pharmacist = 'Pharmacist';
    public static String pharmacyStaff = 'Pharmacy Staff';
    
    public static String errorMessage = 'The Knowledge Assessment service cannot be saved as closed successful because 1 or more of the associated Knowledge Assessment cases does not have the case status as complete and the case outcome as passed. Please update the case or update the service status and service outcome.';
    
    public static void validateKAServiceClosure(List<US_WSREMS__REMS_Service_Summary__c> filteredList, Map<Id, US_WSREMS__REMS_Service_Summary__c> oldMap, Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate){
        
        
        if(isBefore && (isInsert || isUpdate)){
            
            List<US_WSREMS__REMS_Service_Summary__c> closedSuccessfulList = SYN_REMSServiceValidationHandler.filterByStatusAndOutCome(filteredList, oldMap, 'Successful', 'Closed', isInsert, isUpdate);
            if(!closedSuccessfulList.isEmpty()){
                
                Map<id, US_WSREMS__REMS_Service_Summary__c> triggerListMap = new Map<Id, US_WSREMS__REMS_Service_Summary__c>(closedSuccessfulList);
                List<Id> parentRecordIdSet = new List<Id>(triggerListMap.keySet());
                //Just add the child object API name and its relationship name
                Map<String, String> childObjAPIAndRelName = new Map<String, String>{'Case' => 'US_WSREMS__Cases__r'};
                
                //Optionally you can pass the parent object relationship fields
                Set<String> parentObjRelFields = new Set<String>();
                
                //Here you can pass any filter criteria for child objects
                Map<String, String> childConditions = new Map<String, String>{
                    'Case' => ' WHERE US_WSREMS__REMS_Service_Summary__c IN: parentRecordIdSet '
                };
                
                //In this map, you can pass the child object fields. If you are not passing the child object fields, it will take all the fields from schema
                Map<String, String> objectAndListOfFields = new Map<String, String>{         
                    'US_WSREMS__REMS_Service_Summary__c' => 'Name, Program_Name__c',    
                    'Case' => 'CaseNumber, Status, RecordTypeId, RecordType.DeveloperName, US_WSREMS__Status__c, US_WSREMS__Outcome__c, US_WSREMS__REMS_Service_Summary__c, US_WSREMS__UserType_ar__c, Pharmacy_Employee_Type__c '    
                };                
                
                //getInnerQuery-ParentObject, RelationshipFields, childObjAPIAndRelName, contactIdSet, parentQueryFilter
                String queryString = SYN_QueryUtil.getInnerQuery('US_WSREMS__REMS_Service_Summary__c', objectAndListOfFields, parentObjRelFields, childObjAPIAndRelName, childConditions, parentRecordIdSet, 'ORDER BY Name');
                List<US_WSREMS__REMS_Service_Summary__c> rssAndCaseList = Database.query(queryString);
                for(US_WSREMS__REMS_Service_Summary__c rss: rssAndCaseList){
                    
                    Map<String, Set<String>> userTypeAndKA = new Map<String, Set<String>>();
                    if(requesterAndRequiredQA.containsKey(rss.Program_Name__c)){
                        
                        userTypeAndKA = requesterAndRequiredQA.get(rss.Program_Name__c);
                    } 
                    
                    for(Case caseRec : rss.US_WSREMS__Cases__r){
                        
                        if(String.isNotBlank(caseRec.Pharmacy_Employee_Type__c)){
                        
                            if(caseRec.Pharmacy_Employee_Type__c.contains(authRep) && (userTypeAndKA.get(authRep).size() !=  rss.US_WSREMS__Cases__r.size())){
                                
                                triggerListMap.get(rss.Id).addError(errorMessage);
                            }else if(caseRec.Pharmacy_Employee_Type__c.contains(pharmacist) && (userTypeAndKA.get(pharmacist).size() !=  rss.US_WSREMS__Cases__r.size())){
                                
                                triggerListMap.get(rss.Id).addError(errorMessage);
                            }else if(caseRec.Pharmacy_Employee_Type__c.contains(pharmacyStaff) && (rss.US_WSREMS__Cases__r.size() == 0)){

                                triggerListMap.get(rss.Id).addError(errorMessage);
                            }
                        }
                        
                        if(caseRec.Status != 'Complete' || caseRec.US_WSREMS__Outcome__c != 'Pass'){
                        
                            triggerListMap.get(rss.Id).addError(errorMessage);
                        }
                    }
                    
                      
                    
                }
            }
        }
    } 
}