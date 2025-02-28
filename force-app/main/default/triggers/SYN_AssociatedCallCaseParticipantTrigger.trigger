trigger SYN_AssociatedCallCaseParticipantTrigger on Associated_Call_Case_Participant__c (before insert) 
{
    If(trigger.isInsert && trigger.isBefore)
    {
        SYN_AssociatedCallCase_Handler.beforeInsert(trigger.new);
    }
}