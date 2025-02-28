/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class stakeholderEmailsDisplayList {
   /*
    Method: getEmailMessageRecords
    Description: This method is used to query all the email messages that are related to specific accounts and show them
    on the UI. Query involves data collected from case, affiliation and self account.
    param: recordId - current account record Id
   */
    @AuraEnabled
    public static list<EmailMessage> getEmailMessageRecords(Id recordId)
    {
        List<EmailMessage> EmailMessageList = New List<EmailMessage>();
        List<Case> Caselist = New List<Case>();
        List<US_WSREMS__Affiliation__c> affiliationList = New List<US_WSREMS__Affiliation__c>();
        Set<Id> caseAffilIds = New Set<Id>();
        
        if(recordId != null){
            
            Caselist = [Select id from Case WHERE US_WSREMS__Program_Picklist__c = 'Macitentan REMS' AND 
                        (US_WSREMS__Patient__c =: recordId OR SYN_Prescriber__c =: recordId OR 
                         SYN_Pharmacy__c =: recordId OR SYN_Authorized_Rep__c =: recordId OR 
                         US_WSREMS__Distributor__c =: recordId OR Pharmacy_Participant__c =: recordId OR
                         US_WSREMS__Participant__c =: recordId)];
            
            affiliationList = [SELECT Id FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__REMSProgram__r.Name = 'Macitentan REMS' AND 
                               (US_WSREMS__Patient__c =: recordId OR US_WSREMS__Pharmacy__c =: recordId OR 
                                US_WSREMS__Pharmacy_User__c =: recordId OR US_WSREMS__Prescriber__c =: recordId OR 
                                US_WSREMS__Authorized_Representative__c =:recordId)];
            
            if(!Caselist.isEmpty()){
                for(Case cs: Caselist){
                    caseAffilIds.add(cs.Id);
                }
            }
            
            if(!affiliationList.isEmpty()){
                for(US_WSREMS__Affiliation__c aff: affiliationList){
                    caseAffilIds.add(aff.Id);
                }
            }
            
            caseAffilIds.add(recordId);
        }
        
        if(!caseAffilIds.isEmpty()){
            EmailMessageList = [SELECT Id,Name,Subject,RelatedToId,RelatedTo.Name,FromAddress,ToAddress FROM EmailMessage
                                WHERE RelatedToId IN:caseAffilIds];
        }
        
        if(!EmailMessageList.isEmpty()){
            return EmailMessageList;
        }
        
        return null;
    }
    
}