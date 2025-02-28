public with sharing class SYN_MetadataVariablesService {
  
    public static final Map<Id, Schema.RecordTypeInfo> mapAccountRcTyByID =
    Schema.SObjectType.Account.getRecordTypeInfosById();
	private static final String semicolonStr = SYN_Utilitycls.semicolon;
    private static final String Pharmacist = SYN_Utilitycls.userType_Pharmacist;
    private static final String PharmacyStaff = SYN_Utilitycls.userType_PharmacyStaff;
    
    @AuraEnabled(cacheable=true)
    public static portalButtonDatawrapper retrievePortalButtonConfigurationData(String buttomName) {
        Account participantRec = getUserAccountRecord();
        portalButtonDatawrapper ButtonWrapper =  new portalButtonDatawrapper();
        
        String parRecType = mapAccountRcTyByID.get(participantRec.recordTypeId).getDeveloperName();
        List<String> userTypeLst = new List<String>();
        if(parRecType == SYN_Utilitycls.ACC_RCTY_Pharmacy_Participant){
            if (participantRec.SYN_User_Type__c.contains(semicolonStr)){
                userTypeLst = participantRec.SYN_User_Type__c.split(semicolonStr);
            }else{
                userTypeLst.add(participantRec.SYN_User_Type__c);
            }
        }else{
            userTypeLst.add(parRecType);
        }
        Portal_Navigation_Buttons_Configuration__mdt buttonInfo_mdt = [select id , Account_Status__c , Error_Message__c , Portal_Configuration__c , UrlPath__c , User_Type__c,
                                                                        MasterLabel from Portal_Navigation_Buttons_Configuration__mdt where MasterLabel =: buttomName and User_Type__c In: userTypeLst limit 1 ];
        
                                                                        
        Portal_Configuration__mdt portalConfigRecord_mdt = Portal_Configuration__mdt.getInstance( buttonInfo_mdt.Portal_Configuration__c);

        US_WSREMS__Program_Configuration__mdt programConfigRecord_mdt = US_WSREMS__Program_Configuration__mdt.getInstance(portalConfigRecord_mdt.Program_Configuration__c);

        if (participantRec.Program_Name__c != programConfigRecord_mdt.Label){
            return new portalButtonDatawrapper(buttomName, false , 'User does not belongs to SOX program (TBD) ');
        }
        if( buttonInfo_mdt.Account_Status__c !=null  && buttonInfo_mdt.Account_Status__c.contains(participantRec.US_WSREMS__Status__c) ){
            
            ButtonWrapper.Status = true;
            ButtonWrapper.buttonLabelName = buttomName;
            ButtonWrapper.buttonURL = buttonInfo_mdt.UrlPath__c;
            ButtonWrapper.buttonerrorMessage = buttonInfo_mdt.Error_Message__c;
        }else{
            ButtonWrapper.Status = false;
            ButtonWrapper.buttonLabelName = buttomName;
            ButtonWrapper.buttonURL = buttonInfo_mdt.UrlPath__c;
            ButtonWrapper.buttonerrorMessage = buttonInfo_mdt.Error_Message__c;
        }

        return ButtonWrapper;
     
    }

    @AuraEnabled
    public static Account getUserAccountRecord () {
        Id currentUserId = UserInfo.getUserId();
        List<User> portalUser = [SELECT Id, Contact.AccountId FROM User WHERE Id = :currentUserId];
        Account portalContactAccount = [SELECT US_WSREMS__Status__c,Program_Name__c , US_WSREMS__User_Type__c, recordTypeId, SYN_User_Type__c FROM Account WHERE Id = :portalUser[0].Contact.AccountId];
        String parRecType = mapAccountRcTyByID.get(portalContactAccount.recordTypeId).getDeveloperName();
        if(parRecType == SYN_Utilitycls.ACC_RCTY_Pharmacy_Participant){
            portalContactAccount.SYN_User_Type__c = portalContactAccount.SYN_User_Type__c.contains(Pharmacist) ? Pharmacist :
             (portalContactAccount.SYN_User_Type__c.contains(PharmacyStaff) ? PharmacyStaff : portalContactAccount.SYN_User_Type__c );
        }
        return portalContactAccount != null ? portalContactAccount : null;
    }

    public class portalButtonDatawrapper{
        @AuraEnabled
       public boolean status { get; set;}
        @AuraEnabled
       public String buttonLabelName  { get; set;}
        @AuraEnabled
       public String buttonURL  { get; set;}
        @AuraEnabled
       public String buttonerrorMessage  { get; set;}

       public portalButtonDatawrapper(string buttonName , Boolean status , String buttonerrorMessage){
           this.status = status;
           this.buttonerrorMessage = buttonerrorMessage;
           this.buttonLabelName = buttonName;
       }
       public portalButtonDatawrapper(){

       }

    }

}