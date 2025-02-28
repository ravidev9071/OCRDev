public class SYN_REMSChangeAuthorizedRepCtrl {
    @AuraEnabled(cacheable=true)
      public static List<LayoutSection> getPageLayoutFields(String layoutName) {
          List<LayoutSection> lstSections = new List<LayoutSection>();
          Organization orgData = [SELECT NamespacePrefix FROM Organization][0];
  
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
                  if(ls.label != SYN_REMSChangeAuthorizedRepUtilityCls.CASE_INFORMATION && ls.label != SYN_REMSChangeAuthorizedRepUtilityCls.CUSTOM_LINKS && ls.label != '-'){
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
                                  LayoutField field = new LayoutField ( li );
                                  if (orgData.NamespacePrefix != null && field.fieldName != null) {
                                      if (!field.fieldName.startsWithIgnoreCase(SYN_AppLiterals.NAMESPACE_STRING) && field.fieldName.endsWithIgnoreCase('__c')) {
                                          field.fieldName = SYN_AppLiterals.NAMESPACE_STRING+field.fieldName;
                                      }
                                  }
                                  // Pass the LayoutItem object in the LayoutField consturctor
                                  column.lstFields.add( field );
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
      public static caseDetails getPageLayoutforRequestorType(String remsServiceId){
          Map<String,US_WSREMS__Pagelayout_Configuration__mdt> requestorTypeToPageLayoutMap = new Map<String,US_WSREMS__Pagelayout_Configuration__mdt>();
          for(US_WSREMS__Pagelayout_Configuration__mdt metadataObj : [SELECT Id,US_WSREMS__PageLayout_Name__c, US_WSREMS__Requestor_Type__c,US_WSREMS__RecordType_Name__c, US_WSREMS__Program__c, US_WSREMS__Rems_Service_RCtype__c  FROM US_WSREMS__Pagelayout_Configuration__mdt WHERE US_WSREMS__PageLayout_Name__c != null AND US_WSREMS__Object_Name__c = 'Case']){
              String keyforMap = metadataObj.US_WSREMS__Requestor_Type__c+'$'+metadataObj.US_WSREMS__Program__c+'$'+metadataObj.US_WSREMS__Rems_Service_RCtype__c;
              requestorTypeToPageLayoutMap.put(keyforMap, metadataObj);
          }
           
          US_WSREMS__REMS_Service_Summary__c remsSummary = [SELECT Id, US_WSREMS__Requestor_Type__c, US_WSREMS__REMSProgram__c, US_WSREMS__REMSProgram__r.Name, RecordtypeId FROM US_WSREMS__REMS_Service_Summary__c WHERE Id=: String.escapeSingleQuotes(remsServiceId) WITH SECURITY_ENFORCED  LIMIT 1];
          string remsRCtypeAPInameStr = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosById().get(remsSummary.RecordtypeId).getDeveloperName();
          String keyFromREMSService = remsSummary.US_WSREMS__Requestor_Type__c+'$'+remsSummary.US_WSREMS__REMSProgram__r.Name+'$'+remsRCtypeAPInameStr;
          String pageLayoutName = requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__PageLayout_Name__c;
          Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__RecordType_Name__c).getRecordTypeId();
          //caseDetails caseDetailsObj = new caseDetails(pageLayoutName, caseRTId); 
          caseDetails caseDetailsObj = new caseDetails(pageLayoutName, caseRTId,null,null,null);
          caseDetailsObj.requestorType = remsSummary.US_WSREMS__Requestor_Type__c;  
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
           
          US_WSREMS__REMS_Service_Summary__c remsSummary = [SELECT Id, US_WSREMS__Requestor_Type__c, US_WSREMS__REMSProgram__c, US_WSREMS__REMSProgram__r.Name FROM US_WSREMS__REMS_Service_Summary__c WHERE Id=: String.escapeSingleQuotes(remsServiceId) WITH SECURITY_ENFORCED  LIMIT 1];
          String keyFromREMSService = remsSummary.US_WSREMS__Requestor_Type__c+'$'+remsSummary.US_WSREMS__REMSProgram__r.Name;
          String pageLayoutName = requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__PageLayout_Name__c;
          Id affiliationRTId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get(requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__RecordType_Name__c).getRecordTypeId();
          //caseDetails recordObj = new caseDetails(pageLayoutName, affiliationRTId);
          caseDetails recordObj = new caseDetails(pageLayoutName, affiliationRTId,null,null,null);
          recordObj.programId = remsSummary.US_WSREMS__REMSProgram__c;
          return recordObj;
              
      }
      /* methodName : getPageLayoutNameAndRecordTypeIdForPharmacyRegistration
          Parameter : 
          Description: This method will fetch the Pagelayout name and RecordTypeId for Pharmacy Registration Case.
          createdDate: 29th July, 2021
      */ 
      @AuraEnabled
      public static caseDetails getPageLayoutNameAndRecordTypeIdForChangeAuthorizedRep( String recordId){
          String programName ='';
          String pageLayoutName = SYN_REMSChangeAuthorizedRepUtilityCls.CHANGE_AUTHORIZED_REPRESENTATIVE_LAYOUT;
          Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_REMSChangeAuthorizedRepUtilityCls.CHANGE_AUTHORIZED_REPRESENTATIVE_ID).getRecordTypeId();
          String caseRTName = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SYN_REMSChangeAuthorizedRepUtilityCls.CHANGE_AUTHORIZED_REPRESENTATIVE_ID).getDeveloperName();
          
          US_WSREMS__REMS_Service_Summary__c oSummary = [Select id,US_WSREMS__Participant__c,US_WSREMS__REMSProgram__r.Name,US_WSREMS__REMSProgram__c FROM US_WSREMS__REMS_Service_Summary__c where Id=: String.escapeSingleQuotes(recordId) WITH SECURITY_ENFORCED  LIMIT 1 ];
          List<US_WSREMS__Affiliation__c> oAffliationList =[Select id,US_WSREMS__Pharmacy_User__c,US_WSREMS__isActive__c,US_WSREMS__End_Date__c,US_WSREMS__Pharmacy__c,US_WSREMS__REMSProgram__c,US_WSREMS__Start_Date__c,recordTypeId,US_WSREMS__REMS_Service__c,US_WSREMS__UserType__c
                                       FROM US_WSREMS__Affiliation__c where US_WSREMS__REMSProgram__c=:oSummary.US_WSREMS__REMSProgram__c AND US_WSREMS__Pharmacy__c=: oSummary.US_WSREMS__Participant__c AND US_WSREMS__isActive__c = true AND US_WSREMS__UserType__c includes (:System.Label.SYN_Affiliation_User_Type_value) WITH SECURITY_ENFORCED  LIMIT 1 ];
          // return new caseDetails(pageLayoutName, caseRTId);          
           if(oSummary.US_WSREMS__REMSProgram__c != null){
              programName = oSummary.US_WSREMS__REMSProgram__r.Name;
          }
          string pp = oSummary.US_WSREMS__REMSProgram__r.Name+'-'+caseRTName;
          caseDetails caseDetailsObj = new caseDetails(pageLayoutName, caseRTId, null,oSummary,pp);
          caseDetailsObj.programRecordType = programName+'-'+caseRTName;      
           if (!oAffliationList.isEmpty()) {
             return new caseDetails(pageLayoutName, caseRTId, oAffliationList[0],oSummary, caseDetailsObj.programRecordType);
           }
          
         
          return caseDetailsObj;
         // return new caseDetails(pageLayoutName, caseRTId, null,oSummary);
      }
  
       /* methodName : getRelatedFieldsForPharmacyUser
          Parameter : 
          Description: This method will fetch field values for related field to Pharmacy User based on metadata records.
          createdDate: 30th July, 2021
      */ 
      @AuraEnabled
      public static List<LayoutSection> getRelatedFieldsForPharmacyUser(String existingLaoutSectionString, String pharmacyUserId,Boolean onLoadOnly,String recordId){
  
          List<LayoutSection> existingLaoutSection = (List<LayoutSection>)JSON.deserialize(existingLaoutSectionString, List<LayoutSection>.class);
          //Querying all metadata records to store all the fields for mapping.
          Set<String> sourceFieldSet = new set<String>();
          US_WSREMS__REMS_Service_Summary__c oSummary;
          Map<String, US_WSREMS__Field_Mapping_Config__mdt> sourceFieldToMetadataMap = new Map<String, US_WSREMS__Field_Mapping_Config__mdt>();
          for(US_WSREMS__Field_Mapping_Config__mdt metadataObject : [SELECT Id, US_WSREMS__Source_Field__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c,US_WSREMS__Source_Object__c 
                                                          FROM US_WSREMS__Field_Mapping_Config__mdt
                                                          WHERE US_WSREMS__Target_Object__c = 'Case' AND US_WSREMS__Parent_Field__c = 'US_WSREMS__Pharmacy_User__c' AND US_WSREMS__IsActive__c = true AND US_WSREMS__Source_Field__c != null AND US_WSREMS__isOnLoad__c = :onLoadOnly]){
              String fieldName = metadataObject.US_WSREMS__Source_Field__c ;
              sourceFieldSet.add(fieldName);
              sourceFieldToMetadataMap.put(fieldName, metadataObject);
              
          }
          pharmacyUserId =  String.escapeSingleQuotes(pharmacyUserId);
          String queryString = 'SELECT Id,'+String.join((Iterable<String>)sourceFieldSet, ',')+' FROM Account WHERE Id=: pharmacyUserId';
          Account pharmacyUserDetails = Database.query(queryString);
          Map<String,String> targetFieldToValueMap = new Map<String, String>();
          List<US_WSREMS__Affiliation__c> oAffliationList = new List<US_WSREMS__Affiliation__c>();
  
          if (String.isNotEmpty(recordId)) {
              oSummary = [Select id,US_WSREMS__Participant__c,US_WSREMS__REMSProgram__r.name,US_WSREMS__REMSProgram__c,US_WSREMS__Pharmacy__c from US_WSREMS__REMS_Service_Summary__c where Id=: String.escapeSingleQuotes(recordId) WITH SECURITY_ENFORCED  LIMIT 1 ];
              oAffliationList =[Select id,US_WSREMS__Pharmacy_User__c,US_WSREMS__isActive__c,US_WSREMS__End_Date__c,US_WSREMS__Pharmacy__c,US_WSREMS__REMSProgram__c,US_WSREMS__Start_Date__c,recordTypeId,US_WSREMS__REMS_Service__c,US_WSREMS__UserType__c
                                           FROM US_WSREMS__Affiliation__c where US_WSREMS__Pharmacy__c=: oSummary.US_WSREMS__Participant__c AND US_WSREMS__isActive__c = true AND US_WSREMS__UserType__c includes (:System.Label.SYN_Affiliation_User_Type_value) WITH SECURITY_ENFORCED  LIMIT 1 ];
          }
  
  
          for(String accountField : sourceFieldToMetadataMap.keyset()){
              String targetFieldName = sourceFieldToMetadataMap.get(accountField).US_WSREMS__Target_Field__c ;
              
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
  
                  if (onLoadOnly && !oAffliationList.isEmpty()) {
                      if(field.fieldName == SYN_AppLiterals.NAMESPACE_STRING+'UserType_ar__c'){
                          field.fieldValue = oAffliationList[0].US_WSREMS__UserType__c;
                      }
                  }
                  if (onLoadOnly && oSummary != null) {
                      if(field.fieldName == SYN_AppLiterals.NAMESPACE_STRING+'Program_Picklist__c'){
                        field.fieldValue = oSummary.US_WSREMS__REMSProgram__r.name;
                      }
                    }
  
                  if (onLoadOnly && oSummary != null) {
                      if(field.fieldName == SYN_AppLiterals.NAMESPACE_STRING+'REMS_Program__c'){
                          field.fieldValue = oSummary.US_WSREMS__REMSProgram__c;
                      }
                      else if(field.fieldName == SYN_AppLiterals.NAMESPACE_STRING+'Pharmacy__c'){
                          field.fieldValue = oSummary.US_WSREMS__Participant__c;
                      }
                  }
              }
          }
          return existingLaoutSection;
      }
  
      @AuraEnabled
      public static List<LayoutSection> getRelatedFieldsForPharmacy(String existingLaoutSectionString, String pharmacyId){
          // Organization orgData = [SELECT NamespacePrefix FROM Organization][0];
  
          List<LayoutSection> existingLaoutSection = (List<LayoutSection>)JSON.deserialize(existingLaoutSectionString, List<LayoutSection>.class);
          //Querying all metadata records to store all the fields for mapping.
          Set<String> sourceFieldSet = new Set<String>();
          Map<String, US_WSREMS__Field_Mapping_Config__mdt> sourceFieldToMetadataMap = new Map<String, US_WSREMS__Field_Mapping_Config__mdt>();
          for(US_WSREMS__Field_Mapping_Config__mdt metadataObject : [SELECT Id, US_WSREMS__Source_Field__c, US_WSREMS__Target_Field__c, US_WSREMS__Target_Object__c,US_WSREMS__Source_Object__c 
                                                          FROM US_WSREMS__Field_Mapping_Config__mdt
                                                          WHERE US_WSREMS__Target_Object__c = 'Case' AND US_WSREMS__Parent_Field__c = 'US_WSREMS__Pharmacy__c' AND US_WSREMS__IsActive__c = true AND US_WSREMS__Source_Field__c != null AND US_WSREMS__isOnLoad__c=false]){
               String fieldName =  metadataObject.US_WSREMS__Source_Field__c ;
  
              // if (orgData.NamespacePrefix != null && String.isNotEmpty(fieldName)) {
              //     if (fieldName.startsWithIgnoreCase(REMSAppLiterals.NAMESPACE_STRING) 
              //         && fieldName.endsWithIgnoreCase('__c')) {
              //         fieldName = fieldName.removeStartIgnoreCase(REMSAppLiterals.NAMESPACE_STRING);
              //     }
              // }
               sourceFieldSet.add(fieldName);
              sourceFieldToMetadataMap.put(fieldName, metadataObject);
          }
          pharmacyId =  String.escapeSingleQuotes(pharmacyId);
          if (!sourceFieldSet.isEmpty()) {
              String queryString = 'SELECT Id,'+String.join((Iterable<String>)sourceFieldSet, ',')+' FROM Account WHERE Id=: pharmacyId';
              Account pharmacyDetails = Database.query(queryString);
              Map<String,String> targetFieldToValueMap = new Map<String, String>();
      
              for(String accountField : sourceFieldToMetadataMap.keyset()){
                  String targetFieldName =  sourceFieldToMetadataMap.get(accountField).US_WSREMS__Target_Field__c ;
                  targetFieldToValueMap.put(targetFieldName , String.valueof(pharmacyDetails.get(accountField)));
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
      
      
      @AuraEnabled    
          public static String getNameSpace(){
             
              String NameSpace_Str = SYN_AppLiterals.NAMESPACE_STRING;
              return NameSpace_Str;
          }
      
      public class LayoutSection {
          @AuraEnabled public String label;
          @AuraEnabled public List<LayoutField> lstFields;
          @AuraEnabled public Integer totalColumns;
          @AuraEnabled public String onchange;
  
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
          @AuraEnabled public Boolean isRequired;
          @AuraEnabled public Boolean isReadOnly;
          @AuraEnabled public String fieldValue;
          @AuraEnabled public Boolean isInputReadOnly;
           
          public LayoutField() {}
  
          public LayoutField( Metadata.LayoutItem li ) {
  
              //this.fieldName = li.field;
              if(li.field!=null &&  li.field!='')
                  this.fieldName = li.field;
                  //(!li.field.startsWithIgnoreCase(REMSAppLiterals.NAMESPACE_STRING) && li.field.endsWithIgnoreCase('__c'))?(REMSAppLiterals.NAMESPACE_STRING+li.field):li.field;
              if( li.behavior == Metadata.UiBehavior.Required ) {
                  this.isRequired = true;
              }
              else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                  this.isReadOnly = true;
              }
          }
      }
      
      public class caseDetails{
          @AuraEnabled public String pageLayoutName;
          @AuraEnabled public Id caseRecordTypeId;
          @AuraEnabled public Id programId;
          @AuraEnabled public String requestorType;
          @AuraEnabled public US_WSREMS__Affiliation__c oAffliation;
          @AuraEnabled public Id affliationRecordTypeId;
          @AuraEnabled public US_WSREMS__REMS_Service_Summary__c oSummary;
          @AuraEnabled public String programRecordType;
          
          public caseDetails(String pageLayoutName, Id caseRecordTypeId, US_WSREMS__Affiliation__c oAffliation,US_WSREMS__REMS_Service_Summary__c oSummary,String programRecType){
              this.pageLayoutName = pageLayoutName;
              this.caseRecordTypeId = caseRecordTypeId;
              this.oAffliation = oAffliation;
              this.oSummary = oSummary; 
              this.programRecordType = programRecType;
              //Affiliation__c oAffliation
          }
      }
      
  }