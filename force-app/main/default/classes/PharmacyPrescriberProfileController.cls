public without sharing class PharmacyPrescriberProfileController {
    @AuraEnabled
    public static string updatePersonAccount(Account accnt,String CommunityName) {
        try {
            if(accnt != null ) {
                accnt.US_WSREMS__Channel__c ='Portal';
                update accnt;
                List<US_WSREMS__REMS_Program__c> remsPrgm = [Select id,Name FROM US_WSREMS__REMS_Program__c WHERE Name =: Label.Sodium_Oxybate_REMS_Program_Name];
                US_WSREMS__REMS_Service_Summary__c remsService  = new US_WSREMS__REMS_Service_Summary__c();
                remsService.RecordTypeId = Schema.SObjectType.US_WSREMS__REMS_Service_Summary__c.getRecordTypeInfosByDeveloperName().get('Change_of_Information').getRecordTypeId();
                remsService.US_WSREMS__REMSProgram__c = remsPrgm[0].Id;
                remsService.US_WSREMS__Requestor_Type__c = communityName == 'SOXPrescriberPortal' ?'Prescriber':'Pharmacy Participant';
                remsService.US_WSREMS__Participant__c =accnt.Id;
                remsService.US_WSREMS__Registration_Status__c = 'Pending';
                remsService.US_WSREMS__Path_Stage_Name__c ='Closed';
                remsService.US_WSREMS__Status__c = 'Closed';
                remsService.US_WSREMS__Service_Outcome__c = 'Successful';
                
                insert remsService;
                
                Case c  = new case();
                c.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_COI').getRecordTypeId();
                c.SYN_Participant_Phone__c = accnt.Phone;
                c.US_WSREMS__REMS_Program__c= remsPrgm[0].Id;
                c.US_WSREMS__REMS_Service_Summary__c= remsService.Id;
                c.status = 'Complete';
                c.US_WSREMS__Participant__c  = accnt.Id;
                c.US_WSREMS__Program_Picklist__c = 'Sodium Oxybate REMS';
                c.US_WSREMS__Outcome__c = 'Complete';
                if(communityName == 'SOXPrescriberPortal') {
                    c.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Prescriber_COI').getRecordTypeId();
                    c.US_WSREMS__First_Name__c = accnt.FirstName;
                    c.US_WSREMS__Last_Name__c = accnt.LastName;
                    c.US_WSREMS__Middle_Name__c = accnt.MiddleName;
                    c.US_WSREMS__Channel__c = accnt.US_WSREMS__Channel__c;
                    c.Professional_Designation__c = accnt.SYN_Professional_Designation__c;
                    c.US_WSREMS__DEA__c = accnt.US_WSREMS__DEA__c;
                    c.US_WSREMS__NPI__c = accnt.US_WSREMS__NPI__c;
                    c.US_WSREMS__SLN__c = accnt.US_WSREMS__SLN__c;
                    c.US_WSREMS__Address_Line_1__c = accnt.ShippingStreet;
                    c.US_WSREMS__City__c = accnt.ShippingCity;
                    c.US_WSREMS__State__c = accnt.ShippingState;
                    c.SYN_Zip_Code__c = accnt.ShippingPostalCode;
                    c.US_WSREMS__Phone__c = accnt.Phone;
                    c.US_WSREMS__Fax__c = accnt.Fax;
                    c.SYN_Ext__c = accnt.SYN_Ext__c;
                    c.US_WSREMS__Email__c = accnt.US_WSREMS__Email__c;
                    c.US_WSREMS__Preferred_Contact_Method__c = accnt.US_WSREMS__Preferred_Contact_Method__c;
                }
                if(communityName == 'Pharmacyportal') {
                    c.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Pharmacy_Participant_COI').getRecordTypeId();
                    c.US_WSREMS__REMS_Program__c= remsPrgm[0].Id;
                    c.US_WSREMS__REMS_Service_Summary__c= remsService.Id;
                    c.US_WSREMS__Channel__c = accnt.US_WSREMS__Channel__c;
                    c.US_WSREMS__First_Name__c = accnt.FirstName;
                    c.US_WSREMS__Last_Name__c = accnt.LastName;
                    c.US_WSREMS__Middle_Name__c = accnt.MiddleName;
                    c.Professional_Designation__c = accnt.SYN_Professional_Designation__c;
                    c.SYN_Credentials__c = accnt.SYN_Credentials__c;
                    c.US_WSREMS__Phone__c = accnt.Phone;
                    c.SYN_Ext__c = accnt.SYN_Ext__c;
                    c.US_WSREMS__Email__c = accnt.US_WSREMS__Email__c;
                }
                insert c;
                
                remsService.US_WSREMS__Path_Complete__c= true;
                update remsService;
                return 'Success';
             }
            return 'No Users to Update';
        }     
        catch(DMLException e) {
            throw new AuraHandledException('For any information on this screen that you are unable to update, please contact the Sodium Oxybate REMS at 1-833-769-7367:  '+e.getDmlMessage(0));
        }
        catch(Exception e) {
            throw new AuraHandledException('For any information on this screen that you are unable to update, please contact the Sodium Oxybate REMS at 1-833-769-7367.  :'+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getRecordTypeId (String RecTypeName){
        return  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RecTypeName).getRecordTypeId();


    }
    
}