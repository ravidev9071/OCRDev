/*************************
Created by - Narayanan SOX
*************************/
public class SYN_PatientAccountRMRHistListCntllr { 

    @AuraEnabled
    public static List<Case> getRMRAndCOICases(Id patientAccountId){
    
        Id rmrCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        Id patientCOICaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Patient_COI').getRecordTypeId();
    
        return [SELECT Id, CaseNumber, RecordTypeId, RecordType.DeveloperName,RecordType.Name,SYN_Should_patient_be_monitored__c,CreatedDate, 
                (SELECT Id, CreatedDate, Field, OldValue, NewValue FROM Histories WHERE (Field = 'created' OR Field = 'US_WSREMS__Outcome__c' OR Field = 'Status') ORDER By CreatedDate DESC)  
                FROM Case 
                WHERE 
                ((RecordTypeId = :rmrCaseRecordTypeId AND
                US_WSREMS__Patient__c = :patientAccountId)
                OR 
                (RecordTypeId = :patientCOICaseRecordTypeId 
                AND 
                US_WSREMS__Participant__c = :patientAccountId
                AND
                SYN_Should_patient_be_monitored__c = 'No'))
                AND
                Status = 'Complete'
                AND
                US_WSREMS__Outcome__c = 'Complete'
                ORDER By CreatedDate ASC
                ];
    }

    @AuraEnabled
    public static List<Case> getRMRAndCOICasesPrescriber(Id prescriberAccountId){
    
        Id rmrCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Risk_Management_Report').getRecordTypeId();
        Id prescriberCOICaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_COI').getRecordTypeId();
    
        return [SELECT Id, CaseNumber, RecordTypeId, RecordType.DeveloperName,RecordType.Name,Should_prescriber_be_monitored__c,CreatedDate, 
                (SELECT Id, CreatedDate, Field, OldValue, NewValue FROM Histories WHERE (Field = 'created' OR Field = 'US_WSREMS__Outcome__c' OR Field = 'Status') ORDER By CreatedDate DESC)  
                FROM Case 
                WHERE 
                ((RecordTypeId = :rmrCaseRecordTypeId AND
                SYN_Prescriber__c = :prescriberAccountId)
                OR 
                (RecordTypeId = :prescriberCOICaseRecordTypeId 
                AND 
                US_WSREMS__Participant__c = :prescriberAccountId
                AND
                Should_prescriber_be_monitored__c = 'No'))
                AND
                Status = 'Complete'
                AND
                US_WSREMS__Outcome__c = 'Complete'
                ORDER By CreatedDate ASC
                ];
    }
}