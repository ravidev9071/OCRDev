public class SYN_InContactSummaryBatchClass
{
    public static void getIncontactSummary(list<case> lastCase)
    {
        IncontactTokenInfo__mdt newInContactToken = new IncontactTokenInfo__mdt();
        string accessToken;
        string refreshToken;
        boolean generateRefreshToken = false;
        for(IncontactTokenInfo__mdt inConTok: IncontactTokenInfo__mdt.getAll().values())
        {
            if(inConTok.DeveloperName=='IncontactToken')
            {
                if(!string.isBlank(string.valueOf(inConTok.InContact_Token_Expire__c)) && System.now()<=inConTok.InContact_Token_Expire__c)
                {
                    //accessToken = inConTok.InContact_Access_Token__c;
                }
            }
        }
       // Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
       // Boolean isMetadataUpdateNeeded = false;
        if(string.isBlank(accessToken) )
        {
            string IncontactTokenRes = SYN_InContactAPIUtility.generateAccessToken();
            
            if(!string.isBlank(IncontactTokenRes))
            {
                
                Map<String,object>  jsonMap= (Map<String,Object>)JSON.deserializeUntyped(IncontactTokenRes);
                if(jsonMap.KeySet().Contains('access_token') && jsonMap.KeySet().Contains('token_type') && String.valueOf(jsonMap.get('access_token'))!=null && (String.valueOf(jsonMap.get('token_type'))!=null))
                {
                    accessToken = String.valueOf(jsonMap.get('token_type'))+' '+String.valueOf(jsonMap.get('access_token'));
                }
            }
        }
        if(!string.isBlank(accessToken))
        {
            list<case> lstupdateCase = new list<case>();
            for(case caseInfo: lastCase)
            {   
                HTTPRequest req = new HTTPRequest();
                req.setEndpoint(system.label.inContactCallSummaryAPI+''+caseInfo.inContact_Contact_ID__c);
                req.setTimeout(60000);
                req.setMethod('GET');
                req.setHeader('accept', 'application/json');
                req.setHeader('Authorization', accessToken);
                Http http = new Http();
                HTTPResponse res ;
                res = http.send(req);
                if(res.getStatusCode() == 200)
                {
                    Map<String,object>  jsonMapres = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                    if(jsonMapres.KeySet().Contains('contactStart') && !string.isBlank(string.valueOf(jsonMapres.get('contactStart'))))
                    {
                        caseInfo.inContact_Call_Start_Time__c = string.valueOf(jsonMapres.get('contactStart'));
                        string DateValue = string.valueOf(jsonMapres.get('contactStart'));
                        if(DateValue.Contains('T'))
                        {
                            DateValue = DateValue.replace('T',' ');
                        }
                        if(DateValue.Contains('Z'))
                        {
                            DateValue = DateValue.replace('Z',' ');
                        }
                        caseInfo.inContact_Call_Start_Time_Date_Time__c = (datetime.valueof(DateValue)).addMinutes(330);
                    }
                    if(jsonMapres.KeySet().Contains('lastUpdateTime') && !string.isBlank(string.valueOf(jsonMapres.get('lastUpdateTime'))))
                    {
                        caseInfo.inContact_Call_End_Time__c = string.valueOf(jsonMapres.get('lastUpdateTime'));
                        string DateValue = string.valueOf(jsonMapres.get('lastUpdateTime'));
                        if(DateValue.Contains('T'))
                        {
                            DateValue = DateValue.replace('T',' ');
                        }
                        if(DateValue.Contains('Z'))
                        {
                            DateValue = DateValue.replace('Z',' ');
                        }
                        caseInfo.inContact_Call_End_Time_Date_Time__c = (Datetime.valueOf(DateValue)).addMinutes(330);
                    }
                    if(jsonMapres.KeySet().Contains('totalDurationSeconds') && !string.isBlank(string.valueOf(jsonMapres.get('totalDurationSeconds'))))
                    {
                        caseInfo.inContact_Call_Duration__c = string.valueOf(jsonMapres.get('totalDurationSeconds'));
                    }
                    caseInfo.InContact_Call_Details_Collected__c = True;
                    lstupdateCase.add(caseInfo);
                 }       
                       
            }
            
            if(!lstupdateCase.isEmpty())
            {
                database.update(lstupdateCase,false);
            }
            
        }
        
    }
}