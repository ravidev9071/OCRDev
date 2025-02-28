public class SYN_InContactAPIUtility {
    
    public static String generateAccessToken()
    {
        String tokenResponse;
        String access_token;
        SYN_IncontactCreds__mdt incontactCreds = SYN_IncontactCreds__mdt.getInstance('inContact_credentials');
        
        Http httpcall = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(String.valueof(incontactCreds.get('LoginURL__c')));
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        String accesskey=String.valueOf(incontactCreds.get('accessKeyId__c'));
        String security=String.valueOf(incontactCreds.get('accessKeySecret__c')) ;
        String jsonBody = '{' + 
            '\"accessKeyId\": \"' + accesskey + '\",' +
            '\"accessKeySecret\" : \"' + security  +'\"'+ '}';
        req.setBody( jsonBody);
        HttpResponse resp = httpcall.send( req);
        if(resp.getStatusCode() != 200)
        {
            //Need to define error message
            system.debug('Error message'+resp.getBody());
            system.debug('Error'+resp.getStatus());
            
        }
        else
        {
            tokenResponse = resp.getBody();
            Map<String,object>  jsonMap= (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
            User userObj=new User();
            userObj.Id=Id.valueof(UserInfo.getUserId());
            
            if(jsonMap.KeySet().Contains('access_token') && jsonMap.KeySet().Contains('token_type') && String.valueOf(jsonMap.get('access_token'))!=null && (String.valueOf(jsonMap.get('token_type'))!=null))
            {
                userObj.InContact_Access_Token__c=String.valueOf(jsonMap.get('token_type'))+' '+String.valueOf(jsonMap.get('access_token'));
                 access_token=userObj.InContact_Access_Token__c;
            }
            if(jsonMap.KeySet().Contains('refresh_token') && String.valueOf(jsonMap.get('refresh_token'))!=null)
            {
                userObj.InContact_Refresh_Token__c=String.valueOf(jsonMap.get('refresh_token'));
            }
            if(jsonMap.KeySet().Contains('expires_in') && String.valueOf(jsonMap.get('expires_in'))!=null){
                userObj.InContact_Token_Expire__c=Datetime.now().addHours(1);
            }
            if(jsonMap.KeySet().Contains('refresh_token_expires_in') && String.valueOf(jsonMap.get('refresh_token_expires_in'))!=null)
            {
                userObj.InContact_Refresh_Token_Expire__c=Date.valueOf(jsonMap.get('refresh_token_expires_in'));
            }
            
            if(userObj !=null)
            {
               // update userObj;
            } 
            
            
        }
        //return access_token;
        return tokenResponse;
    }
    
    public static String generateRefreshToken(String refreshToken)
    {
        string refreshTokenRes;
        SYN_IncontactCreds__mdt incontactCreds = SYN_IncontactCreds__mdt.getInstance('inContact_credentials');
         String access_token;
        Http httpcall = new Http(); 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(String.valueof(incontactCreds.get('RefreshTokenUrl__c')));
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        String jsonBody = '{' + 
            '\"token\": \"' + refreshToken +'\"'+ '}';
        req.setBody( jsonBody);
        HttpResponse resp = httpcall.send(req);
        if(resp.getStatusCode() != 200)
        {
            //Need to define error message
            system.debug('Error message'+resp.getBody());
            system.debug('Error'+resp.getStatus());
             access_token=null;
        }
        else
        {
            refreshTokenRes = resp.getBody();
            Map<String,object>  jsonMap= (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
            User userObj=new User();
            userObj.Id=Id.valueof(UserInfo.getUserId());
            if(jsonMap.KeySet().Contains('token') && String.valueOf(jsonMap.get('token'))!=null)
            {
                userObj.InContact_Access_Token__c='Bearer'+' '+String.valueOf(jsonMap.get('token'));
                   access_token=userObj.InContact_Access_Token__c;
                
            }
            if(jsonMap.KeySet().Contains('refreshToken') && String.valueOf(jsonMap.get('refreshToken'))!=null)
            {
                userObj.InContact_Refresh_Token__c=String.valueOf(jsonMap.get('refreshToken'));
            }
            if(jsonMap.KeySet().Contains('tokenExpirationTimeSec') && String.valueOf(jsonMap.get('tokenExpirationTimeSec'))!=null)
            {
                Integer seconds=Integer.valueOf(jsonMap.get('tokenExpirationTimeSec'));
                userObj.InContact_Token_Expire__c=System.now().addSeconds(seconds);
            }
            
            if(jsonMap.KeySet().Contains('refreshTokenExpirationTimeSec') && String.valueOf(jsonMap.get('refreshTokenExpirationTimeSec'))!=null){
                Integer seconds=Integer.valueOf(jsonMap.get('refreshTokenExpirationTimeSec'));
                userObj.InContact_Refresh_Token_Expire__c=System.now().addSeconds(seconds);
            }
            if(userObj !=null)
            {
                //update userObj;
            } 
            
            
        }
        //return access_token;
        return refreshTokenRes;
    }
    
   public static string makeACallURL(String noToBeCalled,String Tollfreeno)
   {
       String error_message='';
         String scriptName = '';
        String bus_no = '';
        String scriptId = '';
        String Guid = '';
        String baseUrl = '';
       String agentId='';
       String projectSkillNo ='';//'8412341';//30165180(AgentId)
       User u=[SELECT id,InContact_Agent_Id__c,InContact_ProjectSkillno__c,Program__c from user where id=:UserInfo.getUserId() Limit 1];
       if(u.InContact_Agent_Id__c !=null &&u.InContact_ProjectSkillno__c !=null)
       {
           projectSkillNo=u.InContact_ProjectSkillno__c;
          agentId = u.InContact_Agent_Id__c; 
       }
        //need to remove hardcoded data
        //String projectPhNo=Tollfreeno;//'8884100755'; //'8332384372';//'7205275207'//'1236676789';//fetching from project target tollfree number
        String nondigits = '[^0-9]';
            
        String projectPhNo= Tollfreeno.replaceAll(nondigits,'');
               noToBeCalled = noToBeCalled.replaceAll(nondigits,'');
     	
       if(u.Program__c == 'Macitentan REMS'){
        if(inContact_Settings__mdt.getInstance('scriptNameLightning_Maci').Value__c != null) 
        {
            scriptName = inContact_Settings__mdt.getInstance('scriptNameLightning_Maci').Value__c ;
        }

        if(inContact_Settings__mdt.getInstance('bus_no_Maci').Value__c != null) {
            bus_no = inContact_Settings__mdt.getInstance('bus_no_Maci').Value__c;
        }
      
      
        if(inContact_Settings__mdt.getInstance('scriptIdLightning_Maci').Value__c != null) {
            scriptId = inContact_Settings__mdt.getInstance('scriptIdLightning_Maci').Value__c;
        }

        if(inContact_Settings__mdt.getInstance('Guid_Maci').Value__c != null) {
            Guid = inContact_Settings__mdt.getInstance('Guid_Maci').Value__c;
        }

        if(inContact_Settings__mdt.getInstance('IncontactBaseUrl_Maci').Value__c != null) {
            baseUrl = inContact_Settings__mdt.getInstance('IncontactBaseUrl_Maci').Value__c;
        }
       }else if(u.Program__c == 'Piasky REMS'){
            if(inContact_Settings__mdt.getInstance('scriptNameLightning_Piasky').Value__c != null) 
        {
            scriptName = inContact_Settings__mdt.getInstance('scriptNameLightning_Piasky').Value__c ;
        }

        if(inContact_Settings__mdt.getInstance('bus_no_Piasky').Value__c != null) {
            bus_no = inContact_Settings__mdt.getInstance('bus_no_Piasky').Value__c;
        }

      
        if(inContact_Settings__mdt.getInstance('scriptIdLightning_Piasky').Value__c != null) {
            scriptId = inContact_Settings__mdt.getInstance('scriptIdLightning_Piasky').Value__c;
        }

        if(inContact_Settings__mdt.getInstance('Guid_Piasky').Value__c != null) {
            Guid = inContact_Settings__mdt.getInstance('Guid_Piasky').Value__c;
        }

        if(inContact_Settings__mdt.getInstance('IncontactBaseUrl_Piasky').Value__c != null) {
            baseUrl = inContact_Settings__mdt.getInstance('IncontactBaseUrl_Piasky').Value__c;
        }
       }
       else if(u.Program__c == 'TRYVIO REMS'){
             if(inContact_Settings__mdt.getInstance('scriptNameLightning_Tryvio').Value__c != null) 
            {
                scriptName = inContact_Settings__mdt.getInstance('scriptNameLightning_Tryvio').Value__c ;
        }

        if(inContact_Settings__mdt.getInstance('bus_no_Tryvio').Value__c != null) {
            bus_no = inContact_Settings__mdt.getInstance('bus_no_Tryvio').Value__c;
        }


        if(inContact_Settings__mdt.getInstance('scriptIdLightning_Tryvio').Value__c != null) {
            scriptId = inContact_Settings__mdt.getInstance('scriptIdLightning_Tryvio').Value__c;
            }

            if(inContact_Settings__mdt.getInstance('Guid_Tryvio').Value__c != null) {
                Guid = inContact_Settings__mdt.getInstance('Guid_Tryvio').Value__c;
        }

        if(inContact_Settings__mdt.getInstance('IncontactBaseUrl_Tryvio').Value__c != null) {
                baseUrl = inContact_Settings__mdt.getInstance('IncontactBaseUrl_Tryvio').Value__c;
            }
        }else if(u.Program__c == 'AVEED REMS'){
             if(inContact_Settings__mdt.getInstance('scriptNameLightning_Aveed').Value__c != null) 
            {
                scriptName = inContact_Settings__mdt.getInstance('scriptNameLightning_Aveed').Value__c ;
            }

            if(inContact_Settings__mdt.getInstance('bus_no_Aveed').Value__c != null) {
            bus_no = inContact_Settings__mdt.getInstance('bus_no_Aveed').Value__c;
            }

        
            if(inContact_Settings__mdt.getInstance('scriptIdLightning_Aveed').Value__c != null) {
                scriptId = inContact_Settings__mdt.getInstance('scriptIdLightning_Aveed').Value__c;
            }

            if(inContact_Settings__mdt.getInstance('Guid_Aveed').Value__c != null) {
                Guid = inContact_Settings__mdt.getInstance('Guid_Aveed').Value__c;
        }

        if(inContact_Settings__mdt.getInstance('IncontactBaseUrl_Aveed').Value__c != null) {
            baseUrl = inContact_Settings__mdt.getInstance('IncontactBaseUrl_Aveed').Value__c;
        }
       }
       else if(u.Program__c == 'Xiaflex_REMS_Program_Name'){
            if(inContact_Settings__mdt.getInstance('scriptNameLightning_Xiaflex').Value__c != null) 
        {
            scriptName = inContact_Settings__mdt.getInstance('scriptNameLightning_Xiaflex').Value__c ;
        }

        if(inContact_Settings__mdt.getInstance('bus_no_Xiaflex').Value__c != null) {
            bus_no = inContact_Settings__mdt.getInstance('bus_no_Xiaflex').Value__c;
        }
        if(inContact_Settings__mdt.getInstance('scriptIdLightning_Xiaflex').Value__c != null) {
            scriptId = inContact_Settings__mdt.getInstance('scriptIdLightning_Xiaflex').Value__c;
        }
        if(inContact_Settings__mdt.getInstance('Guid_Xiaflex').Value__c != null) {
            Guid = inContact_Settings__mdt.getInstance('Guid_Xiaflex').Value__c;
        }
        if(inContact_Settings__mdt.getInstance('IncontactBaseUrl_Xiaflex').Value__c != null) {
            baseUrl = inContact_Settings__mdt.getInstance('IncontactBaseUrl_Xiaflex').Value__c;
        }
       }
       else{
           if(inContact_Settings__mdt.getInstance('scriptNameLightning').Value__c != null) 
        {
            scriptName = inContact_Settings__mdt.getInstance('scriptNameLightning').Value__c ;
        }

        if(inContact_Settings__mdt.getInstance('bus_no').Value__c != null) {
            bus_no = inContact_Settings__mdt.getInstance('bus_no').Value__c;
        }
      
      
        if(inContact_Settings__mdt.getInstance('scriptIdLightning').Value__c != null) {
            scriptId = inContact_Settings__mdt.getInstance('scriptIdLightning').Value__c;
        }

        if(inContact_Settings__mdt.getInstance('Guid').Value__c != null) {
            Guid = inContact_Settings__mdt.getInstance('Guid').Value__c;
        }

        if(inContact_Settings__mdt.getInstance('IncontactBaseUrl').Value__c != null) {
            baseUrl = inContact_Settings__mdt.getInstance('IncontactBaseUrl').Value__c;
        }
       }
        
        //update lstUser[0];
        String inContactEndPoint =   (baseUrl+'/inContact/Manage/Scripts/Spawn.aspx?'+
                                   'scriptName='+scriptName+
                                   '&bus_no='+bus_no+
                                   '&scriptId='+scriptId+
                                   '&skill_no='+projectSkillNo+
                                   '&p1='+noToBeCalled+
                                   '&p2='+agentId+
                                   '&p3='+projectPhNo+
                                   '&p4='+
                                   '&p5='+
                                   '&Guid='+Guid);
        return inContactEndPoint;     
    }
public static  Map<String,String> makeFinalCallAPI(String inContactEndPoint)
{
    Map<String,String> status_map=new Map<String,String>();
    String ContactId;
        try
        {
            HTTPRequest req = new HTTPRequest();
           req.setEndpoint(inContactEndPoint);
         // String url='https://api-c13.incontact.com/incontactapi/services/v23.0/contacts/30165180';
          //  String url='https://home-c13.incontact.com/inContactAPI/services/v13.0/Contacts/30165180';
           //req.setEndpoint(url);
            req.setTimeout(60000);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            Http http = new Http();
            HTTPResponse res;
            if(!test.isRunningTest()) 
            {
                res = http.send(req);
                if(res.getStatusCode()!=200)
                {
                   //add error message
                   status_map.put('StatusCode',res.getStatusCode()+'');
                   status_map.put('ErrorMessage',res.getBody()); 
                }
                else
                {
                    String response1=res.getBody();
                    String res3= response1.substringBetween('Contact ID:','</strong>').trim();
                    ContactId=res3;
                   status_map.put('StatusCode',res.getStatusCode()+'');
                   status_map.put('ContactId',ContactId); 
                }
              
            }
            else
            {
                res = new HTTPResponse();
                res.setBody('Test Body');
                res.setStatus('Test Status');
                res.setStatusCode(123);
            }
        }
        catch(Exception e)
        {
            system.debug('-------#### An error occured '+e);
        }
    return status_map;
    }
}