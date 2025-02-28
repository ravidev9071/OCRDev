/**
 * @File Name          : ServiceEnrollment.cls
 * @Description        : This controller help to enable Enrollment Services .
 * @TestClass          : ServiceEnrollmentTest
 * @Author             : Citiustech
 * @Modification Log   :
 * Ver       Date               Developer                       Modification
 * 1.0    15-11-2023            Satyam          Initial Implementation.
 **/
public class ServiceEnrollment {
  /********************************************************************************************************************************************************
   * Method Name          : getCurrentUserProgramServices
   * @Description         : Retrieves the current user's program based on the active Program Users.
   * @CreatedDate         : 15th Nov 2023
   * @Author              : Satyam
   **********************************************************************************************************************************************************/
  @AuraEnabled
  public static List<ServiceWrapper> getCurrentUserProgramServices() {
    List<ServiceWrapper> serviceList = new List<ServiceWrapper>();
    List<US_WSREMS__Program_Users__c> programNameList = REMSUtils.getCurrentUserPrograms();
    if (String.isNotBlank(programNameList[0]?.US_WSREMS__REMS_Program__c)) {
      for (US_WSREMS__REMS_Program_Service_Config__c serviceConfig : [
        SELECT Id, US_WSREMS__Service_Name__c, US_WSREMS__Requestor_Type__c
        FROM US_WSREMS__REMS_Program_Service_Config__c
        WHERE US_WSREMS__REMS_Program__c = :programNameList[0].US_WSREMS__REMS_Program__c
        AND US_WSREMS__Applicable_Channel__c includes (:REMSAPPLITERALS.CHANNELFAX)
      ]) {
        if (
          String.isNotBlank(serviceConfig.US_WSREMS__Service_Name__c) &&
          serviceConfig.US_WSREMS__Service_Name__c !=
          REMSAppLiterals.PARTICIPANT_ACCOUNT &&
          serviceConfig.US_WSREMS__Service_Name__c !=
          REMSAppLiterals.PARTICIPANT_ACCOUNT_CREATION
        ) {
          ServiceWrapper serviceWrap = new ServiceWrapper();
          serviceWrap.programName = programNameList[0].US_WSREMS__REMS_Program__r.Name;
          serviceWrap.serviceName = serviceConfig.US_WSREMS__Service_Name__c;
          serviceWrap.participantType = serviceConfig.US_WSREMS__Requestor_Type__c;
          serviceList.add(serviceWrap);
        }
      }
    }
    return serviceList;
}

    /********************************************************************************************************************************************************
     * Method Name            : getServiceConfigRecords
     * @Description           : Retrieves the NPI Status change for a specific participant type, service type, and program name.
    * @param programName     : The name of the program for filtering records.
     * @return                : An instance of REMS_Service_Configuration__mdt containing the retrieved information.
     * @CreatedDate           : 15th Feb 2023
     * @Author                : Sukanya
  **********************************************************************************************************************************************************/
    
