/************************************************************************** 
    * Name :   SYN_CommonUtility   
      
    Modification Log:  
    ----------------------------------------------------------------------------------  
    Developer               Date                   Description  
    ----------------------------------------------------------------------------------- 
                                                  Initial Version  
    Praveen Vellanki       09/21/2022             MACI - 7433 - 41: Code addition/updation as below:  
                                                  New Change: Line 130: getCurrnetUserActivePrograms() - limit 1 for the query filter has been added.  
    
*********************************************************************************/
public class SYN_CommonUtility{
    
    public static Map<String, BusinessHours> businessHoursRecMap = new Map<String, BusinessHours>();
    public static List<Boolean> businessDay = new Boolean[7];
    public static Map<String, Time> startHours = new Map<String, Time>();
    public static Map<String, Time> endHours = new Map<String, Time>();
   
    public static Id staticSOXProgramId;
    public static Id staticPiaSkyProgramId;//116
    public static Id staticMACIProgramId;
    public static Map<Id,String> staticActiveProgramIdAndNameMap = new Map<Id,String>();
    public static Map<String,US_WSREMS__REMS_Program__c> staticActiveProgramIdAndRecordMap = new Map<String,US_WSREMS__REMS_Program__c>();
    
    public static String getBusinessHoursId(String name){
        
        List<BusinessHours> businessHoursList = [SELECT Id FROM BusinessHours WHERE IsActive = TRUE AND Name =: name LIMIT 1 ];
        if(!businessHoursList.isEmpty()){
            
            return businessHoursList[0].Id;
        }
        return '';
    }
    
    public static Map<String, Long> calculateBusinessHours(String businessHoursId, DateTime dtVal1, DateTime dtVal2){
        
        Long result = BusinessHours.diff(businessHoursId, dtVal1, dtVal2);
        Long milliseconds = result;
        Long mins = milliseconds / 60000;
        Long hours = mins / 60;
        Long remainingMins = mins - (hours * 60);
                
        Map<String, Long> timeElementsMap = new Map<String, Long>{
            'hours' => hours,
            'mins'  => remainingMins
        };                                  
        return timeElementsMap; 
    }
     public static Double calculateHours(String businessHoursId, DateTime dtVal1, DateTime dtVal2){
        
        Long result = BusinessHours.diff(businessHoursId, dtVal1, dtVal2);
        Double res= (result/3600000);
        return res; 
    }
    
    public static BusinessHours getBusinessDaysAndTime(String businessHourName) {
        
        if(!businessHoursRecMap.containsKey(businessHourName)){
            BusinessHours bh = [SELECT Id,
                SundayStartTime, MondayStartTime, TuesdayStartTime,
                WednesdayStartTime, ThursdayStartTime, FridayStartTime,
                SaturdayStartTime, SundayEndTime, MondayEndTime,TuesdayEndTime,
                WednesdayEndTime, ThursdayEndTime, FridayEndTime,SaturdayEndTime
                FROM  BusinessHours 
                WHERE isActive = true AND Name =: businessHourName
            ];
            businessHoursRecMap.put(businessHourName, bh);
        }
        
        return businessHoursRecMap.get(businessHourName);
     }
     
     public static Map<String, Time> getBusinessStartHours(String businessHourName) {
        
        BusinessHours bh = getBusinessDaysAndTime(businessHourName); 
        startHours.put('Sun', bh.SundayStartTime);
        startHours.put('Mon', bh.MondayStartTime);
        startHours.put('Tue', bh.TuesdayStartTime);
        startHours.put('Wed', bh.WednesdayStartTime);
        startHours.put('Thu', bh.ThursdayStartTime);
        startHours.put('Fri', bh.FridayStartTime);
        startHours.put('Sat', bh.SaturdayStartTime);
        return startHours;
     }
     
