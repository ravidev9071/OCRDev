/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 12-15-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SYN_CommonUtility_Test {
    
    @testSetup
    public static void dataSetup(){
        US_WSREMS__REMS_Program__c remsProg1 = new US_WSREMS__REMS_Program__c();
        remsProg1.Name = 'Sodium Oxybate REMS';
        remsProg1.REMS_Project_Code__c = 'BT6825';
        remsProg1.US_WSREMS__Status__c ='Active';       
        remsProg1.QueueName__c ='Syneos Test Call Queue';
        insert remsProg1;
        
        US_WSREMS__REMS_Program__c remsProg2 = new US_WSREMS__REMS_Program__c();
        remsProg2.Name = 'Sodium Oxybate REMS Test';
        remsProg2.US_WSREMS__Status__c ='Active';
        remsProg2.QueueName__c ='Syneos Test Call Queue';
        insert remsProg2;
        
        US_WSREMS__REMS_Program__c aveedProgram = new US_WSREMS__REMS_Program__c();
        aveedProgram.Name = 'AVEED REMS';
        aveedProgram.US_WSREMS__Status__c ='Active';
        aveedProgram.US_WSREMS__Program_State_Date__c = System.today();
        aveedProgram.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert aveedProgram;
        
        List<Account> accountList = new List<Account>();
        Account acc=new Account();
        acc.Name='test';
        acc.Phone='1234567789';
        acc.US_WSREMS__REMS_Program__c=remsProg1.id;
        accountList.add(acc);
        
        Account prescriberaccount =new Account();
        prescriberaccount.Name = 'test prescriber';
        prescriberaccount.Phone = '1234567789';
        prescriberaccount.US_WSREMS__REMS_Program__c = aveedProgram.id;
        prescriberaccount.recordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Health_Care_Setting').getRecordTypeId();
        accountList.add(prescriberaccount);
        insert accountList;
        
        contact con= new contact();
        con.LastName='test';
        con.AccountId=acc.id;
        insert con;
        
        US_WSREMS__REMS_Service_Summary__c usRemsId = new US_WSREMS__REMS_Service_Summary__c(US_WSREMS__REMSProgram__c = remsProg1.Id,
                                                                                             US_WSREMS__Requestor_Type__c = 'Pharmacy'
                                                                                            );
        insert usRemsId;
        
        List<Case> caselist = new List<Case>();
        Case caseA = new Case();
        caseA.US_WSREMS__REMS_Program__c = remsProg1.id;
        caseA.US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS';
        caseA.US_WSREMS__Call_Notes__c = 'test';
        caseA.Us_WSREMS__Participant__c=acc.id;
        caseA.Pharmacy_Participant__c=acc.id;
        caseA.US_WSREMS__REMS_Service_Summary__c =usRemsId.Id;
        caseA.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment A').getRecordTypeId();//Knowledge Assessment A- RecoredTyoeId-0123C000000a0cAQAQ
        
        caseA.Program_Record_Type_Control__c = remsProg1.Name+'-SYN_Knowledge_Assessment_A';
        caselist.add(caseA);
        
        Case caseB = new Case();
        caseB.US_WSREMS__REMS_Program__c = remsProg1.id;
        caseB.US_WSREMS__Call_Notes__c = 'test';
        caseB.Us_WSREMS__Participant__c=acc.id;
        caseB.Pharmacy_Participant__c=acc.id;
        caseB.US_WSREMS__REMS_Service_Summary__c =usRemsId.Id;
        caseB.US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS';
        caseB.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Assessment B').getRecordTypeId();//Knowledge Assessment B- RecoredTyoeId-0123C000000a0c5QAA
        
        caseB.Program_Record_Type_Control__c = remsProg1.Name+'-SYN_Knowledge_Assessment_B';
        caselist.add(caseB);
        
        case caseRec = new case();
        caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Non_Compliance';
        caseRec.US_WSREMS__REMS_Program__c = aveedProgram.Id;
        caseRec.US_WSREMS__REMS_Program__r = aveedProgram;
        caseRec.Status = 'Draft';
        caseRec.US_WSREMS__First_Name__c = 'test';
        caseRec.US_WSREMS__Last_Name__c = 'test';
        caseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
        caseRec.US_WSREMS__Program_Picklist__c = aveedProgram.Name;
        caseRec.US_WSREMS__X1_Participant__r = acc;
        caseRec.US_WSREMS__X1_Participant__c = acc.Id;
        caseList.add(caseRec);
        
        case hcpCaseRec = new case();
        hcpCaseRec.Program_Record_Type_Control__c = 'AVEED REMS-Prescriber_enrollment';
        hcpCaseRec.US_WSREMS__REMS_Program__c = aveedProgram.Id;
        hcpCaseRec.US_WSREMS__REMS_Program__r = aveedProgram;
        hcpCaseRec.Status = 'Draft';
        hcpCaseRec.US_WSREMS__First_Name__c = 'test';
        hcpCaseRec.US_WSREMS__Last_Name__c = 'test';
        hcpCaseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        hcpCaseRec.US_WSREMS__Program_Picklist__c = aveedProgram.Name;
        hcpCaseRec.Us_WSREMS__Participant__r = acc;
        hcpCaseRec.Us_WSREMS__Participant__c = acc.Id;
        caseList.add(hcpCaseRec);
        
        insert caselist;
        
    }
    public static testMethod void testMethod1() {
        test.startTest(); 
        case caseObjRec1 = [Select id,SYN_Prescriber__r.US_WSREMS__Email__c,RecordTypeId,SYN_Authorized_Rep__r.personContactId,Us_WSREMS__Participant__r.personContactId,US_WSREMS__Pharmacy_User__r.Fax,US_WSREMS__Pharmacy_User__r.LastName,US_WSREMS__Participant__r.Fax,US_WSREMS__Participant__r.US_WSREMS__Email__c,
                            US_WSREMS__Pharmacy_User__r.firstName,US_WSREMS__Email__c,SYN_Prescriber_Fax__c,US_WSREMS__Patient__r.LastName,US_WSREMS__Patient__r.firstName,SYN_Prescriber__r.LastName,Status,US_WSREMS__Program_Picklist__c,
                            X1_Pharmacy_Participant__c,X1_Pharmacy_Participant__r.US_WSREMS__Email__c,SYN_Prescriber__r.firstName,US_WSREMS__Fax__c,US_WSREMS__Participant__r.firstName,US_WSREMS__Participant__r.LastName,US_WSREMS__Participant__r.Name,OwnerId,US_WSREMS__Patient__r.Fax,US_WSREMS__Program_Name__c,Us_WSREMS__Participant__c,US_WSREMS__Prescriber__c,SYN_Prescriber__r.Fax,US_WSREMS__Distributor__r.US_WSREMS__Email__c,SYN_Pharmacist__r.personContactId,SYN_Name_of_Reporter__r.personContactId from case Limit 1 ]; 
        
        Account acc=[Select id,personContactId,US_WSREMS__Program_Name__c, Program_Name__c,Fax,Name,OwnerId,(select id from contacts) From Account Limit 1];
        US_WSREMS__REMS_Service_Summary__c rss=[Select id,OwnerId from US_WSREMS__REMS_Service_Summary__c  where US_WSREMS__Requestor_Type__c =: 'Pharmacy' Limit 1];
        
        
        SYN_CommonUtility.getObjectFieldValues(caseObjRec1);
        SYN_CommonUtility.getObjectFieldValues(acc);
        SYN_CommonUtility.getObjectFieldValues(rss);
        test.stopTest();
    }
    
    public static testMethod void testaveed() {
        Id nonComplianceRecId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Non_Compliance').getRecordTypeId();
        test.startTest(); 
        case caseObjRec1 = [Select id,SYN_Prescriber__r.US_WSREMS__Email__c,RecordTypeId,SYN_Authorized_Rep__r.personContactId,Us_WSREMS__Participant__r.personContactId,US_WSREMS__Pharmacy_User__r.Fax,US_WSREMS__Pharmacy_User__r.LastName,US_WSREMS__Participant__r.Fax,US_WSREMS__Participant__r.US_WSREMS__Email__c,
                            US_WSREMS__Pharmacy_User__r.firstName,US_WSREMS__Email__c,SYN_Prescriber_Fax__c,US_WSREMS__Patient__r.LastName,US_WSREMS__Patient__r.firstName,SYN_Prescriber__r.LastName,Status,US_WSREMS__Program_Picklist__c,
                            X1_Pharmacy_Participant__c,X1_Pharmacy_Participant__r.US_WSREMS__Email__c,SYN_Prescriber__r.firstName,US_WSREMS__Fax__c,US_WSREMS__Participant__r.firstName,US_WSREMS__Participant__r.LastName,US_WSREMS__Participant__r.Name,OwnerId,US_WSREMS__Patient__r.Fax,US_WSREMS__Program_Name__c,Us_WSREMS__Participant__c,US_WSREMS__Prescriber__c,SYN_Prescriber__r.Fax
                            ,US_WSREMS__Distributor__r.US_WSREMS__Email__c,SYN_Pharmacist__r.personContactId,SYN_Name_of_Reporter__r.personContactId,US_WSREMS__X1_Participant__c,US_WSREMS__X1_Participant__r.RecordtypeId,
                            US_WSREMS__X1_Participant__r.US_WSREMS__Email__c,US_WSREMS__X1_Participant__r.Fax,US_WSREMS__X1_Participant__r.personContactId,
                            US_WSREMS__X1_Participant__r.Name
                            from case Where RecordtypeId =:nonComplianceRecId Limit 1 ]; 
        
        Account acc=[Select id,personContactId,US_WSREMS__Program_Name__c,US_WSREMS__First_And_Last_Name__c, Program_Name__c,Fax,Name,OwnerId,(select id from contacts) From Account WHERE US_WSREMS__Program_Name__c = 'AVEED REMS' Limit 1];
        US_WSREMS__REMS_Service_Summary__c rss=[Select id,OwnerId from US_WSREMS__REMS_Service_Summary__c  where US_WSREMS__Requestor_Type__c =: 'Pharmacy' Limit 1];
        
        
        SYN_CommonUtility.getObjectFieldValues(caseObjRec1);
        SYN_CommonUtility.getObjectFieldValues(acc);
        SYN_CommonUtility.getObjectFieldValues(rss);
        test.stopTest();
    }
    
    public static testMethod void testMethod2() {
        test.startTest(); 
        SYN_CommonUtility.getCredentials('Veeva_Authentication_API');
        test.stopTest();
    }
    
    public static testMethod void testMethod3() {
        test.startTest(); 
        SYN_CommonUtility.getBusinessHoursId('Clozapine');
        test.stopTest();
    }
    
    public static testMethod void testMethod4() {
        test.startTest(); 
        SYN_CommonUtility.getBusinessDaysAndTime('Clozapine');
        test.stopTest();
    }
    public static testMethod void testMethod5() {
        test.startTest(); 
        SYN_CommonUtility.getBusinessStartHours('Clozapine');
        test.stopTest();
    }
    public static testMethod void testMethod6() {
        test.startTest(); 
        SYN_CommonUtility.getBusinessEndHours('Clozapine');
        test.stopTest();
    }
    
    public static testMethod void testMethod7() {
        test.startTest(); 
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        SYN_CommonUtility.calculateBusinessHours(bhs[0].Id,system.now(),System.now().addhours(1));
        SYN_CommonUtility.calculateHours(bhs[0].Id,system.now(),System.now().addhours(1));
        test.stopTest();
    }
    
    @isTest
    private static void getAsynchronousExpressionTest(){
        String nextFireTime;
        test.startTest(); 
        nextFireTime = SYN_CommonUtility.getAsynchronousExpression();
        test.stopTest(); 
        system.assert(nextFireTime != null);
    }
    
    public static testMethod void testPrescriberCase() {
        Id prescriberRecId = Schema.sObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_enrollment').getRecordTypeId();
        test.startTest(); 
        case caseObjRec1 = [Select id,SYN_Prescriber__r.US_WSREMS__Email__c,RecordTypeId,SYN_Authorized_Rep__r.personContactId,Us_WSREMS__Participant__r.personContactId,US_WSREMS__Pharmacy_User__r.Fax,US_WSREMS__Pharmacy_User__r.LastName,US_WSREMS__Participant__r.Fax,US_WSREMS__Participant__r.US_WSREMS__Email__c,
                            US_WSREMS__Pharmacy_User__r.firstName,US_WSREMS__Email__c,SYN_Prescriber_Fax__c,US_WSREMS__Patient__r.LastName,US_WSREMS__Patient__r.firstName,SYN_Prescriber__r.LastName,Status,US_WSREMS__Program_Picklist__c,
                            X1_Pharmacy_Participant__c,X1_Pharmacy_Participant__r.US_WSREMS__Email__c,SYN_Prescriber__r.firstName,US_WSREMS__Fax__c,US_WSREMS__Participant__r.firstName,US_WSREMS__Participant__r.LastName,US_WSREMS__Participant__r.Name,OwnerId,US_WSREMS__Patient__r.Fax,US_WSREMS__Program_Name__c,Us_WSREMS__Participant__c,US_WSREMS__Prescriber__c,SYN_Prescriber__r.Fax
                            ,US_WSREMS__Distributor__r.US_WSREMS__Email__c,SYN_Pharmacist__r.personContactId,SYN_Name_of_Reporter__r.personContactId,US_WSREMS__X1_Participant__c,US_WSREMS__X1_Participant__r.RecordtypeId,
                            US_WSREMS__X1_Participant__r.US_WSREMS__Email__c,US_WSREMS__X1_Participant__r.Fax,US_WSREMS__X1_Participant__r.personContactId,
                            US_WSREMS__X1_Participant__r.Name,US_WSREMS__First_Name_ar__c,US_WSREMS__Last_Name_ar__c,US_WSREMS__REMS_Authorized_Rep__c,
                            US_WSREMS__REMS_Authorized_Rep__r.Fax,US_WSREMS__REMS_Authorized_Rep__r.personContactId,US_WSREMS__Email_ar__c
                            from case Where RecordtypeId =: prescriberRecId Limit 1 ]; 
        
        Account acc=[Select id,personContactId,US_WSREMS__Program_Name__c, Program_Name__c,Fax,Name,OwnerId,(select id from contacts) From Account Limit 1];
        US_WSREMS__REMS_Service_Summary__c rss=[Select id,OwnerId from US_WSREMS__REMS_Service_Summary__c  where US_WSREMS__Requestor_Type__c =: 'Pharmacy' Limit 1];
        
        
        SYN_CommonUtility.getObjectFieldValues(caseObjRec1);
        SYN_CommonUtility.getObjectFieldValues(acc);
        SYN_CommonUtility.getObjectFieldValues(rss);
        SYN_CommonUtility.getOrgWideAddressesMap();
        SYN_CommonUtility.getProgram('program');
        SYN_CommonUtility.getCurrentUser();
        SYN_CommonUtility.getDefaultportalUser('user');
        SYN_CommonUtility.getCurrentUserContactDetails('user');
        SYN_CommonUtility.getOrgWideEmailAddress('email');
        SYN_CommonUtility.getUserByEmail('user');
        SYN_CommonUtility.PiaSkyprogramId();
            SYN_CommonUtility.getProgramId('program');
        
        test.stopTest();
    }
}