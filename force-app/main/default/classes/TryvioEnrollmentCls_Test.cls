@isTest
public with sharing class TryvioEnrollmentCls_Test {
    @isTest
    static void getNPIOrgNpis(){
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        Account acc = new Account();
        acc.lastname = 'test acc';
        acc.FirstName = 'test';
        acc.US_WSREMS__REMS_Program__c = programList[0].id;
        acc.US_WSREMS__National_Provider_Identifier__c ='2173940290';
        acc.US_WSREMS__NPI__c = '2173940290';
        acc.recordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        acc.US_WSREMS__Program_Picklist__c = programList[0].Name;
        insert acc;
        String response = TryvioEnrollmentCls.getNPISearch('1233333', 'TRYVIO REMS', 'Prescriber_enrollment');
        Test.StartTest();
        SYN_VeevaAPI_Search.pharmacyInfoPrepopWrap accRec = TryvioEnrollmentCls.getAccFromNPI('2173940290', programList[0].Name);
        TryvioEnrollmentCls.InfoPrepopWrap ttp = TryvioEnrollmentCls.getaccount('2173940290','TRYVIO REMS');
        System.assert(programList[0].Name =='TRYVIO REMS');
        Map<String,Map<String,String>> optionMap = TryvioEnrollmentCls.getPicklistFieldValues();        
        System.assert(optionMap !=null);
        Test.StopTest();
    }
    
    public static testMethod void createOPPharmacyRecords(){
        try{
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = new User(
            Username = 'testadmalexin@example.com',
            LastName = 'Admin',
            Email = 'testadmin@example.com',
            Alias = 'tadmin',
            ProfileId = adminProfile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            isActive = true
        );
        insert adminUser;
        TryvioEnrollmentCls.RecordDataWrapper rdWrp = new TryvioEnrollmentCls.RecordDataWrapper();
        rdWrp.name = 'test';
        rdWrp.firstName = 'test';
        rdWrp.middleName = 'test';
        rdWrp.lastName = 'test';
        rdWrp.email = 'test@test.com';
        rdWrp.phone = '(986) 789-6789';
        rdWrp.address1 = 'test';
        rdWrp.address2 = 'test';
        rdWrp.city = 'test';
        //rdWrp.state = 'test';
        rdWrp.zip = 'test';
        rdWrp.ext = 'test';
        rdWrp.type = 'Speciality';
        rdWrp.fax = 'test';
        rdWrp.AR = new TryvioEnrollmentCls.ARWrapper();
        rdWrp.AR.firstName = 'test';
        rdWrp.AR.lastName = 'test';
        rdWrp.AR.mi = 'test';
        rdWrp.AR.offPhone = '(986) 789-6789';
        rdWrp.AR.email = 'test@test.com';
        rdWrp.AR.mPhone = '(986) 789-6789';
        //rdWrp.AR.title = 'test';
        rdWrp.AR.phone = '(986) 789-6789';
        rdWrp.AR.fax = '(986) 789-6789';
        rdWrp.AR.other = 'test';
        rdWrp.AR.ext = 'test';
        rdWrp.AR.credentials = 'PharmD';
        rdWrp.AR.preferredContactMethod = 'Office Phone';
        rdWrp.Sh = new TryvioEnrollmentCls.ShipDataWrapper();
        rdWrp.Sh.shipAddress1 = 'addrest1';
        rdWrp.Sh.shipAddress2 = 'addrest2';
        rdWrp.Sh.shipCity = 'city';
        rdWrp.Sh.shipState = 'test';
        rdWrp.Sh.shipZip = '93434';
        rdWrp.Sh.shipPhone = '(986) 789-6789';
        rdWrp.Sh.shipExt = '66666' ;
        rdWrp.Sh.shipFax = '6545454543';
        
        Map<String, String> insertRecMap = new Map<String, String>{
            'programName' => 'TRYVIO REMS',
            'recordDetails' => JSON.serialize(rdWrp),
            'participantType'=> 'Outpatient Pharmacy',
            'signatureData' => null,
            'arDetails' => JSON.serialize(rdWrp.AR),
            'formType' => 'OPP'
        };
            
       	Map<String, String> insertRecMap1 = new Map<String, String>{
            'programName' => 'TRYVIO REMS',
            'recordDetails' => JSON.serialize(rdWrp),
            'participantType'=> 'Inpatient Pharmacy',
            'signatureData' => null,
            'arDetails' => JSON.serialize(rdWrp.AR),
            'shipDetails' => JSON.serialize(rdWrp.Sh),
            'formType' => 'IPP'
        };
        Map<String, String> insertRecMap3 = new Map<String, String>{
            'programName' => 'TRYVIO REMS',
            'recordDetails' => JSON.serialize(rdWrp),
            'participantType'=> 'Prescriber',
            'signatureData' => null,
            'arDetails' => JSON.serialize(rdWrp.AR),
            'shipDetails' => JSON.serialize(rdWrp.Sh),
            'casecreation' => 'prescribercase'
            
        };
        
        String recStr = TryvioEnrollmentCls.insertDataOnSubmit(insertRecMap);
        String recStr1 = TryvioEnrollmentCls.insertDataOnSubmit(insertRecMap1);
        //String recStr2 = TryvioEnrollmentCls.insertDataOnSubmit(insertRecMap3);
        Account ac = TryvioEnrollmentCls.insertAccount(rdWrp,programList, true,'Prescriber' );
        Account acc1 = TryvioEnrollmentCls.insertAccount(rdWrp,programList, true,null );
        Map<String,Map<String,String>> mapdata = TryvioEnrollmentCls.getPicklistFieldValues();
        }catch(Exception ex){
            System.debug(LoggingLevel.DEBUG,'error found: '+ex.getLineNumber()+ex.getMessage());
        }
        
    }
    
  
    
    public static List<US_WSREMS__REMS_Program__c> createPrograms(integer noOfRecords,boolean isCreate){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = 'TRYVIO REMS';
            programObj.US_WSREMS__Status__c ='Active';
            programObj.US_WSREMS__Program_State_Date__c = System.today();
            programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
            programList.add(programObj);
        }
        
        if(isCreate && programList.size()>0){
            insert programList;
        }
        //TryvioEnrollmentCls.insertAccount(rdWrp,true,programList,null );
        return programList; 
    }
    public static testMethod void createIPPharmacyRecords(){
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = new User(
            Username = 'testadmalexin@example.com',
            LastName = 'Admin',
            Email = 'testadmin@example.com',
            Alias = 'tadmin',
            ProfileId = adminProfile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            isActive = true
        );
        insert adminUser;
        TryvioEnrollmentCls.RecordDataWrapper rdWrp = new TryvioEnrollmentCls.RecordDataWrapper();
        rdWrp.name = 'test';
        rdWrp.firstName = 'test';
        rdWrp.middleName = 'test';
        rdWrp.lastName = 'test';
        rdWrp.email = 'test@test.com';
        rdWrp.phone = '(986) 789-6789';
        rdWrp.address1 = 'test';
        rdWrp.address2 = 'test';
        rdWrp.city = 'test';
        //rdWrp.state = 'test';
        rdWrp.zip = 'test';
        rdWrp.ext = 'test';
        rdWrp.type = 'Speciality';
        rdWrp.fax = 'test';
        rdWrp.AR = new TryvioEnrollmentCls.ARWrapper();
        rdWrp.AR.firstName = 'test';
        rdWrp.AR.lastName = 'test';
        rdWrp.AR.mi = 'test';
        rdWrp.AR.offPhone = '(986) 789-6789';
        rdWrp.AR.email = 'test@test.com';
        rdWrp.AR.mPhone = '(986) 789-6789';
        //rdWrp.AR.title = 'test';
        rdWrp.AR.phone = '(986) 789-6789';
        rdWrp.AR.fax = '(986) 789-6789';
        rdWrp.AR.other = 'test';
        rdWrp.AR.ext = 'test';
        rdWrp.AR.credentials = 'PharmD';
        rdWrp.AR.preferredContactMethod = 'Office Phone';
        rdWrp.Sh = new TryvioEnrollmentCls.ShipDataWrapper();
        rdWrp.Sh.shipAddress1 = 'addrest1';
        rdWrp.Sh.shipAddress2 = 'addrest2';
        rdWrp.Sh.shipCity = 'city';
        rdWrp.Sh.shipState = 'test';
        rdWrp.Sh.shipZip = '93434';
        rdWrp.Sh.shipPhone = '(986) 789-6789';
        rdWrp.Sh.shipExt = '66666' ;
        rdWrp.Sh.shipFax = '6545454543';
        Map<String, String> insertRecMap3 = new Map<String, String>{
            'programName' => 'TRYVIO REMS',
            'recordDetails' => JSON.serialize(rdWrp),
            'participantType'=> 'Prescriber',
            'signatureData' => null,
            'arDetails' => JSON.serialize(rdWrp.AR),
            'shipDetails' => JSON.serialize(rdWrp.Sh),
            'casecreation' => 'prescribercase'
            
        };
        String recStr2 = TryvioEnrollmentCls.insertDataOnSubmit(insertRecMap3);
    }
    public static testMethod void createSecondaryoffice(){
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = new User(
            Username = 'testadmalexin@example.com',
            LastName = 'Admin',
            Email = 'testadmin@example.com',
            Alias = 'tadmin',
            ProfileId = adminProfile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            isActive = true
        );
        insert adminUser;
        Account acc = new Account();
        acc.lastname = 'test acc';
        acc.FirstName = 'test';
        acc.US_WSREMS__REMS_Program__c = programList[0].id;
        acc.US_WSREMS__National_Provider_Identifier__c ='2173940290';
        acc.US_WSREMS__NPI__c = '2173940290';
        acc.recordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        acc.US_WSREMS__Program_Picklist__c = programList[0].Name;
        insert acc;
        TryvioEnrollmentCls.RecordDataWrapper rdWrp = new TryvioEnrollmentCls.RecordDataWrapper();
        rdWrp.name = 'test';
        rdWrp.firstName = 'test';
        rdWrp.middleName = 'test';
        rdWrp.lastName = 'test';
        rdWrp.email = 'test@test.com';
        rdWrp.phone = '(986) 789-6789';
        rdWrp.address1 = 'test';
        rdWrp.address2 = 'test';
        rdWrp.city = 'test';
        //rdWrp.state = 'test';
        rdWrp.zip = 'test';
        rdWrp.ext = 'test';
        rdWrp.type = 'Speciality';
        rdWrp.fax = 'test';
        rdWrp.officePractice = 'test';
        rdWrp.proffDesig = 'test';
        rdWrp.otherSpecialty = 'test';
        rdWrp.pophone = '(986) 789-6789';
        rdWrp.pemail = 'test@test.com';
        rdWrp.semail = 'test@test.com';
        rdWrp.sophone = '(986) 789-6789';
        rdWrp.pext = '(986) 789-6789';
        rdWrp.sext = '(986) 789-6789';
        //rdWrp.pfirstname = 'test ';
        //rdWrp.plastname = 'primary';
        rdWrp.sfirstname = 'secondary ';
        rdWrp.slastname = 'tests';
        rdWrp.preferredContactMethod = 'Office Phone';
                Map<String, String> insertRecMap3 = new Map<String, String>{
            'programName' => 'TRYVIO REMS',
            'recordDetails' => JSON.serialize(rdWrp),
            'participantType'=> 'Prescriber',
            'signatureData' => null,
            'casecreation' => 'Prescriberenrollmentcase',
             'AccountId' => acc.id
            
        };
        String recStr2 = TryvioEnrollmentCls.insertDataOnSubmit(insertRecMap3);
    }
    public static testMethod void createPrimaryoffice(){
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = new User(
            Username = 'testadmalexin@example.com',
            LastName = 'Admin',
            Email = 'testadmin@example.com',
            Alias = 'tadmin',
            ProfileId = adminProfile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            isActive = true
        );
        insert adminUser;
        Account acc = new Account();
        acc.lastname = 'test acc';
        acc.FirstName = 'test';
        acc.US_WSREMS__REMS_Program__c = programList[0].id;
        acc.US_WSREMS__National_Provider_Identifier__c ='2173940290';
        acc.US_WSREMS__NPI__c = '2173940290';
        acc.recordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        acc.US_WSREMS__Program_Picklist__c = programList[0].Name;
        insert acc;
        TryvioEnrollmentCls.RecordDataWrapper rdWrp = new TryvioEnrollmentCls.RecordDataWrapper();
        rdWrp.name = 'test';
        rdWrp.firstName = 'test';
        rdWrp.middleName = 'test';
        rdWrp.lastName = 'test';
        rdWrp.email = 'test@test.com';
        rdWrp.phone = '(986) 789-6789';
        rdWrp.address1 = 'test';
        rdWrp.address2 = 'test';
        rdWrp.city = 'test';
        //rdWrp.state = 'test';
        rdWrp.zip = 'test';
        rdWrp.ext = 'test';
        rdWrp.type = 'Speciality';
        rdWrp.fax = 'test';
        rdWrp.officePractice = 'test';
        rdWrp.proffDesig = 'test';
        rdWrp.otherSpecialty = 'test';
        rdWrp.pophone = '(986) 789-6789';
        rdWrp.pemail = 'test@test.com';
        rdWrp.semail = 'test@test.com';
        rdWrp.sophone = '(986) 789-6789';
        rdWrp.pext = '(986) 789-6789';
        rdWrp.sext = '(986) 789-6789';
        rdWrp.pfirstname = 'test ';
        rdWrp.plastname = 'primary';
        //rdWrp.sfirstname = 'secondary ';
        //rdWrp.slastname = 'tests';
        rdWrp.preferredContactMethod = 'Office Phone';
                Map<String, String> insertRecMap3 = new Map<String, String>{
            'programName' => 'TRYVIO REMS',
            'recordDetails' => JSON.serialize(rdWrp),
            'participantType'=> 'Prescriber',
            'signatureData' => null,
            'casecreation' => 'Prescriberenrollmentcase',
             'AccountId' => acc.id
            
        };
        String recStr2 = TryvioEnrollmentCls.insertDataOnSubmit(insertRecMap3);
    }
    public static testMethod void createprecriberenrollcase(){
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = new User(
            Username = 'testadmalexin@example.com',
            LastName = 'Admin',
            Email = 'testadmin@example.com',
            Alias = 'tadmin',
            ProfileId = adminProfile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            isActive = true
        );
        insert adminUser;
        Account acc = new Account();
        acc.lastname = 'test acc';
        acc.FirstName = 'test';
        acc.US_WSREMS__REMS_Program__c = programList[0].id;
        acc.US_WSREMS__National_Provider_Identifier__c ='2173940290';
        acc.US_WSREMS__NPI__c = '2173940290';
        acc.recordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        acc.US_WSREMS__Program_Picklist__c = programList[0].Name;
        insert acc;
        TryvioEnrollmentCls.RecordDataWrapper rdWrp = new TryvioEnrollmentCls.RecordDataWrapper();
        rdWrp.name = 'test';
        rdWrp.firstName = 'test';
        rdWrp.middleName = 'test';
        rdWrp.lastName = 'test';
        rdWrp.email = 'test@test.com';
        rdWrp.phone = '(986) 789-6789';
        rdWrp.address1 = 'test';
        rdWrp.address2 = 'test';
        rdWrp.city = 'test';
        //rdWrp.state = 'test';
        rdWrp.zip = 'test';
        rdWrp.ext = 'test';
        rdWrp.type = 'Speciality';
        rdWrp.fax = 'test';
        rdWrp.officePractice = 'test';
        rdWrp.proffDesig = 'test';
        rdWrp.otherSpecialty = 'test';
        rdWrp.pophone = '(986) 789-6789';
        rdWrp.pemail = 'test@test.com';
        rdWrp.semail = 'test@test.com';
        rdWrp.sophone = '(986) 789-6789';
        rdWrp.pext = '(986) 789-6789';
        rdWrp.sext = '(986) 789-6789';
        //rdWrp.pfirstname = 'test ';
        //rdWrp.plastname = 'primary';
        //rdWrp.sfirstname = 'secondary ';
        //rdWrp.slastname = 'tests';
        rdWrp.preferredContactMethod = 'Office Phone';
                Map<String, String> insertRecMap3 = new Map<String, String>{
            'programName' => 'TRYVIO REMS',
            'recordDetails' => JSON.serialize(rdWrp),
            'participantType'=> 'Prescriber',
            'signatureData' => null,
            'casecreation' => 'Prescriberenrollmentcase',
             'AccountId' => acc.id
            
        };
                  Map<String, String> insertRecMap4 = new Map<String, String>{
            'programName' => 'TRYVIO REMS',
            'recordDetails' => JSON.serialize(rdWrp),
            'participantType'=> 'Prescriber',
            'signatureData' => null,
            'casecreation' => 'kacase',
             'AccountId' => acc.id
            
        };
        String recStr2 = TryvioEnrollmentCls.insertDataOnSubmit(insertRecMap3);
        String recStr3 = TryvioEnrollmentCls.insertDataOnSubmit(insertRecMap4);
        US_WSREMS__REMS_Service_Summary__c remSer = [SELECT Id FROM US_WSREMS__REMS_Service_Summary__c LIMIT 1];
        Case caseRecord = TryvioEnrollmentCls.insertPrescriberCase(rdWrp, acc, remSer, programList,'Knowledge_Assessment', null, 'Prescriber', Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Knowledge_Assessment').getRecordTypeId(), null, null, null);
    }
    public static testMethod void createIPOPPharmacyRecords(){
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser = new User(
            Username = 'testadmalexin@example.com',
            LastName = 'Admin',
            Email = 'testadmin@example.com',
            Alias = 'tadmin',
            ProfileId = adminProfile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            isActive = true
        );
        insert adminUser;
        Account acc = new Account();
        acc.lastname = 'test acc';
        acc.FirstName = 'test tests';
        acc.US_WSREMS__REMS_Program__c = programList[0].id;
        //acc.US_WSREMS__National_Provider_Identifier__c ='2173940290';
        //acc.US_WSREMS__NPI__c = '2173940290';
        acc.recordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Pharmacy/HCS Participant').getRecordTypeId();
        acc.US_WSREMS__Program_Picklist__c = programList[0].Name;
        insert acc;
        
        Account ipacc = new Account();
        ipacc.name='Testss';
        ipacc.US_WSREMS__REMS_Program__c = programList[0].id;
        //ipacc.US_WSREMS__National_Provider_Identifier__c ='2173940290';
        //ipacc.US_WSREMS__NPI__c = '2173940290';
        ipacc.recordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Inpatient Pharmacy').getRecordTypeId();
        ipacc.US_WSREMS__Program_Picklist__c = programList[0].Name;
        insert ipacc;
        
        TryvioEnrollmentCls.RecordDataWrapper rdWrp = new TryvioEnrollmentCls.RecordDataWrapper();
        //recorddata rdWrp=new recorddata();
        rdWrp.name = 'test';
        rdWrp.firstName = 'test';
        rdWrp.middleName = 'test';
        rdWrp.lastName = 'test';
        rdWrp.email = 'test@test.com';
        rdWrp.phone = '(986) 789-6789';
        rdWrp.address1 = 'test';
        rdWrp.address2 = 'test';
        rdWrp.city = 'test';
        //rdWrp.state = 'test';
        rdWrp.zip = 'test';
        rdWrp.ext = 'test';
        rdWrp.type = 'Speciality';
        rdWrp.fax = 'test';
        rdWrp.AR = new TryvioEnrollmentCls.ARWrapper();
        rdWrp.AR.firstName = 'test';
        rdWrp.AR.lastName = 'test';
        rdWrp.AR.mi = 'test';
        rdWrp.AR.offPhone = '(986) 789-6789';
        rdWrp.AR.email = 'test@test.com';
        rdWrp.AR.mPhone = '(986) 789-6789';
        //rdWrp.AR.title = 'test';
        rdWrp.AR.phone = '(986) 789-6789';
        rdWrp.AR.fax = '(986) 789-6789';
        rdWrp.AR.other = 'test';
        rdWrp.AR.ext = 'test';
        rdWrp.AR.credentials = 'PharmD';
        rdWrp.AR.preferredContactMethod = 'Office Phone';
        rdWrp.Sh = new TryvioEnrollmentCls.ShipDataWrapper();
        rdWrp.Sh.shipAddress1 = 'addrest1';
        rdWrp.Sh.shipAddress2 = 'addrest2';
        rdWrp.Sh.shipCity = 'city';
        rdWrp.Sh.shipState = 'test';
        rdWrp.Sh.shipZip = '93434';
        rdWrp.Sh.shipPhone = '(986) 789-6789';
        rdWrp.Sh.shipExt = '66666' ;
        rdWrp.Sh.shipFax = '6545454543';
        Map<String, String> insertRecMap3 = new Map<String, String>{
            'programName' => 'TRYVIO REMS',
            'recordDetails' => JSON.serialize(rdWrp),
            'participantType'=> 'Inpatient Pharmacy',
            'signatureData' => null,
            'arDetails' => JSON.serialize(rdWrp.AR),
            'shipDetails' => JSON.serialize(rdWrp.Sh),
            //'casecreation' => 'prescribercase'
            'formType'=> 'IPP'
            
        };
            Id pharmacyAffRecId = Schema.SObjectType.US_WSREMS__Affiliation__c.getRecordTypeInfosByName().get('Pharmacy User Affiliation').getRecordTypeId();
        US_WSREMS__Affiliation__c aff=TryvioEnrollmentCls.insertAffiliation(acc,programList,ipacc.id,pharmacyAffRecId,rdWrp);
        String recStr2 = TryvioEnrollmentCls.insertDataOnSubmit(insertRecMap3);
        
        RecordType enrollmentRecId = [SELECT Id,Name,NamespacePrefix,DeveloperName, SObjectType 
        FROM RecordType WHERE SobjectType='US_WSREMS__REMS_Service_Summary__c' 
        AND DeveloperName = 'Enrollment' 
        AND NamespacePrefix = 'US_WSREMS' LIMIT 1];
        //Id idRTforREMSService = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c').get('Enrollment');
        US_WSREMS__REMS_Service_Summary__c service = new US_WSREMS__REMS_Service_Summary__c();
        service.RecordTypeId = enrollmentRecId.Id;
            service.US_WSREMS__REMSProgram__c = programList.size() > 0 ? programList[0].Id : null;
            service.US_WSREMS__Status__c = 'Closed';
            service.US_WSREMS__Service_Outcome__c ='Successful';
            service.US_WSREMS__Participant__c = ipacc.Id;
            service.US_WSREMS__Requestor_Type__c = 'Inpatient Pharmacy';
            insert service;
        id rec=Schema.sObjectType.case.getRecordTypeInfosByName().get('Inpatient Pharmacy Enrollment').getRecordTypeId();
        
        case cs=TryvioEnrollmentCls.insertCase(rdWrp,ipacc,service,programList,'Inpatient_Pharmacy_Enrollment',null,'Inpatient Pharmacy',rec,acc.Id);
        
    }
}