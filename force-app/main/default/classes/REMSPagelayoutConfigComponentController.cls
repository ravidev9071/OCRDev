/**************************************************************************
    * Name :   REMSPagelayoutConfigComponentController 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  8/16/2022             Initial Version
    *********************************************************************************/
public without sharing class REMSPagelayoutConfigComponentController {
    //Date  : 09/15/2024 changes added to resolve Duplicate record type issue from line 13,14,19,21 by DILEEP G  
    
    private
        static final Map<String,Id> mapCaseRecordTypesById = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
    private
        static final Map<Id,String> mapCaseRecordTypesByIdDeveloperName = REMSUtility.retrieveRecTypeIdDeveloperName_Product('Case');
    private
        static final   Map<Id, Schema.RecordTypeInfo> mapCaseRecordTypesByIdDEA = Schema.SObjectType.Case.getRecordTypeInfosById();
    private
        static final   Map<String,Id> mapAccountRecordTypesById = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
    private
        static final   Map<Id,String> mapAccountRecordTypesByIdDeveloperName = REMSUtility.retrieveRecTypeIdDeveloperName_Product('Account'); 
    private
        static final Map<Id, Schema.RecordTypeInfo> mapAccountRecordTypesByIdDEA =  Schema.SObjectType.Account.getRecordTypeInfosById();
    public static Boolean caseStatusComplete = false;
    
    @AuraEnabled(cacheable=true)
    public static List<LightningRecordEditFormController.LayoutSection> getPGfileds(string PGlayoutName){
        
        List<LightningRecordEditFormController.LayoutSection> getLayoutFields = LightningRecordEditFormController.getPageLayoutFields(PGlayoutName);
        return getLayoutFields;
    }
    
    @AuraEnabled(cacheable =true)
    public static Map<String,String> getPrepopFields(Id recordId , string TargetObj , Id RecordTypeId ,  String programName , String parentField){
        Map<string , String> TargetSourceMap ;
        Map<String, String> TargetFieldToValueMap = new Map<String, String>();
        
        List<Sobject> SobjectRecLst = new List<Sobject>();
        
        if (String.isBlank(recordId)){
            return  TargetSourceMap ;
        }
        String SourceobjNameStr =  String.valueOf(recordId?.getsobjecttype());

        String dynRCtyIdQueryStr = 'select RecordTypeId from '+SourceobjNameStr+' where id =: recordId limit 1';
        Sobject SobjRec = Database.query(dynRCtyIdQueryStr);
        String SourceRCtypeName = mapAccountRecordTypesByIdDeveloperName.get(string.valueOf(SobjRec.get('RecordTypeId')));
        String TarRCtypeName = mapCaseRecordTypesByIdDeveloperName.get(RecordTypeId);  
        
        TargetSourceMap = getFieldMapping(SourceobjNameStr, TargetObj , SourceRCtypeName,  TarRCtypeName ,  programName, parentField);
        if(TargetSourceMap != null && !TargetSourceMap.isEmpty()){
        SobjectRecLst = SobjectDynamicFields(TargetSourceMap.values() , SourceobjNameStr , recordId ); 
        
        
        for (string Field : TargetSourceMap.Keyset()){
            
            String Value = TargetSourceMap.get(Field);
            String FieldValue = String.valueOf(SobjectRecLst[0].get(Value));
            TargetFieldToValueMap.put(Field ,  String.isBlank(FieldValue) ? ' ': FieldValue);
        }
        }
        return TargetFieldToValueMap ;
    }
    
    private static Map<String,string> getFieldMapping(String SourceObj , String TarObj, String SourceRCtyName , String TarRCtypeName , String ProgramName, String parentField ){
        Map<string,string> TargetSourceFieldMapping = new Map<String,string>();
        
        for (US_WSREMS__Field_Mapping_Config__mdt mdt : [SELECT Id,US_WSREMS__Parent_Field__c,US_WSREMS__Program__c,US_WSREMS__Request_Type__c,US_WSREMS__Section_Name__c,US_WSREMS__Source_Field__c,
                                                            US_WSREMS__Source_Object__c,US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Target_Field__c,US_WSREMS__Target_Object__c,US_WSREMS__Target_RecordType_Name__c
                                                            FROM US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Source_Object__c =: SourceObj  AND US_WSREMS__Target_Object__c =: TarObj AND US_WSREMS__Source_RecordType_Name__c =: SourceRCtyName 
                                                            AND US_WSREMS__Target_RecordType_Name__c  =: TarRCtypeName AND US_WSREMS__Program__c != NULL AND US_WSREMS__Parent_Field__c =: parentField AND US_WSREMS__Program__r.Masterlabel =: ProgramName
                                                            AND US_WSREMS__IsActive__c = true AND US_WSREMS__isOnLoad__c = true ] ){
            if (mdt.US_WSREMS__Source_Object__c != SourceObj || mdt.US_WSREMS__Target_Object__c != TarObj || mdt.US_WSREMS__Source_RecordType_Name__c != SourceRCtyName || mdt.US_WSREMS__Target_RecordType_Name__c != TarRCtypeName ){
                continue;
            }
            TargetSourceFieldMapping.put( mdt.US_WSREMS__Target_Field__c, mdt.US_WSREMS__Source_Field__c);
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
    /* we are not using DEA Validation for Maci Program */
    
    @AuraEnabled
    public static boolean DEAvalidation(Id recordTypeId , String fields){
        SYN_VeevaAPI_Search.caseParameterWrap CPW;
        if (mapCaseRecordTypesByIdDEA.get(recordTypeId).getDeveloperName().containsIgnoreCase('Pharmacy') || 
            mapCaseRecordTypesByIdDEA.get(recordTypeId).getDeveloperName().containsIgnoreCase('Prescriber')){
                Map<String,Object > fieldMappingMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
                if (fieldMappingMap.Keyset() == null ){
                    return false;
                }
                CPW = new SYN_VeevaAPI_Search.caseParameterWrap(null , String.valueOf(fieldMappingMap.get('US_WSREMS__DEA__c')) , String.valueOf(fieldMappingMap.get('US_WSREMS__Last_Name__c')), String.valueOf(fieldMappingMap.get('RecordTypeId')) );
                return SYN_VeevaAPI_Search.searchResult(CPW);
            }else{
                return false;
            }
        
        
    }
    
    //SHRPP-64,66,68
    @AuraEnabled
    public static AccountCreationDetails createAccountOnCaseCreation(Id CaseId){
        String programName;
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
                                                US_WSREMS__User_Type__c,US_WSREMS__WCBP_Pregnancy_Test_Date__c,US_WSREMS__WCBP__c,US_WSREMS__Zipcode__c,SYN_User_Type__c,SYN_DEA_Validation__c,
                                                Sub_Status__c,Email_address__c,Alternate_Contact_Name__c,Affiliated_hospital__c,Specialty__c,Office_contact_name_Primary_Office__c,Account_Name_Secondary_Office__c,
                                                Affiliated_hospital_Secondary_Office__c,Specialty_Secondary_Office__c,Office_contact_name_Secondary_Office__c,office_contact_phone_Secondary_Office__c,Email_Secondary_Office__c,
                                                Ext_Secondary_Office__c,Fax_Secondary_Office__c,Preferred_Contact_Method_Secondary_Offic__c,Address_1_Secondary_Office__c,Address_2_Secondary_Office__c,City_Secondary_Office__c,
                                                Phone_Secondary_Office__c,Primary_Language__c,Best_time_to_call__c,US_WSREMS__REMS_Shipping_State__c,Emergency_Contact_Name__c,Emergency_Contact_Relationship__c,
                                                Emergency_Contact_Phone__c,Legal_Guardian_Name__c,Legal_Guardian_Relationship__c,Legal_Guardian_Phone__c,Legal_Guardian_Email__c,US_WSREMS__REMS_Alternate_Phone__c,
                                                Alternate_Contact__c,Title__c,Date_Enrolled__c,Other_Credential__c,Other_Title__c,Title_Authorized_Rep__c,US_WSREMS__First_Name_ar__c,US_WSREMS__REMS_Zip_Code__c,
                                                US_WSREMS__Last_Name_ar__c,US_WSREMS__REMS_Office_Contact_Phone__c, US_WSREMS__REMS_Ext__c,Extension__c,Credentials__c,Inpatient_Pharmacy_Type__c,US_WSREMS__REMS_Country__c,Notifications__c,US_WSREMS__UserType__c,
                                                State_Secondary_Office__c,other__c,Pharmacy_Type__c,AR_Category__c,Office_Practice_Clinic_Name__c,Office_Practice_Clinic_Name1__c,Two_Factor_Authentication_Selection__c                                              
                                                FROM Case WHERE ID =: CaseId]);
       
        if (newCaseLst[0].Status == 'Complete'){
            caseStatusComplete = true;
        }
        if(newCaseLst[0].US_WSREMS__Program_Name__c != null){
            programName = newCaseLst[0].US_WSREMS__Program_Name__c;
        }
        List<Account> accListToInsert = New List<Account>();
        Account acc;
        
        Id prescriberCaseRecordTypeId = mapCaseRecordTypesById.get('Prescriber_Person_Account');
        Id presInstrecordTypeId = mapAccountRecordTypesById.get('Prescribing_Institution');
        Id generalConCaseRecordTypeId = mapCaseRecordTypesById.get('General_Contact');
        Id generalConrecordTypeId = mapAccountRecordTypesById.get('General_Contact');   
        Map<String,String> CaseFieldsVsAccountFieldsCustMetaMap = New Map<String,String>();
        Map<String,Object> CaseFieldsVsValuesMap = New Map<String,Object>();
        Map<String,Object> AccFieldsAPIVsCaseFieldValuesMap = New Map<String,Object>(); //Not used yet
        
        Map<String,Id> mapofCaseRecordTypeNameandId = getAllRecordTypeDetailsById('Case'); //Not used yet
        Map<String,Id> mapofAccountRecordTypeNameandId = getAllRecordTypeDetailsById('Account');
        
        Map<Id,String> mapofCaseRecordTypeIdandName = getAllRecordTypeDetailsByName('Case');
        Map<Id,String> mapofAccountRecordTypeIdandName = getAllRecordTypeDetailsByName('Account'); //Not used yet
        
        Map<String,String> mapofCaseRecordTypeNameVSAccName = New Map<String,String>();
        
        List<US_WSREMS__REMSRecordTypeConfig__mdt> recordTypes = New List<US_WSREMS__REMSRecordTypeConfig__mdt>([SELECT US_WSREMS__Source_Record_Type__c,US_WSREMS__Target_Record_Type__c FROM US_WSREMS__REMSRecordTypeConfig__mdt WHERE US_WSREMS__Program__c != null AND US_WSREMS__Program__r.MasterLabel = : programName]);
        
        List<US_WSREMS__Field_Mapping_Config__mdt> fieldMappingList = New List<US_WSREMS__Field_Mapping_Config__mdt>([SELECT US_WSREMS__Source_Field__c,
                                                                                                      US_WSREMS__Source_Object__c,US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Target_Field__c,US_WSREMS__Target_Object__c,
                                                                                                      US_WSREMS__Target_RecordType_Name__c FROM US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Is_Account_Creation__c = True AND US_WSREMS__IsActive__c = True AND US_WSREMS__Program__r.MasterLabel = : programName]);        
        for(US_WSREMS__REMSRecordTypeConfig__mdt rec:recordTypes){
            mapofCaseRecordTypeNameVSAccName.put(rec.US_WSREMS__Source_Record_Type__c,rec.US_WSREMS__Target_Record_Type__c);
        }
        
        //Create map for the source field vs the target field based on the custom metadatatype....
        for(Case cs: newCaseLst){
            for(US_WSREMS__Field_Mapping_Config__mdt fm : fieldMappingList){
                if(mapCaseRecordTypesByIdDeveloperName.get(cs.RecordTypeId) == fm.US_WSREMS__Source_RecordType_Name__c){                   
                    CaseFieldsVsAccountFieldsCustMetaMap.put(fm.US_WSREMS__Source_Field__c,fm.US_WSREMS__Target_Field__c);
                }
            } 
        }
        
        //Create map for the case field vs its actual value to map it later to the target field as a value...
        for(Case cs: newCaseLst){
            for(String cs1 : CaseFieldsVsAccountFieldsCustMetaMap.Keyset()){
                if(cs1 !='Notification__c' ){
                    CaseFieldsVsValuesMap.put(cs1, cs.get(cs1));
                }
            }
        }
        
        //Actual loop......
        for(Case cs: newCaseLst){
            acc = New Account();
            for(String cs1 : CaseFieldsVsAccountFieldsCustMetaMap.Keyset()){
            

                acc.RecordTypeId = mapAccountRecordTypesById.get(mapofCaseRecordTypeNameVSAccName.get(mapCaseRecordTypesByIdDeveloperName.get(cs.RecordTypeId)));
                acc.Put(CaseFieldsVsAccountFieldsCustMetaMap.get(cs1),CaseFieldsVsValuesMap.get(cs1));
            
                
            }
            //If the prescriber information don't have the facility... then create an account...
            if(cs.US_WSREMS__Facility__c == null && (cs.RecordTypeId == prescriberCaseRecordTypeId || cs.RecordTypeId == generalConCaseRecordTypeId) && programName != 'Macitentan REMS' ){
                Account presAcc = New Account(Name = cs.US_WSREMS__Name__c,US_WSREMS__REMS_Program__c = cs.US_WSREMS__REMS_Program__c, SYN_Case_Id__c = cs.Id,RecordTypeId = presInstrecordTypeId,ShippingStreet = cs.US_WSREMS__Address_Line_1__c,
                                              SYN_Shipping_Address_2__c = cs.US_WSREMS__Address_Line_2__c,ShippingCity=cs.US_WSREMS__City__c,
                                              ShippingState = cs.US_WSREMS__State__c,ShippingPostalCode=cs.US_WSREMS__REMS_Zip_Code__c,ShippingCountry=cs.US_WSREMS__REMS_Country__c,
                                              Phone = cs.US_WSREMS__Phone__c, fax=cs.US_WSREMS__Fax__c,SYN_Ext__c=cs.SYN_Ext__c,US_WSREMS__Email__c=cs.US_WSREMS__Email__c,
                                              US_WSREMS__Preferred_Contact_Method__c=cs.US_WSREMS__Preferred_Contact_Method__c);
                accListToInsert.add(presAcc);
            } 
        }
  
        Database.SaveResult accInserted = Database.insert(acc, false);
        // Database method to insert the records in List
        // Iterate through each returned result by the method
        Set<Id> insertedPrescInstitutionIds = New Set<Id>();
                   

        Database.SaveResult[] srList = Database.insert(accListToInsert, false);
        
        
        Id generalConAffiRecTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('General_Contact_Affiliation').getRecordTypeId();
        Id prescAffiRecTypeId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByDeveloperName().get('Prescriber_Affiliation').getRecordTypeId();
        Id presAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prescriber').getRecordTypeId();
        Account accRec = New Account();
        if(accInserted.getId() != null){
            caseAccountAssociation(CaseId,accInserted.getId());  
            accRec = [SELECT Id,RecordTypeId , Program_Name__c, Name FROM Account WHERE Id =: accInserted.getId() limit 1];
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
        
        List<US_WSREMS__Affiliation__c> affListToInsert = New List<US_WSREMS__Affiliation__c>();
        Case cs = [SELECT Id,US_WSREMS__Facility__c,US_WSREMS__REMS_Program__c FROM Case where Id =: CaseId limit 1];
        if(srList.size()>0 && accRec.Program_Name__c != SYN_Utilitycls.MACI_PROGRAM_NAME ){
            US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(
                US_WSREMS__Prescribing_Institution__c = srList[0].getId(),
                US_WSREMS__REMSProgram__c = cs.US_WSREMS__REMS_Program__c,
                US_WSREMS__Start_Date__c = System.Today(),
                US_WSREMS__isActive__c = TRUE
            );
            if(accRec.RecordTypeId == generalConrecordTypeId){
                affiliationRecord.General_Contact_Account__c = accRec.Id;
                affiliationRecord.RecordTypeId = generalConAffiRecTypeId;
            }else if(accRec.RecordTypeId == presAccRecTypeId){
                affiliationRecord.US_WSREMS__Prescriber__c = accRec.Id;
                affiliationRecord.RecordTypeId = prescAffiRecTypeId;
            }
            affListToInsert.add(affiliationRecord);
        }  if(srList.size()==0 && accRec.Program_Name__c != SYN_Utilitycls.MACI_PROGRAM_NAME){
            US_WSREMS__Affiliation__c affiliationRecord = new US_WSREMS__Affiliation__c(
                US_WSREMS__Prescribing_Institution__c = cs.US_WSREMS__Facility__c,
                US_WSREMS__REMSProgram__c = cs.US_WSREMS__REMS_Program__c,
                US_WSREMS__Start_Date__c = System.Today(),
                US_WSREMS__isActive__c = TRUE
            );
            if(accRec.RecordTypeId == generalConrecordTypeId){
                affiliationRecord.General_Contact_Account__c = accRec.Id;
                affiliationRecord.RecordTypeId = generalConAffiRecTypeId;
            }else if(accRec.RecordTypeId == presAccRecTypeId){
                affiliationRecord.US_WSREMS__Prescriber__c = accRec.Id;
                affiliationRecord.RecordTypeId = prescAffiRecTypeId;
            }
            affListToInsert.add(affiliationRecord); 
        }
        
        //DML
        // Database.Insert(affListToInsert,false);
        Database.SaveResult[] srList1 = Database.insert(affListToInsert, false);
        for (Database.SaveResult sr : srList1) {
            if (sr.isSuccess()) {
                // This condition will be executed for successful records and will fetch the ids 
                // of successful records
                insertedPrescInstitutionIds.add(sr.getId());
            } else {
                // This condition will be executed for failed records
                for(Database.Error objErr : sr.getErrors()) {
                       // Printing error message in Debug log
                    System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                    System.debug('Invoice oject field which are affected by the error:' 
                                 + objErr.getFields());
                }
            }
        }
        return ACD;
    }
    
    /*****************************************************************************************************************************************************************
    Method Name: getLookupFields
    Created By : Thandavakrishna Dindu
    Description": It returns lookup fileds, and we are using in aura component
                  1) Before calling this method we can check field is present in custom metadata, if it is present , we are populating values based on parent field.
                  Uses
                  1) Instead of hardcoding field name in aura component 
                  2) Instead of calling each field change
    ********************************************************************************************************************************************************************/
    @AuraEnabled
    public static List<String> getLookupFields(string TargetObj, String programName ){
    
       Set<String> lookfields = new Set<String>();
        List<String> lookfieldslist = new List<String>();
    
        for (US_WSREMS__Field_Mapping_Config__mdt mdt : [SELECT Id,US_WSREMS__Parent_Field__c,US_WSREMS__Program__c,US_WSREMS__Request_Type__c,US_WSREMS__Section_Name__c,US_WSREMS__Source_Field__c,
                                                            US_WSREMS__Source_Object__c,US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Target_Field__c,US_WSREMS__Target_Object__c,US_WSREMS__Target_RecordType_Name__c
                                                            FROM US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Target_Object__c =: TargetObj AND US_WSREMS__Program__c != NULL AND US_WSREMS__Program__r.Masterlabel =: ProgramName
                                                            AND US_WSREMS__IsActive__c = true AND US_WSREMS__isOnLoad__c = true ] ){
             lookfields.add(mdt.US_WSREMS__Parent_Field__c);  
             
        }
        lookfieldslist.addAll(lookfields);
        return lookfieldslist;
      
    }
    
    Private static void caseAccountAssociation(Id CaseId , Id AccountId){
        case cse = new case(id= CaseId);
        cse.US_WSREMS__Participant__c = AccountId;
        US_WSREMS.REMSAvoidRecursiveCls.stop_accountUpdate=true;
        update cse;
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