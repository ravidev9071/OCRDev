public class SYN_PatientEnrollmentMissingInfo{
    public static Id emailCaseId {get;set;}
    public static String personFirstName {get;set;}
    public static String personMiddleName {get;set;}
    public static String personLastName {get;set;}
    public static List<string> missingFieldsList{get;set;}
    
    public static string getpatientNameWithInitials(){
        string nameWithIntials = getTheIntialsFromName(personFirstName,personMiddleName,personLastName);
        return nameWithIntials;
    }
    public static string getTheIntialsFromName(string personFirstName,string personMiddleName,string personLastName){
        string nameWithIntials = personFirstName.substring(0,1)+' ' +personMiddleName.substring(0,1)+' '+ personLastName.substring(0,1);
        return nameWithIntials;
    }
    public static List<string> getPatientEnrollmentMissingFields(){
        List<string> patientEnrollmentMissingFieldsList=selectedPickListValues(emailCaseId,'Medical_Conditions__c');
        return patientEnrollmentMissingFieldsList;
    }
    public static List<string> getStakeholderEnrollmentMissingFields(){
        List<string> stakeholderEnrollmentMissingFieldsList=selectedPickListValues(emailCaseId,'Medical_Conditions__c');
        return stakeholderEnrollmentMissingFieldsList;  
    }
    public static List<string> getRiskManagementReportMissingFields(){
        List<string> riskManagementReportMissingFieldsList=selectedPickListValues(emailCaseId,'Medical_Conditions__c');
        return riskManagementReportMissingFieldsList;
    }
    public static List<string> getPatientCounselingChecklistMissingFields(){
        List<string> patientCounselingChecklistMissingFieldsList=selectedPickListValues(emailCaseId,'Medical_Conditions__c');
        return patientCounselingChecklistMissingFieldsList;
    }
    public static List<string> selectedPickListValues(Id caseValId, string fieldName){
        List<case> caseList = Database.query('SELECT ' + fieldName + ' FROM ' + 'case  WHERE  Id =: caseValId');
        string str =  string.valueOf(caseList[0].get(fieldName));
        List<String> missingFieldsList = str.split(';');
        return missingFieldsList !=null ? missingFieldsList : null;
    }  
}