     public static Map<String, Time> getBusinessEndHours(String businessHourName) {
        
        BusinessHours bh = getBusinessDaysAndTime(businessHourName); 
        endHours.put('Sun', bh.SundayEndTime);
        endHours.put('Mon', bh.MondayEndTime);
        endHours.put('Tue', bh.TuesdayEndTime);
        endHours.put('Wed', bh.WednesdayEndTime);
        endHours.put('Thu', bh.ThursdayEndTime);
        endHours.put('Fri', bh.FridayEndTime);
        endHours.put('Sat', bh.SaturdayEndTime);        
        return endHours;
     }
        public static List<Id> getUserFromPG(String PGname){
        List<Id> userIdList = new List<Id>();
        List<group> publicGroupId = [select Id from group where DeveloperName =:PGname and type ='Regular' limit 1];
        for (GroupMember GM : [select  UserOrGroupId  from GroupMember where GroupId =:publicGroupId[0].Id ]){
            if (String.valueOf(GM.UserOrGroupId).startswith('005')){
                userIdList.add(GM.UserOrGroupId);
            }
        }
        
        return userIdList;
    }
    
      public static List<Id> getUserFromQueue(String Queuename){
        List<Id> userIdList = new List<Id>();
        List<group> QueueId = [select Id from group where DeveloperName =:Queuename and type ='Queue' limit 1];
        for (GroupMember GM : [select  UserOrGroupId  from GroupMember where GroupId =:QueueId[0].Id ]){
            if (String.valueOf(GM.UserOrGroupId).startswith('005')){
                userIdList.add(GM.UserOrGroupId);
            }
        }
        
        return userIdList;
    }

    public static Map<String, SYN_Credentials__mdt> apiAndCredentialMap = new Map<String, SYN_Credentials__mdt>();
    public static SYN_Credentials__mdt getCredentials(String name){
        
        if(!apiAndCredentialMap.containsKey(name)){
            
            for(SYN_Credentials__mdt credentials : [SELECT Id, API_Name__c, Endpoint_URL__c, Password__c, SessionId__c, SessionId_Updated_Time__c, Username__c FROM SYN_Credentials__mdt]){
                
                apiAndCredentialMap.put(credentials.API_Name__c, credentials);
            }
        }
        
        if(apiAndCredentialMap.containsKey(name)){
            
            return apiAndCredentialMap.get(name);
        }else{
            
            return new SYN_Credentials__mdt();
        }   
    }

