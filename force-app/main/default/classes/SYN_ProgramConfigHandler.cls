public class SYN_ProgramConfigHandler {
    public static final string Rule3_error_message ='The selected participant\'s Participant Account Creation Service is not Closed. Please close the service to proceed.';
    public static final string Rule2_error_message_prefix ='The selected participant has an open ';
    public static final string Rule2_error_message_sufix =' Please update the existing service to proceed.';
    public static final string enrollment_error_message ='The selected participant has previously been enrolled. Please create a reenrollment service to process your request.';
    public static final string program_name='Sodium Oxybate REMS';
   
    public static Map<Id,String> accountstatusMap=new Map<Id,String>();
    
    public static void validateBusinessRule( Map<Id, List<US_WSREMS__REMS_Service_Summary__c>> serviceRecords,Map<Id, String> rectypeIdAndNameMap){
        //Getting the custom metadata configuration
        Map<String,ProgramConfigValidation__mdt> pogramConfigMap =new Map<String,ProgramConfigValidation__mdt>();
        List<ProgramConfigValidation__mdt> programConfig = [SELECT RecordTypeName__c,Program_Name__r.Label,Program_Name__r.developerName,CheckParticipantAccountClosure__c,AllowMultipleOpenService__c,AllowedAccountStatus__c,AccountStatusErrorMessage__c,MasterLabel FROM ProgramConfigValidation__mdt where Program_Name__r.Label=:program_name ];
        for(ProgramConfigValidation__mdt programConfigmdt : programConfig){
            pogramConfigMap.put(programConfigmdt.RecordTypeName__c,programConfigmdt);
        }
        
        List<US_WSREMS__REMS_Service_Summary__c> finalListService=new List<US_WSREMS__REMS_Service_Summary__c>();
        List<Id> participantIdList =new List<Id>();
        List<String> servicerecordTypes=new List<String>();
        for(Id recordTypeId :serviceRecords.keyset()){
            if(pogramConfigMap.get(rectypeIdAndNameMap.get(recordTypeId))!=null){//to avoid other services getting in to the loop,Only executed for services which are configured.
                for(US_WSREMS__REMS_Service_Summary__c servicerec:serviceRecords.get(recordTypeId) ){
                   
                    participantIdList.add(servicerec.US_WSREMS__Participant__c);// getting all accountIds
                    finalListService.add(servicerec); //getting all Services
                    servicerecordTypes.add(rectypeIdAndNameMap.get(recordTypeId));//getting recordtypes.
                }
            } 
        }
        
        if(participantIdList!=null && !participantIdList.isEmpty()) {
            
            Map<Id, Map<string,List<US_WSREMS__REMS_Service_Summary__c>>> serviceAccountMap =checkPatientAccountServiceStatus(participantIdList,servicerecordTypes);
            if(finalListService != null && (!finalListService.isEmpty()) && (serviceAccountMap !=null) && (!serviceAccountMap.isEmpty()) ){
                for(US_WSREMS__REMS_Service_Summary__c remsservice : finalListService){
                    
                    if(serviceAccountMap.get(remsservice.US_WSREMS__Participant__c) != null){
                        
                        
                        //Rule1 validation
                        ProgramConfigValidation__mdt programValidationConfig = pogramConfigMap.get(rectypeIdAndNameMap.get(remsservice.RecordTypeId));
                        if(programValidationConfig.AllowedAccountStatus__c != null){
                            //Rule1 If
                            List<String> allowedstatus =programValidationConfig.AllowedAccountStatus__c.split(',');
                            if(accountstatusMap.get(remsservice.US_WSREMS__Participant__c) !=null && allowedstatus.contains(accountstatusMap.get(remsservice.US_WSREMS__Participant__c))){
                                //Rule 2 validation
                                if(!programValidationConfig.AllowMultipleOpenService__c){
                                    //Rule2 validation -When we are restricting Multiple open services.
                                    Map<string,List<US_WSREMS__REMS_Service_Summary__c>> recordtypenameservice = serviceAccountMap.get(remsservice.US_WSREMS__Participant__c);
                                   boolean status= allowedMultipleOpenServices(recordtypenameservice,remsservice,rectypeIdAndNameMap.get(remsservice.RecordTypeId));
                                    
                                    //Rule 3 validation- Closure of Participant Account
                                    if(status){
                                    if(programValidationConfig.CheckParticipantAccountClosure__c){
                                        //If we have Closure of Participant Account creation validation
                                        Map<string,List<US_WSREMS__REMS_Service_Summary__c>> recordtypenameservice_pac = serviceAccountMap.get(remsservice.US_WSREMS__Participant__c);
                                        allowedMultipleOpenServices(recordtypenameservice_pac,remsservice,'Participant_Account_Creation');
                                        
                                    }
                                    }    
                                    
                                }else{
                                    //If we don't have rule 2 validation-When we are not restricting Multiple open services.
                                    
                                    //Rule 3 validation
                                    
                                    if(programValidationConfig.CheckParticipantAccountClosure__c){
                                        //If we have Closure of Participant Account creation validation
                                        Map<string,List<US_WSREMS__REMS_Service_Summary__c>> recordtypenameservice_pac = serviceAccountMap.get(remsservice.US_WSREMS__Participant__c);
                                        allowedMultipleOpenServices(recordtypenameservice_pac,remsservice,'Participant_Account_Creation');
                                        
                                    }
                                }
                            }else{
                                //Rule 1 error case
                                remsservice.addError(programValidationConfig.AccountStatusErrorMessage__c);
                            }
                            
                            
                        }else{
                            //If we don't have rule 1 validation
                            
                            //Rule 2 validation
                            if(!programValidationConfig.AllowMultipleOpenService__c){
                                //Rule2 validation -When we are restricting Multiple open services.
                               // Map<string,List<US_WSREMS__REMS_Service_Summary__c>> recordtypenameservice =serviceAccountMap.get(remsservice.US_WSREMS__Participant__c) ;
                               //remsservice.addError('Test');
                                  boolean status= allowedMultipleOpenServices(serviceAccountMap.get(remsservice.US_WSREMS__Participant__c),remsservice,rectypeIdAndNameMap.get(remsservice.RecordTypeId));
                                
                                //Rule 3 validation- Closure of Participant Account
                                if(status){
                                if(programValidationConfig.CheckParticipantAccountClosure__c){
                                    //If we have Closure of Participant Account creation validation
                                    //Map<string,List<US_WSREMS__REMS_Service_Summary__c>> recordtypenameservice_pac = serviceAccountMap.get(remsservice.US_WSREMS__Participant__c);
                                    allowedMultipleOpenServices(serviceAccountMap.get(remsservice.US_WSREMS__Participant__c),remsservice,'Participant_Account_Creation');
                                    
                                }
                                }
                                
                            }else{
                                //If we don't have rule 2 validation-When we are not restricting Multiple open services.
                                
                                //Rule 3 validation
                                
                                if(programValidationConfig.CheckParticipantAccountClosure__c){
                                    //If we have Closure of Participant Account creation validation
                                    Map<string,List<US_WSREMS__REMS_Service_Summary__c>> recordtypenameservice_pac = serviceAccountMap.get(remsservice.US_WSREMS__Participant__c);
                                    allowedMultipleOpenServices(recordtypenameservice_pac,remsservice,'Participant_Account_Creation');
                                    
                                }
                            }
                            
                        } 
                        
                    }
                }
            }
        }
     
    }
    
    //Rule 2,3 Validation (If we are not allowing multiple open services)
    public static boolean allowedMultipleOpenServices( Map<string,List<US_WSREMS__REMS_Service_Summary__c>> recordtypenameservice,US_WSREMS__REMS_Service_Summary__c remsservice,String recordtypedeveloperName){
        
        if(recordtypenameservice.get(recordtypedeveloperName) !=null && recordtypenameservice.get(recordtypedeveloperName).size()>0){
            //For Enrollment even if the service is closed we have to through error.
            for(US_WSREMS__REMS_Service_Summary__c service:recordtypenameservice.get(recordtypedeveloperName)){
                if(service.US_WSREMS__Status__c == null || service.US_WSREMS__Status__c =='Open'){
                    if(recordtypedeveloperName != 'Participant_Account_Creation'){
                        if(recordtypedeveloperName != 'Pre_Dispense_Authorization'){
                           remsservice.addError(Rule2_error_message_prefix+recordtypedeveloperName.replaceAll('_', ' ') +' service.'+Rule2_error_message_sufix);  
                        }else{
                            remsservice.addError(Rule2_error_message_prefix+'REMS Dispense Authorization' +' service.'+Rule2_error_message_sufix);
                        }
                          
                         
                       return false;
                       
                    }
                    else if(recordtypedeveloperName == 'Participant_Account_Creation'){
                      
                         remsservice.addError(Rule3_error_message);
                       
                        return false;  
                        
                    } 
                   
                }
                 if(service.US_WSREMS__Status__c =='Closed' && service.US_WSREMS__Service_Outcome__c =='Successful'){
                      
                        if(recordtypedeveloperName =='Enrollment'){
                             remsservice.addError(enrollment_error_message);
                             return false;
                        } 
                    }
                
              
            }
            
        }
        return true;
    }
    
    public static  Map<Id, Map<string,List<US_WSREMS__REMS_Service_Summary__c>>> checkPatientAccountServiceStatus(List<Id> participantIdList,List<string> servicerecordtypeName){
        List<String> recordtypeNames=new List<String>();
        recordtypeNames.add('Participant_Account_Creation');
        recordtypeNames.addAll(servicerecordtypeName);
        Map<Id, Map<string,List<US_WSREMS__REMS_Service_Summary__c>>> serviceMap=new Map<Id,Map<String,List<US_WSREMS__REMS_Service_Summary__c>>>();
        List<Account> account_list=[select id,Name,US_WSREMS__Status__c,(select id,Name,US_WSREMS__Status__c,US_WSREMS__Service_Outcome__c,RecordType.developerName from US_WSREMS__Participants__r where RecordType.developerName IN :recordtypeNames) from Account where id IN:participantIdList];
        for(Account acc : account_list){
            accountstatusMap.put(acc.id,acc.US_WSREMS__Status__c);
            Map<string,List<US_WSREMS__REMS_Service_Summary__c>> recordtypeservicemap=new Map<string,List<US_WSREMS__REMS_Service_Summary__c>>();
            for(US_WSREMS__REMS_Service_Summary__c serviceRec:acc.US_WSREMS__Participants__r){
                if(recordtypeservicemap.containsKey(serviceRec.RecordType.developerName)){
                    List<US_WSREMS__REMS_Service_Summary__c> existingList =recordtypeservicemap.get(serviceRec.RecordType.developerName);
                    existingList.add(serviceRec);
                    recordtypeservicemap.put(serviceRec.RecordType.developerName,existingList);
                }else{
                    List<US_WSREMS__REMS_Service_Summary__c> newList=new List<US_WSREMS__REMS_Service_Summary__c>();
                    newList.add(serviceRec);
                    recordtypeservicemap.put(serviceRec.RecordType.developerName,newList);
                }
            }
            serviceMap.put(acc.Id,recordtypeservicemap);
        }
        
        return serviceMap;
        
    }
    
}