/**
* @File Name          : SYN_ParticipantEnrollmentController.cls
* @Description        : This is used as a Controller for SYN_ParticipantEnrollment.cmp (Aura).
* @TestClass          : SYN_ParticipantEnrollmentController_Test
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    03/29/2022        Suchendra Chandra (Wilco)     Initial Implementation (Enrollment/AutoPopulation of fields before save button)
* 2.0     21/9/2022        Krishna Dindu                   Update soql logic in getProgramBasedFieldMapping method.
* 3.0     09/13/2023        Dileep Gurram [Wilco]            Replaced Schema.Sobject syntax by using methods in REMSUtility apex class based on the scenario.
**/

public class SYN_ParticipantEnrollmentController {
    
    private
          static final Map<Id,String> mapCaseRecordTypesById = REMSUtility.retrieveRecTypeIdDeveloperName_Product('Case');

    private
        static final Map<Id, Schema.RecordTypeInfo> mapAccountRecordTypesById =
        Schema.SObjectType.Account.getRecordTypeInfosById();
    public static String getRecordTypeNameById(Id strRecordTypeId){
            return Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
        }
    
    @AuraEnabled
    public static Boolean monitorParticipant(Id recordId){
        Boolean monitorCheckbox;
        List<Account> participantAccList = [select Id,Name, Monitor_Participant__c From Account WHERE Id =:recordId WITH SECURITY_ENFORCED ];
        monitorCheckbox = participantAccList[0].Monitor_Participant__c;
        return monitorCheckbox;  
    }
    