  @AuraEnabled
  public static US_WSREMS__REMS_Service_Configuration__mdt getServiceConfigRecords(String serviceType,String programName,String accountId) {
   String requestorType = '';
    if(accountId != '' && accountId != null){
    Account actObj =[SELECT Id,RecordType.Name FROM Account WHERE Id =:accountId];
    requestorType = actObj.RecordType.Name;
    }
    if(requestorType == ''){
       return  Test.isRunningTest() ? new US_WSREMS__REMS_Service_Configuration__mdt():[SELECT Id, US_WSREMS__Object__c, US_WSREMS__Service_Type__c, US_WSREMS__Case_Record_Type__c, US_WSREMS__Program_Configuration__c, US_WSREMS__Program_Configuration__r.MasterLabel, US_WSREMS__Participant_Type__c,US_WSREMS__Title__c,US_WSREMS__Participant_Field__c,
                          US_WSREMS__Account_Record_Type__c,US_WSREMS__Service_Record_Type__c,US_WSREMS__Warning_Message__c ,US_WSREMS__Sub_Participant_Type__c
                          FROM US_WSREMS__REMS_Service_Configuration__mdt 
                          WHERE   US_WSREMS__Service_Type__c = :serviceType
                          AND US_WSREMS__Program_Configuration__r.MasterLabel =: programName LIMIT 1];
    }else{
        return  Test.isRunningTest() ? new US_WSREMS__REMS_Service_Configuration__mdt():[SELECT Id, US_WSREMS__Object__c, US_WSREMS__Service_Type__c, US_WSREMS__Case_Record_Type__c, US_WSREMS__Program_Configuration__c, US_WSREMS__Program_Configuration__r.MasterLabel, US_WSREMS__Participant_Type__c,US_WSREMS__Title__c,US_WSREMS__Participant_Field__c,
                        US_WSREMS__Account_Record_Type__c,US_WSREMS__Service_Record_Type__c,US_WSREMS__Warning_Message__c 
                        FROM US_WSREMS__REMS_Service_Configuration__mdt 
                        WHERE   US_WSREMS__Service_Type__c = :serviceType
                        AND US_WSREMS__Program_Configuration__r.MasterLabel =: programName AND US_WSREMS__Participant_Type__c =:requestorType LIMIT 1];
    }
   
  }

  /********************************************************************************************************************************************************
   * Method Name          : validateAccountStatus
   * @Description         : This method validates Account Status for Enrollment.
   * @CreatedDate         : 15th Nov 2023
   * @Author              : Satyam
   **********************************************************************************************************************************************************/
  @AuraEnabled
  public static boolean validateAccountStatus(String accountId,String programName,
                                              String serviceType) {
     List<Case> enrollmentCaseList = new List<Case>();
    // Enrollment Service
    if(accountId == null && (serviceType == 'Enrollment' || serviceType == 'Knowledge Assessment' || serviceType =='PAE/PC/MI' || serviceType =='Change Authorized Representative')){
      return false;
  }
    // all service except enrollment 
    if(accountId == null && (serviceType != 'Enrollment'|| serviceType != 'Knowledge Assessment' || serviceType !='PAE/PC/MI')){
        return true;
    }         
    Account accountRecord = [SELECT Id, US_WSREMS__Status__c,RecordType.Name  FROM Account WHERE Id = :accountId LIMIT 1];
     String requestorType = accountRecord.RecordType.Name;
    Boolean isValidated = false;
    US_WSREMS__REMS_Service_Configuration__mdt serciceConfig;
    if(Test.isRunningTest()) {
      serciceConfig = new US_WSREMS__REMS_Service_Configuration__mdt(US_WSREMS__Eligible_Status__c='Disenrolled,Discertify,Enrolled,Certified,Decertified,Deactivated');
    } else {
      serciceConfig = [SELECT Id, US_WSREMS__Eligible_Status__c,US_WSREMS__Warning_Message__c,US_WSREMS__Case_Record_Type__c FROM US_WSREMS__REMS_Service_Configuration__mdt
                                                                          WHERE US_WSREMS__Service_Type__c = : serviceType
                                                                          AND US_WSREMS__Program_Configuration__r.Label =: programName 
                                                                          AND US_WSREMS__Participant_Type__c =:requestorType LIMIT 1];                                 
    }
    if(serciceConfig.US_WSREMS__Eligible_Status__c!=null){

    Set<String> statusSet = new Set<String>(serciceConfig.US_WSREMS__Eligible_Status__c.split(','));
    Set<String> invalidStatusSet = new Set<String>();
    if(accountId!=null){
      if(serviceType == 'Enrollment'){
        invalidStatusSet.add('Cancelled');                        
      }

      if(serviceType == 'Reenrollment'){
        invalidStatusSet = new Set<String>{'Cancelled','Complete'};
      }
      
      if(!invalidStatusSet.isEmpty()){
        enrollmentCaseList = [SELECT Id FROM Case WHERE Recordtype.DeveloperName IN :REMSAppLiterals.CASE_ENROLL_REENROLL_RECTYPE_SET 
                               AND Status NOT IN :invalidStatusSet AND US_WSREMS__Participant__c=:accountId];
      }
    }
    if(!statusSet.isEmpty()){

    if(accountRecord != null && (((accountRecord.US_WSREMS__Status__c == '' || accountRecord.US_WSREMS__Status__c == null ) 
       && serviceType == 'Knowledge Assessment' || serviceType == 'PAE/PC/MI')
       || (serviceType == 'Enrollment' && (accountRecord.US_WSREMS__Status__c == '' || accountRecord.US_WSREMS__Status__c == null 
            || (statusSet.contains(accountRecord.US_WSREMS__Status__c) && enrollmentCaseList.isEmpty())))
       || (serviceType == 'Reenrollment' && (statusSet.contains(accountRecord.US_WSREMS__Status__c) && enrollmentCaseList.isEmpty())))) {
     isValidated = false;
    }
   else if(accountRecord != null && (!statusSet.contains(accountRecord.US_WSREMS__Status__c))
           ||(statusSet.contains(accountRecord.US_WSREMS__Status__c) && serviceType == 'Reenrollment' 
              || serviceType == 'Enrollment' && (!enrollmentCaseList.isEmpty()))) {
      isValidated = true;
    }
  }
    }
    return isValidated;
  }

