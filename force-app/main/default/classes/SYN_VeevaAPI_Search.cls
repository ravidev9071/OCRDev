/**
* @File Name          : SYN_VeevaAPI_Search.cls
* @Description        : This is used to validate npi for maci and dea for SOX and npi,dea for Xiaflex programs using veeva network by doing veeva api call.
* @Trigger            : SYN_VeevaAPI_Search
* @TestClass          : SYN_VeevaAPI_Search_Test
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    02/22/2022        Chaitanya Nandamuri (Wilco)     Initial Implementation 
* 2.0    09/24/2022        Praveen Vellanki (Wilco)       Changes made as listed below:
                                                          New: Line 37: added a string - programName
                                                          Update- Line 44;45: added the string and wrapper declarations to the top
                                                          New: Line 47 - 52: Added the if check to execute, update case only for MACI
                                                          Update: Line 52-56: Added the exising case update code in else
                                                          New: Line 63-65: Added the if check to execute, update participant only for MACI
                                                          Update: Line 65-70: Added the exising participant update code in else for Non-MACI
                                                          New: Line 107-109: If check for MACI, to set NPI
                                                          Update: Line: 109-111: else for non-maci to set for DEA
                                                          New: Line 125-130: Added if check, setting query for prescriber. pharmacy by creating 2 strings for MACI.
                                                          Update: Line 130-133: Added existing conditions in else for non-MACI
                                                          Update: Line 134: Replaced the existing quer filter with the Prescriber and Pharmacy strings created in 134
                                                          Line 191-195: Added program check to set the record status in string; 
                                                          Line 197-199: Added If check to validate the result and pass it to boolean "isvalid" if it is MACI 
                                                          Line 199-201: else condition for existing line that passes the result to "isVAlid" boolean.


**/
public class SYN_VeevaAPI_Search
{
    private static string filterQuery;
    private static boolean isValid = false;
    public static boolean isSche3Validation = false;
    private static String keyStr;
    private static final Map<Id, Schema.RecordTypeInfo> mapCaseRecordTypesById =
        Schema.SObjectType.Case.getRecordTypeInfosById();
    private static SYN_Credentials__mdt Veeva_Auth_API = (SYN_Credentials__mdt)SYN_custom_mdt('Veeva_Authentication_API');
    private static SYN_Credentials__mdt Veeva_Search_API = (SYN_Credentials__mdt)SYN_custom_mdt('Veeva_Search_API');
    public static string programName;
    private static String PrescriberLName='';
    private static string Type;
    private static boolean isNPIValidation =false;
    private static boolean isSLNValidation =false;
    private static boolean isHINValidation = false;

    private static boolean isFirstTime_NPI = false;
    private static String roleStr='';
    private static string pharmacyName = '';
    public static prescriberInfoPrepopWrap PresInfo; 
    private static pharmacyInfoPrepopWrap PharmaInfo;
    private
        static final Map<String, Schema.RecordTypeInfo> mapCaseRecordTypesByDevName =
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
public static boolean invalidDEANumber ; //Added by AshishY : 1331
    
    //@AuraEnabled
    @future(callout=true)
    public static void searchCurrentCase(list<string> caseId){
        map<string,case> mapListCase = new map<string,case>();
        case caseData = new case();
        //Below caseData is modified as part of 1331:AshishY
        caseData = [select id, US_WSREMS__First_Name__c, US_WSREMS__Last_Name__c,Credential_Invalid_Reasons__c,US_WSREMS__REMS_Program__r.Name, US_WSREMS__SLN__c,US_WSREMS__NPI__c,US_WSREMS__DEA__c, US_WSREMS__Participant__c ,US_WSREMS__Status__c, RecordTypeId,SYN_DEA_Validation__c,SYN_Street_Address__c,Pharmacy_Name__c,SYN_Zip_Code__c,US_WSREMS__State__c,US_WSREMS__City__c,Approval_Status__c,SYN_Pharmacy__r.Name from case where id IN: caseId Limit 1];

        caseParameterWrap CPW;
        caseParameterWrap CPW_NPI;
        caseParameterWrap CPW_SLN;
        String DEAvalidation_pickList;
        String NPIvalidation_pickList;
        String SLNvalidation_pickList;
       
        if(caseData.US_WSREMS__REMS_Program__r.Name == Label.Macitentan_REMS_Program_Name){
            programName = Label.Macitentan_REMS_Program_Name;
            pharmacyName = caseData.SYN_Pharmacy__r.Name ;
            CPW  = new caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , caseData.US_WSREMS__Last_Name__c , caseData.RecordTypeId);
            DEAvalidation_pickList = searchResult(CPW) ? SYN_Utilitycls.pickListVal_Active : SYN_Utilitycls.pickListVal_InActive ;
            caseData.US_WSREMS__Status__c = DEAvalidation_pickList;
            isFirstTime_NPI = true;
          } 
       
