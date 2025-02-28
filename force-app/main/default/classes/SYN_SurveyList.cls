/* This class is the controller for survey component */
public  class SYN_SurveyList {
    
    @AuraEnabled(cacheable=true)
    public static List<wrapperSurevyName> listsurvey(String recordId){
        
        US_WSREMS__REMS_Service_Summary__c remsServiceRec =[select id,US_WSREMS__REMSProgram__r.Id from US_WSREMS__REMS_Service_Summary__c where id=:recordId];
        List<Program_Survey__c> program_serveylist=[select id,Survey__c,Survey__r.Name,Survey__r.DeveloperName,Name from Program_Survey__c where REMS_Program__c =:remsServiceRec.US_WSREMS__REMSProgram__r.Id AND Is_Active__c=true];
        List<wrapperSurevyName> lstWSN = new List<wrapperSurevyName>();
        for (Program_Survey__c sur : program_serveylist ){
            
            wrapperSurevyName wsn = new wrapperSurevyName();
            wsn.label = sur.Survey__r.Name;
            wsn.value = sur.Survey__r.DeveloperName;
            lstWSN.add(wsn);
            
        }
        return lstWSN;
    }
    
    @AurAEnabled
    public static List<String> getInvitations(String recordId) {
        SET<String> surveyNamesSet = new SET<String>();
        List<String> suveyNamesList = new List<string>();
        for(SurveyInvitation si : [SELECT Id,Name,SurveyId,Survey.DeveloperName,ResponseStatus FROM SurveyInvitation WHERE Name =: recordId AND ResponseStatus=:'Completed']) {
            surveyNamesSet.add(si.Survey.DeveloperName);
        }
        suveyNamesList.addAll(surveyNamesSet);
        return suveyNamesList;
    }
    
    @AuraEnabled
    public static wrapperSurevy CreateSurveyInvWrpResult(string SurveyDeveloperName , string currentRecordId){
        
        String portal_name;
        string strSurveyURL='';
        string baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/survey/runtimeApp.app?invitationId=';
        Survey surveyRec = [select Id,Name from Survey where DeveloperName =: SurveyDeveloperName ];
        US_WSREMS__REMS_Service_Summary__c remsServiceRec=[SELECT Id,US_WSREMS__REMSProgram__r.name FROM US_WSREMS__REMS_Service_Summary__c WHERE id=:currentRecordId];
        SurveyInvitation SInv = New SurveyInvitation();
        portal_name = System.Label.PortalName;    
        Sinv.CommunityId  = [select Id  from Network where name =:portal_name]?.id ;
        SInv.OptionsCollectAnonymousResponse = true;
        SInv.OptionsAllowGuestUserResponse = true;
        SInv.SurveyId = surveyRec.Id;
        SInv.Name = currentRecordId;
        SInv.REMS_Service__c = currentRecordId;
        insert SInv;
        
        SurveySubject SS = new SurveySubject();
        SS.SubjectId = currentRecordId;
        SS.ParentId = SInv.Id;
        SS.Name = currentRecordId;
        insert SS;
        
        string UniquieInviteId = [Select UUID from SurveyInvitation where id = :SInv.id]?.UUID;
        strSurveyURL = baseUrl+''+SInv.id+'&surveyName='+SurveyDeveloperName+'&UUID='+UniquieInviteId; 
        
        wrapperSurevy survey_wrapper =new wrapperSurevy();
        survey_wrapper.URL=strSurveyURL;
        survey_wrapper.SurveyName =surveyRec.Name;
        return survey_wrapper;
        
    }
    @testVisible
    public class wrapperSurevyName {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
    }
    
    public class wrapperSurevy {
        @AuraEnabled
        public string URL;
        @AuraEnabled
        public string SurveyName;
    }
    
}