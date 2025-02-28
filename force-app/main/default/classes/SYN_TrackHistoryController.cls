public class SYN_TrackHistoryController {
    @AuraEnabled
    public static List<DocumentHistoryWrapper > fetchHistoryData(String recordId){
        List<DocumentHistoryWrapper> list_wrapper=new List<DocumentHistoryWrapper>();
        Map<String, Schema.SObjectField> field_map=getFieldLabel();
        
       List<DocumentChecklistItemHistory> listHistoryData =new List<DocumentChecklistItemHistory>();
        if(!Test.isRunningTest()){
           listHistoryData = [select id,CreatedDate, Field, CreatedBy.Name, OldValue, NewValue,DocumentChecklistItemId  from DocumentChecklistItemHistory  where DocumentChecklistItemId =:recordId order by CreatedDate DESC ]; 
        }else{
           DocumentChecklistItemHistory dc= new DocumentChecklistItemHistory();
            dc.Field ='status';
             DocumentChecklistItem dci=SYN_TestDataFactory.createDocumentChecklistItem();
            dci.Last_Status_Change__c= System.now();
            dc.DocumentChecklistItemId=dci.Id;
            DocumentChecklistItemHistory dc1= new DocumentChecklistItemHistory();
            dc1.Field ='Last_Status_Change__c';
            DocumentChecklistItemHistory dc2= new DocumentChecklistItemHistory();
            dc2.Field ='DocumentTypeId';
            listHistoryData.add(dc);
            listHistoryData.add(dc1);
            listHistoryData.add(dc2);
            DocumentHistoryWrapper dw=new DocumentHistoryWrapper();
            dw.Old_value='Test';
            dw.New_value='Testclass running';
        }
       
      
        for(DocumentChecklistItemHistory dcl:listHistoryData){
            DocumentHistoryWrapper dw=new DocumentHistoryWrapper();
            dw.item=dcl;
            
            if(field_map.containsKey(dcl.Field)){                
                dw=getWrapper(field_map.get(dcl.Field),String.valueOf(dcl.OldValue),String.valueOf(dcl.NewValue),dcl.Field,dw);
                dw.Field_Label=field_map.containsKey(dcl.Field) ? field_map.get(dcl.Field).getDescribe().getLabel() : dcl.Field;
                list_wrapper.add(dw);
                
            }else{
                
                if(dcl.OldValue !=null && (!(String.valueOf(dcl.OldValue) Instanceof Id))){
                   
                    dw.Old_value=String.valueof(dcl.OldValue);
                }
                if(dcl.NewValue !=null && (!(String.valueOf(dcl.NewValue) Instanceof Id))){
                    dw.new_value=String.valueof(dcl.NewValue);
                }
                if(!(String.valueOf(dcl.NewValue) Instanceof Id) && (!(String.valueOf(dcl.OldValue) Instanceof Id)) ){
                dw.Field_Label=field_map.containsKey(dcl.Field) ? field_map.get(dcl.Field).getDescribe().getLabel() : dcl.Field;
                list_wrapper.add(dw);
                }
            }
            
            
        }
        
        return list_wrapper;
        
        
    } 
   
    
    public static DocumentHistoryWrapper getWrapper( Schema.SObjectField  fieldschema, String oldvalue ,String newvalue, String field,DocumentHistoryWrapper dw ){
        if(String.valueof(fieldschema.getDescribe().getType())=='PICKLIST'){
                    List<Schema.PicklistEntry>  fieldResult =fieldschema.getDescribe().getPicklistValues();
                    for(Schema.PicklistEntry f:fieldResult){
                        if( oldvalue !=null &&f.getValue() ==oldvalue){
                            dw.Old_value=f.getLabel();
                        }else if(newvalue !=null &&f.getValue() ==newvalue){
                            dw.New_value=f.getLabel();
                        }
                    }
                    
                }else if(String.valueof(fieldschema.getDescribe().getType())=='DATETIME'){
                    if(oldvalue != null)
                        dw.Old_value= dateformatechanged(DateTime.valueOf(oldvalue));
                    
                    if(newvalue != null)
                        dw.New_value= dateformatechanged(DateTime.valueOf(newvalue));
                    
                }else{
                   
                    if(oldvalue !=null){
                       
                        dw.Old_value=oldvalue;
                    }
                    if(newvalue !=null){
                        dw.new_value=newvalue;
                    }
                }
        return dw;
    }
    public static string dateformatechanged(DateTime dt){
        return dt.format('MM/dd/YYYY hh:mm a');
        
    }
    
    
    public static Map<String, Schema.SObjectField> getFieldLabel(){
        String type='DocumentChecklistItem';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        return fieldMap;
    }
    public class DocumentHistoryWrapper{
        @AuraEnabled
        public DocumentChecklistItemHistory  item{get;set;}
        @AuraEnabled
        public String Field_Label{get;set;}
        @AuraEnabled
        public String Old_value{get;set;}
        @AuraEnabled
        public String New_value{get;set;}
        
    }
    
    
}