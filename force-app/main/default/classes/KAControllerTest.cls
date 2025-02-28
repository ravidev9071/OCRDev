@isTest
public class KAControllerTest {
     @TestSetup
    static void setupData() {
        US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c ();
        programObj.Name = 'Aveed REMS';
        programObj.US_WSREMS__Status__c = 'Active';
        programObj.REMS_Project_Code__c = 'BT1005';
        programObj.US_WSREMS__Program_State_Date__c = System.today();
        programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
        insert programObj;
        Account accountObj = SYN_TestDataFactory.createPersonAccountforPrescriberAveed('0909876545', 12345678, '1234567896', true, programObj.Id);
        accountObj.US_WSREMS__Program_Picklist__c ='AVEED REMS';
        update accountObj;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<UserRole> roles = [SELECT Id FROM UserRole WHERE Name = 'CEO'];
            if (roles != null && !roles.isEmpty()) {
                User currentUser = new User(Id = UserInfo.getUserId());
                currentUser.UserRoleId = roles.get(0).Id;
                update currentUser;
            }
            List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE Id = :accountObj.Id];
            List<Profile> aveedPortalProfile = [SELECT Id, Name FROM Profile WHERE Name = 'AVEED Portal'];
            List<PermissionSet> portalPermissionSet = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'AVEED_PortalPermissionSet'];
            String orgId = UserInfo.getOrganizationId();  
            String dateString =   
                String.valueof(
                    Datetime.now()
                ).replace(
                    ' ',''
                ).replace(
                    ':',''
                ).replace(
                    '-',''
                );  
            Integer randomInt = Integer.valueOf(
                math.rint(
                    math.random()*1000000
                )
            );  
            String uniqueName = orgId + dateString + randomInt;  
            User portalUser = new User(  
                FirstName = accounts.get(0).FirstName,
                LastName = accounts.get(0).LastName,
                email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = aveedPortalProfile.get(0).Id,
                ContactId = accounts.get(0).PersonContactId,
                US_WSREMS__Role__c='Prescriber'
            );  
            insert portalUser;
            
            PermissionSetAssignment permissionAssignment = new PermissionSetAssignment(PermissionSetId = portalPermissionSet.get(0).Id, AssigneeId = portalUser.Id);
            insert permissionAssignment;
        }
    }
    
    @IsTest
    public static void test_Validate() {
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        //Get portal User
        List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
        List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Aveed REMS'];
        System.runAs(portalUser.get(0)) {
            Test.startTest();
            try {
               KAController.validateAssessmentCase(program[0].Id);
               KAController.validateAssessment('AVEED REMS','Prescriber');
               
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
            Test.stopTest();
        }
    }
    
  @isTest
    static void getQuestions(){
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        US_WSREMS__Assessment__c  assessment = new US_WSREMS__Assessment__c();
        assessment.US_WSREMS__REMS_Program__c=programList[0].id;
        assessment.US_WSREMS__Maximum_Attempts__c=3;
        assessment.US_WSREMS__Participant_Type__c='Prescriber';
        assessment.US_WSREMS__Pass_Percentage__c=100;
        assessment.US_WSREMS__Show_Wrong_Answers_Only__c=true;
        assessment.name='Knowledge Assessment';
        insert assessment;
        
        US_WSREMS__Assessment_Question__c ques = new 	US_WSREMS__Assessment_Question__c();
        ques.US_WSREMS__Active__c=true;
        ques.US_WSREMS__Assessment__c=assessment.id;
        ques.US_WSREMS__Correct_Response__c='2';
        ques.US_WSREMS__Question_Text__c='test';
        ques.US_WSREMS__Response_Values__c='1. True;;2. False';
        ques.US_WSREMS__Response_Data_Type__c='Radio Option';
        ques.US_WSREMS__Serial__c=1;
        insert ques;
        
        US_WSREMS__Assessment_Question__c ques1 = new 	US_WSREMS__Assessment_Question__c();
        ques1.US_WSREMS__Active__c=true;
        ques1.US_WSREMS__Assessment__c=assessment.id;
        ques1.US_WSREMS__Correct_Response__c='2';
        ques1.US_WSREMS__Question_Text__c='test2';
        ques1.US_WSREMS__Response_Values__c='1. True;;2. False';
        ques1.US_WSREMS__Response_Data_Type__c='Radio Option';
        ques1.US_WSREMS__Serial__c=1;
        
        insert ques1;
        
        
        case caseRec = new case();
        caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Knowledge_Assessment';
        caseRec.US_WSREMS__REMS_Program__c = programList[0].Id;
        caseRec.Status = 'Draft';
        caseRec.US_WSREMS__First_Name__c = 'test';
        caseRec.US_WSREMS__Last_Name__c = 'test';
        caseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByName().get('Knowledge Assessment').getRecordTypeId();
        caseRec.US_WSREMS__Program_Picklist__c = programList[0].Name;
        insert caseRec;
        
        list<US_WSREMS__Assessment_Response__c> reslist= new list<US_WSREMS__Assessment_Response__c>();
        US_WSREMS__Assessment_Response__c res= new US_WSREMS__Assessment_Response__c();
        res.US_WSREMS__Assessment_Question__c=ques.id;
        res.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res.US_WSREMS__Answer__c='1';
        res.US_WSREMS__Response__c='true';
        reslist.add(res);
        US_WSREMS__Assessment_Response__c res1= new US_WSREMS__Assessment_Response__c();
        res1.US_WSREMS__Assessment_Question__c=ques1.id;
        res1.US_WSREMS__Question__c=ques1.US_WSREMS__Question_Text__c;
        res1.US_WSREMS__Answer__c='1';
        res1.US_WSREMS__Response__c='true';
        reslist.add(res1);
        
        
        US_WSREMS__Assessment_Submission__c sub = new US_WSREMS__Assessment_Submission__c();
        sub.US_WSREMS__Assessment__c=assessment.id;
        sub.US_WSREMS__Case__c=caseRec.id;
        sub.US_WSREMS__Assessment_Result__c='Failed';
        insert sub;
        
        
        US_WSREMS__Assessment_Response__c res3= new US_WSREMS__Assessment_Response__c();
        res3.US_WSREMS__Assessment_Question__c=ques.id;
        res3.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res3.US_WSREMS__Answer__c='1';
        res3.US_WSREMS__Response__c='true';
        res3.US_WSREMS__Assessment_Submission__c=sub.id;
        insert res3;
        
        US_WSREMS__Assessment_Response__c res4= new US_WSREMS__Assessment_Response__c();
        res4.US_WSREMS__Assessment_Question__c=ques1.id;
        res4.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res4.US_WSREMS__Answer__c='1';
        res4.US_WSREMS__Response__c='true';
        res4.US_WSREMS__Assessment_Submission__c=sub.id;
        insert res4;
        
        string response=KAController.getSubmitResponse(caseRec.id,assessment.id,reslist,100,'1');
        
        KAController.CaseAndRelatedDataWrapper wrap= new KAController.CaseAndRelatedDataWrapper();
        
        wrap=KAController.getCaseAndRelatedData(caseRec.id,false);
        
        List<US_WSREMS__Assessment__c> asselist= KAController.getQuestions();
    }
    @isTest
    static void getKaQuestions(){
        List<US_WSREMS__REMS_Program__c> programList = createPrograms(1, true);
        Account acc = new Account();
        acc.lastname = 'test acc';
        acc.FirstName = 'test';
        acc.US_WSREMS__REMS_Program__c = programList[0].id;
        acc.recordtypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        acc.US_WSREMS__Program_Picklist__c = programList[0].Name;
        insert acc;
        US_WSREMS__Assessment__c  assessment = new US_WSREMS__Assessment__c();
        assessment.US_WSREMS__REMS_Program__c=programList[0].id;
        assessment.US_WSREMS__Maximum_Attempts__c=3;
        assessment.US_WSREMS__Participant_Type__c='Prescriber';
        assessment.US_WSREMS__Pass_Percentage__c=100;
        assessment.US_WSREMS__Show_Wrong_Answers_Only__c=true;
        assessment.name='Knowledge Assessment';
        insert assessment;
        
        US_WSREMS__Assessment_Question__c ques = new 	US_WSREMS__Assessment_Question__c();
        ques.US_WSREMS__Active__c=true;
        ques.US_WSREMS__Assessment__c=assessment.id;
        ques.US_WSREMS__Correct_Response__c='1';
        ques.US_WSREMS__Question_Text__c='test';
        ques.US_WSREMS__Response_Values__c='1. True;;2. False';
        ques.US_WSREMS__Response_Data_Type__c='Radio Option';
        ques.US_WSREMS__Serial__c=1;
        insert ques;
        
        US_WSREMS__Assessment_Question__c ques1 = new 	US_WSREMS__Assessment_Question__c();
        ques1.US_WSREMS__Active__c=true;
        ques1.US_WSREMS__Assessment__c=assessment.id;
        ques1.US_WSREMS__Correct_Response__c='1';
        ques1.US_WSREMS__Question_Text__c='test2';
        ques1.US_WSREMS__Response_Values__c='1. True;;2. False';
        ques1.US_WSREMS__Response_Data_Type__c='Radio Option';
        ques1.US_WSREMS__Serial__c=1;
        
        insert ques1;
        
        
        case caseRec = new case();
        caseRec.Program_Record_Type_Control__c = 'AVEED REMS-Knowledge_Assessment';
        caseRec.US_WSREMS__REMS_Program__c = programList[0].Id;
        caseRec.Status = 'Draft';
        caseRec.US_WSREMS__First_Name__c = 'test';
        caseRec.US_WSREMS__Last_Name__c = 'test';
        caseRec.recordtypeId = Schema.sObjectType.case.getRecordTypeInfosByName().get('Knowledge Assessment').getRecordTypeId();
        caseRec.US_WSREMS__Program_Picklist__c = programList[0].Name;
        caseRec.US_WSREMS__Prescriber__c=acc.id;    
        insert caseRec;
        
        
        list<US_WSREMS__Assessment_Response__c> reslist= new list<US_WSREMS__Assessment_Response__c>();
        US_WSREMS__Assessment_Response__c res= new US_WSREMS__Assessment_Response__c();
        res.US_WSREMS__Assessment_Question__c=ques.id;
        res.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res.US_WSREMS__Answer__c='1';
        res.US_WSREMS__Response__c='true';
        res.US_WSREMS__Response_Result__c=true;
        reslist.add(res);
        US_WSREMS__Assessment_Response__c res1= new US_WSREMS__Assessment_Response__c();
        res1.US_WSREMS__Assessment_Question__c=ques1.id;
        res1.US_WSREMS__Question__c=ques1.US_WSREMS__Question_Text__c;
        res1.US_WSREMS__Answer__c='1';
        res1.US_WSREMS__Response__c='true';
        res1.US_WSREMS__Response_Result__c=true;
        reslist.add(res1);
        
        
        US_WSREMS__Assessment_Submission__c sub = new US_WSREMS__Assessment_Submission__c();
        sub.US_WSREMS__Assessment__c=assessment.id;
        sub.US_WSREMS__Case__c=caseRec.id;
        sub.US_WSREMS__Assessment_Result__c='Failed';
        insert sub;
        
        
        US_WSREMS__Assessment_Response__c res3= new US_WSREMS__Assessment_Response__c();
        res3.US_WSREMS__Assessment_Question__c=ques.id;
        res3.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res3.US_WSREMS__Answer__c='1';
        res3.US_WSREMS__Response__c='true';
        res3.US_WSREMS__Assessment_Submission__c=sub.id;
        res3.US_WSREMS__Response_Result__c=true;
        insert res3;
        
        US_WSREMS__Assessment_Response__c res4= new US_WSREMS__Assessment_Response__c();
        res4.US_WSREMS__Assessment_Question__c=ques1.id;
        res4.US_WSREMS__Question__c=ques.US_WSREMS__Question_Text__c;
        res4.US_WSREMS__Answer__c='1';
        res4.US_WSREMS__Response__c='true';
        res4.US_WSREMS__Response_Result__c=true;
        res4.US_WSREMS__Assessment_Submission__c=sub.id;
        insert res4;
        
        string response=KAController.getSubmitResponse(caseRec.id,assessment.id,reslist,100,'1');
        
        KAController.CaseAndRelatedDataWrapper wrap= new KAController.CaseAndRelatedDataWrapper();
        
        wrap=KAController.getCaseAndRelatedData(caseRec.id,true);
        
        List<US_WSREMS__Assessment__c> asselist= KAController.getQuestions();
    }
    public static List<US_WSREMS__REMS_Program__c> createPrograms(integer noOfRecords,boolean isCreate){
        List<US_WSREMS__REMS_Program__c> programList = new List<US_WSREMS__REMS_Program__c>();
        for(integer i=0;i<noOfRecords;i++){
            US_WSREMS__REMS_Program__c programObj = new US_WSREMS__REMS_Program__c();
            programObj.Name = 'AVEED REMS';
            programObj.US_WSREMS__Status__c ='Active';
            programObj.US_WSREMS__Program_State_Date__c = System.today();
            programObj.US_WSREMS__Program_End_Date__c = System.today().addDays(20);
            programList.add(programObj);
        }
        
        if(isCreate && programList.size()>0){
            insert programList;
        }
        return programList; 
    }
    @isTest
    static void testUpdateCommunityUserAccount() {
        User communitydefaulowner = communityDefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        }
        List<US_WSREMS__REMS_Program__c> remsProgramList = SYN_TestDataFactory.createREMSPrograms(1,false);
        remsProgramList[0].name='AVEED REMS';
        insert remsProgramList;
        US_WSREMS__Assessment__c testAssessment = SYN_TestDataFactory.createAssessments(remsProgramList[0].Id , 'Prescriber');
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        PrescriberObj.US_WSREMS__REMS_Program__c = remsProgramList[0].id;
        insert PrescriberObj; 
        User usr;

        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('KnowledgeAssessment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceSummaryObj = SYN_TestDataFactory.createService(true, remsProgramList[0].Id, recordTypeId);
        Account acc;
        Test.StartTest();
        
         system.runAs( new User(Id = UserInfo.getUserId())){
            KAController.CertificationWrapper resultCase = KAController.validateAssessment(remsProgramList[0].Name, 
                                                                             'Prescriber');
                                                                           

         }
         Test.stopTest();
    }


    @isTest
    static void testValidateAssessmentCase() {
        User communitydefaulowner = communityDefaultUser();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        }
         List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Aveed REMS'];
       
        
        US_WSREMS__Assessment__c testAssessment =SYN_TestDataFactory.createAssessment(program[0].Id);
        testAssessment.US_WSREMS__Participant_Type__c = 'Prescriber';
        update testAssessment;
        
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        PrescriberObj.US_WSREMS__REMS_Program__c = program[0].id;
        insert PrescriberObj; 
         List<Account> accounts = [SELECT Id, PersonContactId, US_WSREMS__Program_Picklist__c,Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];
        
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('KnowledgeAssessment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceSummaryObj = SYN_TestDataFactory.createService(true, program[0].Id, recordTypeId);
        serviceSummaryObj.US_WSREMS__Participant__c=accounts[0].id;
        update serviceSummaryObj;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Knowledge_Assessment').getRecordTypeId();
     
        
       
       case caseobj= KAController.createCase(new List<US_WSREMS__REMS_Service_Summary__c>{serviceSummaryObj}, accounts[0].id, 'Prescriber');
        US_WSREMS__Assessment_Submission__c submission = SYN_TestDataFactory.createAssessmentSubmission(caseobj.Id, testAssessment.Id); 
        Test.StartTest();
         
          List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
         system.runAs(portalUser[0]){
           
        	
             KAController.validateAssessment(program[0].Name, 'Prescriber');
         	KAController.AssessmentCaseWrapper assessmentWrapper = KAController.validateAssessmentCase(program[0].Name);
        	
         }
         Test.stopTest();
    }
    @isTest
    static void testValidateAssessmentCaseNew() {
     
         List<US_WSREMS__REMS_Program__c> program = [SELECT Id, Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Aveed REMS'];
       
        US_WSREMS__Assessment__c testAssessment =SYN_TestDataFactory.createAssessment(program[0].Id);
        testAssessment.US_WSREMS__Participant_Type__c = 'Prescriber';
        update testAssessment;
        
        Account PrescriberObj = SYN_TestDataFactory.createPersonAccountforPrescriber('5648603245', 12345, '8987654321', false);
        PrescriberObj.US_WSREMS__REMS_Program__c = program[0].id;
        insert PrescriberObj; 
        List<Account> accounts = [SELECT Id, PersonContactId, Name, FirstName, LastName, US_WSREMS__Email__c, Phone, US_WSREMS__REMS_Program__r.Name, RecordType.Name FROM Account WHERE US_WSREMS__National_Provider_Identifier__c = '0909876545'];

        
        String recordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('KnowledgeAssessment').getRecordTypeId();
        US_WSREMS__REMS_Service_Summary__c serviceSummaryObj = SYN_TestDataFactory.createService(true, program[0].Id, recordTypeId);
        
       Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Knowledge_Assessment').getRecordTypeId();
        Case caseObj = SYN_TestDataFactory.createCase(caseRecordTypeId, 'New', serviceSummaryObj.Id, false );
        caseObj.US_WSREMS__Participant__c = accounts[0].Id;
        caseObj.US_WSREMS__REMS_Program__c = program[0].Id;
        insert caseObj;
        US_WSREMS__Assessment_Submission__c submission = new US_WSREMS__Assessment_Submission__c();
        submission.US_WSREMS__Assessment__c = testAssessment.Id;
        submission.US_WSREMS__Case__c= caseObj.Id;
        submission.US_WSREMS__Assessment_Result__c='Failed';
        insert submission;
        
        
        Test.StartTest();
         List<User> portalUser = [SELECT Id, Name FROM User WHERE ContactId = :accounts.get(0).PersonContactId];
         system.runAs(portalUser[0]){
              KAController.validateAssessment(program[0].Name, 'Prescriber');
         	KAController.AssessmentCaseWrapper assessmentWrapper = KAController.validateAssessmentCase(program[0].Name);
        	System.assert(assessmentWrapper!=null);
        }
         Test.stopTest();
    }
    
 
    
    
 
 // create community default owner 
 public static User communityDefaultUser(){
     // Get the profile details
     UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
     Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
     // Create a new user with following users and return
     User commUser = new User(
         UserRoleId = portalRole.Id,
         ProfileId = profileId,
         Username = 'communityuser_test@test.eversana.com' + Math.random() + '.com',
         CommunityNickname = 'test' + Math.random(),
         Alias = 'batman',
         Email = System.now().millisecond() + 'communitydefaultowner@test.com',
         EmailEncodingKey = 'UTF-8',
         Firstname = 'Admin',
         Lastname = 'User'+System.now().millisecond(),
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         TimeZoneSidKey = 'America/Chicago'
     );
     //insert cumntyuser; 
     return commUser;
    }
    
    
    //Physician Account
 public static User CreateCommunityUser(Account acc, String profileId, String communityProgram, String communityRole) {
   
     //Create contact
     Contact con = [SELECT Id FROM Contact WHERE AccountId = : acc.id LIMIT 1];             
    
     // Create Community User 
     User newCommUser = new User();
     newCommUser.FirstName= 'Elsa';
     newCommUser.LastName = 'Arendelle';
     newCommUser.Email = 'elsa@test.com';
     newCommUser.Alias = 'eversana';
     newCommUser.Username = 'comunityiser_hcp@test.test.com' + Math.random() + '.com'; 
     newCommUser.CommunityNickname = 'usr' + Math.random();
     newCommUser.LocaleSidKey= 'en_US';
     newCommUser.TimeZoneSidKey = 'GMT';
     newCommUser.LanguageLocaleKey = 'en_US';
     newCommUser.EmailEncodingKey  = 'UTF-8';
     newCommUser.ProfileId = profileId;
     newCommUser.ContactId = con.Id; 
     try{
     insert newCommUser; 
     }catch (exception e){
         system.debug('--Error----'+e.getMessage());
     } 
     return newCommUser;
    }  
 
 
    //Prescriber Person Account
    public static Account createPrescriberPersonAccount(Id programId){
        id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prescriber').getRecordTypeId();
        Account accountObj = new Account();
        accountObj.FirstName= 'TestUser';
        accountObj.LastName = 'Program';
        accountObj.RecordTypeId = recordTypeId;
        accountObj.US_WSREMS__Channel__c  = 'fax';
        accountObj.US_WSREMS__SLN_State__c  ='AA';
        accountObj.Phone = '9999999999';
        accountObj.US_WSREMS__National_Provider_Identifier__c = '9999999999';
        accountObj.US_WSREMS__Phone_Type__c  = 'mobile';
        accountObj.US_WSREMS__EXT__c  = '123';
        accountObj.Fax = '9999999999';
        accountObj.US_WSREMS__Email__c  ='testmaci@test.com';
        accountObj.US_WSREMS__Preferred_Contact_Method__c  = 'email';
        accountObj.US_WSREMS__REMS_Program__c = programId;
       insert accountObj;         
        return accountObj;
    }
}