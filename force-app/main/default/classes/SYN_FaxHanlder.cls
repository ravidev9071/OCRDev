/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SYN_FaxHanlder {
    /**
* @Author: Rajadurai Kalyanasundaram    
* @Description:  Method to form the faxpayload based on the case and attachment data 
* @Param: case ,template name,recepient type,Attachments Ids 
*/ 
    // pulic static Map<string,string> fieldValueMap = new Map<string,string>();
    public static List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
    public static  List<ContentVersion> contentVersionList=new List<ContentVersion>();
    public static void createeFaxPayLoad(Sobject sobj, String tempName, String recipType, List<String> attachIds, Map<string,string> fieldValueMap,String type ){
        Id recipientId;
        Id pharmacyEnrollcaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Pharmacy_Enrollment');       
        Id distributorEnrollcaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'SYN_Distributor_Enrollment');
        Id prescriberEnrollCaseRecTypeId = SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        Id rmrCaseRecTypeId =  SYN_CommonUtility.getRecordTypeIdbyDeveloperName('Case', 'Risk_Management_Report');
        List<Attachment> attcmtlist = [Select Name, Body,parentId From Attachment Where id IN: attachIds];  
        SentFaxWrapper faxwrap = new SentFaxWrapper();
        List<SentFaxWrapper.Destinations> destnlst = new List<SentFaxWrapper.Destinations>();
        List<SentFaxWrapper.documents> decmntnlst = new List<SentFaxWrapper.documents>();
        SentFaxWrapper.Destinations destn = new SentFaxWrapper.Destinations();
         
        String programName = fieldValueMap.get('USREMSPROGNAME');
        
        if(recipType == 'Patient' && programName != 'Macitentan REMS') {    //patient ID
             recipientId=fieldValueMap.get('nameOfReportertargetObjectIdVal');
            If(fieldValueMap.get('NameOfReporterFax').length() == 10 ){
                //participantID
                destn.fax_number ='1'+ fieldValueMap.get('NameOfReporterFax');
            }  
            else {
                //participantID
                destn.fax_number = fieldValueMap.get('NameOfReporterFax');
            }            
        }  
        if(recipType == 'Prescriber' || recipType == 'Pharmacy' || (recipType == 'Patient' && programName == 'Macitentan REMS')) {    
            //prescriberId
            
             if(type=='Account') {
                recipientId=fieldValueMap.get('TargetObjectId');
                destn.to_name = fieldValueMap.get('Name');
             }else{
            recipientId=fieldValueMap.get('prescribertargetObjectIdVal');
               destn.to_name = fieldValueMap.get('participantNameVal');
             }
            //destn.fax_number = fieldValueMap.get('participantFax');     
           if(programName == 'Macitentan REMS'){
            if(type=='Account') {
                 fieldValueMap.put('prescriberFax', fieldValueMap.get('FaxNumber'));
            }else{
                 fieldValueMap.put('prescriberFax', fieldValueMap.get('prescriberFaxAccValue'));
                  }                
                }                
                
            If(fieldValueMap.get('prescriberFax').length() == 10 ){
                destn.fax_number ='1'+ fieldValueMap.get('prescriberFax');
            }  
            else {
                destn.fax_number = fieldValueMap.get('prescriberFax');
            }
            }
        if(recipType == 'All') {  
            if(fieldValueMap.get('RecordType') == prescriberEnrollCaseRecTypeId){
                recipientId=fieldValueMap.get('prescribertargetObjectIdVal');
            } else if(fieldValueMap.get('RecordType') == pharmacyEnrollcaseRecTypeId ){
                recipientId=fieldValueMap.get('AuthRepTargetObjId');
            } else if(fieldValueMap.get('RecordType') == distributorEnrollcaseRecTypeId){
                Account targetObjAcc  = [select Id, PersonContactId, Name from Account where Name = :SYN_Utilitycls.SOXPersonContactIdAccName Limit 1];	
                recipientId = targetObjAcc.PersonContactId;
            }
            
            If(fieldValueMap.get('caseFax').length() == 10 ){
                //participantID
                destn.fax_number ='1'+ fieldValueMap.get('caseFax');
            }  
            else {
                //participantID
                destn.fax_number = fieldValueMap.get('caseFax');
            }
        }
        if(recipType == 'Pharmacist') {   
            //PharmacyParticipantId
            destn.to_name = fieldValueMap.get('pharmacistNameVal');                   
            destn.fax_number = fieldValueMap.get('pharmacistFax');
        }
        if(programName == SYN_Utilitycls.AVEED_PROGRAM_NAME || programName == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME){
            if(recipType == 'Health Care Setting') {
                // it should be auth rep
                destn.to_name = fieldValueMap.get('authRepNameValue');                   
                recipientId = fieldValueMap.get('AuthRepTargetObjId');
                if(fieldValueMap.get('authRepFax').length() == 10 ){
                    destn.fax_number ='1'+ fieldValueMap.get('authRepFax');
                }  
                else {
                    destn.fax_number = fieldValueMap.get('authRepFax');
                }
            } else if(recipType == 'Prescriber') {
                destn.to_name = fieldValueMap.get('participantNameVal');                   
                recipientId = fieldValueMap.get('prescribertargetObjectIdVal');
                if(fieldValueMap.get('prescriberFax').length() == 10 ){
                    destn.fax_number ='1'+ fieldValueMap.get('prescriberFax');
                }  
                else {
                    destn.fax_number = fieldValueMap.get('prescriberFax');
                }
            }
        }
        
        destnlst.add(destn);
        faxwrap.destinations = destnlst;
       
        for(Attachment atmtrec: attcmtlist) {
            
            SentFaxWrapper.Documents doc = new SentFaxWrapper.Documents();
            
            doc.document_type = 'PDF';
            doc.document_content = EncodingUtil.base64Encode(atmtrec.body);
            decmntnlst.add(doc);  
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = atmtrec.name;
            contentVersion.Title = atmtrec.name;
            contentVersion.VersionData =atmtrec.body;    
            contentVersionList.add(contentVersion);
        }
       
        Id CommunicationId=Id.valueof(fieldValueMap.get('CommunicationId'));
        faxwrap.documents = decmntnlst;
        String payload = JSON.serialize(faxwrap); 
        sendfax(payload,CommunicationId,recipientId);
    }
    
    /**
* @Author: Rajadurai Kalyanasundaram    
* @Description:  Method to send the fax to corresponding recepient after getting the access token from the Efax Integration service
* @Param: json payload
*/    
    
    //@future (callout=true)
    public static void sendfax( String jString,Id CommunicationId,Id recipientId) {
        
        HttpResponse authresponse = efaxAuthentication();
         if(authresponse.getStatusCode() == 200 ) {
            
            SentFaxWrapper.Oauth_response deserzeresp = (SentFaxWrapper.Oauth_response)system.JSON.deserialize(authresponse.getbody(),SentFaxWrapper.Oauth_response.class);
            
            String reqJson = jString;
            String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            String transid= EncodingUtil.convertToHex(hash);
            
            SYN_Credentials__mdt credentials = SYN_CommonUtility.getCredentials('eFax Callout Api');
            
            String Userid = credentials.Username__c;
            String EndURL =credentials.Endpoint_URL__c;
            
            HttpRequest req = new HttpRequest();    
            req.setEndpoint(EndURL);
            req.setMethod('POST');
            req.setHeader('Authorization','Bearer '+deserzeresp.access_token);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('user-id', Userid);           
            req.setHeader('transaction-id', transid);
            req.setTimeout(90000);
            req.setBody(reqJson);
            
            if(!test.isRunningTest()) {          
                Http http = new Http();            
                HttpResponse response = new HttpResponse();
                response = http.send(req);
                REMS_Outbound_Communication__c recordObj=new REMS_Outbound_Communication__c();
                recordObj.id=CommunicationId;
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                    recordObj.Status__c='Sent';
                    recordObj.ContactName__c=recipientId;
                    if(!(contentVersionList.isEmpty())){
                        insert contentVersionList;
                    }
                    List<id> contentVersionIds=new List<id>();
                    for(ContentVersion cv:contentVersionList){
                        contentVersionIds.add(cv.id);  
                    }
                    List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds];
                    for(ContentVersion contentVersion : contentVersions){
                        ContentDocumentLink contentDocumentLink = createContentDocumentLink(contentVersion.ContentDocumentId,CommunicationId);
                        contentDocumentLinks.add(contentDocumentLink);
                    }
                    if(!(contentDocumentLinks.isEmpty())){
                        insert contentDocumentLinks;
                    }
                    
                }else{
                    recordObj.Status__c='Failed';
                    recordObj.ContactName__c=recipientId;
                }
                update recordObj;
         
            }
        }
    }
    
    /**
* @Author: Rajadurai Kalyanasundaram    
* @Description:  Method to perform the authentication (OAuth2) to Efax Integration service to get the access token 
* @Param: 
*/    
    public static HttpResponse efaxAuthentication() {
        
        SYN_Credentials__mdt credentials = SYN_CommonUtility.getCredentials('eFax Authentication Api');
        
        String appId  = credentials.Username__c;
        String apiKey = credentials.Password__c;
        String authURL = credentials.Endpoint_URL__c; 
        
        HttpResponse resp = new HttpResponse();
        
        if(String.isNotBlank(appId) && String.isNotBlank(apiKey)) {
            
            Http htp = new Http();          
            HttpRequest authreq = new HttpRequest();
            
            String authorizationkey = appId +':'+apiKey;
            authorizationkey = 'Basic '+EncodingUtil.base64Encode(blob.valueOf(authorizationkey));
            authreq.setHeader('Authorization',authorizationkey);
            authreq.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
            authreq.setMethod('POST');
            authreq.setEndpoint(authURL);  
            authreq.setTimeout(120000);
            authreq.setbody('grant_type=client_credentials');
            
            
            HttpResponse authresponse = new HttpResponse();
            if(!test.isRunningTest()) {
                authresponse  = htp.send(authreq);
                return authresponse;
            } else {
                
                resp = new HTTPResponse();
                resp.setBody('{"documents":[{"document_type": "TXT","document_content": "VGhpcyBpcywfeBh33IHRlc3QuIFRlc3QgMi4="}]}');
                resp.setStatus('Test Status');
                resp.setStatusCode(200);
            }
        }
        return resp; 
    }    
    
    
    public static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ShareType = 'I'; // Inferred permission
        contentDocumentLink.Visibility = 'InternalUsers';
        return contentDocumentLink;
    }
    
}