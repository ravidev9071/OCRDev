/**
* @File Name          : SYN_KnowledgeAssessmentAnswerValidation.cls
* @Description        : This is used as a Controller for SYN_KnowledgeAssessmentAnswerValidation (LWC).
* @TestClass          : SYN_KnowledgeAssessAnsValidation_Test
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    20/04/2022        Chaitanya Nandamuri (Wilco)     Initial Implementation (Assessment Results Validation)
*/
public class SYN_KnowledgeAssessmentAnswerValidation {
    
    private static final Map<Id, Schema.RecordTypeInfo> mapCaseRecordTypesById = Schema.SObjectType.Case.getRecordTypeInfosById();
    public static Map<String,String> fieldToHelpTextMap = new Map<String,String>();
    @AuraEnabled(cacheable=false)    
    public static List<KAAnswersWrap> KnowledgeAssessment(Id caseId , Id caseRecordTypeId){
        
        string caseRecordTypeDevName = mapCaseRecordTypesById.get(caseRecordTypeId).getDeveloperName();
        string caseQueryStr = 'Select Id ';
        Map<String,FullQuestionAnswer> questionToAnswerMap = new map<String,FullQuestionAnswer>();
        List<KAAnswersWrap> KAAnsWrapLst = new List<KAAnswersWrap>();
        Map<String,String> fieldAPItoLabelMap = getFieldlabelMap('Case');
        for (SYN_KnowledgeAssessmentAnswerValidation__mdt KAS : [select RecordType_Dev_Name__c,Question__c, Full_Question__c, Answer__c , Order__c  from SYN_KnowledgeAssessmentAnswerValidation__mdt 
                                                                 where RecordType_Dev_Name__c =: caseRecordTypeDevName order by Order__c  ASC] ){
                                                                     FullQuestionAnswer FQA = new FullQuestionAnswer(KAS.Answer__c , KAS.Full_Question__c , KAS.Order__c.intValue() );
                                                                     questionToAnswerMap.put(KAS.Question__c, FQA);
                                                                     caseQueryStr += ', '+KAS.Question__c;
                                                                 }
        caseQueryStr = caseQueryStr+' from case where Id =: caseId';
        List<case>KnowledgeAssessmentCase = Database.query(caseQueryStr);
        
        for (String question : questionToAnswerMap.keyset()){
            String initialAnswerStr = (String)KnowledgeAssessmentCase[0].get(question);
            String CorrectAnswerStr = questionToAnswerMap.get(question).Answer;
            
            KAAnswersWrap KAIwrap = new KAAnswersWrap();
            KAIwrap.questionStr = fieldAPItoLabelMap.get(question);
            KAIwrap.InitialAnswerStr = initialAnswerStr ;
            KAIwrap.fullQuestionStr = fieldToHelpTextMap.get(question) != null ? fieldToHelpTextMap.get(question) : fieldAPItoLabelMap.get(question) ;
            KAIwrap.questionNumber = questionToAnswerMap.get(question).questionNo;
            if (CorrectAnswerStr != initialAnswerStr)
            {
                KAIwrap.correctAnswerStr =  CorrectAnswerStr;
                KAIwrap.fail = true;
                KAIwrap.options = getPicklistValuesorTheQuestion(question);
            }
            KAAnsWrapLst.add(KAIwrap);
        }
        return KAAnsWrapLst;
    }
    @AuraEnabled(cacheable=false)    
    public static List<KAAnswersWrap> knowledgeAssessmentWrongAnswers(Id caseId , Id caseRecordTypeId){
        List<KAAnswersWrap> knowledgeAssessmentList  =  KnowledgeAssessment( caseId ,  caseRecordTypeId);
        List<KAAnswersWrap> wrongANsweredQuestionList  = new List<KAAnswersWrap>();
        if(WrongANsweredQuestionList != null){
            for(KAAnswersWrap kas : knowledgeAssessmentList){
                if(kas.fail = true){
                    wrongANsweredQuestionList.add(kas);
                }
            }
            return wrongANsweredQuestionList;
        }
        return null;
    }
    public static List<String> getPicklistValuesorTheQuestion(String fieldName){
        List<String> pickListValues = new List<string>();
        String strObjectName = 'Case';
        String strPicklistField = fieldName;
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
              pickListValues.add(objPickList.getLabel());
        }
        return pickListValues;
    }
    
    public static Map<String,string> getFieldLabelMap(String ObjectName){
        SObjectType r = ((SObject)Type.forName('Schema',ObjectName).newInstance()).getSObjectType();
        Map<String, Schema.SObjectField> fieldMap = r.getDescribe().fields.getMap();
        Map<String,String> apiNameToLabelMap = new Map<String,String>();
        
        for (String fieldName: fieldMap.keySet()) {
            
            apiNameToLabelMap.put(String.valueOf(fieldMap.get(fieldName)) ,  fieldMap.get(fieldName).getDescribe().getLabel());
            fieldToHelpTextMap.put(String.valueOf(fieldMap.get(fieldName)), fieldMap.get(fieldName).getDescribe().getInlineHelpText());
        }
        return apiNameToLabelMap;
    }
    public class FullQuestionAnswer{
        @AuraEnabled
        public string Answer;
        @AuraEnabled
        public string FullQuestion;
        @AuraEnabled
        public integer questionNo;
        
        public FullQuestionAnswer(String answer , String Question, Integer questionNo){
            this.Answer = answer;
            this.FullQuestion = Question;
            this.questionNo = questionNo;
        }
        
        
    }
    
    public class KAAnswersWrap{
        @AuraEnabled
        public string questionStr{get; set;}
        @AuraEnabled
        public string fullQuestionStr{get; set;}
        @AuraEnabled
        public string InitialAnswerStr;
        @AuraEnabled
        public string correctAnswerStr;
        @AuraEnabled
        public Boolean fail = false;
        @AuraEnabled
        public Integer questionNumber{get; set;}
        @AuraEnabled 
        public List<String> options {get; set;}
        
    }
}