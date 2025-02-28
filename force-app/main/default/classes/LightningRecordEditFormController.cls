/**
 * Created by eo02o3u on 3/31/2021.
 */

public class LightningRecordEditFormController {
    
    @AuraEnabled(cacheable=true)
    public static List<LayoutSection> getPageLayoutFields(String str) {
        List<LayoutSection> lstSections = new List<LayoutSection>();

        try {
            // Provide the page layout name here
            // You can give multiple page layout names here as well
            List<String> layoutList = new List<String>{str};
            // Retrieve page layout details
            List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutList);
            Metadata.Layout layout = new Metadata.Layout();
            if(!layouts.isEmpty()){
                layout = (Metadata.Layout) layouts.get(0);
            }

            // We are going to find the fields names and will keep them according to columns so
            // we can show them as per page layout
            for( Metadata.LayoutSection ls : layout.layoutSections ) {
                    if(ls.label == 'Custom Links' || ls.label == 'Fields'){
                            continue;
                        }
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
    public static recordWrapper getPageLayoutforRequestorType(String caseRecordId, Boolean isFlow, String requestorType, String RemsServiceId){
      
        Map<String,String> requestorTypeToPageLayoutMap = new Map<String,String>();
        List<US_WSREMS__REMS_Service_Summary__C> RemsServiceRecLst = new List<US_WSREMS__REMS_Service_Summary__c>();
        for(US_WSREMS__Pagelayout_Configuration__mdt metadataObj : [SELECT Id,US_WSREMS__PageLayout_Name__c, US_WSREMS__Requestor_Type__c ,US_WSREMS__Program__c,US_WSREMS__Rems_Service_RCtype__c FROM US_WSREMS__Pagelayout_Configuration__mdt WHERE US_WSREMS__PageLayout_Name__c != null]){
            String uniqueKeyStr = metadataObj.US_WSREMS__Requestor_Type__c+'$$'+metadataObj.US_WSREMS__Program__c+'$$'+metadataObj.US_WSREMS__Rems_Service_RCtype__c;
            requestorTypeToPageLayoutMap.put(uniqueKeyStr, metadataObj.US_WSREMS__PageLayout_Name__c);
           
        }
        RemsServiceRecLst = [select US_WSREMS__Requestor_Type__c , US_WSREMS__REMSProgram__r.name, RecordType.DeveloperName from US_WSREMS__REMS_Service_Summary__C where id =:RemsServiceId ] ;
        String PageLayoutKeyStr = RemsServiceRecLst[0].US_WSREMS__Requestor_Type__c+'$$'+RemsServiceRecLst[0].US_WSREMS__REMSProgram__r.name+'$$'+RemsServiceRecLst[0].RecordType.DeveloperName;
        
        if(caseRecordId != null && !isFlow){
            Case caseObj = [SELECT Id, US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c, US_WSREMS__Primary_Facility__c from Case WHERE Id=: caseRecordId LIMIT 1];
            String pageLayoutName = requestorTypeToPageLayoutMap.get(caseObj.US_WSREMS__REMS_Service_Summary__r.US_WSREMS__Requestor_Type__c);
            return new recordWrapper(caseObj, pageLayoutName);
            
        }
        else if(isFlow){
            String pageLayoutName = requestorTypeToPageLayoutMap.get(PageLayoutKeyStr);
            return new recordWrapper(null, pageLayoutName);
        }
        return null;
    }
    
    
    @AuraEnabled
    public static Map<String,Id> getAllRecordTypeDetails(String objName) {
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofCaseRecordTypeNameandId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            if(info.isAvailable()){
            mapofCaseRecordTypeNameandId.put(info.getDeveloperName(),info.getRecordTypeId());
        }
    }
        return mapofCaseRecordTypeNameandId;
    }
    public class LayoutSection {
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;
        @AuraEnabled public Integer totalColumns;
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

    public class recordWrapper {
        @AuraEnabled public Case caseRecord;
        @AuraEnabled public String pageLayoutName;

        public recordWrapper(Case caseRecord, String pageLayoutName){
            this.caseRecord = caseRecord;
            this.pageLayoutName = pageLayoutName;
        }
    
    
    }
    @AuraEnabled
    public static Map<String,String> getPrepopFields(Id recordId , string TargetObj , Id RecordTypeId ){
        return RemsPagelayoutComponent.getPrepopFields( recordId ,  TargetObj ,  RecordTypeId);
    }
}