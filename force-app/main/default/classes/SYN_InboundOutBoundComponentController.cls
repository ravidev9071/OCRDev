public class SYN_InboundOutBoundComponentController {
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
                if(ls.label != SYN_IncontactUtility.CASE_INFORMATION && ls.label != SYN_IncontactUtility.CUSTOM_LINKS && ls.label != '-'){
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
        createdDate: 27 Jan 2022
    */ 
    @AuraEnabled
    public static caseDetails getPageLayoutforRequestorType(String remsCaseId){
        Map<String,US_WSREMS__Pagelayout_Configuration__mdt> requestorTypeToPageLayoutMap = new Map<String,US_WSREMS__Pagelayout_Configuration__mdt>();
        for(US_WSREMS__Pagelayout_Configuration__mdt metadataObj : [SELECT Id,US_WSREMS__PageLayout_Name__c, US_WSREMS__Requestor_Type__c,US_WSREMS__RecordType_Name__c, US_WSREMS__Program__c FROM US_WSREMS__Pagelayout_Configuration__mdt WHERE US_WSREMS__PageLayout_Name__c != null AND US_WSREMS__Object_Name__c = 'Case']){
            String keyforMap = metadataObj.US_WSREMS__Requestor_Type__c+'$'+metadataObj.US_WSREMS__Program__c+'$'+metadataObj.US_WSREMS__RecordType_Name__c;
          
            requestorTypeToPageLayoutMap.put(keyforMap, metadataObj);
            
        }
        Case caseObj=[select id,US_WSREMS__REMS_Service_Summary__c from case where id=:remsCaseId Limit 1];
         
        US_WSREMS__REMS_Service_Summary__c remsSummary = [SELECT Id, US_WSREMS__Requestor_Type__c, US_WSREMS__REMSProgram__c, US_WSREMS__REMSProgram__r.Name,RecordType.DeveloperName FROM US_WSREMS__REMS_Service_Summary__c WHERE Id=: caseObj.US_WSREMS__REMS_Service_Summary__c LIMIT 1];
        String keyFromREMSService=null;
        
        If(remsSummary.RecordType.DeveloperName.contains('Inbound')){
            keyFromREMSService  = remsSummary.US_WSREMS__Requestor_Type__c+'$'+remsSummary.US_WSREMS__REMSProgram__r.Name+'$'+'Inbound_Call';
        }else If(remsSummary.RecordType.DeveloperName.contains('Outbound')){
             keyFromREMSService  = remsSummary.US_WSREMS__Requestor_Type__c+'$'+remsSummary.US_WSREMS__REMSProgram__r.Name+'$'+'Outbound_Call';
        }else{
             keyFromREMSService  = remsSummary.US_WSREMS__Requestor_Type__c+'$'+remsSummary.US_WSREMS__REMSProgram__r.Name+'$'+'PAE';
        }
      
        
        String pageLayoutName = requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__PageLayout_Name__c;
       
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__RecordType_Name__c).getRecordTypeId();
        CaseDetails caseDetails = new CaseDetails(pageLayoutName, caseRTId);
       
        caseDetails.requestorType = requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__RecordType_Name__c.contains('_')?  requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__RecordType_Name__c.replace('_',' ')  : requestorTypeToPageLayoutMap.get(keyFromREMSService).US_WSREMS__RecordType_Name__c;
        return caseDetails;
            
    }

  
    @AuraEnabled
    public static string getObjectAPIName(Id recordId){
        Schema.sobjectType objype  = recordId.getSobjectType();
        return String.valueof(objype);
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
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;
        @AuraEnabled public String fieldValue;
        @AuraEnabled public Boolean isInputReadOnly;
         
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
    
    public class caseDetails{
        @AuraEnabled public String pageLayoutName;
        @AuraEnabled public Id caseRecordTypeId;
        @AuraEnabled public Id programId;
        @AuraEnabled public String requestorType;
        public caseDetails(String pageLayoutName, Id caseRecordTypeId){
            this.pageLayoutName = pageLayoutName;
            this.caseRecordTypeId = caseRecordTypeId;
            //this.programId = programId;
        }
    }

}