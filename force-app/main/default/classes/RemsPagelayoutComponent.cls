/**
* @File Name          : RemsPagelayoutComponent.cls
* @Description        : This is used as a Controller for RemsPageLayoutComponent (Aura).
* @TestClass          : RemsPagelayoutComponent_Test
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    03/12/2022        Chaitanya Nandamuri (Wilco)     Initial Implementation (AutoPopulation of fields before save button)
* 2.0    03/15/2022        Praveen Kumar (Wilco)     	   Creation of Accounts & Affiliations from Case(SHRPP-64,66,68)
**/
public without sharing class RemsPagelayoutComponent {
    
    private
        static final Map<Id, Schema.RecordTypeInfo> mapCaseRecordTypesById =
        Schema.SObjectType.Case.getRecordTypeInfosById();
    private
        static final Map<Id, Schema.RecordTypeInfo> mapAccountRecordTypesById =
        Schema.SObjectType.Account.getRecordTypeInfosById();
    public static Boolean caseStatusComplete = false;
    
    @AuraEnabled(cacheable=true)
    public static List<LightningRecordEditFormController.LayoutSection> getPGfileds(string PGlayoutName){
        
        List<LightningRecordEditFormController.LayoutSection> getLayoutFields = LightningRecordEditFormController.getPageLayoutFields(PGlayoutName);
        return getLayoutFields;
    }
    
    @AuraEnabled(cacheable =true)
    public static Map<String,String> getPrepopFields(Id recordId , string TargetObj , Id RecordTypeId ){
        Map<string , String> TargetSourceMap ;
        Map<String, String> TargetFieldToValueMap = new Map<String, String>();
        
        List<Sobject> SobjectRecLst = new List<Sobject>();
        
        if (String.isBlank(recordId)){
            return  TargetSourceMap ;
        }
        
        String SourceobjNameStr =  String.valueOf(recordId?.getsobjecttype());
        String dynRCtyIdQueryStr = 'select RecordTypeId from '+SourceobjNameStr+' where id =: recordId limit 1';
        Sobject SobjRec = Database.query(dynRCtyIdQueryStr);
        String SourceRCtypeName = mapAccountRecordTypesById.get(string.valueOf(SobjRec.get('RecordTypeId'))).getDeveloperName();
        String TarRCtypeName = mapCaseRecordTypesById.get(RecordTypeId).getDeveloperName();  
        
        TargetSourceMap = getFieldMapping(SourceobjNameStr, TargetObj , SourceRCtypeName,  TarRCtypeName );
        SobjectRecLst = SobjectDynamicFields(TargetSourceMap.values() , SourceobjNameStr , recordId ); 
        
        
        for (string Field : TargetSourceMap.Keyset()){
            
            String Value = TargetSourceMap.get(Field);
            String FieldValue = String.valueOf(SobjectRecLst[0].get(Value));
            TargetFieldToValueMap.put(Field ,  String.isBlank(FieldValue) ? ' ': FieldValue);
        }
        
        return TargetFieldToValueMap ;
    }
    
    private static Map<String,string> getFieldMapping(String SourceObj , String TarObj, String SourceRCtyName , String TarRCtypeName ){
        Map<string,string> TargetSourceFieldMapping = new Map<String,string>();
        
        for (SYN_FieldMapping_Config__mdt mdt : SYN_FieldMapping_Config__mdt.getAll().values()){
            if (mdt.Source_Object__c != SourceObj || mdt.Target_Object__c != TarObj || mdt.Source_RecordType_Name__c != SourceRCtyName || mdt.Target_RecordType_Name__c  != TarRCtypeName ){
                continue;
            }
            TargetSourceFieldMapping.put( mdt.Target_Field__c , mdt.Source_Field__c );
        }
        return TargetSourceFieldMapping;
    }
    
    private static List<Sobject> SobjectDynamicFields(List<String> dynamiceFieldLst, string SourceObj,  Id recordId){
        List<sobject> sourceRecLst = new List<Sobject>();
        String dynamicFieldStr = String.join(dynamiceFieldLst, ',');
        String dynamicQueryStr = 'Select '+dynamicFieldStr+' From '+ SourceObj+' where Id =: recordId';
        return Database.query(dynamicQueryStr);
    }
    
    //SHRPP-64,66,68
    public static Map<String,Id> getAllRecordTypeDetailsById(String objName) {
        //String objectAPIName = 'Case' ; //any object api
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofRecordTypeNameandId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            if(info.isAvailable()){
            mapofRecordTypeNameandId.put(info.getDeveloperName(),info.getRecordTypeId());
        }
     }
        return mapofRecordTypeNameandId;
    }
    //SHRPP-64,66,68
    public static Map<Id,String> getAllRecordTypeDetailsByName(String objName) {
        //String objectAPIName = 'Case' ; //any object api
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<Id,String> mapofRecordTypeNameandId = new Map<Id,String>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            if(info.isAvailable()){
            mapofRecordTypeNameandId.put(info.getRecordTypeId(),info.getDeveloperName());
        }
        }
        return mapofRecordTypeNameandId;
    }
    
    //BT6825-190
    @AuraEnabled
    public static SYN_AccountsDuplicateCheck.duplicateWrapper checkAccountDuplicates(Id recordTypeId , String fields){
        SYN_AccountsDuplicateCheck.duplicateWrapper AccValidationWrapper =  SYN_AccountsDuplicateCheck.checkDuplicate(recordTypeId , fields);
       return AccValidationWrapper;
    }
    @AuraEnabled
    public static ValidationDetails DEAvalidation(Id recordTypeId , String fields){
        SYN_VeevaAPI_Search.caseParameterWrap CPW;
        SYN_VeevaAPI_Search.caseParameterWrap CPW_NPI;
        ValidationDetails vd = new ValidationDetails();
        if (mapCaseRecordTypesById.get(recordTypeId).getDeveloperName().containsIgnoreCase('Pharmacy') || 
            mapCaseRecordTypesById.get(recordTypeId).getDeveloperName().containsIgnoreCase('Prescriber')){
                Map<String,Object > fieldMappingMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
                if (fieldMappingMap.Keyset() == null ){
                    return vd;
                }
                if (fieldMappingMap.get('US_WSREMS__Program_Picklist__c') == 'Macitentan REMS'){
                    SYN_VeevaAPI_Search.programName = 'Macitentan REMS';
                }   
                CPW = new SYN_VeevaAPI_Search.caseParameterWrap(null , String.valueOf(fieldMappingMap.get('US_WSREMS__DEA__c')) , String.valueOf(fieldMappingMap.get('US_WSREMS__Last_Name__c')), String.valueOf(fieldMappingMap.get('RecordTypeId')) );
                vd.DEAValidation= SYN_VeevaAPI_Search.searchResult(CPW);
                CPW_NPI = new SYN_VeevaAPI_Search.caseParameterWrap(null , String.valueOf(fieldMappingMap.get('US_WSREMS__NPI__c')) , String.valueOf(fieldMappingMap.get('US_WSREMS__Last_Name__c')), String.valueOf(fieldMappingMap.get('RecordTypeId')) );
                 CPW_NPI.NPIvalidation=true;
                CPW_NPI.pharmacyName = String.valueOf(fieldMappingMap.get('PharmacyName')) ;
                vd.NPIValidation= SYN_VeevaAPI_Search.searchResult(CPW_NPI);
                return vd;
            }else{
                return vd;
            }
        
        
    }

    //SHRPP-64,66,68
    @AuraEnabled
    public static AccountCreationDetails createAccountOnCaseCreation(Id CaseId){
        
        AccountCreationDetails ACD = new AccountCreationDetails();
        
        List<Case> newCaseLst = New List<Case>([SELECT AccountId,CaseNumber,ClosedDate,Comments,ContactEmail,ContactFax,ContactId,ContactMobile,
                                                ContactPhone,CreatedById,CreatedDate,Description,HealthCloudGA__DueDate__c,HealthCloudGA__FinancialValue__c,
                                                HealthCloudGA__SortOrder__c,HealthCloudGA__SourceAgencyMeasureID__c,HealthCloudGA__SourceAgencyMeasureVersion__c,
                                                HealthCloudGA__SourceAgency__c,HealthCloudGA__SourceSystemID__c,HealthCloudGA__SourceSystemModified__c,HealthCloudGA__SourceSystem__c,
                                                Id,IsClosed,IsDeleted,IsEscalated,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,MasterRecordId,Origin,OwnerId,ParentId,Priority,
                                                ProductId,Professional_Designation__c,Reason,RecordTypeId,Status,Subject,SuppliedCompany,SuppliedEmail,SuppliedName,SuppliedPhone,SYN_Alternate_Phone__c,SYN_Alternate_Phone_Ext__c,
                                                SYN_Authorized_Rep__c,SYN_Case_Id__c,SYN_Country__c,SYN_Credentials__c,SYN_Currently_Enrolled_for_Oxybate__c,SYN_Ext_Office_Contact_Phone__c,SYN_Gender__c,
                                                SYN_Guardian_Name__c,SYN_Job_Title__c,SYN_Office_Contact_Phone__c,SYN_Office_Contact__c,SYN_Pharmacy__c,SYN_Prescriber_Attests_Of_Patient__c,SYN_Prescriber_Ext_Fax__c,
                                                SYN_Prescriber_Ext__c,SYN_Prescriber_Fax__c,SYN_Prescriber_First_Name__c,SYN_Prescriber_Last_Name__c,SYN_Prescriber_Middle_Name__c,SYN_Prescriber_Phone__c,
                                                SYN_Prescriber_Signature_Date__c,SYN_Prescriber_Signature__c,SYN_Prescriber__c,SYN_Previously_Enrolled_for_Oxybate__c,SYN_Ref_Id__c,SYN_Shipping_State__c,SYN_Street_Address__c,
                                                SYN_Zip_Code__c,SystemModstamp,Type,US_WSREMS__AccountStatus__c,US_WSREMS__Account_Type__c,US_WSREMS__Address_Line_1__c,US_WSREMS__Address_Line_2__c,US_WSREMS__Attention__c,
                                                US_WSREMS__Case_Path__c,US_WSREMS__Channel__c,US_WSREMS__City__c,US_WSREMS__Comments__c,US_WSREMS__Credential__c,US_WSREMS__Date__c,US_WSREMS__Deactivation_Date__c,
                                                US_WSREMS__Deactivation_Reason__c,US_WSREMS__DEA__c,US_WSREMS__Dispensing_Date__c,US_WSREMS__Dispensing_Pharmacy_If_Different__c,US_WSREMS__DOB__c,US_WSREMS__Duplicate_Identifier_Status__c,
                                                US_WSREMS__Email_PharmacyAddress__c,US_WSREMS__Email__c,US_WSREMS__End_Date__c,US_WSREMS__EngineeringReqNumber__c,US_WSREMS__Expiration_Date__c,US_WSREMS__Ext__c,SYN_Ext__c,
                                                US_WSREMS__Facility__c,US_WSREMS__Fax__c,US_WSREMS__First_Name__c,US_WSREMS__Full_Name_of_the_Prescribing_Institution__c,US_WSREMS__GMC_ID__c,US_WSREMS__GPhC_ID_Pharmacy__c,
                                                US_WSREMS__GPhC_ID__c,US_WSREMS__Home_Care__c,US_WSREMS__Identifier_Validation_Status__c,US_WSREMS__Incomplete_Enrollment_Reasons__c,US_WSREMS__Indication__c,
                                                US_WSREMS__Is_Portal__c,US_WSREMS__Last_Name__c,US_WSREMS__Male__c,US_WSREMS__ME__c,US_WSREMS__Middle_Name__c,US_WSREMS__MI__c,US_WSREMS__Name__c,
                                                US_WSREMS__NCPDP__c,US_WSREMS__NHS_Trust_Name_Private_Group_Other__c,US_WSREMS__NMC_ID__c,US_WSREMS__NPI__c,US_WSREMS__Other_Speciality__c,
                                                US_WSREMS__Outcome__c,US_WSREMS__Override__c,US_WSREMS__Participant__c,US_WSREMS__Patient2__c,US_WSREMS__Patient_Counseling_Complete__c,
                                                US_WSREMS__Patient_Counselling__c,US_WSREMS__Patient_Date_of_Birth__c,US_WSREMS__Patient_Initials_First_Middle_Last__c,US_WSREMS__Patient_Risk_Category__c,
                                                US_WSREMS__Patient__c,US_WSREMS__Pharmacist_Confirmation__c,US_WSREMS__Pharmacy_Agreement_Complete__c,US_WSREMS__Pharmacy_Declaration_Complete__c,
                                                US_WSREMS__Pharmacy_Name__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__c,US_WSREMS__Phone_Pharmacyaddress__c,US_WSREMS__Phone_Type__c,
                                                US_WSREMS__Phone__c,US_WSREMS__Please_enter_number_of_weeks__c,US_WSREMS__Please_provide_reason__c,US_WSREMS__Please_specify_the_indication__c,
                                                US_WSREMS__Please_verify_if_this_PAF_is_for__c,US_WSREMS__Postcode__c,US_WSREMS__PotentialLiability__c,US_WSREMS__Preferred_Contact_Method__c,
                                                US_WSREMS__Pregnancy_Test_Results__c,US_WSREMS__Prescriber__c,US_WSREMS__Prescribing_Institution__c,US_WSREMS__Prescription_Date__c,
                                                US_WSREMS__Primary_Facility__c,US_WSREMS__Product_Type__c,US_WSREMS__Product__c,US_WSREMS__Program_Name__c,US_WSREMS__PSNI_ID_Pharmacy_service__c,
                                                US_WSREMS__PSNI_ID__c,US_WSREMS__QC_Case_Reviewed_By__c,US_WSREMS__QC_Case_Submitted_By__c,US_WSREMS__Reason_For_Change__c,US_WSREMS__Record_Type_Name__c,
                                                US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Service_Stage__c,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__Requestor_First_Name__c,
                                                US_WSREMS__Requestor_Last_Name__c,US_WSREMS__Requestor_Phone__c,US_WSREMS__Requestor_Type__c,US_WSREMS__Role__c,US_WSREMS__Secondary_Facility__c,
                                                US_WSREMS__Service_Requestor_Type__c,US_WSREMS__Service_Type__c,US_WSREMS__Shipping_City__c,US_WSREMS__Shipping_Country__c,
                                                US_WSREMS__Shipping_State_Province__c,US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_Zip_Postal_Code__c,US_WSREMS__Signature_Date_Pharmacist__c,
                                                US_WSREMS__Signature_Pharmacist__c,US_WSREMS__Signature__c,US_WSREMS__SLN_Issued_State__c,US_WSREMS__SLN__c,US_WSREMS__Speciality__c,
                                                US_WSREMS__Start_Date__c,US_WSREMS__State__c,US_WSREMS__Status__c,US_WSREMS__Target_Prescribing_Institution__c,US_WSREMS__Total_Supply_Prescribed__c,
                                                US_WSREMS__User_Type__c,US_WSREMS__WCBP_Pregnancy_Test_Date__c,US_WSREMS__WCBP__c,US_WSREMS__Zipcode__c,SYN_User_Type__c,SYN_DEA_Validation__c,Sub_Status__c,NPI_Status__c,SLN_Status__c,
                                                SYN_Medical_specialty__c 
                                                FROM Case WHERE ID =: CaseId]);
        if (newCaseLst[0].Status == 'Complete'){
            caseStatusComplete = true;
        
        }

        List<Account> accListToInsert = New List<Account>();
        Account acc;
        
        Id prescriberCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();
        Id presInstrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution').getRecordTypeId();
        Id generalConCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
        Id generalConrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
        
        
        Map<String,String> CaseFieldsVsAccountFieldsCustMetaMap = New Map<String,String>();
        Map<String,Object> CaseFieldsVsValuesMap = New Map<String,Object>();
        Map<String,Object> AccFieldsAPIVsCaseFieldValuesMap = New Map<String,Object>(); //Not used yet
        
        Map<String,Id> mapofCaseRecordTypeNameandId = getAllRecordTypeDetailsById('Case'); //Not used yet
        Map<String,Id> mapofAccountRecordTypeNameandId = getAllRecordTypeDetailsById('Account');
        
        Map<Id,String> mapofCaseRecordTypeIdandName = getAllRecordTypeDetailsByName('Case');
        Map<Id,String> mapofAccountRecordTypeIdandName = getAllRecordTypeDetailsByName('Account'); //Not used yet
        
        Map<String,String> mapofCaseRecordTypeNameVSAccName = New Map<String,String>();
        
        List<SYNRecordTypeConfig__mdt> recordTypes = New List<SYNRecordTypeConfig__mdt>([SELECT Source_Record_Type__c,Target_Record_Type__c FROM SYNRecordTypeConfig__mdt]);
        
        List<SYN_FieldMapping_Config__mdt> fieldMappingList = New List<SYN_FieldMapping_Config__mdt>([SELECT Source_Field__c,
                                                                                                      Source_Object__c,Source_RecordType_Name__c,Target_Field__c,Target_Object__c,
                                                                                                      Target_RecordType_Name__c FROM SYN_FieldMapping_Config__mdt WHERE Account_Creation__c = True]);
        US_WSREMS__REMS_Program__c remsProg = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c where Name =: 'Sodium Oxybate REMS' limit 1];
        
        for(SYNRecordTypeConfig__mdt rec:recordTypes){
            mapofCaseRecordTypeNameVSAccName.put(rec.Source_Record_Type__c,rec.Target_Record_Type__c);
        }
        
        //Create map for the source field vs the target field based on the custom metadatatype....
        for(Case cs: newCaseLst){
            for(SYN_FieldMapping_Config__mdt fm : fieldMappingList){
                if(mapofCaseRecordTypeIdandName.get(cs.RecordTypeId) == fm.Source_RecordType_Name__c){                   
                    CaseFieldsVsAccountFieldsCustMetaMap.put(fm.Source_Field__c,fm.Target_Field__c);
                }
            } 
        }
        
        //Create map for the case field vs its actual value to map it later to the target field as a value...
        for(Case cs: newCaseLst){
            for(String cs1 : CaseFieldsVsAccountFieldsCustMetaMap.Keyset()){
                CaseFieldsVsValuesMap.put(cs1, cs.get(cs1));
            }
        }
        
        //Actual loop......
        for(Case cs: newCaseLst){
            acc = New Account();
            for(String cs1 : CaseFieldsVsAccountFieldsCustMetaMap.Keyset()){
                acc.RecordTypeId = mapofAccountRecordTypeNameandId.get(mapofCaseRecordTypeNameVSAccName.get(mapofCaseRecordTypeIdandName.get(cs.RecordTypeId)));
                acc.Put(CaseFieldsVsAccountFieldsCustMetaMap.get(cs1),CaseFieldsVsValuesMap.get(cs1));
            }
            //If the prescriber information don't have the facility... then create an account...
            if(cs.US_WSREMS__Facility__c == null && (cs.RecordTypeId == prescriberCaseRecordTypeId || cs.RecordTypeId == generalConCaseRecordTypeId) ){
                Account presAcc = New Account(Name = cs.US_WSREMS__Name__c,US_WSREMS__REMS_Program__c = cs.US_WSREMS__REMS_Program__c, SYN_Case_Id__c = cs.Id,RecordTypeId = presInstrecordTypeId,ShippingStreet = cs.US_WSREMS__Address_Line_1__c,
                                              SYN_Shipping_Address_2__c = cs.US_WSREMS__Address_Line_2__c,ShippingCity=cs.US_WSREMS__City__c,
                                              ShippingState = cs.US_WSREMS__State__c,ShippingPostalCode=cs.SYN_Zip_Code__c,ShippingCountry=cs.SYN_Country__c,
                                              Phone = cs.US_WSREMS__Phone__c, fax=cs.US_WSREMS__Fax__c,SYN_Ext__c=cs.SYN_Ext__c,US_WSREMS__Email__c=cs.US_WSREMS__Email__c,
                                              US_WSREMS__Preferred_Contact_Method__c=cs.US_WSREMS__Preferred_Contact_Method__c);
                accListToInsert.add(presAcc);
            } 
        }
        Database.SaveResult[] srList = Database.insert(accListToInsert, false);
        
        Case caseNeedsToBeUpdate = new Case(Id = CaseId);
        
        if(newCaseLst != NULL && newCaseLst.size() > 0 && newCaseLst[0].US_WSREMS__Facility__c == null && newCaseLst[0].RecordTypeId == prescriberCaseRecordTypeId
            && srList != NULL && srList.size() > 0 && srList[0].getId() != NULL) {
                acc.SYN_Facility__c = srList[0].getId();
                caseNeedsToBeUpdate.US_WSREMS__Facility__c = srList[0].getId();
        }
        
        Database.SaveResult accInserted = Database.insert(acc, false);
        // Database method to insert the records in List
        // Iterate through each returned result by the method
        Set<Id> insertedPrescInstitutionIds = New Set<Id>();
        
        Id generalConAffiRecTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('General_Contact_Affiliation').getRecordTypeId();
        Id prescAffiRecTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Prescriber_Affiliation').getRecordTypeId();
        Id presAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Account accRec = New Account();
        if(accInserted.getId() != null){
            caseAccountAssociation(caseNeedsToBeUpdate,accInserted.getId());  
            accRec = [SELECT Id,RecordTypeId , Name FROM Account WHERE Id =: accInserted.getId() limit 1];
            ACD.AccountCreate = true;
            ACD.notificationMsg ='Account record is created';
            ACD.AccountId =   accInserted.getId();
            ACD.accountRec = accRec;
        } else{
            Database.Error err =  accInserted.getErrors()[0];
            
            String ErrorMsg = err.getMessage().contains('US_WSREMS__NPI__c')  ? 'User entered a Duplicate NPI value' : err.getMessage(); 
            ACD.AccountCreate = false;
            ACD.notificationMsg =ErrorMsg;
            return ACD;
        }
        return ACD;
    }

    @AuraEnabled
    public static AccountCreationDetails updateAccountOnCaseCreation(Id CaseId, Id AccountId){
        AccountCreationDetails ACD = new AccountCreationDetails();
        
        List<Case> newCaseLst = New List<Case>([SELECT AccountId,CaseNumber,ClosedDate,Comments,ContactEmail,ContactFax,ContactId,ContactMobile,
                                                ContactPhone,CreatedById,CreatedDate,Description,HealthCloudGA__DueDate__c,HealthCloudGA__FinancialValue__c,
                                                HealthCloudGA__SortOrder__c,HealthCloudGA__SourceAgencyMeasureID__c,HealthCloudGA__SourceAgencyMeasureVersion__c,
                                                HealthCloudGA__SourceAgency__c,HealthCloudGA__SourceSystemID__c,HealthCloudGA__SourceSystemModified__c,HealthCloudGA__SourceSystem__c,
                                                Id,IsClosed,IsDeleted,IsEscalated,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,MasterRecordId,Origin,OwnerId,ParentId,Priority,
                                                ProductId,Professional_Designation__c,Reason,RecordTypeId,Status,Subject,SuppliedCompany,SuppliedEmail,SuppliedName,SuppliedPhone,SYN_Alternate_Phone__c,SYN_Alternate_Phone_Ext__c,
                                                SYN_Authorized_Rep__c,SYN_Case_Id__c,SYN_Country__c,SYN_Credentials__c,SYN_Currently_Enrolled_for_Oxybate__c,SYN_Ext_Office_Contact_Phone__c,SYN_Gender__c,
                                                SYN_Guardian_Name__c,SYN_Job_Title__c,SYN_Office_Contact_Phone__c,SYN_Office_Contact__c,SYN_Pharmacy__c,SYN_Prescriber_Attests_Of_Patient__c,SYN_Prescriber_Ext_Fax__c,
                                                SYN_Prescriber_Ext__c,SYN_Prescriber_Fax__c,SYN_Prescriber_First_Name__c,SYN_Prescriber_Last_Name__c,SYN_Prescriber_Middle_Name__c,SYN_Prescriber_Phone__c,
                                                SYN_Prescriber_Signature_Date__c,SYN_Prescriber_Signature__c,SYN_Prescriber__c,SYN_Previously_Enrolled_for_Oxybate__c,SYN_Ref_Id__c,SYN_Shipping_State__c,SYN_Street_Address__c,
                                                SYN_Zip_Code__c,SystemModstamp,Type,US_WSREMS__AccountStatus__c,US_WSREMS__Account_Type__c,US_WSREMS__Address_Line_1__c,US_WSREMS__Address_Line_2__c,US_WSREMS__Attention__c,
                                                US_WSREMS__Case_Path__c,US_WSREMS__Channel__c,US_WSREMS__City__c,US_WSREMS__Comments__c,US_WSREMS__Credential__c,US_WSREMS__Date__c,US_WSREMS__Deactivation_Date__c,
                                                US_WSREMS__Deactivation_Reason__c,US_WSREMS__DEA__c,US_WSREMS__Dispensing_Date__c,US_WSREMS__Dispensing_Pharmacy_If_Different__c,US_WSREMS__DOB__c,US_WSREMS__Duplicate_Identifier_Status__c,
                                                US_WSREMS__Email_PharmacyAddress__c,US_WSREMS__Email__c,US_WSREMS__End_Date__c,US_WSREMS__EngineeringReqNumber__c,US_WSREMS__Expiration_Date__c,US_WSREMS__Ext__c,SYN_Ext__c,
                                                US_WSREMS__Facility__c,US_WSREMS__Fax__c,US_WSREMS__First_Name__c,US_WSREMS__Full_Name_of_the_Prescribing_Institution__c,US_WSREMS__GMC_ID__c,US_WSREMS__GPhC_ID_Pharmacy__c,
                                                US_WSREMS__GPhC_ID__c,US_WSREMS__Home_Care__c,US_WSREMS__Identifier_Validation_Status__c,US_WSREMS__Incomplete_Enrollment_Reasons__c,US_WSREMS__Indication__c,
                                                US_WSREMS__Is_Portal__c,US_WSREMS__Last_Name__c,US_WSREMS__Male__c,US_WSREMS__ME__c,US_WSREMS__Middle_Name__c,US_WSREMS__MI__c,US_WSREMS__Name__c,
                                                US_WSREMS__NCPDP__c,US_WSREMS__NHS_Trust_Name_Private_Group_Other__c,US_WSREMS__NMC_ID__c,US_WSREMS__NPI__c,US_WSREMS__Other_Speciality__c,
                                                US_WSREMS__Outcome__c,US_WSREMS__Override__c,US_WSREMS__Participant__c,US_WSREMS__Patient2__c,US_WSREMS__Patient_Counseling_Complete__c,
                                                US_WSREMS__Patient_Counselling__c,US_WSREMS__Patient_Date_of_Birth__c,US_WSREMS__Patient_Initials_First_Middle_Last__c,US_WSREMS__Patient_Risk_Category__c,
                                                US_WSREMS__Patient__c,US_WSREMS__Pharmacist_Confirmation__c,US_WSREMS__Pharmacy_Agreement_Complete__c,US_WSREMS__Pharmacy_Declaration_Complete__c,
                                                US_WSREMS__Pharmacy_Name__c,US_WSREMS__Pharmacy_User__c,US_WSREMS__Pharmacy__c,US_WSREMS__Phone_Pharmacyaddress__c,US_WSREMS__Phone_Type__c,
                                                US_WSREMS__Phone__c,US_WSREMS__Please_enter_number_of_weeks__c,US_WSREMS__Please_provide_reason__c,US_WSREMS__Please_specify_the_indication__c,
                                                US_WSREMS__Please_verify_if_this_PAF_is_for__c,US_WSREMS__Postcode__c,US_WSREMS__PotentialLiability__c,US_WSREMS__Preferred_Contact_Method__c,
                                                US_WSREMS__Pregnancy_Test_Results__c,US_WSREMS__Prescriber__c,US_WSREMS__Prescribing_Institution__c,US_WSREMS__Prescription_Date__c,
                                                US_WSREMS__Primary_Facility__c,US_WSREMS__Product_Type__c,US_WSREMS__Product__c,US_WSREMS__Program_Name__c,US_WSREMS__PSNI_ID_Pharmacy_service__c,
                                                US_WSREMS__PSNI_ID__c,US_WSREMS__QC_Case_Reviewed_By__c,US_WSREMS__QC_Case_Submitted_By__c,US_WSREMS__Reason_For_Change__c,US_WSREMS__Record_Type_Name__c,
                                                US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Service_Stage__c,US_WSREMS__REMS_Service_Summary__c,US_WSREMS__Requestor_First_Name__c,
                                                US_WSREMS__Requestor_Last_Name__c,US_WSREMS__Requestor_Phone__c,US_WSREMS__Requestor_Type__c,US_WSREMS__Role__c,US_WSREMS__Secondary_Facility__c,
                                                US_WSREMS__Service_Requestor_Type__c,US_WSREMS__Service_Type__c,US_WSREMS__Shipping_City__c,US_WSREMS__Shipping_Country__c,
                                                US_WSREMS__Shipping_State_Province__c,US_WSREMS__Shipping_Street__c,US_WSREMS__Shipping_Zip_Postal_Code__c,US_WSREMS__Signature_Date_Pharmacist__c,
                                                US_WSREMS__Signature_Pharmacist__c,US_WSREMS__Signature__c,US_WSREMS__SLN_Issued_State__c,US_WSREMS__SLN__c,US_WSREMS__Speciality__c,
                                                US_WSREMS__Start_Date__c,US_WSREMS__State__c,US_WSREMS__Status__c,US_WSREMS__Target_Prescribing_Institution__c,US_WSREMS__Total_Supply_Prescribed__c,
                                                US_WSREMS__User_Type__c,US_WSREMS__WCBP_Pregnancy_Test_Date__c,US_WSREMS__WCBP__c,US_WSREMS__Zipcode__c,SYN_User_Type__c , SYN_DEA_Validation__c,SYN_Validation_Date__c,Sub_Status__c,NPI_Status__c,SLN_Status__c,
                                                SYN_Medical_specialty__c
                                                FROM Case WHERE ID =: CaseId]);
        
        if (newCaseLst[0].Status == 'Complete'){
            caseStatusComplete = true;
        }

        List<Account> accListToInsert = New List<Account>();
        List<Account> accListToUpdate = New List<Account>();
        Account acc;
        
        Id prescriberCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prescriber_Person_Account').getRecordTypeId();
        Id presInstrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescribing_Institution').getRecordTypeId();
        Id generalConCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
        Id generalConrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('General_Contact').getRecordTypeId();
        
        
        Map<String,String> CaseFieldsVsAccountFieldsCustMetaMap = New Map<String,String>();
        Map<String,Object> CaseFieldsVsValuesMap = New Map<String,Object>();
        Map<String,Object> AccFieldsAPIVsCaseFieldValuesMap = New Map<String,Object>(); //Not used yet
        
        Map<String,Id> mapofCaseRecordTypeNameandId = getAllRecordTypeDetailsById('Case'); //Not used yet
        Map<String,Id> mapofAccountRecordTypeNameandId = getAllRecordTypeDetailsById('Account');
        
        Map<Id,String> mapofCaseRecordTypeIdandName = getAllRecordTypeDetailsByName('Case');
        Map<Id,String> mapofAccountRecordTypeIdandName = getAllRecordTypeDetailsByName('Account'); //Not used yet
        
        Map<String,String> mapofCaseRecordTypeNameVSAccName = New Map<String,String>();
        
        List<SYNRecordTypeConfig__mdt> recordTypes = New List<SYNRecordTypeConfig__mdt>([SELECT Source_Record_Type__c,Target_Record_Type__c FROM SYNRecordTypeConfig__mdt]);
        
        List<SYN_FieldMapping_Config__mdt> fieldMappingList = New List<SYN_FieldMapping_Config__mdt>([SELECT Source_Field__c,
                                                                                                      Source_Object__c,Source_RecordType_Name__c,Target_Field__c,Target_Object__c,
                                                                                                      Target_RecordType_Name__c FROM SYN_FieldMapping_Config__mdt WHERE Account_Creation__c = True]);
        US_WSREMS__REMS_Program__c remsProg = [SELECT Id, Name FROM US_WSREMS__REMS_Program__c where Name =: 'Sodium Oxybate REMS' limit 1];
        
        for(SYNRecordTypeConfig__mdt rec:recordTypes){
            mapofCaseRecordTypeNameVSAccName.put(rec.Source_Record_Type__c,rec.Target_Record_Type__c);
        }
        //Create map for the source field vs the target field based on the custom metadatatype....
        for(Case cs: newCaseLst){
            for(SYN_FieldMapping_Config__mdt fm : fieldMappingList){
                if(mapofCaseRecordTypeIdandName.get(cs.RecordTypeId) == fm.Source_RecordType_Name__c){                   
                    CaseFieldsVsAccountFieldsCustMetaMap.put(fm.Source_Field__c,fm.Target_Field__c);
                }
            } 
        }
        
        //Create map for the case field vs its actual value to map it later to the target field as a value...
        for(Case cs: newCaseLst){
            for(String cs1 : CaseFieldsVsAccountFieldsCustMetaMap.Keyset()){
                CaseFieldsVsValuesMap.put(cs1, cs.get(cs1));
            }
        }
        
        //Actual loop......
        
             acc = [SELECT Id, US_WSREMS__REMS_Program__c,Date_Enrolled__c,RecordTypeId,SYN_Ref_Id__c,US_WSREMS__Status__c,US_WSREMS__Channel__c,
            US_WSREMS__DEA__c,SYN_Professional_Designation__c,US_WSREMS__NPI__c,US_WSREMS__SLN__c,Phone,SYN_Ext__c,US_WSREMS__Email__c,Fax,
            US_WSREMS__Preferred_Contact_Method__c,US_WSREMS__Account_Type__c,US_WSREMS__User_Type__c,US_WSREMS__Role__c,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,
            SYN_Shipping_Address_2__c  FROM Account WHERE Id = :AccountId LIMIT 1 ]; 
           
		for(Case cs: newCaseLst){
		   // acc = AccountId;
            for(String cs1 : CaseFieldsVsAccountFieldsCustMetaMap.Keyset()){
                acc.RecordTypeId = mapofAccountRecordTypeNameandId.get(mapofCaseRecordTypeNameVSAccName.get(mapofCaseRecordTypeIdandName.get(cs.RecordTypeId)));
                acc.Put(CaseFieldsVsAccountFieldsCustMetaMap.get(cs1),CaseFieldsVsValuesMap.get(cs1));
            }
            //If the prescriber information don't have the facility... then create an account...
            if(cs.US_WSREMS__Facility__c == null && (cs.RecordTypeId == prescriberCaseRecordTypeId || cs.RecordTypeId == generalConCaseRecordTypeId) ){
                Account presAcc = New Account(Name = cs.US_WSREMS__Name__c,US_WSREMS__REMS_Program__c = cs.US_WSREMS__REMS_Program__c, SYN_Case_Id__c = cs.Id,RecordTypeId = presInstrecordTypeId,ShippingStreet = cs.US_WSREMS__Address_Line_1__c,
                                              SYN_Shipping_Address_2__c = cs.US_WSREMS__Address_Line_2__c,ShippingCity=cs.US_WSREMS__City__c,
                                              ShippingState = cs.US_WSREMS__State__c,ShippingPostalCode=cs.SYN_Zip_Code__c,ShippingCountry=cs.SYN_Country__c,
                                              Phone = cs.US_WSREMS__Phone__c, fax=cs.US_WSREMS__Fax__c,SYN_Ext__c=cs.SYN_Ext__c,US_WSREMS__Email__c=cs.US_WSREMS__Email__c,
                                              US_WSREMS__Preferred_Contact_Method__c=cs.US_WSREMS__Preferred_Contact_Method__c);
                accListToInsert.add(presAcc);
            } 
		}

        Case caseNeedsToBeUpdate = new Case(Id = CaseId);

        Database.SaveResult[] srList = Database.insert(accListToInsert, false);
        Database.SaveResult accUpdated = Database.update(acc, false);
        
        // Database method to insert the records in List
        // Iterate through each returned result by the method
        Set<Id> insertedPrescInstitutionIds = New Set<Id>();
        
        Id generalConAffiRecTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('General_Contact_Affiliation').getRecordTypeId();
        Id prescAffiRecTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Prescriber_Affiliation').getRecordTypeId();
        Id presAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Account accRec = New Account();
        if(accUpdated.getId() != null){
            caseAccountAssociation(caseNeedsToBeUpdate,accUpdated.getId());  
            accRec = [SELECT Id,RecordTypeId FROM Account WHERE Id =: accUpdated.getId() limit 1];
            ACD.AccountCreate = true;
            ACD.notificationMsg ='Account record is updated';
            ACD.AccountId =   accUpdated.getId();
        } else{
            Database.Error err =  accUpdated.getErrors()[0];
            
            String ErrorMsg = err.getMessage().contains('US_WSREMS__NPI__c')  ? 'User entered a Duplicate NPI value' : err.getMessage(); 
            ACD.AccountCreate = false;
            ACD.notificationMsg =ErrorMsg;
            return ACD;
        }
       
        if(caseNeedsToBeUpdate != NULL) {
            update caseNeedsToBeUpdate;
        }
        return ACD;
    }
    
    Private static void caseAccountAssociation(Case caseInstance , Id AccountId){
        case cse = caseInstance;
        cse.US_WSREMS__Participant__c = AccountId;
        cse.Status = 'Complete';
        US_WSREMS.REMSAvoidRecursiveCls.stop_accountUpdate=true;
        update cse;
    }
    
     Public class ValidationDetails {
        @AuraEnabled
        public boolean DEAValidation;
        @AuraEnabled
        public boolean NPIValidation;
       
    }
    
    Public class AccountCreationDetails {
        @AuraEnabled
        public boolean AccountCreate;
        @AuraEnabled
        public string notificationMsg;
        @AuraEnabled
        public Id AccountId;
        @AuraEnabled
        public Account accountRec;
    }
    
}