        //added to check DEA for XIAFLEX
        else if(caseData.US_WSREMS__REMS_Program__r.Name == Label.AVEED_REMS_Program_Name) {
                programName = Label.AVEED_REMS_Program_Name;
                //pharmacyName = caseData.SYN_Pharmacy__r.Name ;
                CPW  = new caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , caseData.US_WSREMS__Last_Name__c , caseData.RecordTypeId);
                DEAvalidation_pickList = searchResult(CPW) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
                caseData.US_WSREMS__DEA_Status__c = DEAvalidation_pickList;
                isFirstTime_NPI = true;
    	}else{
            CPW  = new caseParameterWrap(caseData.id , caseData.US_WSREMS__DEA__c , caseData.US_WSREMS__Last_Name__c , caseData.RecordTypeId);
            DEAvalidation_pickList = searchResult(CPW) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
             //below two lines are added for address validation 1331:AshishY
             Boolean isAddressValidated = (PresInfo != NULL && caseData.SYN_Street_Address__c == PresInfo.StreetAddress && caseData.SYN_Zip_Code__c == PresInfo.postalCode && caseData.US_WSREMS__State__c == PresInfo.State && caseData.US_WSREMS__City__c == PresInfo.city) ? TRUE : FALSE;
			
             //Below lines are added for updating invalidReason field 1331:AshishY
            caseData.Credential_Invalid_Reasons__c  = '';
             
                If(invalidDEANumber == false && roleStr == SYN_Utilitycls.Prescriber){
                    caseData.Credential_Invalid_Reasons__c  = 'The DEA was not found or is not active';
                } else if(isAddressValidated == False && invalidDEANumber == true && roleStr == SYN_Utilitycls.Prescriber){
                    caseData.Credential_Invalid_Reasons__c  = 'DEA Invalid Address';
                } else if (isSche3Validation && roleStr == SYN_Utilitycls.Prescriber){
                    caseData.Credential_Invalid_Reasons__c  = 'Not able to prescribe schedule III narcotics';
                }
             
            //End of invalidReason: AshishY
            
            DEAvalidation_pickList = (DEAvalidation_pickList == SYN_Utilitycls.pickListVal_Valid && isAddressValidated) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
            caseData.SYN_DEA_Validation__c = DEAvalidation_pickList;
            CPW_NPI  = new caseParameterWrap(caseData.id ,caseData.US_WSREMS__NPI__c , caseData.US_WSREMS__Last_Name__c , caseData.RecordTypeId);
            CPW_NPI.NPIvalidation=true;
            Type='NPI';
            NPIvalidation_pickList=searchResult(CPW_NPI) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
            
            caseData.NPI_Status__c= NPIvalidation_pickList;

            //BT6825-435
            CPW_SLN  = new caseParameterWrap(caseData.id ,caseData.US_WSREMS__SLN__c , caseData.US_WSREMS__Last_Name__c , caseData.RecordTypeId);
            CPW_SLN.SLNvalidation=true;
            Type='SLN';
            SLNvalidation_pickList=searchResult(CPW_SLN) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
            
            caseData.SLN_Status__c= SLNvalidation_pickList; //BT6825-435
            
        }
        caseData.SYN_Validation_Date__c = Date.today();
        //caseParameterWrap CPW = new caseParameterWrap(caseData.id , caseData.US_WSREMS__DEA__c , caseData.US_WSREMS__Last_Name__c , caseData.RecordTypeId);                
        update caseData;
        
        if (!String.isBlank(caseData.US_WSREMS__Participant__c)){
            Account participantData;
            if(caseData.US_WSREMS__REMS_Program__r.Name == Label.Macitentan_REMS_Program_Name){
                participantData = new Account (id = caseData.US_WSREMS__Participant__c , SYN_NPI_Validation_Status__c = DEAvalidation_pickList);
            }else{
                participantData = new Account (id = caseData.US_WSREMS__Participant__c , SYN_DEA_Validation__c = DEAvalidation_pickList,NPI_Status__c=NPIvalidation_pickList,SLN_Status__c=SLNvalidation_pickList);
            }
            update participantData;
        }
    }
    public static boolean searchResultPiasky(caseParameterWrap CPW,string piaskyProgram){
        programName = piaskyProgram;
        return searchResult(cpw);
    }

    public static boolean searchResultTryvio(caseParameterWrap CPW,string tryvioProgram){
        programName = tryvioProgram;
        return searchResult(cpw);
    }
    
    @auraEnabled
    public static boolean searchResult(caseParameterWrap CPW){
        isValid = false;
        //String roleStr;
        case caseData = new case();
        Credential_Validation__c creValinfo = new Credential_Validation__c();
        if(CPW.NPIvalidation){
             Type='NPI';
        }
        if (Veeva_Auth_API == null || Veeva_Search_API == null ){
            return isValid;
        }
        string key='';
        string DEAlicenseNumber=''; 
        string LastName='';
        
            if(!string.isBlank(CPW.lastName)){
                key = key+''+CPW.lastName;
                LastName = EncodingUtil.urlEncode(CPW.lastName,'utf-8');
            }
            if(!string.isBlank(CPW.DEANumber)){
                key = key+''+CPW.DEANumber;
                DEAlicenseNumber = EncodingUtil.urlEncode(CPW.DEANumber,'utf-8');
                creValinfo.Credential_Number__c = CPW.DEANumber;
            }
        
        if(mapCaseRecordTypesById.get(CPW.RecordTypeId).getDeveloperName().containsIgnoreCase('Pharmacy') ){
            roleStr = 'Pharmacy';
        }else if(mapCaseRecordTypesById.get(CPW.RecordTypeId).getDeveloperName().containsIgnoreCase('Prescriber')){
            roleStr = 'Prescriber';
        }else if(mapCaseRecordTypesById.get(CPW.RecordTypeId).getDeveloperName().containsIgnoreCase('HCS_Enrollment') &&( programName == 'Xiaflex'||programName == 'AVEED REMS' )){ // added check for xiaflex HCS enrollement BT2816-524
            roleStr = 'HCS';
            
        }
         
        pharmacyName = String.isBlank(pharmacyName) ? CPW.pharmacyName : pharmacyName;
      
       
        filterQuery = queryFilter ( roleStr , CPW);
        if(!Test.isRunningTest())
        VeevaAuthenticationProcess( Veeva_Auth_API );
        creValinfo.Request__c = filterQuery;
        creValinfo.Case__c = !String.isBlank(CPW.caseId) ? CPW.caseId : null ;
        creValinfo.Status__c = isValid ? 'Valid' : 'InValid';
        creValinfo.Status_Date__c = System.Today();
        creValinfo.Account__c = !string.isBlank(caseData.US_WSREMS__Participant__c) ? caseData.US_WSREMS__Participant__c : null;       
        if(programName == Label.Macitentan_REMS_Program_Name || programName == Label.PiaSky_REMS_Program_Name || programName == Label.Tryvio_REMS_Program_Name || programName == Label.Xiaflex_REMS_Program_Name ){
            creValinfo.Type__c = 'NPI';
        }else{
            if(CPW.NPIvalidation){
                creValinfo.Type__c = 'NPI';  
                return isNPIValidation;
            }
            if(CPW.SLNvalidation){
                creValinfo.Type__c = 'SLN';  
                return isSLNValidation;
            }
            if (CPW.HINvalidation) {
               creValinfo.Type__c = 'HIN';
              return isHINValidation;                
            }
            if(CPW.Sche3validation){
                creValinfo.Type__c = 'DEA';
                return isSche3Validation;
            }else{
              creValinfo.Type__c = 'DEA';  
            }
            
        }
      
        //insert creValinfo;
        return isValid;
    }
    
    public static String queryFilter( String role , caseParameterWrap CPW){
        String filterQuery = 'q='+EncodingUtil.urlEncode('*','utf-8');
        if (role == 'Prescriber'){
            keyStr = CPW.lastName+CPW.DEANumber; 
            PrescriberLName = CPW.lastName; 
        }else if (role == 'Pharmacy'){
             keyStr = CPW.DEANumber;
        }

        string pharmacyfilter;
        string prescriberfilter;
        if(programName == Label.Macitentan_REMS_Program_Name ||programName == Label.PiaSky_REMS_Program_Name || programName == Label.Tryvio_REMS_Program_Name){
            pharmacyfilter = '&types=HCO&filters=hco.npi_num__v:'+CPW.DEANumber;
            prescriberfilter = '&types=HCP&filters=hcp.last_name__v:'+CPW.lastName+'~hcp.npi_num__v:'+CPW.DEANumber;
        }else{
            if(CPW.NPIvalidation){
                Type='NPI';
                pharmacyfilter = '&types=HCO&filters=hco.npi_num__v:'+CPW.DEANumber;
            	prescriberfilter = '&types=HCP&filters=hcp.last_name__v:'+CPW.lastName+'~hcp.npi_num__v:'+CPW.DEANumber; 
            }
            else if(CPW.SLNvalidation){
                Type='SLN';
              //  pharmacyfilter = '&types=HCO&filters=hco.npi_num__v:'+CPW.DEANumber;
                prescriberfilter = '&sortResultChildren=true&returnHighlights=true&nestChildObjectFieldQueries=true&includeMasterResults=true&states=VALID%2CUNDER_REVIEW&types=HCP&offset=0&fieldqueries=&filters=hcp.last_name__v:'+CPW.lastName+'~licenses.license_number__v:'+CPW.DEANumber+'~license_status__v:A~licenses.type__v:STATE'; 
            } else if (CPW.HINvalidation) {
                Type = 'HIN';
                 prescriberfilter = '&types=HCO&filters=hin__v:' + CPW.DEANumber;
            }else{
            	pharmacyfilter = '&types=HCO&filters=licenses.license_number__v:'+CPW.DEANumber+',licenses.type_value__v:DEA';
                if(programName == Label.AVEED_REMS_Program_Name){
                    prescriberfilter = '&types=HCP&filters=licenses.license_number__v:'+CPW.DEANumber+',licenses.type_value__v:DEA';
           
                }else{
                    prescriberfilter = '&types=HCP&filters=licenses.license_number__v:'+CPW.DEANumber+',licenses.type_value__v:DEA,hcp.last_name__v:'+CPW.lastName;    
                }
            	  
            }
        }
       
        return filterQuery += role == 'Pharmacy' ? pharmacyfilter : (role == 'HCS' && CPW.HCSPresValidationFailed) ? pharmacyfilter : prescriberfilter;
    	//return filterQuery += '&types=HCO&filters=licenses.type_value__v:DEA,licenses.license_number__v:FH6354132,license_status__v:A';
                                                   //*&types=HCP&offset=0&fieldqueries=&filters=hcp.last_name__v:Sherman~hcp.npi_num__v:1447229463
    }
    
    public static void VeevaAuthenticationProcess (SYN_Credentials__mdt Veeva_Auth_API  ){
        map<string,Object> authResponse ;
        HttpRequest req = new HttpRequest();
        String username = EncodingUtil.urlEncode(Veeva_Auth_API.UserName__c ,'utf-8');
        String password = EncodingUtil.urlEncode(Veeva_Auth_API.Password__c,'utf-8');
        req.setEndpoint(Veeva_Auth_API.Endpoint_URL__c+'?username='+username+'&'+'password='+password);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        try{
            if(res.getStatusCode() == 200){
                authResponse = (map<string,Object>)JSON.deserializeUntyped(res.getBody());
                if(authResponse.KeySet().Contains('sessionId')){
                    VeevaSearchAPI(Veeva_Search_API.Endpoint_URL__c , filterQuery , String.valueOf(authResponse.get('sessionId')) );
                }
            }
        }
        catch(exception e){
            isValid = isValid; 
        }
    }
    
    public static Sobject SYN_custom_mdt (String mdt_name){
        return SYN_Credentials__mdt.getInstance(mdt_name);
    }
    
    private static void VeevaSearchAPI (String searchAPI , String filterQuery , String sessionId ){
        HttpRequest reqData = new HttpRequest();
        reqData.setEndpoint(searchAPI+'?'+filterQuery);
        reqData.setHeader('Authorization', sessionId );
        reqData.setMethod('POST');
        Http httpData = new Http();
        HTTPResponse resData = httpData.send(reqData);
        if(resData.getStatusCode()==200){
            searchVeevaData veevaSearchData = new searchVeevaData();
            String veevaJSONData = string.valueOf(resData.getBody());
            list<Credential_Validation__c> lstCreValidation = new list<Credential_Validation__c>();
            if(!string.isBlank(veevaJSONData)){
                veevaJSONData = veevaJSONData.Contains('limit') ? veevaJSONData.replace('limit','dataLimit') : veevaJSONData ;
                veevaJSONData = veevaJSONData.Contains('__v') ?  veevaJSONData = veevaJSONData.replace('__v','') :  veevaJSONData ;
                veevaJSONData = veevaJSONData.Contains('__c') ?  veevaJSONData = veevaJSONData.replace('__c','') :  veevaJSONData ;
                veevaSearchData = (searchVeevaData)JSON.deserialize(veevaJSONData, searchVeevaData.class);
                prescriberInfoPrepopWrap PrescriberInfo = new prescriberInfoPrepopWrap();
                pharmacyInfoPrepopWrap   PharmacyInfo = new pharmacyInfoPrepopWrap();
                System.debug('veevaSearchData.entities--->'+veevaSearchData.entities);

                if(veevaSearchData!=null && veevaSearchData.entities != null && !veevaSearchData.entities.isEmpty()){
                    System.debug('veevaSearchData.entities--->'+veevaSearchData.entities);
                    for(searchEntitiesData entitiesData: veevaSearchData.entities){
                        if (roleStr == SYN_Utilitycls.Prescriber){
                          		PrescriberInfo.FirstName = entitiesData.entity.first_name;
                        		PrescriberInfo.MiddleName = !string.isBlank(entitiesData.entity.middle_name) ? entitiesData.entity.middle_name : '';
                       			PrescriberInfo.LastName    =  entitiesData.entity.last_name ; 
                            if(programName == Label.Macitentan_REMS_Program_Name ||  programName == Label.PiaSky_REMS_Program_Name || programName == Label.Tryvio_REMS_Program_Name  || programName == Label.AVEED_REMS_Program_Name){ 
                                isValid = entitiesData.entity.last_name == PrescriberLName ? true :false;
                            }
                        }else if (roleStr == SYN_Utilitycls.REQUESTORTYPE_PHARMACY){
                            PharmacyInfo.PharmacyName = entitiesData.entity.corporate_name;
                            if(programName == Label.Macitentan_REMS_Program_Name ||  programName == Label.PiaSky_REMS_Program_Name || programName == Label.Tryvio_REMS_Program_Name){ 
                                isValid =   entitiesData.entity.corporate_name != null && entitiesData.entity.corporate_name != '' ? true :false;
                                //isValid =   PharmacyInfo.PharmacyName == pharmacyName ? true :false;
                            }
                        }else if(roleStr == 'HCS'){ // for individual NPI validation on HCS based on HCP NPI
                            if(entitiesData.entity.last_name != null){
                                isValid = true;
                            }
                        }     
                        
                        
                        if(entitiesData.entity.licenses!=null && !entitiesData.entity.licenses.isEmpty()){
                            for(licensesData licenseInfo: entitiesData.entity.licenses){
                                string lastNameKey = String.valueOf(entitiesData.entity.last_name) == null ? '' : String.valueOf(entitiesData.entity.last_name);
                                string keyValue = lastNameKey+String.valueOf(licenseInfo.license_number);
                                string drugschedule = String.valueOf(licenseInfo.drug_schedule);
                                string recordStatus;
                                string lastNameNPIKey;
                                if(programName == Label.Macitentan_REMS_Program_Name ||programName ==Label.PiaSky_REMS_Program_Name || programName == Label.Tryvio_REMS_Program_Name  || programName == Label.AVEED_REMS_Program_Name){
                                     recordStatus = String.valueOf(entitiesData.entity.record_state) == null ? '' : String.valueOf(entitiesData.entity.record_state);
                                }else{
                                     recordStatus = String.valueOf(entitiesData.entity.record_state) == null ? '' : String.valueOf(entitiesData.entity.record_state);

                                }
                                
                                if(programName != Label.Macitentan_REMS_Program_Name){
                                    if(Type == 'NPI'){
                                         isNPIValidation =  recordStatus == 'VALID' ? true : isNPIValidation ;
                                         isValid = isNPIValidation;

                                    }
                                    else if(Type == 'SLN'){
                                        isSLNValidation =  recordStatus == 'VALID' ? true : isSLNValidation ;
                                   }
                                   else if(Type == 'HIN'){
                                        isHINValidation =  recordStatus == 'VALID' ? true : isHINValidation ;
                                        isValid = isHINValidation;
                                   }
                                   else if(licenseInfo.type_value == 'DEA'){
                                      //isValid = (licenseInfo.type_value == 'DEA' && licenseInfo.license_status == 'A' && !string.isBlank(keyValue) && keyValue == keyStr &&(drugschedule.contains('3N') || drugschedule.contains('33N'))) ? true : isValid ;
                                      isValid = (licenseInfo.type_value == 'DEA' && licenseInfo.license_status == 'A' && !string.isBlank(keyValue) && keyValue == keyStr) ? true : isValid ;
                                      invalidDEANumber = isValid;
                                      //isSche3Validation = false;  
                                        if(isValid)
                                      {
                                          if(!drugschedule.contains('3N') && !drugschedule.contains('33N'))
                                          {
                                             isSche3Validation = true; 
                                           isValid =false;
                                            }
                                         }  
                                            if(programName == Label.Xiaflex_REMS_Program_Name){
                                                isValid = recordStatus == 'VALID' ? true : false ;
                                             }      
                                      }
                                    }
                                    if (programName == Label.Macitentan_REMS_Program_Name){
                                    if (roleStr == SYN_Utilitycls.Prescriber){
                                      //  isValid = lastNameKey == PrescriberLName ? true : false;
                                    }       
                                }

                              if(programName == Label.AVEED_REMS_Program_Name){
                                isValid = recordStatus == 'VALID' ? true : false ;
                                isNPIValidation=recordStatus =='VALID' ? true:false;
                            }
                        }
                          
                        }
                        
                        if (entitiesData.entity.addresses!=null && !entitiesData.entity.addresses.isEmpty()){
                            
                            for (addressesData addressesInfo: entitiesData.entity.addresses){
                                if(addressesInfo.nwk_primary_address == 'Y'){ 
                               if (roleStr == SYN_Utilitycls.Prescriber && addressesInfo.entity_type == 'HCP'){
                                    PrescriberInfo.StreetAddress = addressesInfo.address_line_1;
                                    PrescriberInfo.StreetAddress2 = !string.isBlank(addressesInfo.address_line_2) ? addressesInfo.address_line_2 : '';
                                    PrescriberInfo.State = addressesInfo.administrative_area_parsed;
                                    PrescriberInfo.city = addressesInfo.locality ;
                                    PrescriberInfo.postalCode = addressesInfo.postal_code_primary;
                                    PrescriberInfo.Phonenumber1 = !string.isBlank(addressesInfo.phone_1) ? addressesInfo.phone_1 : '';
                                    PrescriberInfo.fax = !string.isBlank(addressesInfo.fax_1) ? addressesInfo.fax_1 : '';
                                    break;
                                }else if (roleStr == SYN_Utilitycls.REQUESTORTYPE_PHARMACY){
                                    PharmacyInfo.StreetAddress = addressesInfo.address_line_1;
                                    PharmacyInfo.State = addressesInfo.administrative_area_parsed;
                                    PharmacyInfo.city = addressesInfo.locality ;
                                    PharmacyInfo.postalCode = addressesInfo.postal_code_primary;
                                    PrescriberInfo.fax = !string.isBlank(addressesInfo.fax_1) ? addressesInfo.fax_1 : '';
                                    PharmacyInfo.Phonenumber1 = !string.isBlank(addressesInfo.phone_1) ? addressesInfo.phone_1 : '';
                                    break;
                                }
                            }
                            }
                        }
                        
                    }
                }else {
                    if(programName == Label.PiaSky_REMS_Program_Name || programName == Label.Tryvio_REMS_Program_Name){
                        PrescriberInfo =null; 
                    }
                    if(programName == Label.AVEED_REMS_Program_Name ){  // added under BT2816-524
                        PrescriberInfo =null; 
						isValid = false;                        
                    }
                   
                }
                PresInfo = PrescriberInfo;
                PharmaInfo = PharmacyInfo;
                
            }else if(programName == Label.Xiaflex_REMS_Program_Name){
                isValid = false;
            }
        }
    }
    
    public static  prescriberInfoPrepopWrap NPIreturnValue( string NPI ){
        programName = Label.Macitentan_REMS_Program_Name;
        Id prescriberEnrolRCtypeId = mapCaseRecordTypesByDevName.get('Prescriber_enrollment').getRecordtypeId();
        caseParameterWrap cpw = new caseParameterWrap (null,NPI, '',prescriberEnrolRCtypeId);
        searchResult (CPW);
        return PresInfo;
    }    
    public static  prescriberInfoPrepopWrap NPIreturnValue_Piasky( string NPI ){
        programName =Label.PiaSky_REMS_Program_Name;
        Id prescriberEnrolRCtypeId = mapCaseRecordTypesByDevName.get('Prescriber_enrollment').getRecordtypeId();
        caseParameterWrap cpw = new caseParameterWrap (null,NPI, '',prescriberEnrolRCtypeId);
        searchResult (CPW);
        return PresInfo;
    } 

     public static  prescriberInfoPrepopWrap NPIreturnValue_Aveed( string NPI ){
        programName =Label.AVEED_REMS_Program_Name;
        Id prescriberEnrolRCtypeId = mapCaseRecordTypesByDevName.get('Prescriber_enrollment').getRecordtypeId();
        caseParameterWrap cpw = new caseParameterWrap (null,NPI, '',prescriberEnrolRCtypeId);
        searchResult (CPW);
        return PresInfo;
    } 
     public static  boolean DEAreturnValue_Aveed( string DEA,String LastName ){
        programName =Label.AVEED_REMS_Program_Name;
        Id prescriberEnrolRCtypeId = mapCaseRecordTypesByDevName.get('Prescriber_enrollment').getRecordtypeId();
        caseParameterWrap cpw = new caseParameterWrap (null,DEA, '',prescriberEnrolRCtypeId);
        cpw.NPIvalidation = false; 
       	return searchResult (cpw);
        
    } 

    public static  prescriberInfoPrepopWrap NPIreturnValue_Tryvio( string NPI ){
        programName =Label.Tryvio_REMS_Program_Name;
        Id prescriberEnrolRCtypeId = mapCaseRecordTypesByDevName.get('Prescriber_enrollment').getRecordtypeId();
        caseParameterWrap cpw = new caseParameterWrap (null,NPI, '',prescriberEnrolRCtypeId);
        searchResult (CPW);
        return PresInfo;
    }   
    
    public static  pharmacyInfoPrepopWrap PharmaNPIreturnValue( string NPI ){
        programName = Label.Macitentan_REMS_Program_Name;
        Id PharmacyEnrolRCtypeId = mapCaseRecordTypesByDevName.get('Pharmacy_Enrollment').getRecordtypeId();
        caseParameterWrap cpw = new caseParameterWrap (null,NPI, '',PharmacyEnrolRCtypeId);
        searchResult (CPW);
        return PharmaInfo;
    }    

    public static String getNPIStatusVeeva_tryvio(String searchNPIKey,String programName, String caseRecordTypeDevName){
        try{
            //this.programName = Label.Tryvio_REMS_Program_Name;
            String returnValue = '';
            Id caseRecordTypeId = mapCaseRecordTypesByDevName.get(caseRecordTypeDevName).getRecordtypeId();
            caseParameterWrap cpw = new caseParameterWrap (null,searchNPIKey, '',caseRecordTypeId);
            searchResult (CPW);
            if(caseRecordTypeDevName == 'Prescriber_enrollment') {
                returnValue = (PresInfo != NULL && PresInfo.LastName != '') ? JSON.serialize(PresInfo) : 'Failed';
            } else if(caseRecordTypeDevName == 'Outpatient_Pharmacy_Enrollment' || caseRecordTypeDevName == 'Inpatient_Pharmacy_Enrollment') {
                returnValue = (PharmaInfo != NULL && PharmaInfo.PharmacyName != '') ? JSON.serialize(PharmaInfo) : 'Failed';
            }
            return returnValue;
        }catch(Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }  
    
    public class prescriberInfoPrepopWrap{
        
        @AuraEnabled
        Public string FirstName='';
        @AuraEnabled
        Public string MiddleName='';
        @AuraEnabled
        public string LastName='';
        @AuraEnabled 
        public String StreetAddress='';
        @AuraEnabled 
        public String StreetAddress2='';
        @AuraEnabled 
        public string State='';
        @AuraEnabled 
        public string city='';
        @AuraEnabled 
        public string postalCode='';
        @AuraEnabled 
        public string Phonenumber1;
        @AuraEnabled 
        public Integer phonenumber2; 
        @AuraEnabled 
        public String fax;
        @AuraEnabled 
        public String Email;
    }
    
     public class pharmacyInfoPrepopWrap{
        
        @AuraEnabled
        Public string PharmacyName='';
        @AuraEnabled 
        public String StreetAddress='';
        @AuraEnabled 
        public string State='';
        @AuraEnabled 
        public string city='';
        @AuraEnabled 
        public string postalCode='';
        @AuraEnabled 
        public string Phonenumber1;
    }
    
    
    
    public class caseParameterWrap{
        public Id caseId;
        public String DEANumber;
        public String lastName;
        public Id recordtypeId;
        public boolean NPIvalidation=false;
        public boolean SLNvalidation=false;
        public boolean HINvalidation = false;
        public boolean HCSPresValidationFailed = false;
        public boolean Sche3validation =false;
        public String pharmacyName;
        public caseParameterWrap(Id caseId , String DEANumber ,String lastName, Id recordtypeId ){
            this.caseId = caseId;
            this.DEANumber = DEANumber;
            this.lastName = lastName;
            this.recordtypeId = recordtypeId;
        }
    }
    
    public class searchVeevaData{
        public string dataLimit;
        public string offset;
        public string totalCount;
        public string responseStatus;
        public list<searchEntitiesData> entities;
        public list<supplementalResultsData> supplementalResults;
    }
    public class searchEntitiesData{
        public string entityType;
        public string entityId;
        public entityData entity;
        public metaData metaData;
    }
    
    public class entityData{
        public string middle_name;
        public string pdrp_optout;
        public list<licensesData> licenses;
        public string me_id;
        public string record_owner_name;
        public string birth_country;
        public string record_delta_id;
        public string hcp_status;
        public string vid;
        public string type_of_practice;
        public string is_externally_mastered;
        public string master_vid;
        public list<entityCustom_keys_Data> custom_keys;
        public string last_name;
        public string ama_do_not_contact;
        public string gender;
        public string prefix;
        public string record_owner_type;
        public string kaiser;
        public string record_state;
        public string years_in_progress;
        public string grad_trg_end_date;
        public string NewAlt;
        public string specialty_1_rank;
        public string primary_country;
        public string birth_city;
        public string corporate_name;
        public string modified_date;
        public string place_of_employment;
        public string birth_state;
        public string hcp_type;
        public string specialty_1;
        public string is_veeva_master;
        public string record_version;
        public string mpa;
        public list<parent_hcosData> parent_hcos;
        public string formatted_name;
        public string ams_id;
        public string status_update_time;
        public list<addressesData> addresses;
        public string entity_is_third_party_master_for_search_only;
        public string fellow;
        public string birth_year;
        public string created_date;
        public string grad_training;
        public string education_level;
        public string first_name;
        public string medical_degree_1;
        public string upin;
        
    }
    
    public class metaData{
        public string highlights;
        public string highlightTerms;
        public string vid;
        public string relevance;
    }
    
    public class licensesData{
        Public string is_veeva_master;
        Public string initial_board_license_date;
        Public string license_degree;
        Public string record_owner_name;
        Public string record_delta_id;
        Public string license_number;
        Public string dea_business_activity_code;
        public string license_subtype;
        Public string license_eligibility;
        Public string is_externally_mastered;
        Public string vid;
        Public list<entityCustom_keys_Data> custom_keys;
        public string entity_type;
        Public string type_value;
        Public string type;
        Public string grace_period;
        Public string record_owner_type;
        Public string body;
        Public string license_status_condition;
        Public string status_update_time;
        Public string rxa_eligible;
        Public string record_state;
        Public string expiration_date;
        Public string primary_license;
        Public string created_date;
        Public string best_state_license;
        Public string modified_date;
        Public string license_status;
        Public string entity_vid;
        Public string drug_schedule;
    }
    
    public class entityCustom_keys_Data{
        public string custom_key_entity_type;
        public string custom_key_item_type;
        public string status_update_time;
        public string custom_key_value;
        public string custom_key_entity_id;
        public string modified_date;
        public string custom_key_status;
        public string custom_key_vid_key;
        public string created_date;
        public string vid;
        public string custom_key_source_type;
        
    }
    
    public class addressesData{
        public string address_status;
        public string record_delta_id;
        public string dpv_confirmed_indicator;
        public string record_owner_name;
        public string entity_type;
        public string formatted_address;
        public string delivery_address_1;
        public string cbsa;
        public string thoroughfare_name;
        public string address_type;
        public string thoroughfare_trailing_type;
        public string is_externally_mastered;
        public string locality;
        public string vid;
        public list<entityCustom_keys_Data> custom_keys;
        public string postal_code;
        public string ISO_3166_n;
        public string postal_code_secondary;
        public string thoroughfare;
        public string record_state;
        public string record_owner_type;
        public string sub_administrative_area;
        public string modified_date;
        public string entity_vid;
        public string address_line_1;
        public string address_line_2;
        public string administrative_area;
        public string administrative_area_parsed;
        public string country;
        public string premise;
        public string premise_number;
        public string delivery_address;
        public string ISO_3166_3;
        public string is_veeva_master;
        public string sub_building_number;
        public string sub_building;
        public string postal_code_primary;
        public string sub_building_type;
        public string address_ordinal;
        public string status_update_time;
        public string latitude;
        public string address_verification_status;
        public string created_date;
        public string longitude;
        public string phone_1;
        public string fax_1;
        public string nwk_primary_address;
    }
    
    public class supplementalResultsData{
        public string specialty_1;
        public string hco_type;
        public string master_vid;
        public string record_owner_type;
        public string lab_services;
        public string hco_status;
        public string accept_medicare;
        public string record_delta_id;
        public string record_owner_name;
        public string kaiser;
        public string primary_country;
        public string top_parent;
        public string created_date;
        public string training_facility;
        public string is_veeva_master;
        public string va_dod_affiliated;
        public string major_class_of_trade;
        public string ama_do_not_contact;
        public string corporate_name;
        public string status_update_time;
        public string modified_date;
        public string accept_medicaid;
        public string record_state;
        public string candidate_record;
        public string record_version;
        public string vid;
        public string is_externally_mastered;
        public string xray_services;
        public string roster_date;
        public list<entityCustom_keys_Data> custom_keys;
        public list<licensesData> licenses;
        public list<addressesData> addresses;
        public list<parent_hcosData> parent_hcos;
    }
    
    public class parent_hcosData{
        public string parent_hco_vid;
        public string related_entity_type;
        public string record_owner_type;
        public string relationship_type;
        public string status_update_time;
        public string record_delta_id;
        public string entity_type;
        public string hierarchy_type;
        public string record_owner_name;
        public string modified_date;
        public string record_state;
        public string parent_hco_status;
        public string is_primary_relationship;
        public string vid;
        public string entity_vid;
        public string is_externally_mastered;
        public string created_date;
        public string nwk_primary_relationship;
        public string is_veeva_master;
        public list<entityCustom_keys_Data> custom_keys;
    }
}