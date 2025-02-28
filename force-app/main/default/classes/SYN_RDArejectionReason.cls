public class SYN_RDArejectionReason {
    
   
    
    @AuraEnabled
    Public static List<string> RDArejectionReasons(Id CurrentRDAcaseId){
        List<case> currentRDAlst = [select Id , US_WSREMS__Patient__c, US_WSREMS__Prescriber__c,US_WSREMS__Pharmacy__c, X4_Received_dispense_of_oxybate_product__c ,
                                    SYN_Days_Supply__c, X4a_What_was_the_most_recent_fill_date__c, date_of_Fill__c,SYN_Prescriber__c,
                                    X2_Patient_currently_disenrolled__c, X3_Prescriber_currently_disenrolled__c,X4b_Days_supply_of_last_dispance__c,
                                    US_WSREMS__Prescription_Date__c,SYN_Quantity__c,X1_Number_of_attempts__c,US_WSREMS__Outcome__c, US_WSREMS__REMS_Program__c
                                    from case where Id =: CurrentRDAcaseId ];
        SYN_CaseTriggerHelper.RDACaseValidation(currentRDAlst);
        string RDArejectionReasonsStr = SYN_CaseTriggerHelper.RDArejectionReasonsStr;
        List<String> Ruleslist = New List<String>();
        List<String>RRR_Lst = new List<String>();
        if(RDArejectionReasonsStr.contains(';')){
            Ruleslist = RDArejectionReasonsStr.split(';');
        }else{
            Ruleslist.add(RDArejectionReasonsStr);
        }
        
        for( RDArejectionReasons__mdt RRR_mdt : [select DeveloperName , Rejection_Message__c  from RDArejectionReasons__mdt where DeveloperName In : Ruleslist]){
            RRR_Lst.add(RRR_mdt.Rejection_Message__c);
        }
        
        return RRR_Lst;
    }
}