public class SYN_Utility {
    public class ListOption {
        @AuraEnabled  public String label {get; set;}
        @AuraEnabled  public String value {get; set;}
        public ListOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
        public ListOption() {}
    }

 public class FilterWrapper {
        @AuraEnabled public Boolean isVisible {get; set;}
        @AuraEnabled public Decimal order {get; set;}
        @AuraEnabled public List<ListOption> filterValues {get; set;}
        @AuraEnabled public String filterType {get; set;}
        @AuraEnabled public String fieldType {get; set;}
        @AuraEnabled public String filterName {get; set;}
        @AuraEnabled public String fieldName {get; set;}
        @AuraEnabled public String query {get; set;}
        @AuraEnabled public String staticValues {get; set;}
        @AuraEnabled public String objectPicklistField {get; set;}
        @AuraEnabled public String labelValuePair {get; set;}
        @AuraEnabled public Boolean hasDependent {get; set;}
        @AuraEnabled public String dependentOrder {get; set;}
        @AuraEnabled public String userObjectFieldName {get; set;}
        @AuraEnabled public String selectedValue {get; set;}
     
        @AuraEnabled public Boolean selectedCheckboxValue {get; set;}
    }
    
    @AuraEnabled
    public static List<FilterWrapper> getFilters() {
       List<FilterWrapper> wrapperList = new List<FilterWrapper>();
        SYN_CallListConfiguration__mdt[] filters = [SELECT MasterLabel, DeveloperName, Field_Name__c, Field_Type__c, Filter_Type__c, 
                                                 		Query__c,Order__c, 
                                                 		Object_Picklist_Field__c, Is_Visible__c,Label_Value_Pair__c,StaticValue__c
                                                 FROM SYN_CallListConfiguration__mdt 
                                      			 ORDER BY Order__c];
        for(SYN_CallListConfiguration__mdt filter: filters) {
            FilterWrapper wrapper = new FilterWrapper();
            wrapper.filterName = filter.MasterLabel;
            wrapper.filterType = filter.Filter_Type__c;
            wrapper.fieldName = filter.Field_Name__c;
            wrapper.fieldType = filter.Field_Type__c;
            wrapper.order = filter.Order__c;
            wrapper.isVisible = filter.Is_Visible__c;
            wrapper.staticValues = filter.StaticValue__c;
            wrapper.objectPicklistField = filter.Object_Picklist_Field__c;
            wrapper.labelValuePair = filter.Label_Value_Pair__c;
            wrapper.query = filter.Query__c;
          
            wrapperList.add(wrapper);
        } 
        return wrapperList;
    }
     public static List<String> getDefaultFilters(String formName) {
        List<String> defaultFiltersList = new List<String>();
        SYN_CallListConfiguration__mdt[] filters = [SELECT MasterLabel, Is_Visible__c FROM SYN_CallListConfiguration__mdt  ORDER BY Order__c];
        for(SYN_CallListConfiguration__mdt filter: filters) {
            if(filter.Is_Visible__c) {
                defaultFiltersList.add(filter.MasterLabel);
            }
        }
        return defaultFiltersList;
    }
    
     public static FilterWrapper getFilterValues(FilterWrapper filterWrapper, Map<String, String> varibleValues) {
        String userId = UserInfo.getUserId(); //Variable to be used to bind value in query
        
        filterWrapper.filterValues = new List<ListOption>();
        if(filterWrapper.staticValues != null) {
            for(String value: filterWrapper.staticValues.split(';')) {
                filterWrapper.filterValues.add(new ListOption(value.split(':')[0],value.split(':')[1]));
            }
        }
        if(filterWrapper.query != null) {
            String query = filterWrapper.query;
            
            if(varibleValues!=null){
                for(String key: varibleValues.keySet()) {
                  
                    query = query.replace(key, varibleValues.get(key));
                }
            }
           
            sObject[] result = Database.query(query);
            /* Using Map to filter out duplicate values */
            Map<String,ListOption> optionsMap = new Map<String,ListOption>();
            optionsMap.put('All',new ListOption('All', 'All'));
            for(sObject res: result) {
                String value;
                String label;
              
                value = getSObjectFieldValue(res,filterWrapper.labelValuePair.split(':')[1]);
                label = getSObjectFieldValue(res,filterWrapper.labelValuePair.split(':')[0]);
               
                optionsMap.put(value,new ListOption(label, value));
            }
            filterWrapper.filterValues.addAll(optionsMap.values());
        }
        if(filterWrapper.objectPicklistField != null) {
            String objectPicklistField = filterWrapper.objectPicklistField;
            List<String> splitString = objectPicklistField.split('\\.');
            Schema.SObjectField theField = Schema.getGLobalDescribe().get(splitString[0]).getDescribe().fields.getMap().get(splitString[1]);
            Schema.DescribeFieldResult fieldResult = theField.getDescribe();
            List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry ple : picklistEntry){
                filterWrapper.filterValues.add(new ListOption(ple.getLabel(),ple.getValue()));
            }
        }

        return filterWrapper;
    }
    
    public static FilterWrapper getEscalationQueueMemebers(FilterWrapper wrapper, List<User> userList){
          Map<String,ListOption> optionsMap = new Map<String,ListOption>();
            optionsMap.put('All',new ListOption('All', 'All'));
            for(User res: userList) {
                String value;
                String label;
              
                value = getSObjectFieldValue(res,wrapper.labelValuePair.split(':')[1]);
                label = getSObjectFieldValue(res,wrapper.labelValuePair.split(':')[0]);
               
                optionsMap.put(value,new ListOption(label, value));
            }
         wrapper.filterValues.addAll(optionsMap.values());
        return wrapper;
    }
    
    
    
     public static String getSObjectFieldValue(SObject record,String field){
        
        if(record==null){
            return '';
        }
        if(field.contains('.')){
            String realtionShip = field.split('\\.')[0];
            String nextField = field.replaceFirst(realtionShip+'.', '');
            return getSObjectFieldValue(record.getSObject(realtionShip),nextField);
        }else{
            Object objValue = record.get(field);
            String fieldValue ='';
            if(objValue!=null){
                if(objValue instanceof Date){
                    fieldValue = ((Date)objValue).format();
                }else if(objValue instanceof DateTime){
                    fieldValue = ((DateTime)objValue).format('M/dd/yyyy h:mm a z');
                }else{
                    fieldValue = String.valueOf(objValue);
                }
                
            }
            return fieldValue;
        }
    }

    /**
    * @Author: Wilco Source.   
    * @Date:   09/27/2022 
    * @Description:  This method is used to handle the DML errors. We are printing both success and failure message in debug log                     
    * @pram 1: Classname  - From which class this methods in invoked 
    * @pram 2: methodName - From which method this invocation happend 
    * @pram 3: objectName - From which method this invocation happend 
    * @pram 4: action - DML action name. Ex. Insert, Update, Updsert & Delete
    * @pram 5: saveResultList - DML Result
    * @Return: none
    * @Throws:    
    */    
    public static void handleDMLErrors(String className, String methodName, String objectName, String action, List<Database.SaveResult> saveResultList){
        
        String successMessage = '';
        String errorMessage = '';
        for (Database.SaveResult saveResultRec : saveResultList) {
            
            if (saveResultRec.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                successMessage += saveResultRec.getId() + '\n';
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : saveResultRec.getErrors()) {
                    
                    errorMessage += err.getStatusCode() + ' | ' + err.getMessage() + err.getFields()+'\n';
                }
            }
        }   
    }
}