    //Get RecordTypeId by DeveloperName
    public static Id getRecordTypeIdbyDeveloperName(String objectName, String strRecordTypeName)
    {
        Map<String,Id> recordTypeMap = REMSUtility.retrieveRecTypeDeveloperNameId_Product(objectName);
        return recordTypeMap.get(strRecordTypeName);
        //return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(strRecordTypeName).getRecordTypeId();
    }
  
  
  /***********************************************************************************
  Method Name: getCurrnetUserActivePrograms
  description: return the current user porgram
    ************************************************************************************/
    Public static list<US_WSREMS__Program_Users__c> getCurrnetUserActivePrograms(){
    
      return [SELECT Id,US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.Name,US_WSREMS__User__c FROM US_WSREMS__Program_Users__c WHERE US_WSREMS__Is_Active__c = true AND US_WSREMS__User__c = : UserInfo.getUserId() AND US_WSREMS__REMS_Program__r.US_WSREMS__Status__c = 'Active' limit 1];
       
    }
  
  
  /***********************************************************************************
   Method Name: getActivePrograms
  description: return the All Active programs 
    ************************************************************************************/
    public static Map<Id,String> getActivePrograms(){
       if(staticActiveProgramIdAndNameMap.size() == 0) {
           Map<Id,String> programMap = new Map<Id,String>();
           for(US_WSREMS__REMS_Program__c rems : [SELECT Id, Name FROM US_WSREMS__REMS_Program__c WHERE US_WSREMS__Status__c =: 'Active' LIMIT 49999]){
               programMap.put(rems.Id, rems.Name);
           }
           staticActiveProgramIdAndNameMap = programMap; 
       }
       return staticActiveProgramIdAndNameMap;
    }
    public static Map<string,string> getObjectFieldValues(SObject source){
        Id prescriberEnrollCaseRecTypeId = getRecordTypeIdbyDeveloperName('Case', 'Prescriber_enrollment');
        Id nonComplianceCaseRecTypeId = getRecordTypeIdbyDeveloperName('Case', 'Non_Compliance');
        Id changeAuthRepRecTypeId = getRecordTypeIdbyDeveloperName('Case', 'Change_Authorized_Representative');
         
        Map<string,string> fieldValueMap = new Map<string,string>();  
        Id myId = source.Id;  
        string programName;
        String sObjName;
        String prescriberFaxAccValue;  
        String authRepEmail;
        String prescriberFax;
        String prescriberEmail;
        String authRepFax;
        String authRepNameValue;
        Id authRepId;
        Id prescriberId;
        Id authRepTargetObjectIdVal;
        Id prescribertargetObjectIdVal;
        String participantNameVal;
        SObjectType ObjectName = source.getSObjectType();  
        if(myId != Null ){
            sObjName = myId.getSObjectType().getDescribe().getName();
        }
          
        if(sObjName == 'Case' || String.valueOf(ObjectName) == 'Case'){  
            case cs = (case) source; 
            if(cs.Status =='Draft' && cs.US_WSREMS__Program_Name__c == 'Macitentan REMS' && cs.RecordTypeId == prescriberEnrollCaseRecTypeId){
                prescriberFaxAccValue=cs.US_WSREMS__Fax__c;
            }else{
            prescriberFaxAccValue = cs.SYN_Prescriber__r.Fax;
            } 

            Id RecordTypeId = cs.RecordTypeId;  
            authRepEmail = cs.SYN_Authorized_Rep__r.US_WSREMS__Email__c; 
            prescriberFax = cs.SYN_Prescriber_Fax__c;  
            String faxNumber = cs.US_WSREMS__Participant__r.Fax;
            String patientFax = cs.US_WSREMS__Patient__r.Fax; 
            String pharmacistFax = cs.US_WSREMS__Pharmacy_User__r.Fax; 
            participantNameVal = cs.US_WSREMS__Participant__r.firstName + cs.US_WSREMS__Participant__r.LastName; 
            String patientNameVal = cs.US_WSREMS__Patient__r.firstName + cs.US_WSREMS__Patient__r.LastName; 
            String pharmacistNameVal = cs.US_WSREMS__Pharmacy_User__r.firstName + cs.US_WSREMS__Pharmacy_User__r.LastName;  
            String email = cs.US_WSREMS__Participant__r.US_WSREMS__Email__c;
            prescriberEmail = cs.SYN_Prescriber__r.US_WSREMS__Email__c;
            string caseEmail =cs.US_WSREMS__Email__c;
            string caseFax = cs.US_WSREMS__Fax__c;
            Id participantId = cs.US_WSREMS__Participant__c;
            prescriberId = cs.SYN_Prescriber__c;  
            authRepId = cs.SYN_Authorized_Rep__c;
            Id targetObjectIdVal = cs.US_WSREMS__Participant__r.personContactId;  
            authRepTargetObjectIdVal = cs.SYN_Authorized_Rep__r.personContactId;
            String distrbAuthrepEmail = cs.US_WSREMS__Distributor__r.US_WSREMS__Email__c;
            prescribertargetObjectIdVal = cs.SYN_Prescriber__r.personContactId;
            Id nameOfReportertargetObjectIdVal = cs.SYN_Name_of_Reporter__r.personContactId;
            String NameOfReporterFax = cs.SYN_Name_of_Reporter__r.Fax;
            String pharmacyPartipEmail = cs.X1_Pharmacy_Participant__r.US_WSREMS__Email__c;
            Id PharmacyParticipantId = cs.X1_Pharmacy_Participant__c;
            String pharmacistEmail = cs.SYN_Pharmacist__r.US_WSREMS__Email__c; 
            String rmrReporterEmail = cs.SYN_Name_of_Reporter__r.US_WSREMS__Email__c; 
            
            if(cs.US_WSREMS__Program_Name__c == SYN_Utilitycls.AVEED_PROGRAM_NAME || cs.US_WSREMS__Program_Name__c == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME){
                prescriberId = cs.US_WSREMS__Participant__c;
                prescriberEmail = cs.US_WSREMS__Participant__r.US_WSREMS__Email__c;
                prescriberFax = cs.US_WSREMS__Participant__r.Fax; 
                prescribertargetObjectIdVal = cs.US_WSREMS__Participant__r.personContactId;
                participantNameVal = cs.US_WSREMS__Participant__r.Name;
                if(cs.RecordTypeId == nonComplianceCaseRecTypeId) {
                    if(cs.US_WSREMS__X1_Participant__r.RecordTypeId == AVEEDAutomationCommunicationUtility.hcsRecordType){
                        if(SYN_SOXCorrespondenceHandler.accountIdToaffiliationMap.containsKey(cs.US_WSREMS__X1_Participant__c)){
                            US_WSREMS__Affiliation__c affiliationRecord  = SYN_SOXCorrespondenceHandler.accountIdToaffiliationMap.get(cs.US_WSREMS__X1_Participant__c);
                            authRepNameValue = affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c;
                            authRepId = affiliationRecord.US_WSREMS__Authorized_Representative__c;
                            authRepEmail = affiliationRecord.US_WSREMS__Authorized_Representative__r.PersonEmail;
                            authRepFax = affiliationRecord.US_WSREMS__Authorized_Representative__r.Fax;
                            authRepTargetObjectIdVal = affiliationRecord.US_WSREMS__Authorized_Representative__r.personContactId;
                            prescriberId = cs.US_WSREMS__X1_Participant__c;
                        }
                    } else {
                        prescriberId = cs.US_WSREMS__X1_Participant__c;
                        prescriberEmail = cs.US_WSREMS__X1_Participant__r.US_WSREMS__Email__c;
                        prescriberFax = cs.US_WSREMS__X1_Participant__r.Fax; 
                        prescribertargetObjectIdVal = cs.US_WSREMS__X1_Participant__r.personContactId;
                        participantNameVal = cs.US_WSREMS__X1_Participant__r.Name;
                    }
                } else if(cs.RecordTypeId == changeAuthRepRecTypeId){
                    authRepNameValue = cs.US_WSREMS__First_Name_New_Primary_AR__c + cs.US_WSREMS__Last_Name_New_Primary_AR__c;
                    authRepId = cs.US_WSREMS__Authorized_Representative_New_Primary_AR__c;
                    authRepEmail = cs.US_WSREMS__AR_Email_New_Primary_AR__c;
                    authRepFax = cs.US_WSREMS__AR_Fax_New_Primary_AR__c;
                    authRepTargetObjectIdVal = cs.US_WSREMS__Authorized_Representative_New_Primary_AR__r.personContactId;
                } else {
                    authRepNameValue = cs.US_WSREMS__First_Name_ar__c + cs.US_WSREMS__Last_Name_ar__c;
                    authRepId = cs.US_WSREMS__REMS_Authorized_Rep__c;
                    authRepEmail = (cs.US_WSREMS__REMS_Authorized_Rep__c != null && cs.US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c != null) ? cs.US_WSREMS__REMS_Authorized_Rep__r.US_WSREMS__Email__c : cs.US_WSREMS__Email_ar__c;
                    authRepFax = cs.US_WSREMS__REMS_Authorized_Rep__r.Fax;
                    authRepTargetObjectIdVal = cs.US_WSREMS__REMS_Authorized_Rep__r.personContactId;
                }
            } 
            fieldValueMap.put('prescriberFaxAccValue',prescriberFaxAccValue);  
            fieldValueMap.put('RecordType',RecordTypeId);  
            fieldValueMap.put('TargetObjectId', targetObjectIdVal);   
            fieldValueMap.put('USREMSPROGNAME',cs.US_WSREMS__Program_Name__c);  
            fieldValueMap.put('ownerId',cs.OwnerId);  
            fieldValueMap.put('participantFax',faxNumber);
            fieldValueMap.put('caseEmail',caseEmail);
            fieldValueMap.put('caseFax',caseFax);
            fieldValueMap.put('patientFax',patientFax); 
            fieldValueMap.put('prescriberFax', prescriberFax); 
            fieldValueMap.put('participantNameVal',participantNameVal); 
            fieldValueMap.put('patientNameVal',patientNameVal); 
            fieldValueMap.put('pharmacistNameVal',pharmacistNameVal);  
            fieldValueMap.put('EmailAddress', email);
            fieldValueMap.put('prescriberEmail', prescriberEmail);  
            fieldValueMap.put('caseRecordTypeId', RecordTypeId);  
            fieldValueMap.put('participantId', participantId);
            //why this is cs.Id? instead of SYN_Prescriber__c?
            fieldValueMap.put('whatId', cs.Id); 
            fieldValueMap.put('prescriberId', cs.Id);  
            fieldValueMap.put('AuthRepEmailId', authRepEmail);  
            fieldValueMap.put('AuthRepAccountId', authRepId);  
            fieldValueMap.put('AuthRepTargetObjId', authRepTargetObjectIdVal);
            fieldValueMap.put('prescribertargetObjectIdVal', prescribertargetObjectIdVal);
            fieldValueMap.put('distrbAuthrepEmail', distrbAuthrepEmail);
            fieldValueMap.put('pharmacyPartipEmail', pharmacyPartipEmail); 
            fieldValueMap.put('PharmacyParticipantId', PharmacyParticipantId);
            fieldValueMap.put('pharmacistEmail', pharmacistEmail);
            fieldValueMap.put('rmrReporterEmail', rmrReporterEmail);
            fieldValueMap.put('nameOfReportertargetObjectIdVal', nameOfReportertargetObjectIdVal); 
            fieldValueMap.put('NameOfReporterFax', NameOfReporterFax); 
            fieldValueMap.put('authRepNameValue', authRepNameValue);
            fieldValueMap.put('participantid', prescriberId);  
            fieldValueMap.put('authRepFax', authRepFax);  
            return fieldValueMap;  
        }  
        if(sObjName == 'Account'){  
            Account accountRec = (Account) source; 
            String authRepName;
            String authRepFaxValue;
            String prescriberName;
            Id authRepTargetObjectIdValue;
            if(accountRec.US_WSREMS__Program_Name__c == SYN_Utilitycls.AVEED_PROGRAM_NAME || accountRec.US_WSREMS__Program_Name__c == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME){
                prescriberFax = accountRec.Fax; 
                prescriberName = accountRec.US_WSREMS__First_And_Last_Name__c;
                prescriberId = accountRec.Id; 
                if(SYN_SOXCorrespondenceHandler.accountIdToaffiliationMap.containsKey(accountRec.Id)){
                    US_WSREMS__Affiliation__c affiliationRecord = SYN_SOXCorrespondenceHandler.accountIdToaffiliationMap.get(accountRec.Id);
                    authRepName = affiliationRecord.US_WSREMS__Authorized_Representative__r.US_WSREMS__First_And_Last_Name__c;
                    authRepFaxValue = affiliationRecord.US_WSREMS__Authorized_Representative__r.Fax;
                    authRepTargetObjectIdValue = affiliationRecord.US_WSREMS__Authorized_Representative__r.personContactId;
                }
                fieldValueMap.put('AuthRepTargetObjId', authRepTargetObjectIdValue);
                fieldValueMap.put('prescribertargetObjectIdVal', String.valueof(source.get('personContactId')));
                fieldValueMap.put('USREMSPROGNAME', String.valueof(source.get('US_WSREMS__Program_Name__c'))); 
                fieldValueMap.put('ownerId',String.valueof(source.get('ownerId')));  
                fieldValueMap.put('authRepFax',authRepFaxValue);  
                fieldValueMap.put('authRepNameValue',authRepName);
                fieldValueMap.put('participantid', prescriberId);
                fieldValueMap.put('prescriberFax', prescriberFax); 
                fieldValueMap.put('participantNameVal',prescriberName);   
                
                //Xiaflex HCP and HCS update affiliation notification
                if( accountRec.US_WSREMS__Program_Name__c == SYN_Utilitycls.XIAFLEX_PROGRAM_NAME && SYN_SOXCorrespondenceHandler.affiliationFirstAndLastReferenceMap.containsKey(accountRec.Id) ) {
                    Map<String, String> firstAndLastRefMap = SYN_SOXCorrespondenceHandler.affiliationFirstAndLastReferenceMap.get(accountRec.Id);
                    if( firstAndLastRefMap.containsKey('First') ){
                        fieldValueMap.put('affiliationStartName', firstAndLastRefMap.get('First')); 
                    }
                    
                    if( firstAndLastRefMap.containsKey('Last') ){
                        fieldValueMap.put('affiliationEndName',firstAndLastRefMap.get('Last'));
                    }

                    if( firstAndLastRefMap.containsKey('AccountRecordType') ){
                        fieldValueMap.put('accountRecordType',firstAndLastRefMap.get('AccountRecordType'));
                    }
                }

            } else {
                fieldValueMap.put('TargetObjectId', String.valueof(source.get('personContactId')));  
                fieldValueMap.put('USREMSPROGNAME',String.valueof(source.get('Program_Name__c'))); 
                fieldValueMap.put('ownerId',String.valueof(source.get('ownerId')));  
                fieldValueMap.put('FaxNumber',String.valueOf(Source.get('Fax')));  
                fieldValueMap.put('Name',String.valueOf(Source.get('Name')));  
            }  
            return fieldValueMap;
        }  
        
        return null;  
    }    
    public static portalSharingData PSD = new portalSharingData();
    public static portalSharingData portalSharingInfo(){
          if(SYN_CommonUtility.PSD != NULL && SYN_CommonUtility.PSD.ProgramNameAndAccMap != NULL && SYN_CommonUtility.PSD.accNameAndRecordMap != NULL){
           return SYN_CommonUtility.PSD;
       }        
        Set<String> protalSharingPrms = new Set<String>{
            'Sodium Oxybate REMS','Macitentan REMS'
        };
        Map<String, String> programNameAndAccountMap = new Map<String, String>();
        for(US_WSREMS__Program_Configuration__mdt  programConfigRecord : [SELECT Id, MasterLabel, US_WSREMS__Portal_Sharing_Account__c FROM US_WSREMS__Program_Configuration__mdt WHERE MasterLabel IN: protalSharingPrms LIMIT 5000]){        
            
            programNameAndAccountMap.put(programConfigRecord.MasterLabel, programConfigRecord.US_WSREMS__Portal_Sharing_Account__c);
        }
        
        Map<String, Account> accountNameAndRecMap = new Map<String, Account>();
        if(!programNameAndAccountMap.isEmpty()){
        
            for(Account portalSharingAcc: [SELECT id, Name FROM Account WHERE Name IN: programNameAndAccountMap.values()]){
                
                accountNameAndRecMap.put(portalSharingAcc.Name, portalSharingAcc);
            }
        }
        SYN_CommonUtility.PSD.ProgramNameAndAccMap = programNameAndAccountMap;
        SYN_CommonUtility.PSD.accNameAndRecordMap = accountNameAndRecMap;
        return SYN_CommonUtility.PSD;
    }
    public static Id SOXprogramId (){

        if(SYN_CommonUtility.staticSOXProgramId == NULL) {
            List<US_WSREMS__REMS_Program__c> remsList = new List<US_WSREMS__REMS_Program__c>();
            remsList =  [select id from US_WSREMS__REMS_Program__c  where name ='Sodium Oxybate REMS' and REMS_Project_Code__c = 'BT6825' ];
            if(remsList.size()>0) {
                SYN_CommonUtility.staticSOXProgramId = remsList[0].Id;
            } 
        }
           return SYN_CommonUtility.staticSOXProgramId;
   }

