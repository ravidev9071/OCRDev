/**************************************************************************
    * Name :   SYN_AccountsDuplicateCheck 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Chaitanya                                     Initial Version
    Praveen Vellanki       09/21/2022             MACI - 7433 - 41: Code addition/updation as below:
                                                  New Change: Line 40:  Program user data is being retrieved.
                                                  New Change: Line 41:  Program Name is being captured from the program user data.
                                                  New Change: Line 43-47:  If condition, was added that will check the program,along with the record type metadata query. 
                                                  Update:     Line 47-51:  else condition - exisiting metadata for loop was kept inside the else condition.
                                                  New Change: Line 67-75:  If condition - was added that will check the program and get the fields from field mapping metadata.
                                                  Update:     Line 75-83:  else condition - exisiting for loop was kept inside the else condition for exising loop to get the metadata.
                                                  New Change: Line 117-120:  If condition for prescriber was added to the exisitng DEA as it is not needed for MACI
                                                  New Change: Line 142: Added if check for prescriber, maci, added the string with needed conditions and else for other programs dup string which is exisiting.
                                                  New Change: Line 161; 170: Pharmacy_Participant; If check for the fields only for maci. if check for dupstring for maci and else for other programs dup string that is existing.
                                                  New Change: Line 195; 215: Distributor: If check for the fields only for maci. if check for dupstring for maci and else for other programs dup string that is existing.
                                                  New Change: Line 231; 251; 256:Pharmacy: If check for the fields only for maci. if check for dupstring for maci and else for other programs dup string that is existing.                   
  
*********************************************************************************/
public with sharing class SYN_AccountsDuplicateCheck {
    
    private
        static final Map<Id,String> mapCaseRecordTypesById = REMSUtility.retrieveRecTypeIdDeveloperName_Product('Case');
      private
        static final Map<String,Id> mapAccRcTyByDevName = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
       
      
    public static duplicateWrapper checkDuplicate(Id recordTypeId , String fields){
        
        Map<String,String> mapofCaseRecordTypeNameVSAccName = new Map<String,String>();
        Map<String,String> AccToCasefieldmap = new Map<String,String>();
        List<Account> AccountList = new List<Account>();
        duplicateWrapper dw = new duplicateWrapper();
        
       
        list<US_WSREMS__Program_Users__c> programUserData = SYN_CommonUtility.getCurrnetUserActivePrograms();
        String programName = programUserData.size() > 0 ? programUserData[0].US_WSREMS__REMS_Program__r.Name:'';
       
            if(programName == Label.Macitentan_REMS_Program_Name){
                for(US_WSREMS__REMSRecordTypeConfig__mdt rec: [SELECT US_WSREMS__Source_Record_Type__c,US_WSREMS__Target_Record_Type__c FROM US_WSREMS__REMSRecordTypeConfig__mdt WHERE US_WSREMS__Program__r.Label =: programName]){
                    mapofCaseRecordTypeNameVSAccName.put(rec.US_WSREMS__Source_Record_Type__c,rec.US_WSREMS__Target_Record_Type__c);
                }
            }else{
                for(SYNRecordTypeConfig__mdt rec: [SELECT Source_Record_Type__c,Target_Record_Type__c FROM SYNRecordTypeConfig__mdt]){
                    mapofCaseRecordTypeNameVSAccName.put(rec.Source_Record_Type__c,rec.Target_Record_Type__c);
                }
            }
              
        Map<String,Object > fieldMappingMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        
        if (fieldMappingMap.Keyset() == null ){
            return dw;
        }
        
        
        String caseRcTyDevName = mapCaseRecordTypesById.get(recordTypeId);
        String accRcTyDevName = mapofCaseRecordTypeNameVSAccName.get(caseRcTyDevName) ;
        Id AccountRCtyID = mapAccRcTyByDevName.get(accRcTyDevName);
        String accountQuerryStr ='Select Id ,US_WSREMS__REMS_Program__r.Name, ';
        Boolean isPersonAccount = true;
        String dupConditionStr=''; 
        
        if(programName == Label.Macitentan_REMS_Program_Name){
            for(US_WSREMS__Field_Mapping_Config__mdt fm : [SELECT US_WSREMS__Source_Field__c,US_WSREMS__Source_Object__c,US_WSREMS__Source_RecordType_Name__c,US_WSREMS__Target_Field__c,US_WSREMS__Target_Object__c,
                                                               US_WSREMS__Target_RecordType_Name__c FROM US_WSREMS__Field_Mapping_Config__mdt WHERE US_WSREMS__Program__r.Label =: programName and US_WSREMS__Is_Account_Creation__c = True and US_WSREMS__IsActive__c = true]){
                                                                   
                                                                   if(caseRcTyDevName == fm.US_WSREMS__Source_RecordType_Name__c){                   
                                                                       AccToCasefieldmap.put(fm.US_WSREMS__Target_Field__c,fm.US_WSREMS__Source_Field__c);
                                                                   }
                                                               }
        }else{
            for(SYN_FieldMapping_Config__mdt fm : [SELECT Source_Field__c,Source_Object__c,Source_RecordType_Name__c,Target_Field__c,Target_Object__c,
                                                   Target_RecordType_Name__c FROM SYN_FieldMapping_Config__mdt WHERE Account_Creation__c = True]){
                                                       
                                                       if(caseRcTyDevName == fm.Source_RecordType_Name__c){                   
                                                           AccToCasefieldmap.put(fm.Target_Field__c,fm.Source_Field__c);
                                                       }
                                                   } 
        }
    
        switch on accRcTyDevName {
            when 'Patient' {		
                accountQuerryStr += 'Phone,FirstName, LastName, Name,US_WSREMS__DOB__c,ShippingPostalCode,US_WSREMS__NCPDP__c,Zip_Secondary_Office__c,US_WSREMS__Email__c '  ;
                
                string phoneval =  String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')))) ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')));
                
                Date DOBval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__DOB__c')))) ? null:
                Date.valueOf(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__DOB__c')) )) ;
                
                string FNval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('FirstName')))) ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('FirstName')));
                
                string LNval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('LastName')))) ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('LastName')));
                
                string zipval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('ShippingPostalCode')))) ? ' ' : 
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('ShippingPostalCode')));
                
                FNval = FNval.contains('\'') ? String.escapeSingleQuotes(FNval) : FNval ;
                LNval = LNval.contains('\'') ? String.escapeSingleQuotes(LNval) : LNval ;
                dupConditionStr += ' and (Phone =\'' +phoneval+'\' OR (LastName =\''+ LNval+'\' AND US_WSREMS__DOB__c =: DOBval AND ShippingPostalCode=\''+ zipval+'\' ) or (FirstName =\''+ FNval+'\' AND US_WSREMS__DOB__c = : DOBval AND ShippingPostalCode=\'' +zipval+'\' ) OR (FirstName =\'' +FNval+'\' AND US_WSREMS__DOB__c = : DOBval ) OR (LastName =\'' +LNval+'\' AND US_WSREMS__DOB__c =: DOBval ) ) ' ;
            }	
            when 'Prescriber' {		
                accountQuerryStr += 'Phone,Email_address__c, US_WSREMS__DEA__c, US_WSREMS__NPI__c, US_WSREMS__Email__c, FirstName, LastName, Name, ShippingPostalCode,US_WSREMS__NCPDP__c '  ;
                string DEAval = '';
                string Emailval = '';
                if(programName != Label.Macitentan_REMS_Program_Name){ 
                    DEAval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__DEA__c'))))  ? '***' :
                    String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__DEA__c')));
                    
                    Emailval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__Email__c'))))  ? '***' :
                    String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__Email__c')));                    
                }
                if(programName == Label.Macitentan_REMS_Program_Name){
                    Emailval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Email_address__c'))))  ? '***' :
                    String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Email_address__c')));
                }
                string NPIPval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__NPI__c'))))  ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__NPI__c')));
                
                string phoneval =  String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')))) ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')));
                                
                string FNval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('FirstName')))) ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('FirstName')));
                
                string LNval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('LastName')))) ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('LastName')));
                
                string zipval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('ShippingPostalCode')))) ? ' ' : 
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('ShippingPostalCode')));
                
                FNval = FNval.contains('\'') ? String.escapeSingleQuotes(FNval) : FNval ;
                LNval = LNval.contains('\'') ? String.escapeSingleQuotes(LNval) : LNval ;
              //  dupConditionStr += ' and (US_WSREMS__DEA__c =\''+ DEAval+'\' or US_WSREMS__NPI__c =\''+ NPIPval+'\' or Phone =\''+ phoneval+'\' or US_WSREMS__Email__c=\''+ Emailval+'\' or (FirstName =\''+ FNval+'\' and LastName =\''+ LNval+'\' and ShippingPostalCode =\''+ zipval+'\')) '  ;
                if(programName == Label.Macitentan_REMS_Program_Name){
                    dupConditionStr += ' and (Phone =\''+ phoneval+'\' or US_WSREMS__NPI__c =\''+ NPIPval+'\' or Email_address__c=\''+ Emailval+'\' or (FirstName =\''+ FNval+'\' and LastName =\''+ LNval+'\' and ShippingPostalCode =\''+ zipval+'\')) '  ;
                }else{
                    
                    dupConditionStr += ' and (US_WSREMS__DEA__c =\''+ DEAval+'\' or US_WSREMS__NPI__c =\''+ NPIPval+'\' or US_WSREMS__Email__c=\''+ Emailval+'\' or (FirstName =\''+ FNval+'\' and LastName =\''+ LNval+'\' and Phone =\''+ phoneval+'\')) '  ;
                }
            }
            when 'Pharmacy_Participant' {		
                accountQuerryStr += 'Phone, Fax,US_WSREMS__Email__c, Name, LastName, FirstName, US_WSREMS__NPI__c,US_WSREMS__NCPDP__c,Zip_Secondary_Office__c,ShippingPostalCode '; 
                string Faxval = '';
                string Emailval = '';
                string phoneval = String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone'))) == '***' ? null :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')));
                string FNval = String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('FirstName'))) == ''? null :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('FirstName'))) ;
                string LNval = String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('LastName'))) == ''? null :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('LastName')));
                
                if(programName == Label.Macitentan_REMS_Program_Name){ 
                    Faxval = String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Fax'))) == '***'? null :
                    String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Fax')));
                    Emailval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__Email__c'))))  ? '***' :
                    String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__Email__c')));
                }
                
                FNval = FNval.contains('\'') ? String.escapeSingleQuotes(FNval) : FNval ;
                LNval = LNval.contains('\'') ? String.escapeSingleQuotes(LNval) : LNval ;
                if(programName == Label.Macitentan_REMS_Program_Name){ 
                    dupConditionStr += ' and (Fax =\''+ Faxval+'\' OR Phone =\''+ phoneval+'\' OR US_WSREMS__Email__c =\''+ Emailval+'\' OR (LastName =\''+ LNval+'\' AND FirstName =\''+ FNval+'\'  )) ' ;
                }else{
                    dupConditionStr += ' and (Phone =\''+ phoneval+'\' OR (LastName =\''+ LNval+'\' AND FirstName =\''+ FNval+'\'  )) ' ;  
                }
            }
            when 'General_Contact' {		
                accountQuerryStr += 'Phone, Name, LastName, FirstName,US_WSREMS__DOB__c,US_WSREMS__DEA__c,US_WSREMS__NPI__c,US_WSREMS__NCPDP__c,US_WSREMS__Email__c,ShippingPostalCode ';
                string phoneval = String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone'))) == '***' ? null :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')));
                string FNval = String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('FirstName'))) == ''? null :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('FirstName'))) ;
                string LNval = String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('LastName'))) == ''? null :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('LastName')));
                 
                FNval = FNval.contains('\'') ? String.escapeSingleQuotes(FNval) : FNval ;
                LNval = LNval.contains('\'') ? String.escapeSingleQuotes(LNval) : LNval ;
                dupConditionStr += ' and (Phone =\''+ phoneval+'\' OR (LastName =\''+ LNval+'\' AND FirstName =\''+ FNval+'\'  )) ' ;
            }
            when 'REMS_Distributor_Account' {		
                accountQuerryStr += 'Phone,US_WSREMS__Email__c,US_WSREMS__DEA__c,  Fax, Name , ShippingPostalCode,US_WSREMS__DOB__c ,US_WSREMS__NPI__c,US_WSREMS__NCPDP__c';
                string deaval = '';
                if(programName == Label.Macitentan_REMS_Program_Name){ 
                    deaval =  String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__DEA__c')))) ? '***' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__DEA__c')));
                }
                string phoneval =  String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')))) ? '***' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')));
                string Emailval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__Email__c'))))  ? '***' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__Email__c')));
                string Faxval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Fax'))))  ? '***' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Fax')));
                string Nameval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Name')))) ? '***' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Name')));
                string zipval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('ShippingPostalCode')))) ? ' ' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('ShippingPostalCode')));
                
                Nameval = Nameval.contains('\'') ? String.escapeSingleQuotes(Nameval) : Nameval ;
                if(programName == Label.Macitentan_REMS_Program_Name){
                    dupConditionStr += ' and (US_WSREMS__DEA__c = \''+ deaval+'\' OR Phone = \''+ phoneval+'\' OR US_WSREMS__Email__c =\''+ Emailval+'\' OR Fax = \''+ Faxval+'\' OR (Name = \''+ Nameval+'\' AND ShippingPostalCode =\''+ zipval +'\'  ))' ; 
                }else{
                  dupConditionStr += ' and (Phone = \''+ phoneval+'\' OR US_WSREMS__Email__c =\''+ Emailval+'\' OR Fax = \''+ Faxval+'\' OR (Name = \''+ Nameval+'\' AND ShippingPostalCode =\''+ zipval +'\'  ))' ;   
                }
                
                isPersonAccount = false;
            }
            when 'Pharmacy' {		
                accountQuerryStr += 'US_WSREMS__DEA__c,Zip_Secondary_Office__c,US_WSREMS__NPI__c, US_WSREMS__NCPDP__c, Phone, Fax, ShippingPostalCode, Name,US_WSREMS__Email__c,US_WSREMS__DOB__c '; 
                
                string NCPDPval = '';
                string DEAval = '';
                string npiVal = '';
                string zipval = '';
                
                if(programName != Label.Macitentan_REMS_Program_Name){ 
                    DEAval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__DEA__c'))))  ? '***' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__DEA__c')));
                    NCPDPval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__NCPDP__c'))))  ? '***' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__NCPDP__c')));
                    zipval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('ShippingPostalCode')))) ? ' ' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('ShippingPostalCode')));
                }
                
                string phoneval =  String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')))) ? '***' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')));
                string Faxval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Fax'))))  ? '***' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Fax')));
                string Nameval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Name')))) ? '***' : String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Name')));                
        
                if(programName == Label.Macitentan_REMS_Program_Name){ 
                    npiVal = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__NPI__c')))) ? '*** ' : 
                    String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__NPI__c')));
                    
                    zipval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Zip_Secondary_Office__c')))) ? ' ' : 
                    String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Zip_Secondary_Office__c')));
                }
                Nameval = Nameval.contains('\'') ? String.escapeSingleQuotes(Nameval) : Nameval ;
                if(programName == Label.Macitentan_REMS_Program_Name){ 
                    dupConditionStr += ' and (US_WSREMS__NPI__c =\''+ npiVal+'\' or Phone =\''+ phoneval+'\' or Fax=\''+ Faxval+'\' or (Name =\''+ Nameval+'\' and Zip_Secondary_Office__c =\''+ zipval+'\')) ';
                }else{
                    dupConditionStr += ' and (US_WSREMS__DEA__c =\''+ DEAval+'\' or US_WSREMS__NCPDP__c =\''+ NCPDPval+'\' or Phone =\''+ phoneval+'\' or Fax=\''+ Faxval+'\' or (Name =\''+ Nameval+'\' and ShippingPostalCode =\''+ zipval+'\')) ';
                }
                isPersonAccount = false;
            }
            when 'Prescribing_Institution' {		
                accountQuerryStr += 'Phone, Fax,  Name ,ShippingPostalCode,US_WSREMS__DOB__c,US_WSREMS__DEA__c, US_WSREMS__NPI__c,US_WSREMS__NCPDP__c,US_WSREMS__Email__c';
                
                string phoneval =  String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')))) ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Phone')));
                
                string Faxval = String.isBlank( String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Fax'))))  ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Fax')));
                
                string Nameval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Name')))) ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('Name')));
                
                Nameval = Nameval.contains('\'') ? String.escapeSingleQuotes(Nameval) : Nameval ;
                
                string zipval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('ShippingPostalCode')))) ? ' ' : 
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('ShippingPostalCode')));
                
                dupConditionStr += ' and ( Phone =\''+ phoneval+'\' or Fax=\''+ Faxval+'\' or (Name =\''+ Nameval+'\' and ShippingPostalCode =\''+ zipval+'\'))';
                isPersonAccount = false;
            } 
            when 'Office_Contact' {		
                accountQuerryStr += 'Name, FirstName,LastName,US_WSREMS__REMS_Program__c, Phone, US_WSREMS__Email__c,US_WSREMS__NPI__c,US_WSREMS__DOB__c';

                string FNval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('FirstName')))) ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('FirstName')));
                FNval = FNval.contains('\'') ? String.escapeSingleQuotes(FNval) : FNval ;

                string LNval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('LastName')))) ? '***' :
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('LastName')));
                LNval = LNval.contains('\'') ? String.escapeSingleQuotes(LNval) : LNval ;

                string Emailval = String.isBlank(String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__Email__c')))) ? ' ' : 
                String.valueOf(fieldMappingMap.get(AccToCasefieldmap.get('US_WSREMS__Email__c')));

                if(programName == Label.Macitentan_REMS_Program_Name){ 
                    dupConditionStr += ' and ( FirstName=\''+ FNval+'\' AND LastName=\''+ LNval+'\'AND US_WSREMS__Email__c =\''+ Emailval+'\')';
                }

            }
            
        }
        
        accountQuerryStr += ' from Account where RecordTypeId =: AccountRCtyID and IsPersonAccount =: isPersonAccount' +dupConditionStr;
        
        AccountList=Database.query(accountQuerryStr);
        
        SObjectType type = Schema.getGlobalDescribe().get('Account');
        Map<String,Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        
        dw.Accountlst = AccountList;
        dw.dupFound = AccountList.size()>0 ? true : false;
        
        return dw;
        
    }
    
    
    Public class duplicateWrapper{
        
        @AuraEnabled 
        public List<Account> Accountlst;
        @AuraEnabled 
        public boolean dupFound = false;
    }
    
}