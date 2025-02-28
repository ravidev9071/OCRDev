public class MaciRDABanner {
    @AuraEnabled
    Public static Case getCurrentRDARecord(Id CurrentRDAcaseId){
        List<String> listRemsProgram = new List<String> {'Macitentan REMS','TRYVIO REMS'};
        Id rdaCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'PDA');
        Case cs = New Case();
        cs = [SELECT Id,Status,US_WSREMS__Outcome__c,US_WSREMS__Authorization_Status__c,RDA_Authorization_Code__c,US_WSREMS__Program_Name__c, US_WSREMS__Authorization_Status_Reason__c FROM Case WHERE Id =: CurrentRDAcaseId AND
              US_WSREMS__Program_Name__c IN: listRemsProgram AND RecordTypeId =: rdaCaseRecTypeId];
        if(cs != null){
            return cs;
        }
        return null;
    }
    
}