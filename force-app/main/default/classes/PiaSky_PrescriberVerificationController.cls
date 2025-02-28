public without sharing class PiaSky_PrescriberVerificationController {
    /************************************************************************
MethodName : getPrescriberList
Description : retiurn list of prescriber record based on program.
*************************************************************************/
    @AuraEnabled
    public static List<Account> getPrescriberList(String npiNumber, String firstName, String lastName, String state){
        List<Account> accounts;
        String escapedProgramName = String.escapeSingleQuotes('PiaSky REMS');
        if(String.isEmpty(npiNumber) && String.isEmpty(firstName) && String.isEmpty(lastName) && String.isEmpty(state)) return null;
        if(!String.isEmpty(npiNumber)){
            accounts = [SELECT Id,US_WSREMS__National_Provider_Identifier__c,LastName,FirstName,US_WSREMS__REMS_ID__c,US_WSREMS__Status__c FROM Account WHERE US_WSREMS__National_Provider_Identifier__c != null AND US_WSREMS__National_Provider_Identifier__c = :npiNumber AND US_WSREMS__REMS_Program__r.Name =:escapedProgramName AND US_WSREMS__Record_Type_Name__c = 'Prescriber' LIMIT 1];
        } else{
            String firstNameQuery = '%' + firstName + '%';
            String lastNameQuery = '%' + lastName + '%';              
            accounts = [SELECT Id, LastName,FirstName,Address_1_Secondary_Office__c,US_WSREMS__REMS_ID__c,ShippingCity,
                        US_WSREMS__State__c,US_WSREMS__Zip__c,US_WSREMS__National_Provider_Identifier__c,
                        US_WSREMS__Status__c FROM Account
                        WHERE  ((LastName LIKE :lastNameQuery AND US_WSREMS__State__c =:state)
                                OR (FirstName LIKE :firstNameQuery AND US_WSREMS__State__c =:state AND LastName LIKE :lastNameQuery) )
                        AND US_WSREMS__REMS_Program__r.Name =:escapedProgramName AND US_WSREMS__Record_Type_Name__c = 'Prescriber' LIMIT 4999];
        }
        return accounts;        
    }
    
    @AuraEnabled
    public static Account getPrescriberById(Id prescriberId){
        String escapedProgramName = String.escapeSingleQuotes('PiaSky REMS');
        return[
            SELECT Id,LastName,FirstName,US_WSREMS__National_Provider_Identifier__c,US_WSREMS__Status__c,
            US_WSREMS__REMS_ID__c FROM Account WHERE Id =:prescriberId 
            AND US_WSREMS__REMS_Program__r.Name =:escapedProgramName
            AND US_WSREMS__Record_Type_Name__c = 'Prescriber' LIMIT 1
        ];
    }
    @AuraEnabled
    public static string getOutpatientPharmacy(String userId, string npiNumber,string firstName,string lastName, Account prescriberAcc){
        User loginUser = [Select Id,firstname,lastname, Contact.Name, Contact.AccountId from User where Id =: userId Limit 1];
        List<Account> pharmaAcc = [Select Id, US_WSREMS__REMS_ID__c,US_WSREMS__Status__c, name, Address_1_Secondary_Office__c,Address_2_Secondary_Office__c, ShippingCity,
                                   US_WSREMS__State__c, ShippingPostalCode, Phone,Fax,US_WSREMS__National_Provider_Identifier__c from Account where Id in(Select US_WSREMS__Pharmacy__c from US_WSREMS__Affiliation__c where 
                                    US_WSREMS__Pharmacy_User__c =: loginUser.Contact.AccountId)and US_WSREMS__Recordtype_Label__c = 'Outpatient Pharmacy' and US_WSREMS__Program_Name__c = 'Piasky REMS' and  
                                    US_WSREMS__Status__c = 'Certified' order by createddate DESC limit 1];
        if(pharmaAcc != null && pharmaAcc.size() > 0){
            List<US_WSREMS__REMS_Program__c>  program = [SELECT Id,Name, US_WSREMS__Phone__c, US_WSREMS__Fax__c FROM US_WSREMS__REMS_Program__c WHERE Name = 'Piasky REMS'];
          //  US_WSREMS__REMS_Service_Summary__c service  = PiaSky_NPISearchControllerPortal.insertServiceSummary(pharmaAcc[0], program,'Outpatient Pharmacy', 'Pre_Dispense_Authorization');
            Id idRTforREMSService = REMSUtility.retrieveRecTypeDeveloperNameId_Product('REMS_Service_Summary__c').get('Pre_Dispense_Authorization');
        US_WSREMS__REMS_Service_Summary__c service = new US_WSREMS__REMS_Service_Summary__c();
        service.recordTypeId = idRTforREMSService;
        service.US_WSREMS__REMSProgram__c = program.size() > 0 ? program[0].Id : null;
        service.US_WSREMS__Status__c = REMSAppLiterals.SERVICE_STATUS;
        service.US_WSREMS__Service_Outcome__c = REMSAppLiterals.SERVICE_OUTCOME;
        service.US_WSREMS__Participant__c = pharmaAcc[0].Id;
        service.US_WSREMS__Requestor_Type__c = 'Outpatient Pharmacy';
        insert service;
            
            Case caseRec = insertRDACase( pharmaAcc[0], service,program,'PDA','','','');
            caseRec.US_WSREMS__REMS_Authorized_Rep__c = loginUser.Contact.AccountId;
            caseRec.Participant_LastName__c = loginUser.lastname;
            caseRec.Participant_FirstName__c = loginUser.firstname;
            if(lastName != '' ){caseRec.US_WSREMS__Prescriber_Last_Name__c =  lastName;}
            if(firstName != ''){ caseRec.US_WSREMS__Prescriber_First_Name__c = firstName;}
            if(npiNumber != '') {caseRec.Prescriber_NPI__c = npiNumber;} 
            caseRec.SYN_Prescriber__c = prescriberAcc != null ? prescriberAcc.Id : null;
            caseRec.Prescriber_REMS_ID_Number__c = prescriberAcc != null ? prescriberAcc.US_WSREMS__REMS_ID__c : null;
            insert caseRec;
            service.US_WSREMS__Status__c = 'Closed';
            service.US_WSREMS__Service_Outcome__c = 'Unsuccessful';
            update service;
            string potentialTaskMessage = 'RDA rejection for prescriber not found/certified. Please follow up for additional information and prescriber certification.';
            Group taskOwner = [SELECT Id FROM Group WHERE DeveloperName =: SYN_Utilitycls.PiaSky_REMS_Task_Queue AND Type = 'Queue' LIMIT 1];
            date duedate = system.today();
            task createRdaTask = Piasky_AutomatedTaskCreation.createTask(taskOwner.Id, 'RDA Request Follow-up', caseRec.id,duedate , 'In Progress',potentialTaskMessage, caseRec.US_WSREMS__REMS_Program__c, 'Piasky REMS');
            insert createRdaTask;
            return 'success';                                
        }
        else
            return null;
    }
    // method to check login user is affiliated with outpatient pharmacy or not
    @AuraEnabled
    public static boolean checkOutpatientPharmacy(String userId){
        User loginUser = [Select Id, Contact.Name, Contact.AccountId from User where Id =: userId Limit 1];
        List<Account> pharmaAcc = [Select Id, US_WSREMS__Recordtype_Label__c,
                                   US_WSREMS__Status__c from Account where Id in
                                   (Select US_WSREMS__Pharmacy__c from
                                    US_WSREMS__Affiliation__c where 
                                    US_WSREMS__Pharmacy_User__c =:
                                    loginUser.Contact.AccountId) limit 1];
        if(pharmaAcc[0].US_WSREMS__Recordtype_Label__c == 'Outpatient Pharmacy' && pharmaAcc[0].US_WSREMS__Status__c == 'Certified'){
            return true;
        } else
            return false;
    }
    //added method to define RDA case as existing methods were defining and inserting case in same method   
    public static Case insertRDACase(Account accountRec,US_WSREMS__REMS_Service_Summary__c service,List<US_WSREMS__REMS_Program__c>  program,String recordType,string firstname,string lastname, string presNPI) {
        Case caseRec = new Case();
        Id caseRecordTypeId = REMSUtility.retrieveRecTypeDeveloperNameId(REMSAppLiterals.CASE_OBJECT).get(recordType);
        caseRec.recordTypeId = caseRecordTypeId;
        caseRec.US_WSREMS__Participant__c = accountRec.Id;
        caseRec.US_WSREMS__REMS_Service_Summary__c = service.Id;
        caseRec.US_WSREMS__Program_Picklist__c = program.size() > 0 ? program[0].Name : null;
        caseRec.US_WSREMS__Pharmacy__c = accountRec.Id;
        caseRec.SYN_Pharmacy_REMS_ID_Number__c = accountRec.US_WSREMS__REMS_ID__c;
        caseRec.US_WSREMS__NPI__c = accountRec.US_WSREMS__National_Provider_Identifier__c;
        caseRec.US_WSREMS__Pharmacy_Name__c = accountRec.name;
        caseRec.US_WSREMS__REMS_Program__c = program[0].id;
        caseRec.US_WSREMS__Is_Portal__c = true;
        return caseRec;
    }
    
}