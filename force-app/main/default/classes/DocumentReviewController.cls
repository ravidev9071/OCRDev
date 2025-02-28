/**
* @Description        : This is controller for REMSDocumentReview auracomponent.
* @TestClass          : DocumentReviewController_Test
* @Author 			  : 
* @Modification Log   : 
* Ver       Date            Developer      		        Modification
*              	            Sukanya P           		Initial Implementation.
**/

public with sharing class DocumentReviewController {
    public static List<US_WSREMS__Dynamic_Account_Search_Config__mdt> testAccConfigList = new List<US_WSREMS__Dynamic_Account_Search_Config__mdt>();
    public static List<US_WSREMS__ServiceTreeViewQueryConfig__mdt> testQueryConfigList = new List<US_WSREMS__ServiceTreeViewQueryConfig__mdt>();
    public static List<US_WSREMS__ServiceTreeViewConfig__mdt> testTreeViewList = new List<US_WSREMS__ServiceTreeViewConfig__mdt>();
    public static list<US_WSREMS__Pagelayout_Configuration__mdt> testPagelayoutList = new list<US_WSREMS__Pagelayout_Configuration__mdt>();

    /* MethodName : retrieveFilesOnDocumentDetail
    Description: This method retrive the files on DocumentDetail object and generate public url.
    */
    @AuraEnabled
    public static ContentDistribution retrieveFilesOnDocumentDetail(String parentObjId){
        List<ContentDocumentLink> docLinkList = new List<ContentDocumentLink>();
      docLinkList=[SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                  ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType
                  FROM ContentDocumentLink 
                  WHERE LinkedEntityId = :parentObjId order by ContentDocument.createdDate desc limit 1];
      if(docLinkList.size()>0){
          ContentVersion file = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :docLinkList[0].ContentDocumentId order by ContentDocument.createdDate desc limit 1];
          //Generate public file url in contentDistribution object.
          List <ContentDistribution> insdistList = new List <ContentDistribution>(); 
          ContentDistribution distObj = new ContentDistribution();
          insdistList = [Select Id,DistributionPublicUrl from ContentDistribution where Name = :file.Title
                        and ContentVersionId = :file.Id and PreferencesAllowViewInBrowser= true];
          
          if (insdistList.size()>0) {
            return insdistList[0];
          }             
          distObj.Name = file.Title;
          distObj.ContentVersionId = file.Id;
          distObj.PreferencesAllowViewInBrowser= true;
          insert distObj;

          ContentDistribution insdistOb = [Select Id,DistributionPublicUrl from ContentDistribution where Id=:distObj.Id];
         return insdistOb;
        }
        return null;
    }
    
    /* MethodName : retrieveAccountConfigFields
    Description: This method retrive the fields configuration from US_WSREMS__Dynamic_Account_Search_Config__mdt configuration.
                This configuration is used in search section of Document review component.
    */
    @AuraEnabled
    public static AccSearchWrapCls retrieveAccountConfigFields(){
        List<US_WSREMS__Dynamic_Account_Search_Config__mdt> accConfigList = new List<US_WSREMS__Dynamic_Account_Search_Config__mdt>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(REMSAppLiterals.ACCOUNT_OBJECT) ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        programList = getPrograms();
        AccSearchWrapCls searchWrapObj = new AccSearchWrapCls();
        searchWrapObj.acSearchConfigList = new List<US_WSREMS__Dynamic_Account_Search_Config__mdt>();
        searchWrapObj.pickconfigMap = new  Map<String,List<pickListOptions>>();
        accConfigList = [SELECT Id,DeveloperName,US_WSREMS__DataType__c,US_WSREMS__Picklist_values__c,US_WSREMS__Inbound_Call__c,US_WSREMS__Field_Label__c,US_WSREMS__Field_Name__c,US_WSREMS__PlaceHolder__c,US_WSREMS__Order__c,US_WSREMS__Required__c FROM US_WSREMS__Dynamic_Account_Search_Config__mdt order by US_WSREMS__Order__c asc];

       
               if(testAccConfigList.size()>0){
            accConfigList = testAccConfigList;
        }
        
        for(US_WSREMS__Dynamic_Account_Search_Config__mdt configObj:accConfigList){

            searchWrapObj.acSearchConfigList.add(configObj);
            //Get the picklistvalues for the picklist fields configured in the metadata 'US_WSREMS__Dynamic_Account_Search_Config__mdt' 
            if(configObj.US_WSREMS__DataType__c == 'Combobox' ){
                if(configObj.US_WSREMS__Field_Name__c!=REMSAppLiterals.NAMESPACE_STRING+'US_WSREMS__REMS_Program__c'){
                    searchWrapObj.pickconfigMap.put(configObj.US_WSREMS__Field_Name__c,new List<pickListOptions>{});
                Schema.DescribeFieldResult fieldResult = fields.get(configObj.US_WSREMS__Field_Name__c).getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                List<pickListOptions> pickObjList = new List<pickListOptions>();
                for( Schema.PicklistEntry pickListVal : ple){
                    pickListOptions optobj = new pickListOptions();
                    optobj.label = pickListVal.getLabel();
                    optobj.value = pickListVal.getValue();
                    searchWrapObj.pickconfigMap.get(configObj.US_WSREMS__Field_Name__c).add(optobj);
                }
                
            }else{
                //Query the programs and set the picklistvalues for the field US_WSREMS__REMS_Program__c 
                searchWrapObj.pickconfigMap.put(REMSAppLiterals.NAMESPACE_STRING+'US_WSREMS__REMS_Program__c',new List<pickListOptions>{});
                List<pickListOptions> pickObjList = new List<pickListOptions>();
                for(US_WSREMS__REMS_Program__c progObj: programList){
                    pickListOptions optobj = new pickListOptions();
                    optobj.label = progObj.Name;
                    optobj.value = progObj.Id;
                    searchWrapObj.pickconfigMap.get(configObj.US_WSREMS__Field_Name__c).add(optobj);
                }
            }
            }
        }    
            return searchWrapObj;
        }
        
    
    /* MethodName : retriveExistingRemsServices
    Description: This method retrives the Account,REMS Servie and Case records .These 
                 records used in Tree grid view of REMSDocumentReview component.    
    Parameters: accountValues(input fields & values given in search section. 
                             valid format {'Name':'test','Email':'test@test.com'})
    */
    @AuraEnabled
    public static List<accountWrapClass> retriveExistingRemsServices(String accountValues){
        List<US_WSREMS__Dynamic_Account_Search_Config__mdt> accConfigList = new List<US_WSREMS__Dynamic_Account_Search_Config__mdt>();
        List<US_WSREMS__ServiceTreeViewQueryConfig__mdt> treeQueryList = new List<US_WSREMS__ServiceTreeViewQueryConfig__mdt>();
        Set<Id> accSet = new Set<Id>();
       Map<Id,Account> accountMap = new Map<Id,Account>();
       //metadata configuration to query and display data in tree grid view.
       Map<String,US_WSREMS__ServiceTreeViewQueryConfig__mdt> queryConfigMap = new Map<String,US_WSREMS__ServiceTreeViewQueryConfig__mdt>();
       //Store Account lookup API names on REMS service object.These fields used to get account related REMSService records.
       Map<String,List<String>> parentFldsMap = new Map<String,List<String>>(); 
       //Store data to display in treegrid view
       Map<Account,Map<US_WSREMS__REMS_Service_Summary__c,List<Case>>> treeDataMap = new Map<Account,Map<US_WSREMS__REMS_Service_Summary__c,List<Case>>>();
       Map<String,String> accConfigMap = new Map<String,String>();
       String WhereCondition;
       String progWhereCondition;
       String remsWhereCondition;
        String searchCriteria;
       String remsSearchCriteria;
       String remsQuery;
       String caseQuery;
       String caseWhereCondition;
       Set<Id> accountKeySet = new Set<Id>();
       Set<Id> remsIdSet = new Set<Id>();
       try {
        accConfigList = [SELECT Id,DeveloperName,US_WSREMS__DataType__c,US_WSREMS__Picklist_values__c,US_WSREMS__Field_Label__c,US_WSREMS__Field_Name__c,US_WSREMS__PlaceHolder__c,US_WSREMS__Order__c,US_WSREMS__Required__c FROM US_WSREMS__Dynamic_Account_Search_Config__mdt order by US_WSREMS__Order__c asc];
        if(testAccConfigList.size()>0){
            accConfigList = testAccConfigList;
        }
        treeQueryList = US_WSREMS__ServiceTreeViewQueryConfig__mdt.getAll().values();
        if(testQueryConfigList.size()>0){
            treeQueryList = testQueryConfigList;
        }
        //Get values from US_WSREMS__Dynamic_Account_Search_Config__mdt . Used to create dynamic query where condition.
           for(US_WSREMS__Dynamic_Account_Search_Config__mdt accConfig: accConfigList){
               accConfigMap.put(accConfig.US_WSREMS__Field_Name__c,accConfig.US_WSREMS__DataType__c);
           }

           //Convert account search input values string into Map<String,String>
            Map<String,String> accountinputMap = (Map<String,String>)JSON.deserialize(String.valueOf(accountValues), Map<String,String>.class);
             accountinputMap =  checkWhiteSpaces(accountinputMap);
           //Get the values from US_WSREMS__ServiceTreeViewQueryConfig__mdt for each object.
            for(US_WSREMS__ServiceTreeViewQueryConfig__mdt QueryConfig : treeQueryList){
                queryConfigMap.put(QueryConfig.US_WSREMS__Object_API_Name__c,QueryConfig);
            }
          
           //Account SOQL query where condition
            for(String fieldName:accountinputMap.KeySet()){
                if(accountinputMap.get(fieldName)!=null && accountinputMap.get(fieldName)!=''){
                    if(accConfigMap.containsKey(fieldName) && accConfigMap.get(fieldName) == 'Date'){
                        Date dt ;
                            dt= date.valueOf(accountinputMap.get(fieldName));
                            WhereCondition = WhereCondition==null ? ' Where (' +fieldName + ''+'=:dt': WhereCondition + ' Or '+fieldName + ' =:dt'; 
                    }else if(accConfigMap.containsKey(fieldName) && accConfigMap.get(fieldName) == 'Phone'){
                        String Phone = accountinputMap.get(fieldName);
                        String phoneFormat  = '(' + Phone.substring(0, 3) + ') ' + Phone.substring(3, 6) + '-' + Phone.substring(6);
                        WhereCondition = WhereCondition==null ? ' Where (' +fieldName + ''+' like \'%' +accountinputMap.get(fieldName)+'%\'': WhereCondition + ' Or '+fieldName + ' like \'%'+accountinputMap.get(fieldName)+'%\'';
                        WhereCondition = WhereCondition==null ? ' Where (' +fieldName + ''+' like \'%' +phoneFormat+'%\'': WhereCondition + ' Or '+fieldName + ' like \'%'+phoneFormat+'%\'';  
                    }
                    else if(accConfigMap.containsKey(fieldName) && accConfigMap.get(fieldName) == 'Combobox' && fieldName==REMSAppLiterals.NAMESPACE_STRING+'US_WSREMS__REMS_Program__c'){
                        string fieldId = accountinputMap.get(fieldName);
                        progWhereCondition=  fieldName + ''+'=:fieldId';
                    }else{
                        WhereCondition = WhereCondition==null ? ' Where (' +fieldName + ''+' like \'%' +accountinputMap.get(fieldName)+'%\'': WhereCondition + ' Or '+fieldName + ' like \'%'+accountinputMap.get(fieldName)+'%\''; 
                    }
                }
            }
            searchCriteria = queryConfigMap.get(REMSAppLiterals.ACCOUNT_OBJECT).US_WSREMS__Search_Criteria__c!=null ? ' '+queryConfigMap.get(REMSAppLiterals.ACCOUNT_OBJECT).US_WSREMS__Search_Criteria__c:'';
            // add program check to where condition
            if(progWhereCondition!=null){
            WhereCondition = WhereCondition==null  ?' Where '+progWhereCondition+searchCriteria:WhereCondition+') And '+progWhereCondition+searchCriteria;
            }
            else{
                WhereCondition = WhereCondition!=null ? WhereCondition+')'+searchCriteria:null;
            }
            String Query = 'Select ';
            if(queryConfigMap.containsKey(REMSAppLiterals.ACCOUNT_OBJECT) && queryConfigMap.get(REMSAppLiterals.ACCOUNT_OBJECT).US_WSREMS__Fields_to_Query__c!=null){
                Query = Query+queryConfigMap.get(REMSAppLiterals.ACCOUNT_OBJECT).US_WSREMS__Fields_to_Query__c+' from '+queryConfigMap.get(REMSAppLiterals.ACCOUNT_OBJECT).US_WSREMS__Object_API_Name__c+WhereCondition+ ' order by createdDate Desc';
            }else{
                Query = 'Select Id from Account'+WhereCondition+' order by createdDate Desc';
            }
            List<Account> accList = new List<Account>();
            List<SObject> accRecordList = database.query(query);
            List<US_WSREMS__REMS_Service_Summary__c> remsServiceList = new List<US_WSREMS__REMS_Service_Summary__c>();
            List<accountWrapClass> acWrapList = new List<accountWrapClass>();
            Map<Id,accountWrapClass> accWrapMap = new Map<Id,accountWrapClass>();
            Map<Id,serviceWrapClass> ServiceWrapMap = new Map<Id,serviceWrapClass>();
            Map<Id,US_WSREMS__REMS_Service_Summary__c> ServiceSummaryMap = new  Map<Id,US_WSREMS__REMS_Service_Summary__c>();
            
            //Build wrapper structure for tree grid view
            if(!accRecordList.isEmpty()){
                for(Account accobj: (List<Account>)accRecordList){
                    accountWrapClass acWrapbj = new accountWrapClass();
                    acWrapbj.accObj = accobj;
                  //  acWrapbj.accObj.Id = URL.getSalesforceBaseUrl().toExternalForm()+'/'+acWrapbj.accObj.Id ;
                    acWrapbj.remsServiceObjList = new List<serviceWrapClass>{};
                    accWrapMap.put(accobj.Id,acWrapbj);
                    accountMap.put(accobj.Id,accobj);
                    treeDataMap.put(accobj,new Map<US_WSREMS__REMS_Service_Summary__c,List<Case>>{});
                }
            }

            //REMS Service SOQL 
            if(!accountMap.isEmpty()){
                accountKeySet = accountMap.KeySet();
                if(queryConfigMap.containsKey(REMSAppLiterals.SERVICE_SUMMARY_OBJECT) 
                && queryConfigMap.get(REMSAppLiterals.SERVICE_SUMMARY_OBJECT).US_WSREMS__Parent_FieldAPI_Names__c!=null){
                   parentFldsMap= (Map<String,List<String>>)JSON.deserialize( queryConfigMap.get(REMSAppLiterals.SERVICE_SUMMARY_OBJECT).US_WSREMS__Parent_FieldAPI_Names__c, Map<String,List<String>>.class);
                   remsQuery = 'Select '+ queryConfigMap.get(REMSAppLiterals.SERVICE_SUMMARY_OBJECT).US_WSREMS__Fields_to_Query__c+' from '+REMSAppLiterals.SERVICE_SUMMARY_OBJECT;
                }
            //REMS Service where clause . Account lookup API values are added from REMSUS_WSREMS__ServiceTreeViewQueryConfig__mdt
            if(parentFldsMap!=null &&parentFldsMap.containsKey(REMSAppLiterals.ACCOUNT_OBJECT) && parentFldsMap.get(REMSAppLiterals.ACCOUNT_OBJECT).size()>0){
                for(String lookupFld: parentFldsMap.get(REMSAppLiterals.ACCOUNT_OBJECT)){
                    remsWhereCondition = remsWhereCondition==null ? ' Where '+lookupFld +' in :accountKeySet' : remsWhereCondition+' Or '+ lookupFld +' in :accountKeySet';

                }
            remsSearchCriteria = queryConfigMap.get(REMSAppLiterals.SERVICE_SUMMARY_OBJECT).US_WSREMS__Search_Criteria__c!=null ? ' '+queryConfigMap.get(REMSAppLiterals.SERVICE_SUMMARY_OBJECT).US_WSREMS__Search_Criteria__c:'';
            
            if(remsWhereCondition!=null){
                remsQuery = remsQuery!=null?remsQuery+remsWhereCondition+remsSearchCriteria : 'Select Id from '+REMSAppLiterals.SERVICE_SUMMARY_OBJECT +remsWhereCondition+remsSearchCriteria;
            }
            }
            if(testQueryConfigList.size()>0){
                remsQuery = 'Select Id,Participant__c from '+REMSAppLiterals.SERVICE_SUMMARY_OBJECT +' limit 1';
                parentFldsMap.put(REMSAppLiterals.ACCOUNT_OBJECT,new list<string>{'Participant__c'});
            }
            List<Sobject> remsObjList = database.query(remsQuery);
            for(US_WSREMS__REMS_Service_Summary__c remsObj: (List<US_WSREMS__REMS_Service_Summary__c>)remsObjList){
                remsIdSet.add(remsObj.Id);
                for(String lookupFld: parentFldsMap.get(REMSAppLiterals.ACCOUNT_OBJECT)){
                    
                if(accountMap.containsKey(String.valueOf(remsObj.get(lookupFld)))){
                    treeDataMap.get(accountMap.get(String.ValueOf(remsObj.get(lookupFld)))).put(remsObj,new List<Case>{});
                    serviceWrapClass servicewrapObj = new serviceWrapClass();
                    servicewrapObj.remsServiceObj = remsObj;
                //    servicewrapObj.remsServiceObj.Id = URL.getSalesforceBaseUrl().toExternalForm()+'/'+servicewrapObj.remsServiceObj.Id ;
                    servicewrapObj.caseList = new List<Case>();
                    ServiceWrapMap.put(remsObj.Id,servicewrapObj);
                    ServiceSummaryMap.put(remsObj.Id,remsObj);
                 //   accWrapMap.get(String.ValueOf(remsObj.get(lookupFld))).remsServiceObjList.add(servicewrapObj);
                }
                }
            }

            if(queryConfigMap.containsKey(REMSAppLiterals.CASE_OBJECT)){
                caseQuery = queryConfigMap.get(REMSAppLiterals.CASE_OBJECT).US_WSREMS__Fields_to_Query__c!=null?'Select '+queryConfigMap.get(REMSAppLiterals.CASE_OBJECT).US_WSREMS__Fields_to_Query__c+' From Case':'Select Id from Case';
                caseWhereCondition = queryConfigMap.get(REMSAppLiterals.CASE_OBJECT).US_WSREMS__Parent_FieldAPI_Names__c!=null?' Where '+queryConfigMap.get(REMSAppLiterals.CASE_OBJECT).US_WSREMS__Parent_FieldAPI_Names__c + ' in :remsIdSet': null;
                caseQuery = queryConfigMap.get(REMSAppLiterals.CASE_OBJECT).US_WSREMS__Search_Criteria__c!=null? caseQuery +caseWhereCondition+' '+queryConfigMap.get(REMSAppLiterals.CASE_OBJECT).US_WSREMS__Search_Criteria__c:caseQuery+caseWhereCondition;
            }

            //Case SOQL Query
            if(caseQuery!=null){
                List<Sobject> caseObjList = database.query(caseQuery);
                for(Case caseObj: (List<Case>) caseObjList){
                    if(ServiceWrapMap.containsKey(caseObj.US_WSREMS__REMS_Service_Summary__c)){
                        ServiceWrapMap.get(caseObj.US_WSREMS__REMS_Service_Summary__c).caseList.add(caseObj);
                    }
                }

                if(!ServiceWrapMap.isEmpty()){
                    for(serviceWrapClass servObj: ServiceWrapMap.Values()){
                        for(String lookupFld: parentFldsMap.get(REMSAppLiterals.ACCOUNT_OBJECT)){
                    
                            if(accWrapMap.containsKey(String.valueOf(servObj.remsServiceObj.get(lookupFld)))){
                                accWrapMap.get(String.valueOf(servObj.remsServiceObj.get(lookupFld))).remsServiceObjList.add(ServiceWrapMap.get(servObj.remsServiceObj.Id));
                            }

                        }
                    }
                }
            }
        }
            return accWrapMap.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Get programs from US_WSREMS__REMS_Program__c
    @AuraEnabled
    public static List<US_WSREMS__REMS_Program__c> getPrograms(){
        List<US_WSREMS__REMS_Program__c> programList =[SELECT Id,Name,US_WSREMS__Status__c  FROM US_WSREMS__REMS_Program__c
                                            where US_WSREMS__Status__c='Active' WITH SECURITY_ENFORCED ];
        return programList;
    }

    //Get dynamic component name
    @AuraEnabled
           public static String getComponentName(String programName,String recordTypeLabel,String feature){ 
          
                string componentName = '';
                List<Dynamic_Component_Config__mdt> lstDynamicComponents = new List<Dynamic_Component_Config__mdt>();
                String Query;
                if(String.isNotEmpty(programName)){
                    Query = 'SELECT Id,Component_Name__c,Program_Name__r.Label, IsActive__c FROM Dynamic_Component_Config__mdt WHERE Feature__c=:feature and Program_Name__r.Label=:programName AND IsActive__c=true';
               
                } else{
                    Query = 'SELECT Id,Component_Name__c,Program_Name__r.Label, IsActive__c FROM Dynamic_Component_Config__mdt WHERE Feature__c=:feature and IsActive__c=true';
                }

                if(String.isNotEmpty(recordTypeLabel)){
                    Query = Query + ' AND Record_Type__c = :recordTypeLabel';
                }
                lstDynamicComponents = (List<Dynamic_Component_Config__mdt>)Database.Query(Query);
                if (!lstDynamicComponents.isEmpty()) 
                    componentName =lstDynamicComponents[0].Component_Name__c;
                return componentName;
            }

    //Properties for treegrid view columns
    @AuraEnabled
    public static List<ServiceTreeViewConfigWrap> getREMSServiceViewConfig(String feature){ 
        List<ServiceTreeViewConfigWrap> columnsList = new List<ServiceTreeViewConfigWrap>();
        List<US_WSREMS__ServiceTreeViewConfig__mdt> treeViewList = new List<US_WSREMS__ServiceTreeViewConfig__mdt>();
        treeViewList = [Select US_WSREMS__Field_Name__c,US_WSREMS__initialWidth__c,US_WSREMS__Label__c,US_WSREMS__Parent_Relation__c,
        US_WSREMS__Order__c,US_WSREMS__Type__c,US_WSREMS__TypeAttributes__c,US_WSREMS__Visible_on_UI__c,US_WSREMS__Editable__c , US_WSREMS__ParentQueryField__c
        from US_WSREMS__ServiceTreeViewConfig__mdt where US_WSREMS__feature__c=:feature order by US_WSREMS__Order__c asc];
        if(testTreeViewList.size()>0){
            treeViewList = testTreeViewList;
        }
        for(US_WSREMS__ServiceTreeViewConfig__mdt configObj: treeViewList){
                ServiceTreeViewConfigWrap columnObj = new ServiceTreeViewConfigWrap();
                Map<String,Map<String,String>> typeAttMap ;
                if(configObj.US_WSREMS__TypeAttributes__c!=null){
                    typeAttMap  = (Map<String,Map<String,String>>)JSON.deserialize(String.valueOf(configObj.US_WSREMS__TypeAttributes__c), Map<String,Map<String,String>>.class);
                }
                columnObj.type = configObj.US_WSREMS__Type__c;
                columnObj.fieldName = configObj.US_WSREMS__Field_Name__c;
                columnObj.label = configObj.US_WSREMS__Label__c;
                columnObj.initialWidth = Integer.valueOf(configObj.US_WSREMS__initialWidth__c);
                columnObj.typeAttributes = typeAttMap;
                columnObj.Parent = configObj.US_WSREMS__Parent_Relation__c;
                columnObj.editable = configObj.US_WSREMS__Editable__c;
                columnObj.ParentQueryField = configObj.US_WSREMS__ParentQueryField__c;
                columnsList.add(columnObj);
        }

        return columnsList;
    }

  //Get all the Service configurations of a program
  @AuraEnabled
  public static List<US_WSREMS__REMS_Program_Service_Config__c> getProgramServiceConfigRecordTypeList(String programId) {

    List<US_WSREMS__REMS_Program_Service_Config__c> programServiceConfigList = [SELECT Id, US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.Name,US_WSREMS__Service_Name__c,US_WSREMS__Service_API_Name__c,US_WSREMS__Description__c
    FROM US_WSREMS__REMS_Program_Service_Config__c WHERE US_WSREMS__REMS_Program__c=:programId ORDER BY  US_WSREMS__Service_Name__c];
    return programServiceConfigList;
    }

    //Update Remsservice Id  in documentdetail object
    @AuraEnabled
    public static void updateReceivedDetailsDocumentList(String serviceId,String receivedDocumentId){
        DocumentChecklistItem DocListItemObj = new DocumentChecklistItem();
        DocListItemObj.Id = receivedDocumentId;
        DocListItemObj.US_WSREMS__REMS_Service__c = serviceId;
        try{
            update DocListItemObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }   
    
    //Get programId from document detail object
    @AuraEnabled
    public static DocumentCheckListItem retrieveDocumentDetails(String detailId){
        List<DocumentCheckListItem> checkList = new List<DocumentCheckListItem>();
        checkList=[Select ParentRecordId,US_WSREMS__REMS_Service__c from DocumentCheckListItem where Id=:detailId];
        if(checkList.size()>0 && checkList[0].ParentRecordId!=null){
            String sObjName = checkList[0].ParentRecordId.getSObjectType().getDescribe().getName();
            if(sObjName == REMSAppLiterals.PROGRAM_OBJECT){
                checkList=[Select ParentRecordId,US_WSREMS__REMS_Service__c,ParentRecord.Name from DocumentCheckListItem where Id=:detailId];
                return checkList[0];
            }
            
        }
        return null;
    }  

    @AuraEnabled
    public static ContentVersion retrieveFileOnDocumentDetail(String parentObjId){
        List<ContentDocumentLink> docLinkList = new List<ContentDocumentLink>();
      docLinkList=[SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                  ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType
                  FROM ContentDocumentLink 
                  WHERE LinkedEntityId = :parentObjId order by ContentDocument.createdDate desc limit 1];
      if(docLinkList.size()>0){
          ContentVersion file = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :docLinkList[0].ContentDocumentId order by ContentDocument.createdDate desc limit 1];
          //Generate public file url in contentDistribution object.
                return file;
        }
        return null;
    }

    //Get recordtypes for account object.
    @AuraEnabled
    public static Map<String,String> getRecordTypes(String objectName){
        Map<String,String> recTypeMap = new Map<String,String>();
        recTypeMap = REMSUtility.retrieveRecTypeNameId(objectName);
        return recTypeMap;
    }

    //Get recordtypes for account object.
    @AuraEnabled
    public static Boolean validateSelectedParticiapant(String AccountId,String requesterType){
       List<Account> accountList = [Select Id,RecordTypeId,RecordType.Name from Account where Id=:AccountId];
       if(accountList.size()>0){
           if(accountList[0].RecordTypeId!=null && accountList[0].RecordType.Name==requesterType){
               return true;
           }
       }
       return false;

    }

    //Retrive child cases associated to a Remsservice.
    @AuraEnabled
    public static List<Case> retrieveRemsChildCases(string remsSerId,List<String> fldsList){
        try {
            List<Case> caseList = new List<Case>();
            Set<String> fieldsSet = new Set<String>();
            string queryFlds;
            for(string fld: fldsList){
                if(fld!=null && !fieldsSet.contains(fld)){
                    fieldsSet.add(fld);
                }
            }
            for(string fld: fieldsSet){
                queryFlds = queryFlds==null? fld:queryFlds+','+fld;
            }
            string query = 'select '+queryFlds+' from case where US_WSREMS__REMS_Service_Summary__c=:remsSerId';
            caseList = (List<Case>)Database.Query(query);
            return caseList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static void updateCases(List<case> caseList){
        try{
            update caseList;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static LayoutInfoWrap getProgramServicelayoutConfig(Id serviceId) {
        String buttonName= '';
        List<US_WSREMS__Pagelayout_Configuration__mdt> pagelayoutList = new List<US_WSREMS__Pagelayout_Configuration__mdt>();
        string recTypeDevName = REMSUtility.retrieveRecTypeIdDeveloperName(REMSAppLiterals.SERVICE_SUMMARY_OBJ).get(serviceId);
        String pagelayoutName;
        List<DocumentReviewUtility_OCR.LayoutSection> layoutSecobjList = new List<DocumentReviewUtility_OCR.LayoutSection>();
        try {
            pagelayoutList = [SELECT Id,US_WSREMS__PageLayout_Name__c, US_WSREMS__Object_Name__c,US_WSREMS__RecordType_Name__c ,US_WSREMS__Quick_Action_Name__c 
                              FROM US_WSREMS__Pagelayout_Configuration__mdt 
                              WHERE US_WSREMS__PageLayout_Name__c != null AND US_WSREMS__Object_Name__c = :REMSAppLiterals.SERVICE_SUMMARY_OBJECT 
                              AND US_WSREMS__RecordType_Name__c = :recTypeDevName];
            if(testPagelayoutList.size()>0){
                pagelayoutList = testPagelayoutList;
            }
            for(US_WSREMS__Pagelayout_Configuration__mdt metadataObj : pagelayoutList){
                pagelayoutName = metadataObj.US_WSREMS__PageLayout_Name__c;
                buttonName = metadataObj.US_WSREMS__Quick_Action_Name__c;
                
            }
            
            if(pagelayoutName!=null){
                layoutSecobjList = DocumentReviewUtility_OCR.getPageLayoutFields(pagelayoutName);
            }
            LayoutInfoWrap LIW = new LayoutInfoWrap();
            LIW.layoutSecobjListInfo  = layoutSecobjList;
            LIW.ButtonName =buttonName; 
            return LIW;
        }
        catch (Exception e) {
        }
        return null; 
        
    }
    
        
    //Get Remsservice fields based on Recordtype.
    @AuraEnabled
    public static List<DocumentReviewUtility_OCR.LayoutSection> getProgramServicelayoutConfigBasedonProgram(Id serviceId,Id programId) {
        List<US_WSREMS__Pagelayout_Configuration__mdt> pagelayoutList = new List<US_WSREMS__Pagelayout_Configuration__mdt>();
        string recTypeDevName = REMSUtility.retrieveRecTypeIdDeveloperName(REMSAppLiterals.SERVICE_SUMMARY_OBJ).get(serviceId);
        US_WSREMS__REMS_Program__c programeObj = [SELECT id,Name FROM US_WSREMS__REMS_Program__c
                                                        WHERE Id=: String.escapeSingleQuotes(programId) WITH SECURITY_ENFORCED  LIMIT 1 ];
           String pagelayoutName;
           List<DocumentReviewUtility_OCR.LayoutSection> layoutSecobjList = new List<DocumentReviewUtility_OCR.LayoutSection>();
            try {
                pagelayoutList = [SELECT Id,US_WSREMS__PageLayout_Name__c, US_WSREMS__Requestor_Type__c,US_WSREMS__RecordType_Name__c
                                    FROM US_WSREMS__Pagelayout_Configuration__mdt 
                                    WHERE US_WSREMS__Object_Name__c = :REMSAppLiterals.SERVICE_SUMMARY_OBJECT 
                                    AND US_WSREMS__Rems_Service_RCtype__c != null
                                    AND US_WSREMS__Program_Name__r.Label =:programeObj.Name  
                                    AND US_WSREMS__Rems_Service_RCtype__c = :recTypeDevName WITH SECURITY_ENFORCED];
                if(testPagelayoutList.size()>0){
                    pagelayoutList = testPagelayoutList;
                }
            for(US_WSREMS__Pagelayout_Configuration__mdt metadataObj : pagelayoutList){
                        pagelayoutName = metadataObj.US_WSREMS__PageLayout_Name__c;
            }
            
            if(pagelayoutName!=null){
                layoutSecobjList = DocumentReviewUtility_OCR.getPageLayoutFields(pagelayoutName);
            }
            return layoutSecobjList;
        }
        catch (Exception e) {
        }
        return null; 
               
    }

    /********************************************************************************************************************************************************
MethodName : getNameSpace
Description: This method will to get Namespace
CreatedDate: 10 Oct, 2023
***********************************************************************************************************************************************************/ 
@AuraEnabled    
public static String getNameSpace(){
    String NameSpace_Str = REMSAppLiterals.NAMESPACE_STRING;
    return NameSpace_Str;
} 


    @AuraEnabled 
    public static List<US_WSREMS__Program_Users__c> getCurrentUserPrograms(){
        try {
            List<US_WSREMS__Program_Users__c> programusersList = [SELECT Id, US_WSREMS__REMS_Program__c, US_WSREMS__REMS_Program__r.Name, US_WSREMS__Is_Active__c
                                                       FROM US_WSREMS__Program_Users__c WHERE US_WSREMS__User__c != null AND US_WSREMS__User__c = :UserInfo.getUserId() AND US_WSREMS__Is_Active__c = true LIMIT 1]; 
            return programusersList;    
        } catch (QueryException e) {
            throw new AuraHandledException('Error fetching current user\'s program: ' + e.getMessage());
        }        
    }
    
/********************************************************************************************************************************************************
   * Method Name          : validateLoggedInUserProgram
   * @Description         : This method is used to validate Program for Logged in User.
   * @CreatedDate         : 15th Nov 2023
   * @Author              : Satyam
   **********************************************************************************************************************************************************/
     @AuraEnabled 
    public static Boolean validateLoggedInUserProgram(){
          boolean isAffiliatedToProgram = False ;
          //List<US_WSREMS__Program_Users__c> programNameList = REMSUtility.getCurrentUserPrograms();
          List<US_WSREMS__Program_Users__c> programNameList = getCurrentUserPrograms();
          if(!programNameList?.isEmpty()){
            isAffiliatedToProgram = True;
          }
        return isAffiliatedToProgram;        
    }
    /********************************************************************************************************************************************************
   * Method Name          : checkWhiteSpaces
   * @Description         : This method is used to check for spaces while searching the Account Name.
   * @CreatedDate         : 11th Jan 2024
   * @parameters          : accountInputMap - A Map containing key-value pairs of account information.
   * @Return              : A Map with white spaces replaced by '%' in specified keys.
   * @Author              : Sukanya
 **********************************************************************************************************************************************************/

 public static Map<String,String> checkWhiteSpaces(Map<String,String> accountinputMap){
           for(String mk: accountinputMap.keySet()){
                if(mk=='MiddleName'){
                   accountinputMap.put(mk,replaceWhiteSpace(accountinputMap.get(mk)));
                }
                if(mk=='Name'){
                   accountinputMap.put(mk,replaceWhiteSpace(accountinputMap.get(mk)));
                }
            }
            return accountinputMap;
    }
/**********************************************************************************************************************
 * Method Name      : replaceWhiteSpace
 * Description      : Replaces white spaces in the given string with '%'.
 * Parameters       : str - The input string.
 * Return           : The string with white spaces replaced by '%'.
 * Created Date     : 11th Jan 20234
 * Author           : Sukanya
 *********************************************************************************************************************/

    public static String replaceWhiteSpace(String str){
        if(str.contains(' ')){
            str = str.replace(' ','%');
        }
        return str;
    }
    
    /********************************************************************************************************************************************************
    * Method Name          : getActiveProgram
    * @Description         : Retrieves the current user's program based on the active Program Users.
    * @CreatedDate         : 9th Jan 2024
    * @Author              : Sukanya 
    **********************************************************************************************************************************************************/
    @AuraEnabled 
    public static US_WSREMS__Program_Users__c getActiveProgram(){
          boolean isAffiliatedToProgram = False ;
          //List<US_WSREMS__Program_Users__c> programNameList = REMSUtility.getCurrentUserPrograms();
          List<US_WSREMS__Program_Users__c> programNameList = getCurrentUserPrograms();
        return programNameList[0];        
    }

    public class LayoutInfoWrap{
        
        @AuraEnabled
        public List<DocumentReviewUtility_OCR.LayoutSection> layoutSecobjListInfo ;
        @AuraEnabled
        public String ButtonName;
    }

    public class ServiceTreeViewConfigWrap{
        @AuraEnabled 
        public String type;
        @AuraEnabled 
        public String fieldName;
        @AuraEnabled 
        public String label;
        @AuraEnabled 
        public Integer initialWidth;
        @AuraEnabled 
        public Map<String,Map<String,String>> typeAttributes;
        @AuraEnabled 
        public String Parent;
        @AuraEnabled 
        public String editable;
        @AuraEnabled 
        public String ParentQueryField;
        
    }

    public class serviceWrapClass{
        @AuraEnabled 
        public US_WSREMS__REMS_Service_Summary__c remsServiceObj;
        @AuraEnabled 
        public List<Case> caseList;
    }

    public class accountWrapClass{
        @AuraEnabled 
        public Account accObj;
        @AuraEnabled 
        public List<serviceWrapClass> remsServiceObjList;
    }

    public class RemsLayoutWrapCls{
        @AuraEnabled 
        public String sectionName;
        @AuraEnabled
        public List<fieldWrap> fieldList; 
        
    }

    public class fieldWrap{
        @AuraEnabled 
        public String fieldName;
        @AuraEnabled 
        public String fieldValue;
    }

    public class pickListOptions{
        @AuraEnabled 
        public String label;
        @AuraEnabled 
        public String value;
    }

    public class AccSearchWrapCls{
        @AuraEnabled 
        public List<US_WSREMS__Dynamic_Account_Search_Config__mdt> acSearchConfigList;
        @AuraEnabled 
        public Map<String,List<pickListOptions>> pickconfigMap;
    }
   
}