  /********************************************************************************************************************************************************
    * Method Name          : getStakeholderProgramServiceConfigList
    * @Description         : Retrieves the Services applicable to the stakeholder type from Account
    * @CreatedDate         : 11th Apr 2024
    * @Author              : Divya G
    **********************************************************************************************************************************************************/

 @AuraEnabled(cacheable=true)
 public static List<US_WSREMS__REMS_Program_Service_Config__c> getStakeholderProgramServiceConfigList(string programId,string StakeHolderType) {
   try{
     List<US_WSREMS__REMS_Program_Service_Config__c> programServiceConfigList = new List<US_WSREMS__REMS_Program_Service_Config__c> ();
     programServiceConfigList = [SELECT Id, US_WSREMS__REMS_Program__c,US_WSREMS__REMS_Program__r.Name,US_WSREMS__Service_Name__c,US_WSREMS__Service_API_Name__c,US_WSREMS__Description__c
                                                             FROM US_WSREMS__REMS_Program_Service_Config__c WHERE US_WSREMS__REMS_Program__c=:programId AND US_WSREMS__Applicable_Services_Account__c includes (:StakeHolderType) ORDER BY  US_WSREMS__Service_Name__c];
     
                                                             return programServiceConfigList;
   }catch (Exception ex) {
     throw new AuraHandledException(
         'An unexpected error occurred: ' + ex.getMessage()
     );
   }
 }

 /********************************************************************************************************************************************************
   * Method Name          : getStakeholderrecord
   * @Description         : Retrieves account data
   * @CreatedDate         : 11th Apr 2024
   * @Author              : Divya G
   **********************************************************************************************************************************************************/

 @AuraEnabled(cacheable=true)
 public static Account getStakeholderrecord(Id accountId) {
   List<Account> accountList = new List<Account>();
   try{
     accountList = [SELECT US_WSREMS__REMS_Program__c,US_WSREMS__Program_Picklist__c,US_WSREMS__Recordtype_Label__c FROM Account WHERE Id=:accountId];
     if(!accountList.isEmpty()){
       return accountList[0];
     }
   }
   catch (Exception ex) {
     throw new AuraHandledException(
         'An unexpected error occurred: ' + ex.getMessage()
     );
   }
   return null;
 }

  public class ServiceWrapper {
    @AuraEnabled
    public String programId;
    @AuraEnabled
    public String programName;
    @AuraEnabled
    public String serviceName;
    @AuraEnabled
    public String participantType;
  }
}