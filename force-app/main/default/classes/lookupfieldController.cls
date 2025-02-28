public with Sharing class lookupfieldController {    
    @AuraEnabled
    public static List<sObject> GetRecentRecords(String ObjectName, List<String> ReturnFields, Integer MaxResults) {
          //Added for Quality check
        List<String> returnFieldsAccessible=new List<String>();
        List<Id> recentIds = new List<Id>();
        for(RecentlyViewed recent : [SELECT Id FROM RecentlyViewed WHERE Type = :ObjectName ORDER BY LastViewedDate DESC LIMIT :MaxResults]) {
            recentIds.add(recent.Id);
        }
        //Added for Quality check
        for(String field:ReturnFields){
            if(isSafeField(field,ObjectName)){
                returnFieldsAccessible.add(field);
            }

        }
        
        String sQUERY = 'SELECT Id, ';

         //Added for Quality check
        if (returnFieldsAccessible != null && returnFieldsAccessible.Size() > 0) {
            sQuery += String.join(returnFieldsAccessible, ',');
        } else {
            sQuery += 'Name';   
        }
        
        sQuery += ' FROM ' + ObjectName + ' WHERE Id IN :recentIds';

        List<sObject> searchResult = Database.query(sQuery);
        
        return searchResult;
    }
    
    @AuraEnabled
    public static List<sObject> SearchRecords(String ObjectName, List<String> ReturnFields, List<String> QueryFields, String SearchText, String SortColumn, String SortOrder, Integer MaxResults, String Filter) {
        
         //Added for Quality check
         List<String> returnFieldsAccessible=new List<String>();

        //always put a limit on the results
        if (MaxResults == null || MaxResults == 0) {
            MaxResults = 5;
        }

         //Added for Quality check
         for(String field:ReturnFields){
            if(isSafeField(field,ObjectName)){
                returnFieldsAccessible.add(field);
            }

        }
        
        SearchText = '%' + SearchText + '%';
        
        List <sObject > returnList = new List < sObject > ();
        
        String sQuery =  'SELECT Id, ';
        
         //Added for Quality check
         if (returnFieldsAccessible != null && returnFieldsAccessible.Size() > 0) {
            sQuery += String.join(returnFieldsAccessible, ',');
        } else {
            sQuery += 'Name';   
        }
        
        sQuery += ' FROM ' + ObjectName + ' WHERE ';
        
        if (QueryFields == null || QueryFields.isEmpty()) {
            sQuery += ' Name LIKE :SearchText ';
        } else {
            string likeField = '';
            for(string field : QueryFields) {
                likeField += ' OR ' + field + ' LIKE :SearchText ';    
            }
            sQuery += ' (' + likeField.removeStart(' OR ') + ') ';
        }
        
        if (Filter != null) {
            sQuery += ' AND (' + Filter + ')';
        }
        
        if(string.isNotBlank(SortColumn) && string.isNotBlank(SortOrder)) {
            sQuery += ' ORDER BY ' + SortColumn + ' ' + SortOrder;
        }
        
        sQuery += ' LIMIT ' + MaxResults;
       
        List <sObject> searchResult = Database.query(sQuery);
        
        return searchResult;
    }
    
    @AuraEnabled
    public static List<sObject> GetRecord(String ObjectName, List<String> ReturnFields, String Id) {
             //Added for Quality check
             List<String> returnFieldsAccessible=new List<String>();
             
         //Added for Quality check
         for(String field:ReturnFields){
            if(isSafeField(field,ObjectName)){
                returnFieldsAccessible.add(field);
            }

        }

        String sQUERY = 'SELECT Id, ';

         //Added for Quality check
         if (returnFieldsAccessible != null && returnFieldsAccessible.Size() > 0) {
            sQuery += String.join(returnFieldsAccessible, ',');
        } else {
            sQuery += 'Name';   
        }
        
        sQuery += ' FROM ' + ObjectName + ' WHERE Id = :Id';

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