@isTest
public class GenerateAffiliationRelatedDetailsTest {

    @testSetup
    static void setupTestData() {

        US_WSREMS__REMS_Program__c programObj = SYN_TestDataUtility.createProgram(SYN_Utilitycls.XIAFLEX_PROGRAM_NAME, SYN_Utilitycls.pickListVal_Active);

        //Account Record Types
        Id hcpAccountRT = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.ACCOUNT_OBJECT, SYN_Utilitycls.Prescriber); 
        Id hcsAccountRT = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.ACCOUNT_OBJECT, 'Health_Care_Setting'); 
        Id arAccountRT = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.ACCOUNT_OBJECT, 'Authorized_Representative'); 

        List<Account> accList = new List<Account>();

        // Create Accounts
        Account healthCareSetting = new Account(
            Name = 'Health Care Setting',
            US_WSREMS__Email__c = 'healthcare@example.com',
            US_WSREMS__REMS_Program__c = programObj.Id,
            US_WSREMS__Preferred_Contact_Method__c = 'Email',
            US_WSREMS__Program_Type__c = SYN_Utilitycls.REMS,
            RecordTypeId = hcsAccountRT
        );
        accList.add(healthCareSetting);

        Account healthCareSetting1 = new Account(
            Name = 'Health Care Setting-1',
            US_WSREMS__Email__c = 'healthcare1@example.com',
            US_WSREMS__REMS_Program__c = programObj.Id,
            US_WSREMS__Preferred_Contact_Method__c = 'Email',
            US_WSREMS__Program_Type__c = SYN_Utilitycls.REMS,
            RecordTypeId = hcsAccountRT
        );
        accList.add(healthCareSetting1);

        Account prescriber = new Account(
            FirstName = 'Prescriber',
            LastName = 'Test123',
            PersonEmail = 'prescriber@example.com',
            US_WSREMS__REMS_Program__c = programObj.Id,
            US_WSREMS__Preferred_Contact_Method__c = 'Email',
            US_WSREMS__Program_Type__c = SYN_Utilitycls.REMS,
            RecordTypeId = hcpAccountRT
        );
        accList.add(prescriber);

        Account prescriber1 = new Account(
            FirstName = 'Prescriber-1',
            LastName = 'Test123',
            PersonEmail = 'prescriber1@example.com',
            US_WSREMS__REMS_Program__c = programObj.Id,
            US_WSREMS__Preferred_Contact_Method__c = 'Email',
            US_WSREMS__Program_Type__c = SYN_Utilitycls.REMS,
            RecordTypeId = hcpAccountRT
        );
        accList.add(prescriber1);
        
        Account authorizedRep = new Account(
            FirstName = 'Authorized',
            LastName = 'Rep123',
            PersonEmail = 'authorizedRep1@example.com',
            US_WSREMS__REMS_Program__c = programObj.Id,
            US_WSREMS__Preferred_Contact_Method__c = 'Email',
            US_WSREMS__Program_Type__c = SYN_Utilitycls.REMS,
            RecordTypeId = arAccountRT
        );
        accList.add(authorizedRep);

        insert accList;
    }

    @isTest
    static void affiliationRelatedDetailsTest() {

        // Retrieve record types
        Id prescriberAffiliationRT = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.AFFILIATION_OBJECT, SYN_Utilitycls.PRESCRIBER_AFFILIATION_RECORDTYPENAME); 
        Id arAffiliationRT = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.AFFILIATION_OBJECT, 'Authorized_Representative_Affiliation'); 
        Id hcsAffiliationRT = SYN_CommonUtility.getRecordTypeIdbyDeveloperName(SYN_Utilitycls.AFFILIATION_OBJECT, 'Healthcare_Setting_Affiliation'); 
        
        // Retrieve accounts
        List<Account> hcsList = new List<Account>();
        List<Account> hcpList = new List<Account>();
        List<Account> arList = new List<Account>();
        for( Account acc : [ SELECT Id, RecordType.DeveloperName FROM Account ]){
            if( acc.RecordType.DeveloperName == 'Health_Care_Setting' ){
                hcsList.add(acc);
            } else if( acc.RecordType.DeveloperName == SYN_Utilitycls.Prescriber ){
                hcpList.add(acc);
            } else if( acc.RecordType.DeveloperName == 'Authorized_Representative' ){
                arList.add(acc);
            }
        }

        List<US_WSREMS__REMS_Program__c> programList = [ Select Id From US_WSREMS__REMS_Program__c Where Name =: SYN_Utilitycls.XIAFLEX_PROGRAM_NAME ];
        List<US_WSREMS__Affiliation__c> affList = new List<US_WSREMS__Affiliation__c>();

        US_WSREMS__Affiliation__c arAffiliation = new US_WSREMS__Affiliation__c(
            RecordTypeId = arAffiliationRT,
            US_WSREMS__Health_Care_Setting__c = hcsList[0].Id,
            US_WSREMS__Authorized_Representative__c = arList[0].Id,
            US_WSREMS__REMSProgram__c = programList[0].Id,
            US_WSREMS__isActive__c = TRUE
        );
        affList.add(arAffiliation);

        US_WSREMS__Affiliation__c arAffiliation2 = new US_WSREMS__Affiliation__c(
            RecordTypeId = arAffiliationRT,
            US_WSREMS__Health_Care_Setting__c = hcsList[0].Id,
            US_WSREMS__Authorized_Representative__c = arList[0].Id,
            US_WSREMS__REMSProgram__c = programList[0].Id,
            US_WSREMS__isActive__c = TRUE
        );
        affList.add(arAffiliation2);

        insert affList;

        affList = new List<US_WSREMS__Affiliation__c>();

        // Create affiliations
        US_WSREMS__Affiliation__c prescriberAffiliation = new US_WSREMS__Affiliation__c(
            RecordTypeId = prescriberAffiliationRT,
            US_WSREMS__Prescriber__c = hcpList[0].Id,
            US_WSREMS__Health_Care_Setting__c = hcsList[0].Id,
            US_WSREMS__isActive__c = TRUE,
            US_WSREMS__REMSProgram__c = programList[0].Id
        );
        affList.add(prescriberAffiliation);

        US_WSREMS__Affiliation__c prescriberAffiliation2 = new US_WSREMS__Affiliation__c(
            RecordTypeId = prescriberAffiliationRT,
            US_WSREMS__Prescriber__c = hcpList[1].Id,
            US_WSREMS__Health_Care_Setting__c = hcsList[0].Id,
            US_WSREMS__isActive__c = TRUE,
            US_WSREMS__REMSProgram__c = programList[0].Id
        );
        affList.add(prescriberAffiliation2);

        US_WSREMS__Affiliation__c hcsAffiliation = new US_WSREMS__Affiliation__c(
            RecordTypeId = hcsAffiliationRT,
            US_WSREMS__Prescriber__c = hcpList[0].Id,
            US_WSREMS__Health_Care_Setting__c = hcsList[0].Id,
            US_WSREMS__isActive__c = TRUE,
            US_WSREMS__REMSProgram__c = programList[0].Id
        );
        affList.add(hcsAffiliation);

        US_WSREMS__Affiliation__c hcsAffiliation2 = new US_WSREMS__Affiliation__c(
            RecordTypeId = hcsAffiliationRT,
            US_WSREMS__Prescriber__c = hcpList[1].Id,
            US_WSREMS__Health_Care_Setting__c = hcsList[1].Id,
            US_WSREMS__isActive__c = TRUE,
            US_WSREMS__REMSProgram__c = programList[0].Id
        );
        affList.add(hcsAffiliation2);

        insert affList;
    }
}