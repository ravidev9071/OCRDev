public with sharing class REMSlookupfieldController {    
    @AuraEnabled
    public static List<sObject> GetRecentRecords(String ObjectName, List<String> ReturnFields, Integer MaxResults) {
          //Added for Quality check
        List<String> returnFieldsAccessible=new List<String>();
        String strObjectName = String.escapeSingleQuotes(ObjectName);
        Integer intMaxResults = Integer.valueOf(MaxResults);
        List<Id> recentIds = new List<Id>();
        for(RecentlyViewed recent : [SELECT Id FROM RecentlyViewed WHERE Type = :strObjectName ORDER BY LastViewedDate DESC LIMIT : intMaxResults]) {
            recentIds.add(recent.Id);
        }
        //Added for Quality check
        for(String field:ReturnFields){
            if(isSafeField(field,strObjectName)){
                returnFieldsAccessible.add(String.escapeSingleQuotes(field));
            }

        }
        
        String sQUERY = 'SELECT Id, ';

         //Added for Quality check
        if (!returnFieldsAccessible.isEmpty()) {
            sQuery += String.join(returnFieldsAccessible, ',');
        } else {
            sQuery += 'Name';   
        }
        
        sQuery += ' FROM ' + strObjectName + ' WHERE Id IN :recentIds WITH SECURITY_ENFORCED';

        List<sObject> searchResult = Database.query(sQuery);
        
        return searchResult;
    }
    
    @AuraEnabled
    public static List<sObject> SearchRecords(String ObjectName, List<String> ReturnFields, List<String> QueryFields, String SearchText, String SortColumn, String SortOrder, Integer MaxResults, String Filter, 
                                      String Label,String ProgramId,String requestorType)  {
        
         //Added for Quality check
         List<String> returnFieldsAccessible=new List<String>();
         String strObjectName = String.escapeSingleQuotes(ObjectName);
         String strSearchText = String.escapeSingleQuotes(SearchText);
         String strSortColumn = String.escapeSingleQuotes(SortColumn);
         String strSortOrder = String.escapeSingleQuotes(SortOrder);
         String strFilter = String.escapeSingleQuotes(Filter);
         String fieldLabel = String.escapeSingleQuotes(Label);
         Integer intMaxResults = (MaxResults == null || MaxResults == 0) ? 5 : Integer.valueOf(MaxResults);

         //Added for Quality check
         for(String field:ReturnFields){
            if(isSafeField(field,strObjectName)){
                returnFieldsAccessible.add(String.escapeSingleQuotes(field));
            }

        }
        
        SearchText = '%' + strSearchText + '%';
        
        List <sObject > returnList = new List < sObject > ();
        
        String sQuery =  'SELECT Id, ';

         //Added for Quality check
         if (returnFieldsAccessible != null && returnFieldsAccessible.Size() > 0) {
            sQuery += String.join(returnFieldsAccessible, ',');
        } else {
            sQuery += 'Name';   
        }
        
        sQuery += ' FROM ' + strObjectName + ' WHERE ';

        if(strSearchText!=null && strSearchText!=''){
        if (!QueryFields.isEmpty()) {
            string likeField = '';
            for(string field : QueryFields) {
                likeField += ' OR ' + String.escapeSingleQuotes(field) + ' LIKE :SearchText ';    
            }
            sQuery += ' (' + likeField.removeStart(' OR ') + ') AND';
        } else {
            sQuery += ' Name LIKE :SearchText ';
        }
    }
        
        if (Filter != null && Filter !='') {         
            if(sQuery.endsWithIgnoreCase('AND')) {
                sQuery += ' (' + String.escapeSingleQuotes(Filter) + ')';
            } else {
                sQuery += ' AND (' + String.escapeSingleQuotes(Filter) + ')';
            }   
        }
        if(fieldLabel!=null && fieldLabel=='Participant'){
            if(ProgramId!=null){
                sQuery += Filter!=null && Filter!=''?' AND ('+'US_WSREMS__REMS_Program__c=\''+ProgramId+'\')':' ('+'US_WSREMS__REMS_Program__c=\''+ProgramId+'\')';
                Filter = sQuery;
            }
            if(requestorType!=null){
                sQuery += Filter!=null && Filter!=''?' AND ('+'RecordType.Name=\''+requestorType+'\')': ' ('+'RecordType.Name=\''+requestorType+'\')';
                Filter = sQuery;
            }
        }
        if(string.isNotBlank(strSortColumn) && string.isNotBlank(strSortOrder)) {
            sQuery += ' ORDER BY ' + String.escapeSingleQuotes(strSortColumn) + ' ' + String.escapeSingleQuotes(strSortOrder);
        }
        
        sQuery += ' LIMIT ' + intMaxResults;                                
        List <sObject> searchResult = Database.query(sQuery);
        
        return searchResult;
    }
    
    @AuraEnabled
    public static List<sObject> GetRecord(String ObjectName, List<String> ReturnFields, String Id) {
        //Added for Quality check
        List<String> returnFieldsAccessible=new List<String>();
        String strId = String.escapeSingleQuotes(Id);
        String strObjectName = String.escapeSingleQuotes(ObjectName);
             
         //Added for Quality check
         for(String field:ReturnFields){
            if(isSafeField(field,strObjectName)){
                returnFieldsAccessible.add(String.escapeSingleQuotes(field));
            }

        }

        String sQUERY = 'SELECT Id, ';

         //Added for Quality check
         if (!returnFieldsAccessible.isEmpty()) {
            sQuery += String.join(returnFieldsAccessible, ',');
        } else {
            sQuery += 'Name';   
        }
        
        sQuery += ' FROM ' + strObjectName + ' WHERE Id = :strId';

        List<sObject> searchResult = Database.query(sQuery);
        
        return searchResult;
    }
    
    @AuraEnabled
    public static string findObjectIcon(String ObjectName) {    
        String u;
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
        
        for(Schema.DescribeTabSetResult describeTabSetResult : Schema.describeTabs()) {
            for(Schema.DescribeTabResult describeTabResult : describeTabSetResult.getTabs()) {
                if(describeTabResult.getSobjectName() == ObjectName) { 
                    if( describeTabResult.isCustom() == true ) {
                        for (Schema.DescribeIconResult describeIcon : describeTabResult.getIcons()) {
                            if (describeIcon.getContentType() == 'image/svg+xml'){
                                return 'custom:' + describeIcon.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                            }
                        }
                    } else {
                        return 'standard:' + ObjectName.toLowerCase();
                    }
                }
            }
        }

        return 'standard:default';
    }
    
    @AuraEnabled
    public static objectDetails getObjectDetails(String ObjectName) {    

        objectDetails details = new objectDetails();
        
        Schema.DescribeSObjectResult describeSobjectsResult = Schema.describeSObjects(new List<String>{ObjectName})[0];

        details.label = describeSobjectsResult.getLabel();
        details.pluralLabel = describeSobjectsResult.getLabelPlural();

        details.iconName = findObjectIcon(ObjectName);
        
        return details;
    }

    @AuraEnabled
    public static String getRecordTypeId(String objAPIName, String RecordTypeDeveloperName){
        String recordTypeId = Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByDeveloperName()
        .get(RecordTypeDeveloperName).getRecordTypeId();
        return recordTypeId;
    }
 //Added for Quality check
     static boolean isSafeField(String fieldName, String objName){
         Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
         SObjectType myObj = schemaMap.get(objName);
        if (myObj.getDescribe().isAccessible() ) { 
            SObjectField myField = myObj.getDescribe().fields.getMap().get(fieldName);
            if(myField.getDescribe().isAccessible()){
                return true;
            }else{
                return false;
            }
       
        }
         return false;
    }
    
    public class objectDetails {
        @AuraEnabled
        public string iconName;
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string pluralLabel;
    }
}