    //116
   public static Id PiaSkyprogramId (){
    if(staticPiaSkyProgramId == NULL) {
        List<US_WSREMS__REMS_Program__c> remsList = new List<US_WSREMS__REMS_Program__c>();
        remsList =  [select id from US_WSREMS__REMS_Program__c  where name = :Label.PiaSky_REMS_Program_Name and REMS_Project_Code__c = 'BT1005' ];
        if(remsList.size()>0) {
            staticPiaSkyProgramId = remsList[0].Id;
        } 
    }
    return staticPiaSkyProgramId;
}
public static Id getProgramId(String programName){
List<US_WSREMS__REMS_Program__c> remsList= [Select id from US_WSREMS__REMS_Program__c  where name = :programName limit 1];
return  (remsList != null && remsList.size() > 0) ? remsList[0].id : null;
}
   
    public static Id MACIprogramId (){
        if(staticMACIProgramId == NULL) {
            List<US_WSREMS__REMS_Program__c> remsList = new List<US_WSREMS__REMS_Program__c>();
            remsList =  [select id from US_WSREMS__REMS_Program__c  where name ='Macitentan REMS' and US_WSREMS__Status__c='Active' LIMIT 1];
            if(remsList.size()>0) {
                staticMACIProgramId = remsList[0].Id;
            } 
        }
        return staticMACIProgramId;
   }
    
