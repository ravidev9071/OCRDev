public without sharing class PiaSky_NPISearchController {
    private static final Map<Id, Schema.RecordTypeInfo> mapCaseRecordTypesById =
        Schema.SObjectType.Case.getRecordTypeInfosById();
    public static string programName;
    private static string pharmacyName = '';
    private static boolean isFirstTime_NPI = false;
    private static string Type;
    
    public static void NPIvalidationPiasky(List<Case> caseList, Map<Id,Case> oldCaseList, Boolean isUpdate ){
        List<Id> caseIdlst = new List<Id>();
        for (case caseobj:caseList){
            if(caseobj.US_WSREMS__REMS_Program__c != null && 
               (caseobj.US_WSREMS__Program_Name__c == Label.Tryvio_REMS_Program_Name ||
                caseobj.US_WSREMS__Program_Name__c == Label.Xiaflex_REMS_Program_Name ||caseobj.US_WSREMS__Program_Name__c == Label.AVEED_REMS_Program_Name ||
                (caseObj.US_WSREMS__Channel__c !='Portal' && caseobj.US_WSREMS__Program_Name__c == Label.PiaSky_REMS_Program_Name)) &&         
               (mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == 'Inpatient_Pharmacy_Enrollment' ||
                mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == 'Prescriber_enrollment'        ||
                mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == 'Outpatient_Pharmacy_Enrollment'|| 
                mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == 'Prescriber_Reenrollment'       ||  
                mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == 'Inpatient_Pharmacy_Reenrollment' ||  
                mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == 'Outpatient_Pharmacy_Reenrollment' ||
                mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == 'Health_Care_Setting'||
                mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == 'HCS_Enrollment' ||
                mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == 'Prescriber_Reenrollment'||
                mapCaseRecordTypesById.get(caseobj.RecordTypeId).getDeveloperName() == 'HCS_Reenrollment'
               )){
                   
                if ((isUpdate && caseobj.US_WSREMS__NPI__c != oldCaseList.get(caseObj.Id).US_WSREMS__NPI__C) || 
                       (isUpdate && caseobj.US_WSREMS__Program_Name__c == Label.Xiaflex_REMS_Program_Name && 
                           (caseobj.US_WSREMS__DEA__c != oldCaseList.get(caseObj.Id).US_WSREMS__DEA__c || 
                      caseobj.US_WSREMS__HIN__c != oldCaseList.get(caseObj.Id).US_WSREMS__HIN__c))){
                     caseIdlst.add(caseobj.id);
                 } 
                 else if ((!isUpdate && caseobj.US_WSREMS__NPI__c != null) || 
                              (!isUpdate && caseobj.US_WSREMS__Program_Name__c == Label.Xiaflex_REMS_Program_Name && 
                               caseobj.US_WSREMS__DEA__c != null)) {
                         caseIdlst.add(caseobj.id);
                 }
                 else if(isUpdate && caseobj.US_WSREMS__Program_Name__c == Label.AVEED_REMS_Program_Name && caseobj.US_WSREMS__DEA__c != oldCaseList.get(caseObj.Id).US_WSREMS__DEA__c){
                        caseIdlst.add(caseobj.id); 
                 }
}	
        }
        if(!caseIdlst.isEmpty() && caseIdlst != null){
           
            if(!system.isFuture()){
                searchCurrentCasePiasky(caseIdlst);
            }
        }
        
    } 
    
    @future(callout=true)
    public static void searchCurrentCasePiasky(list<string> caseId){
        map<string,case> mapListCase = new map<string,case>();
        Map<Id,Account> accountMap=new Map<Id,Account>();
        Map<Id,US_WSREMS__REMS_Service_Summary__c> serviceMap=new Map<Id,US_WSREMS__REMS_Service_Summary__c>();
        //case caseData = new case();
        string programName = Label.PiaSky_REMS_Program_Name;
        string tryvioProgramName;
        Profile profile = [SELECT Id,Name FROM Profile WHERE Name =: SYN_Utilitycls.XIAFLEX_Super_User_ProfileName Limit 1];
        Boolean isSuperUser = UserInfo.getProfileId() == profile.Id ? true : false;
        List<US_WSREMS__Affiliation__c> affiliations=new List<US_WSREMS__Affiliation__c>();
        Case caseData = [select id, US_WSREMS__First_Name__c, US_WSREMS__Last_Name__c,US_WSREMS__REMS_Program__r.Name, US_WSREMS__SLN__c,US_WSREMS__NPI__c,
                         US_WSREMS__DEA__c,US_WSREMS__DEA_Status__c, US_WSREMS__HIN__c, US_WSREMS__HIN_Status__c,
                         US_WSREMS__Participant__c,US_WSREMS__Participant__r.US_WSREMS__Status__c,US_WSREMS__Healthcare_Setting__c,US_WSREMS__Channel__c,US_WSREMS__Status__c, RecordTypeId,SYN_DEA_Validation__c, Pharmacy_Name__c , SYN_Pharmacy__r.Name,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Status__c, US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Service_Outcome__c  from case where id IN: caseId Limit 1];
        
        SYN_VeevaAPI_Search.caseParameterWrap CPW;
        SYN_VeevaAPI_Search.caseParameterWrap CPW1;
        SYN_VeevaAPI_Search.caseParameterWrap CPW2;

        SYN_VeevaAPI_Search.caseParameterWrap CPW_NPI;
        SYN_VeevaAPI_Search.caseParameterWrap CPW_SLN;
        SYN_VeevaAPI_Search.caseParameterWrap CPW_HIN;
        String NPIvalidation_pickList;
        String HINvalidation_pickList;
        String DEAvalidation_pickList;
        
        if(caseData.US_WSREMS__REMS_Program__r.Name == Label.PiaSky_REMS_Program_Name){
            programName = Label.PiaSky_REMS_Program_Name;
            pharmacyName = caseData.SYN_Pharmacy__r.Name ;
            if((mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName()).containsIgnoreCase('Prescriber')){
                CPW  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , caseData.US_WSREMS__Last_Name__c , caseData.RecordTypeId);
            }
            else{
                CPW  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , '' , caseData.RecordTypeId);
            }
            CPW.NPIvalidation = true;
            NPIvalidation_pickList = SYN_VeevaAPI_Search.searchResultPiasky(CPW,programName) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
            caseData.US_WSREMS__NPI_Status__c= NPIvalidation_pickList;
        }
        
        else if(caseData.US_WSREMS__REMS_Program__r.Name == Label.Tryvio_REMS_Program_Name && (
            mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'Inpatient_Pharmacy_Enrollment' ||
            mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'Outpatient_Pharmacy_Enrollment' ||
            mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'Prescriber_Enrollment')){
                
                tryvioProgramName = Label.Tryvio_REMS_Program_Name;
                pharmacyName = caseData.SYN_Pharmacy__r.Name ;
                if(mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'Prescriber_Enrollment'){
                    
                    CPW  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , caseData.US_WSREMS__Last_Name__c , caseData.RecordTypeId);
                }
                else if(mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'Inpatient_Pharmacy_Enrollment' || 
                        mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'Outpatient_Pharmacy_Enrollment'){
                            
                            CPW  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , '' , caseData.RecordTypeId);
                        }
                CPW.NPIvalidation = true;
                NPIvalidation_pickList = SYN_VeevaAPI_Search.searchResultTryvio(CPW,tryvioProgramName) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
                caseData.US_WSREMS__NPI_Status__c= NPIvalidation_pickList;
            }
        
        else if(caseData.US_WSREMS__REMS_Program__r.Name == Label.Xiaflex_REMS_Program_Name)
        {
            if((mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'Prescriber_Enrollment' || mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'Prescriber_Reenrollment') 
                && (caseData.US_WSREMS__NPI__c != NULL && (!isSuperUser || (isSuperUser && caseData.US_WSREMS__NPI_Status__c != 'Valid')))
            ) {
                CPW  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , '' , caseData.RecordTypeId);
                CPW.NPIvalidation = true;
                NPIvalidation_pickList = SYN_VeevaAPI_Search.searchResultPiasky(CPW,Label.Xiaflex_REMS_Program_Name) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
                caseData.US_WSREMS__NPI_Status__c= NPIvalidation_pickList;
            }
            else if(mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'HCS_Enrollment' || mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'HCS_Reenrollment')
            {   
                if((caseData.US_WSREMS__NPI__c != NULL && (!isSuperUser || (isSuperUser && caseData.US_WSREMS__NPI_Status__c != 'Valid')))){
                    CPW1  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , '' , caseData.RecordTypeId);
                    CPW1.NPIvalidation = true;
                    NPIvalidation_pickList = SYN_VeevaAPI_Search.searchResultPiasky(CPW1,Label.Xiaflex_REMS_Program_Name) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
                    if(NPIvalidation_pickList == 'Invalid' )
                    {
                        Id PharmacyRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Account').getRecordTypeId();
                        CPW1  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , '' , PharmacyRecordtypeId);
                        CPW1.NPIvalidation = true;
                        NPIvalidation_pickList = SYN_VeevaAPI_Search.searchResultPiasky(CPW1,Label.Xiaflex_REMS_Program_Name) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
                        caseData.US_WSREMS__NPI_Status__c= NPIvalidation_pickList;
                    }
                    else { caseData.US_WSREMS__NPI_Status__c= NPIvalidation_pickList;  
                    } 
                }

                
                if((caseData.US_WSREMS__DEA__c != NULL && (!isSuperUser || (isSuperUser && caseData.US_WSREMS__DEA_Status__c != 'Valid')))){
                    CPW  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__DEA__c , caseData.US_WSREMS__Last_Name__c , caseData.RecordTypeId);
                    DEAvalidation_pickList = SYN_VeevaAPI_Search.searchResult(CPW) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
                    caseData.US_WSREMS__DEA_Status__c= DEAvalidation_pickList;  
                }

                if((caseData.US_WSREMS__HIN__c != NULL && (!isSuperUser || (isSuperUser && caseData.US_WSREMS__HIN_Status__c != 'Valid')))){
                    CPW_HIN = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.Id, caseData.US_WSREMS__HIN__c, '', caseData.RecordTypeId);
                    CPW_HIN.HINvalidation = true;
                    HINvalidation_pickList = SYN_VeevaAPI_Search.searchResult(CPW_HIN) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid;
                    caseData.US_WSREMS__HIN_Status__c = HINvalidation_pickList;
                }
            }      
        }else if(caseData.US_WSREMS__REMS_Program__r.Name == Label.AVEED_REMS_Program_Name){
        if(mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'Prescriber_Enrollment' || mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'Prescriber_Reenrollment'){
            CPW  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , caseData.US_WSREMS__Last_Name__c , caseData.RecordTypeId);
        }else if(mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'HCS_Enrollment' || mapCaseRecordTypesById.get(caseData.RecordTypeId).getDeveloperName() == 'HCS_Reenrollment'){
            CPW  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__NPI__c , '' , caseData.RecordTypeId);
        }
    CPW.NPIvalidation = true;
    NPIvalidation_pickList = SYN_VeevaAPI_Search.searchResultPiasky(CPW,Label.AVEED_REMS_Program_Name) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
    caseData.US_WSREMS__NPI_Status__c= NPIvalidation_pickList;
    CPW  = new SYN_VeevaAPI_Search.caseParameterWrap(caseData.id , caseData.US_WSREMS__DEA__c , caseData.US_WSREMS__Last_Name__c  , caseData.RecordTypeId);
    CPW.NPIvalidation = false; 
    DEAvalidation_pickList = SYN_VeevaAPI_Search.searchResult(CPW) ? SYN_Utilitycls.pickListVal_Valid : SYN_Utilitycls.pickListVal_Invalid ;
    caseData.US_WSREMS__DEA_Status__c= DEAvalidation_pickList;  
        }
        update caseData;
        if((NPIvalidation_pickList == 'Invalid' || DEAvalidation_pickList== 'Invalid' || HINvalidation_pickList=='Invalid') && caseData.US_WSREMS__REMS_Program__r.Name == Label.Xiaflex_REMS_Program_Name && caseData.US_WSREMS__Channel__c=='Portal')
        {
                if(caseData.US_WSREMS__Participant__r?.US_WSREMS__Status__c=='Certified'){
                    accountMap.put(caseData.US_WSREMS__Participant__c,new Account(Id=caseData.US_WSREMS__Participant__c,US_WSREMS__Status__c='Pending'));
              }
                if(caseData.US_WSREMS__REMS_Service_Summary__r?.US_WSREMS__Status__c!='Open' || caseData.US_WSREMS__REMS_Service_Summary__r?.US_WSREMS__Service_Outcome__c!=''){
                    serviceMap.put(caseData.US_WSREMS__REMS_Service_Summary__c,new US_WSREMS__REMS_Service_Summary__c(Id=caseData.US_WSREMS__REMS_Service_Summary__c,US_WSREMS__Status__c='Open',US_WSREMS__Service_Outcome__c='',US_WSREMS__Path_Stage_Name__c = 'Intake',US_WSREMS__StageName__c='Intake'));
            }
                if(caseData.US_WSREMS__Healthcare_Setting__c!=null && caseData.US_WSREMS__Participant__c!=null){
                    affiliations=[select id,US_WSREMS__isActive__c,US_WSREMS__Start_Date__c from US_WSREMS__Affiliation__c where  (US_WSREMS__Prescriber__c=:caseData.US_WSREMS__Participant__c or US_WSREMS__Authorized_Representative__c=:caseData.US_WSREMS__Participant__c)  and US_WSREMS__Health_Care_Setting__c=:caseData.US_WSREMS__Healthcare_Setting__c];
                        if(affiliations.size()> 0){
                            for(US_WSREMS__Affiliation__c  affiliation:affiliations){
                                affiliation.US_WSREMS__isActive__c=false;
                                affiliation.US_WSREMS__Start_Date__c=null;
                            }
                        }
                    }
                }
        
    if(accountMap.values().size()>0)
        update accountMap.values();
     if(serviceMap.values().size()>0)
        update serviceMap.values();   
         if(affiliations.size()>0)
        update affiliations;   
    }   
}