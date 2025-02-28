/**
* @File Name          : REMSchangeOfInformation.cls
* @Description        : This controller is used in the COI Lwc component.
* @Reference		  : changeOfInformation (LWC Component)
* @TestClass          : REMSchangeOfInformation_Test
* @Author 			  : Wilcosource
* @Modification Log   :
* Ver       Date            Developer      		             Modification
* 1.0     05/26/2021        Chaitanya Nandamuri (Wilco)     Initial Implementation. (BT6825-266)
**/
public class REMSchangeOfInformation {
    
    public static SYN_ParticipantEnrollmentController.caseDetails casePageLayoutDetails;
    Public static Id participantId;
    
    
    @AuraEnabled(cacheable=true)
    public static List<LayoutSection> getPageLayoutFields(String remsServiceId) {
        
        List<Account>  participantDetailsList ;
        List<LayoutSection> sectionsList = new List<LayoutSection>();
        Map<String,String> FieldMappingMap = new Map<String,String>();
        
         //MACI-COI - SP8- 54
        US_WSREMS__REMS_Service_Summary__c remsSummary = [SELECT Id, US_WSREMS__REMSProgram__c, US_WSREMS__REMSProgram__r.Name, RecordtypeId, Recordtype.Name FROM US_WSREMS__REMS_Service_Summary__c WHERE Id=: remsServiceId LIMIT 1];
        if(remsSummary != null){ //MACI-COI - SP8- 54
            if(remsSummary.US_WSREMS__REMSProgram__r.Name == Label.Macitentan_REMS_Program_Name){  //MACI-COI - SP8- 54
                casePageLayoutDetails = SYN_ParticipantEnrollmentController.getPageLayoutforRequestorType(remsServiceId,'COI'); //MACI-COI - SP8- 54
            }else{ 
                casePageLayoutDetails = SYN_ParticipantEnrollmentController.getPageLayoutforRequestorType(remsServiceId,'');
            }
        }
        
        // Method M1 to query CustomMdata to get the field Mapping
        FieldMappingMap   = fieldMappingCustomMetadata(remsServiceId);
        
        // Method M2 that takes AccountId and account field to query Account details .
        if ( FieldMappingMap.values() != null ){
            participantDetailsList = getParticipantDetails(participantId , FieldMappingMap.values());
        }
        
        try {
            // Provide the page layout name here
            List<String> layoutList = new List<String>{casePageLayoutDetails.pageLayoutName };
                List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutList);
            Metadata.Layout layout = new Metadata.Layout();
            if(!layouts.isEmpty()){
                layout = (Metadata.Layout) layouts.get(0);
            }
            
            // We are going to find the fields names and will keep them according to columns
            for( Metadata.LayoutSection ls : layout.layoutSections ) {
                if(ls.label != SYN_Utilitycls.CASE_INFORMATION && ls.label != SYN_Utilitycls.CUSTOM_LINKS && ls.label != '-'){
                    LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );
                    section.caseRTId = casePageLayoutDetails.caseRecordTypeId;
                    section.participantId = participantId;
                    section.mappingFieldsMap = FieldMappingMap;
                    
                    List<LayoutColumn> columnsList = new List<LayoutColumn>();
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
                                
                                LayoutField field = new LayoutField ( li );
                                
                                string sourceAccountFieldAPI = FieldMappingMap.get(li.field);
								
								if(li.field=='US_WSREMS__Program_Picklist__c'){
                                   field.fieldValue=remsSummary.US_WSREMS__REMSProgram__r.Name;  
                                }
                                
                                if (sourceAccountFieldAPI != null){
                                    field.fieldValue = participantDetailsList[0].get(sourceAccountFieldAPI) != null ?
                                        String.valueOf(participantDetailsList[0].get(sourceAccountFieldAPI))  : ''; 
                                } 
                                
                                if (sourceAccountFieldAPI == null && li.field != null ){
                                   // continue;
                                }
								
						        if(li.field=='Program_Record_Type_Control__c'){
                                   field.fieldValue=casePageLayoutDetails.programRecordType;  
                                }
                                if(li.field=='US_WSREMS__Channel__c'){
                                    if (remsSummary.US_WSREMS__REMSProgram__r.Name == 'Macitentan REMS' ){
                                        field.fieldValue='Fax';
                                    }
                                }
                                

                                
                                column.fieldsList.add( field );
                            }
                        }
                        // No need to add a column in the section if there is no field available
                        if( column.fieldsList.size() > 0 ) {
                            columnsList.add( column );
                        }
                    }
                    
                    // Now, we need to arrange the fields in section so we can use them in the iteration on the component
                    
                    if( maxFieldsInColumn > 0 ) {
                        for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                            for( Integer j = 0; j < columnsList.size(); j++ ){
                                if( columnsList[j].fieldsList.size() > i ) {
                                    section.fieldsList.add( columnsList[j].fieldsList[i] );
                                }
                                else {
                                    section.fieldsList.add( new LayoutField() );
                                }
                            }
                        }
                    }
                    
                    sectionsList.add( section );
                }
            }
        }
        catch( Exception e ){
           
            System.assert(false, e.getLineNumber() + ' : ' + e.getMessage() );
        } 
        return sectionsList;
    }
    
    /*Params : remsServiceId
*Returns : Map of Source and Target 
*/  
    public static Map<String,String> fieldMappingCustomMetadata(String remsServiceId){
        
        string remsRequstorTypeStr;
        string programName ='';
        Map<String, string> sourceTargetfieldMap = new Map<String, String>();
        
        for (US_WSREMS__REMS_Service_Summary__c  rems : [select US_WSREMS__Participant__c , US_WSREMS__Requestor_Type__c , US_WSREMS__REMSProgram__r.Name    from US_WSREMS__REMS_Service_Summary__c where Id =:remsServiceId limit 1]){
            participantId = rems.US_WSREMS__Participant__c;
            remsRequstorTypeStr = rems.US_WSREMS__Requestor_Type__c;
            programName = rems.US_WSREMS__REMSProgram__r.Name;
        }
        
        for (US_WSREMS__Field_Mapping_Config__mdt fMapSerRec : [SELECT Id, US_WSREMS__IsActive__c, US_WSREMS__Order__c, US_WSREMS__Request_Type__c, US_WSREMS__Source_Field__c, US_WSREMS__Source_Object__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c, NamespacePrefix, US_WSREMS__Program__r.MasterLabel  FROM
                                                                US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Program__r.MasterLabel =: programName AND   US_WSREMS__Source_Object__c =:  SYN_Utilitycls.CASE_OBJECT  
                                                                AND US_WSREMS__Target_Object__c =: SYN_Utilitycls.ACCOUNT_OBJECT AND NamespacePrefix != 'US_WSREMS' AND US_WSREMS__IsActive__c = true ]  ){
                                                         
                                                         string requestTypeStr = fMapSerRec.US_WSREMS__Request_Type__c;
                                                         
                                                         String SourceStr = fMapSerRec.US_WSREMS__Source_Field__c.contains('__c') && fMapSerRec.NamespacePrefix == 'US_WSREMS'  ? 'US_WSREMS__'+fMapSerRec.US_WSREMS__Source_Field__c : fMapSerRec.US_WSREMS__Source_Field__c;
                                                         String TargetStr = fMapSerRec.US_WSREMS__Target_Field__c.contains('__c') && fMapSerRec.NamespacePrefix == 'US_WSREMS' ? 'US_WSREMS__'+fMapSerRec.US_WSREMS__Target_Field__c : fMapSerRec.US_WSREMS__Target_Field__c;
                                                         
                                                         if(String.isNotBlank(requestTypeStr) && requestTypeStr.split(',') != null && requestTypeStr.split(',').size() > 0){
                                                             for(String requesType : requestTypeStr.split(',') ){
                                                                 if (requesType == remsRequstorTypeStr){
                                                                     
                                                                     sourceTargetfieldMap.put(SourceStr, TargetStr);
                                                                     
                                                                 }
                                                                 
                                                             }
                                                         }
                                                         else{
                                                             if (requestTypeStr == remsRequstorTypeStr){
                                                                 sourceTargetfieldMap.put(SourceStr, TargetStr);
                                                             }
                                                         }                                                        
                                                     }
        return sourceTargetfieldMap;
    }
    
    
    /*Params : AccountId , List of fields to Querry
*Returns : account Object with requested details 
*/  
    Private static List<Account> getParticipantDetails(String participantId , List<String> fieldsToQuerrylist){
        
        string accountFields = string.join(fieldsToQuerrylist,',');
        string accQuerryWithField =  'Select Id ,' +accountFields +' from Account where Id =: participantId limit 1';
        string accQuerryWithNoField = 'Select Id from Account where Id =: participantId limit 1';
        String accountQueryString = !String.isBlank(accountFields)  ? accQuerryWithField : accQuerryWithNoField ;
        
        List <Account> participantAccountList = database.query(accountQueryString);
        
        return participantAccountList;
        
    }   
    
    public class LayoutSection {
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> fieldsList;
        @AuraEnabled public Integer totalColumns;
        @AuraEnabled public Id caseRTId;
        @AuraEnabled public Id participantId;
        @AuraEnabled public Map<String,string> mappingFieldsMap;
        public LayoutSection (){ }
        public LayoutSection( String label, Integer totalColumns ) {
            this.label = label;
            this.totalColumns = totalColumns;
            this.fieldsList = new List<LayoutField>();
        }
    }
    private class LayoutColumn {
        private List<LayoutField> fieldsList;
        public LayoutColumn() {
            this.fieldsList = new List<LayoutField>();
        }
    }
    
    public class LayoutField {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        @AuraEnabled public String fieldValue;
        
        public LayoutField() {}
        
        public LayoutField( Metadata.LayoutItem li ) {
            
            this.fieldName = li.field;
            if( li.behavior == Metadata.UiBehavior.Required ) {
                this.isRequired = true;
            }
            else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            }
        }
    }
    @AuraEnabled
    Public static String updateParticipant(Id caseId , Id parId  , String fieldMappingStr){
        String failedAction='';
        Account updateParticipant = new Account(Id = parId);
        List<Account> participantList = new List<Account>();
        List<Case> createCaseRecordList;
        List<Account> existingAccountRecordList ;
        string querryAccField ='';
        string querryCaseField ='';
        try{
            
            
            
            Map<String,Object > fieldMappingMap = (Map<String, Object>) JSON.deserializeUntyped(fieldMappingStr);
            
            if (fieldMappingMap.Keyset() == null || fieldMappingMap.values() == null ){
                return failedAction;
            }
            
            for (object fieldName :  fieldMappingMap.Keyset() ){
                querryCaseField += ','+String.valueof(fieldName); 
                querryAccField += ','+fieldMappingMap.get(String.valueOf(fieldName));
            }
            
            querryCaseField = 'Select Id '+querryCaseField+' from Case Where Id =: caseId limit 1 ';
            querryAccField = 'Select Id '+querryAccField+' from account Where Id =: parId limit 1 ';
            
            createCaseRecordList = database.query(querryCaseField);
            existingAccountRecordList = database.query(querryAccField);
            if (createCaseRecordList == null || existingAccountRecordList == null){
                return failedAction;
            }
            
            for (string field : fieldMappingMap.keyset()){
                
                string caseValueStr = String.valueOf(createCaseRecordList[0].get(field)) ;
                string AccValueStr = String.valueOf(existingAccountRecordList[0].get(String.valueOf(fieldMappingMap.get(field)) )) ;
                
                
                AccValueStr = AccValueStr == null ? '' : AccValueStr;
                caseValueStr = caseValueStr == null ? '' : caseValueStr;
                
                if ( AccValueStr != caseValueStr ){
                    updateParticipant.put(String.valueOf(fieldMappingMap.get(field)) , createCaseRecordList[0].get(field) == null ? '' : createCaseRecordList[0].get(field));
                }  
                
            }
            
            participantList.add(updateParticipant);
            
        }catch( Exception e ){
            System.assert(false, e.getLineNumber() + ' : ' + e.getMessage() );
        }
        return updateAccount(participantList);
    }
    
    Public static String updateAccount(List<Account> accList){
        
        String updateStatusStr = '';
        if(accList.size() > 0){
            for(Database.SaveResult sr : Database.update(accList, false)){
                if(sr.isSuccess()){
                    updateStatusStr = 'Success';
                }
                else{
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }

            }
        }
        return updateStatusStr;
    }    
      @AuraEnabled(cacheable=true)
    public static List<Account> fetchAccountDetails(String accId) {
        return [Select Id,  Fax, Phone, US_WSREMS__Email__c, ShippingCity, ShippingState, ShippingPostalCode, ShippingStreet,ShippingCountry,SYN_Shipping_Address_2__c,SYN_Ext__c From Account where Id =: accId];
    }
    @AuraEnabled(cacheable=true)
    public static RMSPageLoadWrapper fetchPageLoadParams(String remsServiceId, String SourceObj , String TarObj, String SourceRCtyName , String TarRCtypeName, String SectionLabel) {
        RMSPageLoadWrapper wrapperParams = new RMSPageLoadWrapper();
        wrapperParams.layoutSection = getPageLayoutFields(remsServiceId);
        wrapperParams.fieldMappings = getFieldMapping(SourceObj, TarObj, SourceRCtyName, TarRCtypeName, SectionLabel);
        return wrapperParams;
    }
    private static Map<String,string> getFieldMapping(String SourceObj , String TarObj, String SourceRCtyName , String TarRCtypeName, String SectionLabel ){
        Map<string,string> TargetSourceFieldMapping = new Map<String,string>();
        
        for (SYN_FieldMapping_Config__mdt mdt : SYN_FieldMapping_Config__mdt.getAll().values()){
            if (mdt.Source_Object__c == SourceObj && mdt.Target_Object__c == TarObj && mdt.Source_RecordType_Name__c == SourceRCtyName && mdt.Target_RecordType_Name__c  == TarRCtypeName){
                TargetSourceFieldMapping.put( mdt.Target_Field__c , mdt.Source_Field__c );
            }
        }
        return TargetSourceFieldMapping;
    }
    Public Class RMSPageLoadWrapper {
        @AuraEnabled Public List<LayoutSection> layoutSection;
        @AuraEnabled Public Map<String,string> fieldMappings;
    }
}