    public static Id ClozapineprogramId (){
        if(staticMACIProgramId == NULL) {
            List<US_WSREMS__REMS_Program__c> remsList = new List<US_WSREMS__REMS_Program__c>();
            remsList =  [select id from US_WSREMS__REMS_Program__c  where name ='Clozapine REMS' and US_WSREMS__Status__c='Active' LIMIT 1];
            if(remsList.size()>0) {
                staticMACIProgramId = remsList[0].Id;
            } 
        }
        return staticMACIProgramId;
   }
   
     public class portalSharingData{
         public Map<String, Account> accNameAndRecordMap;
         public Map<String, String> ProgramNameAndAccMap;
     }
     /***********************************************************************************
     Method Name: getActiveProgramIds
    description: return the All Active programs 
    ************************************************************************************/
    public static Map<String,US_WSREMS__REMS_Program__c> getActiveProgramIds(){
        if(staticActiveProgramIdAndRecordMap.size() == 0) {
          Map<String,US_WSREMS__REMS_Program__c> programMap = new Map<String,US_WSREMS__REMS_Program__c>();
           for(US_WSREMS__REMS_Program__c rems : [SELECT Id, Name FROM US_WSREMS__REMS_Program__c WHERE US_WSREMS__Status__c =: 'Active' LIMIT 49999]){
               programMap.put(rems.Name, rems);
           }
           staticActiveProgramIdAndRecordMap = programMap;
       }
       return staticActiveProgramIdAndRecordMap;
    }
     
