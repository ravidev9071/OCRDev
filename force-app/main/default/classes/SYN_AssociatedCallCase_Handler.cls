public class SYN_AssociatedCallCase_Handler{
    public static void beforeInsert(list<Associated_Call_Case_Participant__c> lstAssociatedCall)
    {
        
            list<string> keyValues = new list<string>();
        for(Associated_Call_Case_Participant__c associatedInfo: lstAssociatedCall)
        {
             String key;
             Key = associatedInfo.Case__c+''+associatedInfo.Participant__c+''+associatedInfo.REMS_Program__c;
             keyValues.add(key);
        }
        
        map<string,string> mapKeyValues = new map<string,string>();
        if(!keyValues.isEmpty())
        {
            for(Associated_Call_Case_Participant__c assoInfo: [select id, External_ID__c from Associated_Call_Case_Participant__c where External_ID__c IN: keyValues])
            {
                mapKeyValues.put(assoInfo.External_ID__c,assoInfo.External_ID__c);
            }
        }
        
        for(Associated_Call_Case_Participant__c associatedInfo: lstAssociatedCall)
        {
             String key;
             Key = associatedInfo.Case__c+''+associatedInfo.Participant__c+''+associatedInfo.REMS_Program__c;
             if(mapKeyValues.KeySet().Contains(Key))
             {
                 associatedInfo.addError(System.Label.SYN_AssociatedCallCaseParticipantErrorMessage);
             }
             else
             {
                 associatedInfo.External_ID__c = associatedInfo.Case__c+''+associatedInfo.Participant__c+''+associatedInfo.REMS_Program__c;
             }
        }
        
    }
}