    @AuraEnabled(cacheable =true)
    public static Map<String,String> getPrepopFields(Id recordId , string TargetObj , Id RecordTypeId, String SectionName ){
       
        boolean SecondARrecorded = false;
        Map<string , String> TargetSourceMap ;
		Map<string , String> TargetSourceMapChild;
        Map<String, String> TargetFieldToValueMap = new Map<String, String>();
        
        List<Sobject> SobjectRecLst = new List<Sobject>();
        
        if (String.isBlank(recordId)){
            return  TargetSourceMap ;
        }
        
        
        String RequestorType = '';
        String Parentfield = '';
        String Program = '';
        String secName = '';
		string PCRecordId='';
        string PatientId='';

        
        if(!String.isBlank(SectionName)){
            String serviceKey= SectionName;
            String[] keys = serviceKey.split(';');
            if(keys.size()>2){
                RequestorType = keys[0];
                Parentfield  = keys[1];
                Program = keys[2];
            }
            
            if(keys.size()>3){
                secName = keys[3];
				PCRecordId=keys[3]; //BT7433-1137
            }
            
        }

        String SourceobjNameStr =  String.valueOf(recordId?.getsobjecttype());
        if(SourceobjNameStr == 'Product2'){
            String SourceRCtypeName = SYN_Utilitycls.ProductRCType;
            String TarRCtypeName = mapCaseRecordTypesById.get(RecordTypeId); 
            if(Program == null || Program == '' || Program == Label.Sodium_Oxybate_REMS_Program_Name) {
                TargetSourceMap = getFieldMapping(SourceobjNameStr, TargetObj , SourceRCtypeName,  TarRCtypeName, SectionName );  
            }else{
                TargetSourceMap = getProgramBasedFieldMapping(SourceobjNameStr, TargetObj, SourceRCtypeName,  TarRCtypeName, secName, Program, RequestorType, Parentfield);  
            }
             
         }
         if(SourceobjNameStr != 'Product2') {
            String dynRCtyIdQueryStr = 'select RecordTypeId from '+SourceobjNameStr+' where id =: recordId limit 1';
            Sobject SobjRec = Database.query(dynRCtyIdQueryStr);
            String SourceRCtypeName = mapAccountRecordTypesById.get(string.valueOf(SobjRec.get('RecordTypeId'))).getDeveloperName();
            String TarRCtypeName = mapCaseRecordTypesById.get(RecordTypeId);  
            if(Program == Label.Sodium_Oxybate_REMS_Program_Name || String.isBlank(Program)) {
                TargetSourceMap = getFieldMapping(SourceobjNameStr, TargetObj , SourceRCtypeName,  TarRCtypeName, SectionName );  
            }else{
                TargetSourceMap = getProgramBasedFieldMapping(SourceobjNameStr, TargetObj, SourceRCtypeName,  TarRCtypeName, secName, Program, RequestorType, Parentfield);
				TargetSourceMap = getProgramBasedFieldMapping(SourceobjNameStr, TargetObj, SourceRCtypeName,  TarRCtypeName, secName, Program, RequestorType, Parentfield);
                //BT7433-1137
               if((TarRCtypeName== 'Patient_Counseling_Checklist'|| TarRCtypeName=='Patient_Pregnancy_Test') && Parentfield=='Onload')
                {
                    US_WSREMS__REMS_Service_Summary__c RSSPatientId = [Select id, US_WSREMS__Participant__c,Patient__c FROM US_WSREMS__REMS_Service_Summary__c WHERE Id =:PCRecordId Limit 1]; 
                    
                    if (RSSPatientId.Patient__c  != null){
                        Parentfield='US_WSREMS__Patient__c';
                        PatientId=RSSPatientId.Patient__c;
                       TargetSourceMapChild = getProgramBasedFieldMapping(SourceobjNameStr, TargetObj, SourceRCtypeName,  TarRCtypeName, secName, Program, RequestorType, Parentfield);  
  
                   }
                }
            }
         }
      
		//BT7433-1137
         if(TargetSourceMapChild != null && !TargetSourceMapChild.isEmpty()){
        
        SobjectRecLst = SobjectDynamicFields(TargetSourceMapChild.values() , SourceobjNameStr , PatientId ); 
            for (string Field : TargetSourceMapChild.Keyset()){
                String Value = TargetSourceMapChild.get(Field);
                String FieldValue = String.valueOf(SobjectRecLst[0].get(Value));
                TargetFieldToValueMap.put(Field ,  String.isBlank(FieldValue) ? ' ': FieldValue);
            }
    }
        
        if(TargetSourceMap != null && !TargetSourceMap.isEmpty()){
        
        SobjectRecLst = SobjectDynamicFields(TargetSourceMap.values() , SourceobjNameStr , recordId ); 
            for (string Field : TargetSourceMap.Keyset()){
                
                String Value = TargetSourceMap.get(Field);
                String FieldValue = String.valueOf(SobjectRecLst[0].get(Value));
                If(Field == SYN_Utilitycls.NonComplianceImpactedRTNameField && FieldValue != Null){
                    String RtName = getRecordTypeNameById(FieldValue);
                    TargetFieldToValueMap.put(Field, RtName);
                }
                else if(Field == SYN_Utilitycls.NonComplianceInvestigatedRTNameField && FieldValue != Null){
                    String RtName = getRecordTypeNameById(FieldValue);
                    TargetFieldToValueMap.put(Field, RtName);
                }else if(Field == SYN_Utilitycls.NonComplianceReporterRTNameField && FieldValue != Null){
                    String RtName = getRecordTypeNameById(FieldValue);
                    TargetFieldToValueMap.put(Field, RtName); //BT6825-135
                }else{
                TargetFieldToValueMap.put(Field ,  String.isBlank(FieldValue) ? ' ': FieldValue);
                }
            }
    }
	String TarRCtypeName = mapCaseRecordTypesById.get(RecordTypeId); 
        if(TargetSourceMap != null && !TargetSourceMap.isEmpty() && TarRCtypeName=='Change_Authorized_Representative' && (SectionName.contains('US_WSREMS__Pharmacy__c') || SectionName.contains('Onload')) && Program != Label.Sodium_Oxybate_REMS_Program_Name)
        {
        List<US_WSREMS__Affiliation__c>  AffiliatinARFieldValues = [SELECT  Id,Name,AR_Category__c, US_WSREMS__Pharmacy_User__r.FirstName,US_WSREMS__Pharmacy_User__r.LastName , US_WSREMS__Pharmacy_User__r.US_WSREMS__Email__c, US_WSREMS__Pharmacy_User__r.Phone,US_WSREMS__Pharmacy_User__r.SYN_User_Type__c FROM US_WSREMS__Affiliation__c WHERE RecordType.Name='Pharmacy User Affiliation' and US_WSREMS__Pharmacy__c=:recordId and US_WSREMS__isActive__c = true and US_WSREMS__UserType__c='Authorized Representative' order by LastModifiedDate desc limit 10]; 
        
            string SourceARFName='US_WSREMS__First_Name_ar__c';
            string SourceARLName='US_WSREMS__Last_Name_ar__c';
            string SourceAREmail='US_WSREMS__Email_ar__c';
            string SourceARPhone='US_WSREMS__Phone_ar__c';
            string SourceUsertype='US_WSREMS__UserType_ar__c';
            String SourceSecARFName='First_Name_ar2__c';
            string SourceSecARLName='Last_Name_ar2__c';
            string SourceSecAREmail='US_WSREMS__Email_PharmacyAddress__c';
            string SourceSecARPhone='US_WSREMS__Phone_Pharmacyaddress__c';
            TargetFieldToValueMap.put(SourceARFName, ' '); 
            TargetFieldToValueMap.put(SourceARLName, ' ');
            TargetFieldToValueMap.put(SourceAREmail, ' ');
            TargetFieldToValueMap.put(SourceARPhone, ' ');
            TargetFieldToValueMap.put(SourceUsertype, ' ');
            TargetFieldToValueMap.put(SourceSecARFName, ' ');
            TargetFieldToValueMap.put(SourceSecARLName, ' ');
            TargetFieldToValueMap.put(SourceSecAREmail, ' ');
            TargetFieldToValueMap.put(SourceSecARPhone, ' ');

            for(US_WSREMS__Affiliation__c affRec :AffiliatinARFieldValues){
                if(affRec.AR_Category__c == 'Primary')
                {
                    TargetFieldToValueMap.put(SourceARFName, affRec.US_WSREMS__Pharmacy_User__r.FirstName); 
                    TargetFieldToValueMap.put(SourceARLName, affRec.US_WSREMS__Pharmacy_User__r.LastName);
                    TargetFieldToValueMap.put(SourceAREmail, affRec.US_WSREMS__Pharmacy_User__r.US_WSREMS__Email__c);
                    TargetFieldToValueMap.put(SourceARPhone, affRec.US_WSREMS__Pharmacy_User__r.Phone);
                    TargetFieldToValueMap.put(SourceUsertype, affRec.US_WSREMS__Pharmacy_User__r.SYN_User_Type__c);
                }
                else {
                    if (SecondARrecorded){
                        continue;
                    }
                    TargetFieldToValueMap.put(SourceSecARFName,affRec.US_WSREMS__Pharmacy_User__r.FirstName); 
                    TargetFieldToValueMap.put(SourceSecARLName, affRec.US_WSREMS__Pharmacy_User__r.LastName);
                    TargetFieldToValueMap.put(SourceSecAREmail, affRec.US_WSREMS__Pharmacy_User__r.US_WSREMS__Email__c);
                    TargetFieldToValueMap.put(SourceSecARPhone, affRec.US_WSREMS__Pharmacy_User__r.Phone);
                    SecondARrecorded = true;
                }
            }
                  
        }
        
        return TargetFieldToValueMap ;
    } 

    
    private static Map<String,string> getFieldMapping(String SourceObj , String TarObj, String SourceRCtyName , String TarRCtypeName, String SectionLabel ){
        Map<string,string> TargetSourceFieldMapping = new Map<String,string>();
        
        for (SYN_FieldMapping_Config__mdt mdt : SYN_FieldMapping_Config__mdt.getAll().values()){
            if(SectionLabel != Null){
                if (mdt.Source_Object__c != SourceObj || mdt.Target_Object__c != TarObj || mdt.Source_RecordType_Name__c != SourceRCtyName || mdt.Target_RecordType_Name__c  != TarRCtypeName || mdt.Section_Name__c != SectionLabel){
                    continue;
                }

            }else if(String.isBlank(SectionLabel)) {
                
                if (mdt.Source_Object__c != SourceObj || mdt.Target_Object__c != TarObj || mdt.Source_RecordType_Name__c != SourceRCtyName || mdt.Target_RecordType_Name__c  != TarRCtypeName ){
                    continue;
                }
            }
            TargetSourceFieldMapping.put( mdt.Target_Field__c , mdt.Source_Field__c );
        }
        return TargetSourceFieldMapping;
    }
    