    public static Map<Id, String> getsObjectRecordTypeMap(String objectName) {

        Map<Id, String> recordTypeMap = new Map<Id, String>();
        
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        
        if (objectType != null) {
        
            DescribeSObjectResult objResult = objectType.getDescribe();
            for (RecordTypeInfo rt : objResult.getRecordTypeInfos()) {
            
                if (!rt.isMaster()) { 
                    
                    recordTypeMap.put(rt.getRecordTypeId(), rt.getDeveloperName());
                }
            }
            
        }
        return recordTypeMap;
    }
    
    public static String getSObjectTypeName(SObject so) {
        return so.getSObjectType().getDescribe().getName();
    }
    
    public static String callProgramSpecficClass(String programName,  String objectName){

        if(String.isNotBlank(programName)){
    
            programName = programName.deleteWhitespace();
            if(programName.containsIgnoreCase('SodiumOxybate'))  
                programName = 'SOX';
            if(programName.containsIgnoreCase('Macitentan'))  
                programName = 'Maci';
                
            return programName + objectName +'Handler';
        }
        
        return '';
    }
    
    /**************************************************************************************
    Created By      : Thandavakrishna Dindu
    Method Name   : triggerByPass
    Description   : This method returns tells whether to skip triggers execution or not based on custom setting.
    Input Args    : None
    Returns     : Boolean
    ****************************************************************************************/   
    public static Boolean triggerByPass() {
        SYN_ByPass_Automation__c triggerBypassSetting =  SYN_ByPass_Automation__c.getValues(UserInfo.getUserId());
        if(triggerBypassSetting != null && triggerBypassSetting.Skip_Trigger__c) {
            return true;
        }
        else {
            return false;
        }      
        
    }
    public static Id maciEscQueueId;
    public static Id getMaciEscQueue(){
        
        if(SYN_CommonUtility.maciEscQueueId == NULL){
            SYN_CommonUtility.maciEscQueueId = [select id from Group where Type = 'Queue' AND DeveloperName ='Macitentan_Escalation_Queue' limit 1].id;
        }
        
        return SYN_CommonUtility.maciEscQueueId;
    }

