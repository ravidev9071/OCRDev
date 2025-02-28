global class SYN_Incontact_BatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global list<case> start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id, Name FROM Case';
        list<case> lstCase = new list<case>();
        integer processDays = integer.valueOf(system.label.inContactSummaryProcessDays);
        date startdate = system.today().addDays(-processDays);
        for(case caseInfo: [select id, inContact_Contact_ID__c, inContact_Call_Start_Time__c, inContact_Call_End_Time__c, inContact_Call_Duration__c, InContact_Call_Details_Collected__c from case where inContact_Contact_ID__c!=null and InContact_Call_Details_Collected__c=:false and CreatedDate >=: startdate])
        {
            lstCase.add(caseInfo);
        }
        return lstCase;
    }
    global void execute(Database.BatchableContext BC, List<Case> CaseList)
    {
        SYN_InContactSummaryBatchClass.getIncontactSummary(CaseList);
    }
    global void finish(Database.BatchableContext BC)
    {
    
    }
    
    
}