    private static List<Sobject> SobjectDynamicFields(List<String> dynamiceFieldLst, string SourceObj,  Id recordId){
        List<sobject> sourceRecLst = new List<Sobject>();
        Set<String> dynamiceFieldSet = new Set<String>();
        for(String s : dynamiceFieldLst){
            dynamiceFieldSet.add(s);    
        }
       String dynamicFieldStr = String.join(new List<String>(dynamiceFieldSet), ',');
        String dynamicQueryStr = 'Select '+dynamicFieldStr+' From '+ SourceObj+' where Id =: recordId';
        return Database.query(dynamicQueryStr);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<LayoutSection> getPageLayoutFields(String layoutName) {
        List<LayoutSection> lstSections = new List<LayoutSection>();

        try {
            // Provide the page layout name here
            // You can give multiple page layout names here as well
            List<String> layoutList = new List<String>{layoutName};
            // Retrieve page layout details
            List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutList);
            Metadata.Layout layout = new Metadata.Layout();
            if(!layouts.isEmpty()){
                layout = (Metadata.Layout) layouts.get(0);
            }

            // We are going to find the fields names and will keep them according to columns so
            // we can show them as per page layout
            for( Metadata.LayoutSection ls : layout.layoutSections ) {
                if(ls.label != SYN_Utilitycls.CASE_INFORMATION && ls.label != SYN_Utilitycls.CUSTOM_LINKS && ls.label != '-'){
                    LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );

                    List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                    Integer maxFieldsInColumn = 0;
                    for( Metadata.LayoutColumn lc : ls.layoutColumns ) {

                        LayoutColumn column = new LayoutColumn();
                        // check if there are fields available in that column
                        if( lc.layoutItems != null ) {
                            // Get the max number of fields in a column to preserve the alignment
                            if( maxFieldsInColumn < lc.layoutItems.size() ) {
                                maxFieldsInColumn = lc.layoutItems.size();
                            }
                            for( Metadata.LayoutItem li : lc.layoutItems ) {

                                // Pass the LayoutItem object in the LayoutField consturctor
                                column.lstFields.add( new LayoutField( li ) );
                            }
                        }
                        // No need to add a column in the section if there is no field available
                        if( column.lstFields.size() > 0 ) {
                            lstColumns.add( column );
                        }
                    }

                    // Now, we need to arrange the fields in section so we can use them in the iteration
                    // on the component so we will have to arrange them in the order
                    if( maxFieldsInColumn > 0 ) {
                        for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                            for( Integer j = 0; j < lstColumns.size(); j++ ){
                                if( lstColumns[j].lstFields.size() > i ) {
                                    section.lstFields.add( lstColumns[j].lstFields[i] );
                                }
                                else {
                                    section.lstFields.add( new LayoutField() );
                                }
                            }
                        }
                    }

                    lstSections.add( section );
                }
            }
        }
        catch( Exception e ){
            System.assert(false, e.getLineNumber() + ' : ' + e.getMessage() );
        }
        return lstSections;
    }
    /* methodName : getPageLayoutforRequestorType
        Parameter : caseRecordId
        Description: This method will fetch the Pagelayout name stored in the Metadata based on the Requestor Type of Parent REMS Service.
        createdDate: 10th June, 2021
    */ 
    @AuraEnabled
    public static caseDetails getPageLayoutforRequestorType(String remsServiceId, String caseActionName){

        boolean isKAbutton = isKnowledgeAssessButton(caseActionName);
        Map<String,String> buttonNameToCaseRCtyMap = KAButtonNameToCaseRCType();
        Map<String,US_WSREMS__Pagelayout_Configuration__mdt> requestorTypeToPageLayoutMap = new Map<String,US_WSREMS__Pagelayout_Configuration__mdt>();
        String programName = '';
        
        US_WSREMS__REMS_Service_Summary__c remsSummary = [SELECT Id, US_WSREMS__Requestor_Type__c, US_WSREMS__REMSProgram__c, US_WSREMS__REMSProgram__r.Name, US_WSREMS__Participant__r.FirstName, US_WSREMS__Participant__r.LastName, RecordtypeId, US_WSREMS__Participant__r.US_WSREMS__Status__c, Recordtype.Name FROM US_WSREMS__REMS_Service_Summary__c WHERE Id=: remsServiceId LIMIT 1];
        
        if(remsSummary.US_WSREMS__REMSProgram__c != null){
            programName = remsSummary.US_WSREMS__REMSProgram__r.Name;
        }
        
        for(US_WSREMS__Pagelayout_Configuration__mdt metadataObj : [SELECT Id,US_WSREMS__PageLayout_Name__c, US_WSREMS__Requestor_Type__c,US_WSREMS__RecordType_Name__c, US_WSREMS__Program__c, US_WSREMS__Rems_Service_RCtype__c, US_WSREMS__Program_Name__r.Label,US_WSREMS__Quick_Action_Name__c,US_WSREMS__Title__c FROM US_WSREMS__Pagelayout_Configuration__mdt WHERE US_WSREMS__PageLayout_Name__c != null AND US_WSREMS__Object_Name__c = 'Case']){
            // Create a unique Key for knowledge assessment by skipping other layouts (in PageLayoutConfig_mdt)
           if(programName == Label.Sodium_Oxybate_REMS_Program_Name){ 
                if (!isKAbutton){
                    if (metadataObj.US_WSREMS__RecordType_Name__c == 'SYN_Knowledge_Assessment_A' || metadataObj.US_WSREMS__RecordType_Name__c == 'SYN_Knowledge_Assessment_B' ){
                       continue;
                       }
                }else{
                    // Create a unique Key for other layouts by skipping knowledge assessment (in PageLayoutConfig_mdt)
                if(metadataObj.US_WSREMS__RecordType_Name__c != 'SYN_Knowledge_Assessment_A' && metadataObj.US_WSREMS__RecordType_Name__c != 'SYN_Knowledge_Assessment_B'){
                  continue;
                }
                }
                String keyforMap = metadataObj.US_WSREMS__Requestor_Type__c+'$'+metadataObj.US_WSREMS__Program__c+'$'+metadataObj.US_WSREMS__Rems_Service_RCtype__c ;
                requestorTypeToPageLayoutMap.put(isKAbutton ? keyforMap+'$'+metadataObj.US_WSREMS__RecordType_Name__c : keyforMap, metadataObj);
            }else if(metadataObj.US_WSREMS__Program_Name__c != null){
                requestorTypeToPageLayoutMap.put(metadataObj.US_WSREMS__Requestor_Type__c+'$'+metadataObj.US_WSREMS__Program_Name__r.Label+'$'+metadataObj.US_WSREMS__Rems_Service_RCtype__c+'$'+metadataObj.US_WSREMS__Quick_Action_Name__c,metadataObj);
            }
        }

        // Added US_WSREMS__Participant__r.US_WSREMS__Status__c && RecordType.Name to the query //BT-6825-253string remsRCtypeAPInameStr = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosById().get(remsSummary.RecordtypeId).getDeveloperName();
        string remsRCtypeAPInameStr = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosById().get(remsSummary.RecordtypeId).getDeveloperName();
        string KeyRemServiceStr = remsSummary.US_WSREMS__Requestor_Type__c+'$'+remsSummary.US_WSREMS__REMSProgram__r.Name+'$'+remsRCtypeAPInameStr;
        String keyFromREMSService = '';
        String pageLayoutName ='';
        if(programName == Label.Sodium_Oxybate_REMS_Program_Name){
            keyFromREMSService = isKAbutton ? KeyRemServiceStr+'$'+buttonNameToCaseRCtyMap.get(caseActionName) : KeyRemServiceStr ;
            pageLayoutName = requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__PageLayout_Name__c;
        }else{
            keyFromREMSService = remsSummary.US_WSREMS__Requestor_Type__c+'$'+remsSummary.US_WSREMS__REMSProgram__r.Name+'$'+remsRCtypeAPInameStr+'$'+caseActionName;
            if(requestorTypeToPageLayoutMap.containsKey(keyFromREMSService)){
                pageLayoutName = requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__PageLayout_Name__c;
            }
        }
        Map<String,Id> caseRecordTypes = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
        Id caseRTId = caseRecordTypes.get(requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__RecordType_Name__c);
		  if(caseRTId == Null){
		  caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__RecordType_Name__c).getRecordTypeId();
		}	String caseRTName = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__RecordType_Name__c).getDeveloperName();
        caseDetails caseDetailsObj = new caseDetails(pageLayoutName, caseRTId);  
        caseDetailsObj.requestorType = remsSummary.US_WSREMS__Requestor_Type__c;
        caseDetailsObj.ParticipantFName = remsSummary.US_WSREMS__Participant__r.FirstName;
        caseDetailsObj.ParticipantLName = remsSummary.US_WSREMS__Participant__r.LastName;
        caseDetailsObj.ParticipantStatus = remsSummary.US_WSREMS__Participant__r.US_WSREMS__Status__c; //BT-6825-253
        caseDetailsObj.remsServiceRecordTypeName = remsSummary.RecordType.Name; //BT-6825-253
		caseDetailsObj.programName=programName;
		caseDetailsObj.programRecordType = programName+'-'+caseRTName;
        if(programName != Label.Sodium_Oxybate_REMS_Program_Name && requestorTypeToPageLayoutMap.containsKey(keyFromREMSService) && requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__Title__c != ''){
            caseDetailsObj.pageTitle = requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__Title__c;
        }
   
        return caseDetailsObj;
            
    }

    /* methodName : getPageLayougetPageLayoutforAffiliationtforRequestorType
        Parameter : remsRecordId
        Description: This method will fetch the Pagelayout name stored in the Metadata based on the Requestor Type of Parent REMS Service.
        createdDate: 17th Aug, 2021
    */ 
    @AuraEnabled
    public static caseDetails getPageLayoutforAffiliation(String remsServiceId){
        Map<String,US_WSREMS__Pagelayout_Configuration__mdt> requestorTypeToPageLayoutMap = new Map<String,US_WSREMS__Pagelayout_Configuration__mdt>();
        for(US_WSREMS__Pagelayout_Configuration__mdt metadataObj : [SELECT Id,US_WSREMS__PageLayout_Name__c, US_WSREMS__Requestor_Type__c,US_WSREMS__RecordType_Name__c, US_WSREMS__Program__c FROM US_WSREMS__Pagelayout_Configuration__mdt WHERE US_WSREMS__PageLayout_Name__c != null AND US_WSREMS__Object_Name__c = 'Affiliation__c']){
            String keyforMap = metadataObj.US_WSREMS__Requestor_Type__c+'$'+metadataObj.US_WSREMS__Program__c;
            requestorTypeToPageLayoutMap.put(keyforMap, metadataObj);
        }
         
        US_WSREMS__REMS_Service_Summary__c remsSummary = [SELECT Id, US_WSREMS__Requestor_Type__c, US_WSREMS__REMSProgram__c, US_WSREMS__REMSProgram__r.Name FROM US_WSREMS__REMS_Service_Summary__c WHERE Id=: remsServiceId LIMIT 1];
        String keyFromREMSService = remsSummary.US_WSREMS__Requestor_Type__c+'$'+remsSummary.US_WSREMS__REMSProgram__r.Name;
        String pageLayoutName = requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__PageLayout_Name__c;
        Id affiliationRTId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get(requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__RecordType_Name__c).getRecordTypeId();
        caseDetails recordObj = new caseDetails(pageLayoutName, affiliationRTId);
        recordObj.programId = remsSummary.US_WSREMS__REMSProgram__c;
        return recordObj;
            
    }

    /* methodName : getPageLayoutNameAndRecordTypeIdForPharmacyRegistration
        Parameter : 
        Description: This method will fetch the Pagelayout name and RecordTypeId for Pharmacy Registration Case.
        createdDate: 29th July, 2021
    */ 
    @AuraEnabled
    public static caseDetails getPageLayoutNameAndRecordTypeIdForPharmacyRegistration(){
        String pageLayoutName = SYN_Utilitycls.PHARMACY_REGISTRATION_LAYOUT;
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_Utilitycls.PHARMACY_REGISTRATION_ID).getRecordTypeId();
        return new caseDetails(pageLayoutName, caseRTId);
    }

    /* methodName : getRelatedFieldsForPharmacyUser
        Parameter : 
        Description: This method will fetch field values for related field to Pharmacy User based on metadata records.
        createdDate: 30th July, 2021
    */ 
    @AuraEnabled
    public static List<LayoutSection> getRelatedFieldsForPharmacyUser(String existingLaoutSectionString, String pharmacyUserId){

        List<LayoutSection> existingLaoutSection = (List<LayoutSection>)JSON.deserialize(existingLaoutSectionString, List<LayoutSection>.class);
        //Querying all metadata records to store all the fields for mapping.
        List<String> sourceFieldList = new List<String>();
        Map<String, US_WSREMS__Field_Mapping_Config__mdt> sourceFieldToMetadataMap = new Map<String, US_WSREMS__Field_Mapping_Config__mdt>();
        for(US_WSREMS__Field_Mapping_Config__mdt metadataObject : [SELECT Id, US_WSREMS__Source_Field__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c,US_WSREMS__Source_Object__c 
                                                        FROM US_WSREMS__Field_Mapping_Config__mdt
                                                        WHERE US_WSREMS__Target_Object__c = 'Case' AND US_WSREMS__Parent_Field__c = 'Pharmacy_User__c' AND US_WSREMS__IsActive__c = true AND US_WSREMS__Source_Field__c != null]){
                      String fieldName = string.valueOf(metadataObject.US_WSREMS__Source_Field__c).endsWithIgnoreCase('__c') ? (SYN_AppLiterals.NAMESPACE_STRING+metadataObject.US_WSREMS__Source_Field__c) : metadataObject.US_WSREMS__Source_Field__c ;
                                                            
                                              sourceFieldList.add(fieldName);
            sourceFieldToMetadataMap.put(fieldName, metadataObject);
            
        }
        pharmacyUserId =  String.escapeSingleQuotes(pharmacyUserId);
        String queryString = 'SELECT Id,'+String.join(sourceFieldList, ',')+' FROM Account WHERE Id=: pharmacyUserId';
        Account pharmacyUserDetails = Database.query(queryString);
        Map<String,String> targetFieldToValueMap = new Map<String, String>();

        for(String accountField : sourceFieldToMetadataMap.keyset()){
            String targetFieldName = String.valueOf(sourceFieldToMetadataMap.get(accountField).US_WSREMS__Target_Field__c).endsWithIgnoreCase('__c') ?
                (SYN_AppLiterals.NAMESPACE_STRING+sourceFieldToMetadataMap.get(accountField).US_WSREMS__Target_Field__c) : sourceFieldToMetadataMap.get(accountField).US_WSREMS__Target_Field__c ;
            
            targetFieldToValueMap.put(targetFieldName , String.valueof(pharmacyUserDetails.get(accountField)));
        }

        for(LayoutSection ls : existingLaoutSection){
            for(LayoutField field : ls.lstFields){
                if(targetFieldToValueMap.containsKey(field.fieldName)){
                    field.fieldValue = targetFieldToValueMap.get(field.fieldName);
                    field.isInputReadOnly = false;
                }
                if(field.fieldName == SYN_AppLiterals.NAMESPACE_STRING+'Pharmacy_User__c'){
                    field.fieldValue = pharmacyUserId;
                }
            }
        }
        return existingLaoutSection;
    }

    
    /* methodName : getRelatedFieldsForPharmacy
        Parameter : 
        Description: This method will fetch field values for related field to Pharmacy User based on metadata records.
        createdDate: 2nd August, 2021
    */ 
    @AuraEnabled
    public static List<LayoutSection> getRelatedFieldsForPharmacy(String existingLaoutSectionString, String pharmacyId){

        List<LayoutSection> existingLaoutSection = (List<LayoutSection>)JSON.deserialize(existingLaoutSectionString, List<LayoutSection>.class);
        //Querying all metadata records to store all the fields for mapping.
        List<String> sourceFieldList = new List<String>();
        Map<String, US_WSREMS__Field_Mapping_Config__mdt> sourceFieldToMetadataMap = new Map<String, US_WSREMS__Field_Mapping_Config__mdt>();
        for(US_WSREMS__Field_Mapping_Config__mdt metadataObject : [SELECT Id, US_WSREMS__Source_Field__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c,US_WSREMS__Source_Object__c 
                                                        FROM US_WSREMS__Field_Mapping_Config__mdt
                                                        WHERE US_WSREMS__Target_Object__c = 'Case' AND US_WSREMS__Parent_Field__c = 'Pharmacy__c' AND US_WSREMS__IsActive__c = true AND US_WSREMS__Source_Field__c != null]){
             String fieldName = string.valueOf(metadataObject.US_WSREMS__Source_Field__c).endsWithIgnoreCase('__c') ? (SYN_AppLiterals.NAMESPACE_STRING+metadataObject.US_WSREMS__Source_Field__c) : metadataObject.US_WSREMS__Source_Field__c ;
                                                            
                                              sourceFieldList.add(fieldName);
            sourceFieldToMetadataMap.put(fieldName, metadataObject);
            
        }
        pharmacyId =  String.escapeSingleQuotes(pharmacyId);
        String queryString = 'SELECT Id,'+String.join(sourceFieldList, ',')+' FROM Account WHERE Id=: pharmacyId';
        Account pharmacyDetails = Database.query(queryString);
        Map<String,String> targetFieldToValueMap = new Map<String, String>();

        for(String accountField : sourceFieldToMetadataMap.keyset()){
            String targetFieldName = String.valueOf(sourceFieldToMetadataMap.get(accountField).US_WSREMS__Target_Field__c).endsWithIgnoreCase('__c') ?
                (SYN_AppLiterals.NAMESPACE_STRING+sourceFieldToMetadataMap.get(accountField).US_WSREMS__Target_Field__c) : sourceFieldToMetadataMap.get(accountField).US_WSREMS__Target_Field__c ;
            
            targetFieldToValueMap.put(targetFieldName , String.valueof(pharmacyDetails.get(accountField)));
            
         //   targetFieldToValueMap.put(sourceFieldToMetadataMap.get(accountField).US_WSREMS__Target_Field__c, String.valueof(pharmacyDetails.get(accountField)));
        }

        for(LayoutSection ls : existingLaoutSection){
            for(LayoutField field : ls.lstFields){
                if(targetFieldToValueMap.containsKey(field.fieldName)){
                    field.fieldValue = targetFieldToValueMap.get(field.fieldName);
                    field.isInputReadOnly = false;
                }
                if(field.fieldName == SYN_AppLiterals.NAMESPACE_STRING+'Pharmacy__c'){
                    field.fieldValue = pharmacyId;
                }
            }
        }
        return existingLaoutSection;
    }
    
     /* methodName : getObjectAPIName
        Parameter : 
        Description: This method will fetch API Name of the object based on the record ID
        createdDate: 3rd August, 2021
    */ 
    @AuraEnabled
    public static string getObjectAPIName(Id recordId){
        Schema.sobjectType objype  = recordId.getSobjectType();
        return String.valueof(objype);
    }
    
    public static boolean isKnowledgeAssessButton(String quickActionNameStr){
        for (SYN_Knowledge_Assessment__mdt KA : SYN_Knowledge_Assessment__mdt.getAll().values()){
            if(KA.Quick_Action_Name__c == quickActionNameStr ){
                return true;
            }
        }
        return false;
    }
    
    public static Map<String,String> KAButtonNameToCaseRCType(){
        map<String,String> buttonNameToRCtype = new Map<String,String>();
        for (SYN_Knowledge_Assessment__mdt KA : SYN_Knowledge_Assessment__mdt.getAll().values()){
            buttonNameToRCtype.put(KA.Quick_Action_Name__c , KA.Case_RCTypeDev_Name__c);
        }
        return buttonNameToRCtype;       
    }
    @AuraEnabled    
        public static String getNameSpace(){
           
            String NameSpace_Str = SYN_AppLiterals.NAMESPACE_STRING;
            return NameSpace_Str;
        }
    
    @AuraEnabled
    public static RemsPagelayoutComponent.ValidationDetails DEAValidation_enrollment(Id recordTypeId , String fields){
       return RemsPagelayoutComponent.DEAvalidation( recordTypeId ,  fields);
    }
    
    /********************************************************************************************************************************************************
    Method Name     : getRemsServiceProgramName
    Description     : get the rems program name from REMS Service based on record id.
    CreatedBy       : Thandavakrishna Dindu
    ********************************************************************************************************************************************************** */
    @AuraEnabled 
    Public static string getRemsServiceProgramName( id recordId){
    
        return [SELECT Id, US_WSREMS__REMSProgram__c, US_WSREMS__REMSProgram__r.Name FROM US_WSREMS__REMS_Service_Summary__c WHERE Id =: recordId AND US_WSREMS__REMSProgram__c != null].US_WSREMS__REMSProgram__r.Name;
    }
    
    
   /********************************************************************************************************************************************************
    Method Name     : getProgramName
    Description     : get the rems program name from Account based on record id.
    CreatedBy       : Thandavakrishna Dindu
    ********************************************************************************************************************************************************** */
    Public static string getProgramName( id recordId){
    
        return [SELECT Id, US_WSREMS__REMS_Program__c, US_WSREMS__REMS_Program__r.Name FROM Account WHERE Id =: recordId AND US_WSREMS__REMS_Program__c != null].US_WSREMS__REMS_Program__r.Name;
    }
    
    /********************************************************************************************************************************************************
    Method Name     : getProgramBasedFieldMapping
    Description     : returns auto populate fields mapping.
    CreatedBy       : Thandavakrishna Dindu
    ********************************************************************************************************************************************************** */  
    Public static Map<String,string> getProgramBasedFieldMapping(String SourceObj , String TarObj, String SourceRCtyName , String TarRCtypeName, String SectionLabel, String programName, String remServiceReqType, String parentfield ){
    
        Map<string,string> TargetSourceFieldMapping = new Map<String,string>();
       
         if(parentfield=='Onload')
        {
         US_WSREMS__Field_Mapping_Config__mdt mdtParentField= [SELECT  US_WSREMS__Parent_Field__c  FROM US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Program__c != null AND 
                                                            US_WSREMS__Program__r.MasterLabel ='Macitentan REMS' and US_WSREMS__Target_RecordType_Name__c=:TarRCtypeName and US_WSREMS__Source_RecordType_Name__c=:SourceRCtyName  and US_WSREMS__IsActive__c = True and US_WSREMS__Request_Type__c=:remServiceReqType and US_WSREMS__Source_Field__c='Id' Limit 1]; 
           if(mdtParentField.US_WSREMS__Parent_Field__c!=null) 
           {
             parentfield=mdtParentField.US_WSREMS__Parent_Field__c;   
           }
        
        }
		for (US_WSREMS__Field_Mapping_Config__mdt mdt : [SELECT id,US_WSREMS__Program__c,US_WSREMS__Request_Type__c,US_WSREMS__Section_Name__c,US_WSREMS__Source_Field__c,US_WSREMS__Source_Object__c,
                                                                US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Target_Field__c,US_WSREMS__Target_Object__c,US_WSREMS__Target_RecordType_Name__c FROM US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Program__c != null AND 
                                                             US_WSREMS__Program__r.MasterLabel =: programName AND US_WSREMS__Request_Type__c Like:  '%'+remServiceReqType+'%' AND US_WSREMS__Target_RecordType_Name__c =: TarRCtypeName AND US_WSREMS__Parent_Field__c =: parentfield AND US_WSREMS__isOnLoad__c = True AND US_WSREMS__IsActive__c = True]){
           
           
            TargetSourceFieldMapping.put( mdt.US_WSREMS__Target_Field__c, mdt.US_WSREMS__Source_Field__c);
        }
        return TargetSourceFieldMapping;
    }
    
     /********************************************************************************************************************************************************
    Method Name     : deleteDistLink
    Description     : deletes ContentDistribution (Fax Transformation feature)
    CreatedBy       : Fax trandformation feature (Product Team)
    ********************************************************************************************************************************************************** */  
    
    @AuraEnabled    
    public static void deleteDistLink(String distObjId){
        ContentDistribution distObj = new ContentDistribution();
        distObj.Id=distObjId;
        try{
            delete distObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
    
    public class LayoutSection {
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;
        @AuraEnabled public Integer totalColumns;
        public LayoutSection (){ }
        public LayoutSection( String label, Integer totalColumns ) {
            this.label = label;
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();
        }
    }

    private class LayoutColumn {
        private List<LayoutField> lstFields;
        public LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }

    public class LayoutField { 
        @AuraEnabled public String fieldName;
        @AuraEnabled public String fieldlabel;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        @AuraEnabled public String fieldValue;
        @AuraEnabled public Boolean isInputReadOnly;
        @AuraEnabled public Boolean isDatefield;
         
        public LayoutField() {}

        public LayoutField( Metadata.LayoutItem li ) {
            //BT6825-278
            String type='Case';
      Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      Schema.SObjectType myobjectSchema = schemaMap.get(type);
      Map<String, Schema.SObjectField> fieldMap = myobjectSchema.getDescribe().fields.getMap(); //BT6825-278
            if(li.field!=null &&  li.field!=''){
           
            this.fieldName = li.field;
                if( li.behavior == Metadata.UiBehavior.Required ) {
                this.isRequired = true;
            }
             else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            }
             Schema.DisplayType fielddataType = fieldMap.get(li.field).getDescribe().getType();   //It provides to get the object fields data type.      
             String label = fieldMap.get(li.field).getDescribe().getLabel();
                this.fieldlabel = label;
                if(fielddataType == Schema.DisplayType.Date)
                this.isDatefield = true;
        }
        }
    }
    
    public class caseDetails{
        @AuraEnabled public String pageLayoutName;
        @AuraEnabled public Id caseRecordTypeId;
        @AuraEnabled public Id programId;
        @AuraEnabled public String requestorType;
        @AuraEnabled public String ParticipantFName;
        @AuraEnabled public String ParticipantLName;
        @AuraEnabled public String ParticipantStatus; //BT-6825-253
        @AuraEnabled public String remsServiceRecordTypeName; //BT-6825-253
        @AuraEnabled public String pageTitle; 
		@AuraEnabled public String programName;
        @AuraEnabled public String participantId;
        @AuraEnabled public String participantFieldAPIName;
        @AuraEnabled public String programRecordType;

        public caseDetails(String pageLayoutName, Id caseRecordTypeId){
            this.pageLayoutName = pageLayoutName;
            this.caseRecordTypeId = caseRecordTypeId;
        }
    }
    
}