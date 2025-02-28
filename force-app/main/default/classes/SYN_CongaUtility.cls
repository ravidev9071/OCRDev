/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class SYN_CongaUtility{      
    
    public static Map<String,String> getStaticCongaParams(UserDetails userdetail){
        
        Map<String,String> paramMap = new Map<String,String>();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
        
        if(userdetail == null){
            userdetail = getUserDetails();
        }
        Set<String> congaQueryNames = new Set<String>{'HCS Enrollment Case Query', 'HCP Updated HCS Affiliations', 'HCS Updated HCP Affiliations'};
        String queryId;
        String hcpUpdatedHCSAffiliationsQueryId;
        String hcsUpdatedHCPAffiliationsQueryId;

        for(APXTConga4__Conga_Merge_Query__c congaQuery : [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c IN : congaQueryNames ] ) {

            if( congaQuery.APXTConga4__Name__c == 'HCS Enrollment Case Query' ){
                queryId = congaQuery.Id;
            } else if( congaQuery.APXTConga4__Name__c == 'HCP Updated HCS Affiliations' ){
                hcpUpdatedHCSAffiliationsQueryId = congaQuery.Id; 
            } else if( congaQuery.APXTConga4__Name__c == 'HCS Updated HCP Affiliations' ){
                hcsUpdatedHCPAffiliationsQueryId = congaQuery.Id;
            }
        }
        paramMap.put('endpoint','https://composer.congamerge.com/composer8/index.html');               
        paramMap.put('sessionId',userdetail.sessionID);        
        paramMap.put('serverUrl',EncodingUtil.urlEncode(servUrl, 'UTF-8'));
        paramMap.put('DefaultPDF','1');
        paramMap.put('SC1','Attachments');
        paramMap.put('DS7','12');    
        paramMap.put('APIMode','1');
        paramMap.put('QueryId', queryId); 
        paramMap.put('hcsAffiliationQueryId', hcpUpdatedHCSAffiliationsQueryId); //Conga query Id which defined to query the related HCS affiliations for the HCP
        paramMap.put('hcpAffiliationQueryId', hcsUpdatedHCPAffiliationsQueryId); //Conga query Id which defined to query the related HCP affiliations for the HCS
        return paramMap;
    }
    public class GeneratePDFUsingConga implements Queueable,Database.AllowsCallouts{
        string recordId;
        string obj;
        REMS_Correspondence_Settings__mdt corrSettings;
        String corresType;
        Map<string,string> fieldValueMap = new Map<string,string>();
        public GeneratePDFUsingConga(String recordId , REMS_Correspondence_Settings__mdt corrSettings, String corresType, Map<string,string> fieldValueMap,String Obj){
            this.recordId = recordId;
            this.corrSettings = corrSettings;
            this.corresType = corresType;
            this.fieldValueMap = fieldValueMap;
            this.obj=obj;
        }
        public void execute(QueueableContext qc){
            UserDetails userDetails = getUserDetails(); 
            Map<String,String> congaStaticParams = getStaticCongaParams(userDetails);
            Map<String,String> variableParams = new Map<String,String>();
            congaStaticParams.put('Id',recordId);  //'RecordId'
            congaStaticParams.put('programName',fieldValueMap.get('USREMSPROGNAME'));
            if(fieldValueMap.containsKey('participantid')){
                congaStaticParams.put('pv0', fieldValueMap.get('participantid'));
            }
            //Added the following code for sending Xiaflex affiliations notification for HCP and HCS
            //Passing the first affiliation name (autonumber) value among the multiple to define the start value for query
            if(fieldValueMap.containsKey('affiliationStartName')){
                congaStaticParams.put('pv1', fieldValueMap.get('affiliationStartName'));
            }
            //Passing the last affiliation name (autonumber) value among the multiple to define the last value for query
            if(fieldValueMap.containsKey('affiliationEndName')){
                congaStaticParams.put('pv2', fieldValueMap.get('affiliationEndName'));
            }
            //Passing the accountRecordType to pass the queryId dynamic in the URL
            if(fieldValueMap.containsKey('accountRecordType')){
                congaStaticParams.put('accountRecordType', fieldValueMap.get('accountRecordType'));
            }
            String congaTemplateKey = getCongaTemplateKey(corrSettings.Conga_Attachment_Template__c);
            variableParams.put('TemplateId',congaTemplateKey); //'Conga Template Id'
            String url = getURL(congaStaticParams,variableParams);
            //Future method won't accept sObject as param, so passing the caseRecord Id to fetch the latest values in future method
            //As corrSettings value is configuration record, passing as JSON string to avoid unneccerrary query  
            sendCongaHTTPRequest(url, recordId , JSON.serialize(corrSettings), corresType,fieldValueMap,obj);
        }
    }
    
   
    public static String getURL(Map<String,String> staticMap,Map<String,String> variableMap){
        Set<String> keysToIgnore = new Set<String> {'endpoint', 'QueryId', 'programName', 'pv0', 'hcsAffiliationQueryId', 'hcpAffiliationQueryId', 'pv1', 'pv2', 'accountRecordType'};
        String url = staticMap.get('endpoint')+'?';
        for(String key:staticMap.keySet())
        {
            if(!keysToIgnore.contains(key))
            {
                url += key+'='+staticMap.get(key)+'&';
            }
        }
        for(String key:variableMap.keySet())
        {
            if(!key.equals('type'))
            {
                String value = variableMap.get(key);
                url += key+'='+ EncodingUtil.urlEncode(value,'UTF-8')+'&';
            }
        }

        if(staticMap.get('programName') == SYN_Utilitycls.AVEED_PROGRAM_NAME && staticMap.containsKey('QueryId') && staticMap.get('QueryId') != null) {
            url += 'QueryId=[affiliationRec]'+staticMap.get('QueryId');
            if(staticMap.containsKey('pv0') && staticMap.get('pv0') != null) {
                url += '?pv0=' + staticMap.get('pv0');
            }
        } else {
            url = url.removeEnd('&');
        }
        if(staticMap.get('programName') == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME && staticMap.containsKey('QueryId') && staticMap.get('QueryId') != null) {
            url += '&QueryId=[affiliationRec]'+staticMap.get('QueryId');
            if(staticMap.containsKey('pv0') && staticMap.get('pv0') != null) {
                url += '?pv0=' + staticMap.get('pv0');
            }
            if(staticMap.containsKey('accountRecordType')){
                if( staticMap.get('accountRecordType') == 'Prescriber' ){
                    url += ',[hcsAffiliationsData]'+staticMap.get('hcsAffiliationQueryId');
                } else if( staticMap.get('accountRecordType') == 'Health_Care_Setting' ){
                    url += ',[hcpAffiliationsData]'+staticMap.get('hcpAffiliationQueryId');
                }
                if(staticMap.containsKey('pv0') && staticMap.get('pv0') != null) {
                    url += '?pv0=' + staticMap.get('pv0');
                }
                if(staticMap.containsKey('pv1') && staticMap.get('pv1') != null) {
                    url += '~pv1=' + staticMap.get('pv1');
                }
                if(staticMap.containsKey('pv2') && staticMap.get('pv2') != null) {
                    url += '~pv2=' + staticMap.get('pv2');
                }
            }
            
        } else {
            url = url.removeEnd('&');
        }
        return url;
    }
    
    public static UserDetails getUserDetails(){
        SYN_Credentials__mdt credentials = SYN_CommonUtility.getCredentials('Get Salesforce SessionId');
        String sfdcUsername = credentials.Username__c;
        String sfdcPassword = credentials.Password__c;
        
        if(String.isNotBlank(sfdcUsername) && String.isNotBlank(sfdcPassword)){
            
            String sfEndpoint = credentials.Endpoint_URL__c;           
            string password = sfdcPassword;
            HttpRequest request = new HttpRequest();
            request.setEndpoint(sfEndpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            request.setHeader('SOAPAction', '""');
            request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + sfdcUsername+ '</username><password>' + password+ '</password></login></Body></Envelope>');           
            string SERVER_URL;
            string SESSION_ID;
            if(!test.isRunningTest())
            {
                Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement() .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
                    .getChildElement('result', 'urn:partner.soap.sforce.com');
                SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com').getText();
                SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com').getText();
            }
            else
            {
                SERVER_URL = 'https://test.salesforce.com';
                SESSION_ID = '6789987978jjklj79j';
            }
            UserDetails details = new UserDetails(SESSION_ID,SERVER_URL);           
            return details;
        }
        
        return null; 
    }
    
    //@future(callout=true)
    public static void sendCongaHTTPRequest(String urlVal, String recId, String corrSettingJSON, String type,Map<string,string> fieldMapVal,String obj){
       Case caseRec;
       Account acc ;
       Id targetObjectId;

        if(obj=='case'){
              caseRec = [SELECT Id,US_WSREMS__Participant__r.PersonContactId,US_WSREMS__Record_Type_Name__c From Case WHERE Id =: recId and US_WSREMS__Participant__c != null WITH SECURITY_ENFORCED];
               targetObjectId = caseRec.US_WSREMS__Participant__r.PersonContactId;
       
            }else if(obj=='Account'){
              acc = [SELECT Id,name,fax,PersonContactId,ownerid,Program_Name__c From Account WHERE Id =: recId WITH SECURITY_ENFORCED];
              targetObjectId = acc.PersonContactId;
            }
        
        REMS_Correspondence_Settings__mdt corresSettingRec = (REMS_Correspondence_Settings__mdt)Json.deserialize(corrSettingJSON, REMS_Correspondence_Settings__mdt.class);
        string emailId = '';
        List<String> bccEmailAdd;

        if(corresSettingRec.Template_Name__c == 'PAE_PC_MI'){
        emailId = System.Label.Email_Addresses_for_PAE_Template;
        }
        List<String> emailidList = emailId.split(';');
        bccEmailAdd = new List<String>();
        bccEmailAdd.add(System.Label.SOXREMSSupportEmail);
        
        HTTPRequest req = new HTTPRequest();    
        req.setEndpoint(urlVal);
        req.setTimeout(120000);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res;
        if(!test.isRunningTest()){
            try{
                
                res = http.send(req);
                
                if(type == 'Email'){
                    //As it's external callout there may be a possibility for delay is response 
                    SYN_CorrespondenceHandler.EmailWrapperClass emailwrappvalues = new SYN_CorrespondenceHandler.EmailWrapperClass();
                    emailwrappvalues.templateName = corresSettingRec.Template_Name__c;
                    emailwrappvalues.recipientType = corresSettingRec.Recipient_Type__c;
                    emailwrappvalues.oweAdd = corresSettingRec.From__c;
                    emailwrappvalues.setActivity = True;
                    emailwrappvalues.toAddressList = emailidList;
                    emailwrappvalues.bccEmailAddress = bccEmailAdd;
                    emailwrappvalues.whatIdVal = recId;
                    emailwrappvalues.communicationRecId= Id.valueof(fieldMapVal.get('CommunicationId'));
                    emailwrappvalues.targetObjIdVal = targetObjectId;
                    emailwrappvalues.attachIds = new List<String>{res.getbody()};
                        // SYN_EmailUtility.sendEmail(caseRec, corresSettingRec.Template_Name__c, corresSettingRec.Recipient_Type__c, corresSettingRec.From__c, FALSE, caseRec.Id, caseRec.Id, new List<String>{res.getbody()});
                        SYN_EmailUtility.sendEmail(emailwrappvalues);
                }else if(type == 'Fax'){
                    if(caseRec!=null){
                        
                       SYN_FaxHanlder.createeFaxPayLoad(caseRec, corresSettingRec.Template_Name__c, corresSettingRec.Recipient_Type__c, new List<String>{res.getbody()},fieldMapVal,'Case');
                    }else if(acc!=null){
                         SYN_FaxHanlder.createeFaxPayLoad(acc, corresSettingRec.Template_Name__c, corresSettingRec.Recipient_Type__c, new List<String>{res.getbody()},fieldMapVal,'Account');
                    }
                }
                
            }catch(Exception ex){
                system.debug('Exception =>'+ex);
            }
            if(res.getbody().toUpperCase().contains('ERROR')){
                
                system.debug(' ::: error- '+res.getbody());
            }
        }else{
            
            res = new HTTPResponse();
            res.setBody('abc'); 
        }           
        
    }
    
    public static String getCongaTemplateKey(String templateName){
        return  [SELECT APXTConga4__Key__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c =: templateName  LIMIT 1 ].APXTConga4__Key__c;    
    }
    
    public class UserDetails{
        
        public string sessionId{get;set;}
        public string serverUrl{get;set;}
        public UserDetails( string sessionId,string serverUrl){
            this.sessionId = sessionId;
            this.serverUrl = serverUrl;
        }
    }
}