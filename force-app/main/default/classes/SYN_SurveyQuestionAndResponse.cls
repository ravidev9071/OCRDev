public class SYN_SurveyQuestionAndResponse
{
    public static List<SurveyQuestionResponse> sList = new List<SurveyQuestionResponse>();
    @AuraEnabled
    public static List<respWrapper> getQuestionAndResponse(String recId,String responses)
    {
        List<SurveyResponse> srList = new List<SurveyResponse>();
        List<SurveyResponse> srList1 = new List<SurveyResponse>();
        set<string> setSurResIds = new set<string>();
        if(!test.isRunningTest()) 
        {
            srList1 = [SELECT Id,Status,Name,Invitation.Survey.Name,SubmitterId,Submitter.Name,CompletionDateTime,CreatedDate from SurveyResponse WHERE Invitation.Name=:recId and Status=:'Completed' order by createdDate desc];
        }
        else {
            srList1 = (List<SurveyResponse>)JSON.deserialize(responses, List<SurveyResponse>.class);
        }
        
        for(SurveyResponse surRes:srList1 )
        {
            srList.add(surRes);
            setSurResIds.add(surRes.id);
        }
        
        map<string,list<SurveyQuestionResponse>> mapSurveyRes = new map<string,list<SurveyQuestionResponse>>();
        List<respWrapper> respWrapperList = new List<respWrapper>();
        if(!setSurResIds.isEmpty())
        {
            for(SurveyQuestionResponse surveyQuesRes : [SELECT Id,InvitationId,Invitation.Name,Questionid,Invitation.Survey.Name,Question.ValidationType, Question.Name,ResponseValue,ResponseId,Response.Status,Response.Submitter.Name, Response.CompletionDateTime,createdDate FROM SurveyQuestionResponse WHERE ResponseId IN : setSurResIds order by Questionid asc])
            {
                if(mapSurveyRes.KeySet().Contains(surveyQuesRes.ResponseId))
                {
                    mapSurveyRes.get(surveyQuesRes.ResponseId).add(surveyQuesRes);
                }
                else
                {
                    list<SurveyQuestionResponse> lstQusResMap = new list<SurveyQuestionResponse>();
                    lstQusResMap.add(surveyQuesRes);
                    mapSurveyRes.put(surveyQuesRes.ResponseId,lstQusResMap);
                }
            }
            
            for(SurveyResponse surRes: srList)
            {
                respWrapper res1 = new respWrapper();
                res1.SurveyName = surRes.Invitation.Survey.Name;
                res1.Id = surRes.Id;
                res1.SubmitterName =surRes.Submitter.Name;
                if(!string.isBlank(string.valueOf(surRes.createdDate)))
                {
                    res1.StartDate = formatDate(surRes.createdDate.Date());
                }
                if(!string.isBlank(string.valueOf(surRes.CompletionDateTime)))
                {
                    res1.EndDate = formatDate(surRes.CompletionDateTime.Date());
                }
                res1.status = surRes.Status;
                List<qstnandRespWrapper> subWrap = new List<qstnandRespWrapper>();
                
                if(mapSurveyRes.KeySet().contains(surRes.id))
                {
                    map<string,string> mapQuesAns = new map<string, string>();
                    for(SurveyQuestionResponse surveyQuesRes: mapSurveyRes.get(surRes.id))
                    {
                        if(mapQuesAns.KeySet().Contains(surveyQuesRes.Question.Name))
                        {
                            string resvalue = mapQuesAns.get(surveyQuesRes.Question.Name) +','+surveyQuesRes.ResponseValue;
                            mapQuesAns.put(surveyQuesRes.Question.Name, resvalue); 
                        }
                        else
                        {
                            mapQuesAns.put(surveyQuesRes.Question.Name,surveyQuesRes.ResponseValue); 
                        }
                    }
                    for(string surveyQuesRes: mapQuesAns.KeySet())
                    {
                        
                        qstnandRespWrapper qa = new qstnandRespWrapper();
                        qa.Question = surveyQuesRes;
                        qa.Response = mapQuesAns.get(surveyQuesRes);
                        subWrap.add(qa);
                    }
                    
                }
                res1.qstnsrespList =subWrap;
                respWrapperList.add(res1);
            }
        }
        
        return respWrapperList;
    }
    public static String formatDate(Date dt) {
        // Datetime dtTodayDateTime = dt.newInstance(dt.year(), dt.month(),dt.day());
        string strDate = dt.month() + '-' + dt.day() + '-' + dt.year(); //dtTodayDateTime.format('MM-dd-yyyy');
        return strDate;
    }
    public class respWrapper {
        @AuraEnabled public String SurveyName {get;set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String SubmitterName {get;set;}
        @AuraEnabled public String StartDate {get;set;}
        @AuraEnabled public String EndDate{get;set;}
        @AuraEnabled public String Status {get;set;}
        @AuraEnabled public List<qstnandRespWrapper> qstnsrespList{get;set;}
    }
    public class qstnandRespWrapper{
        @AuraEnabled public String Question {get;set;}
        @AuraEnabled public String Response{get;set;}
    }
}