    public static String getAsynchronousExpression() {
        Datetime currentDateTime = DateTime.now().addSeconds(70);
        String hour = String.valueOf(currentDateTime.hour());
        String minute = String.valueOf(currentDateTime.minute());
        String second = String.valueOf(currentDateTime.second());
        String nextFireTime = second + ' ' + minute + ' ' + hour + ' * * ?';
        return nextFireTime;
    }

    public static List<US_WSREMS__REMS_Program__c> getProgram(String programName){
        return [SELECT Id,Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name =:programName];
    } 
    public static List<User> getCurrentUser(){
        return [SELECT Id, Name, Email, AccountId, ContactId,contact.accountId FROM User WHERE ContactId != null AND Id = :UserInfo.getUserId()];
    }
    public static User getDefaultportalUser(String queryString){
        List<User> accountOwner = [SELECT Id, name  FROM user WHERE username =: queryString Limit 1];
        return  (accountOwner != null && accountOwner.size() > 0) ? accountOwner[0] : null;
    }
    public static User getCurrentUserContactDetails(String userId){
        List<User> loginUser = [Select Id, Contact.Name, Contact.AccountId from User where Id =: userId Limit 1];
        return  (loginUser != null && loginUser.size() > 0) ? loginUser[0] : null;
    }
     public static List<OrgWideEmailAddress> getOrgWideEmailAddress(String address){
       List<OrgWideEmailAddress> owea = [select Id,Address from OrgWideEmailAddress where Address =:Label.XIAFLEXMDPSupportEmail];
        return  (owea != null && owea.size() > 0) ? owea : null;
    }
    public static List<User> getUserByEmail(String Email){
        List<user> arUser = [SELECT ID, EMAIL,username FROM USER WHERE email =:Email];
        return   arUser;

    }
    public static Id getAccountRecordtypeByName(string name){ 
        Id presId = Schema.sObjectType.Account.getRecordTypeInfosByName().get(name).getRecordTypeId();
        return presId;
    }
    public static Id getPPARecordType(string name){ 
        Id presId = Schema.sObjectType.Case.getRecordTypeInfosByName().get(name).getRecordTypeId();
        return presId;
    }
    /*This method retrieve and return all the orgwideemail address values which are verified*/
    public static Map<String, OrgWideEmailAddress> getOrgWideAddressesMap(){
        Map<String, OrgWideEmailAddress> owaMap = new Map<String, OrgWideEmailAddress>();
        for(OrgWideEmailAddress owa : [Select Id, Address, DisplayName from Orgwideemailaddress where Address != NULL ] ) {
            owaMap.put(owa.Address.toLowerCase(), owa);
        }
        return owaMap;
    }
}