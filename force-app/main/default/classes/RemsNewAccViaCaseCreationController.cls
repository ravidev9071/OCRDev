/**************************************************************************
    * Name :   RemsNewAccViaCaseCreationController 
    
    Modification Log:
    ----------------------------------------------------------------------------------
    Developer               Date                   Description
    -----------------------------------------------------------------------------------
    Thandavakrishna Dindu  8/12/2022             Initial Version
    *********************************************************************************/
public class RemsNewAccViaCaseCreationController {
    //Date  : 09/15/2024 changes added to resolve Duplicate record type issue from line 13 AND 14 by DILEEP G  
    
    private
        static final  Map<String,Id> mapCaseRecordTypesByDeveloperName = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Case');
    private
        static final  Map<String,Id> mapAccountRecordTypesByDeveloperName = REMSUtility.retrieveRecTypeDeveloperNameId_Product('Account');
    
    /********************************************************************************************************************************************************
    Method Name     : getRecordTypeInfo
    Description     : Fetches record types and page layouts based on Program.
    Date : 09/15/2024 changes added to resolve Duplicate record type issue from line 177 to 182 by DILEEP G  
   
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    Public static  List<RCtypeAndRelatedInfoWrapper> getRecordTypeInfo(String ProgramName , String ObjectName){
        List<RCtypeAndRelatedInfoWrapper> RCtypeWrapperLst = new List<RCtypeAndRelatedInfoWrapper>();
        for (US_WSREMS__Pagelayout_Configuration__mdt Rctype: [SELECT Id,MasterLabel,NamespacePrefix,US_WSREMS__Object_Name__c,US_WSREMS__PageLayout_Name__c,US_WSREMS__RecordType_Name__c
            FROM US_WSREMS__Pagelayout_Configuration__mdt WHERE US_WSREMS__Program__c = : ProgramName AND US_WSREMS__Object_Name__c = : ObjectName AND US_WSREMS__Requestor_Type__c = '' AND US_WSREMS__Rems_Service_RCtype__c = '' ORDER BY MasterLabel ASC]){
            String RCtyname = Rctype.MasterLabel;
            Id RCtypeId = mapCaseRecordTypesByDeveloperName.get(Rctype.US_WSREMS__RecordType_Name__c);
            String PGlayoutName = Rctype.US_WSREMS__PageLayout_Name__c;
			String programRecordType = ProgramName+'-'+mapCaseRecordTypesByDeveloperName.get(Rctype.US_WSREMS__RecordType_Name__c);
            RCtypeAndRelatedInfoWrapper RCWrap = new RCtypeAndRelatedInfoWrapper(RCtyname ,RCtypeId ,PGlayoutName,programRecordType);
            RCtypeWrapperLst.add(RCWrap);      
        }
         return RCtypeWrapperLst;
    }
    
     /********************************************************************************************************************************************************
    Method Name     : getCurrentUserProgram
    Description     : it returns current user program.
    ********************************************************************************************************************************************************** */
    @AuraEnabled
    Public static List<US_WSREMS__Program_Users__c> getCurrentUserProgram(){
         return SYN_CommonUtility.getCurrnetUserActivePrograms();
      
    }
    
    Public class RCtypeAndRelatedInfoWrapper{
        @AuraEnabled
        public String RCTypeName;
        @AuraEnabled
        public Id RCTypeId;
        @AuraEnabled
        public String PagelayoutName;
		@AuraEnabled
        public String programRecordType;
        
        public RCtypeAndRelatedInfoWrapper( String RCTypeName , Id RCTypeId ,String PagelayoutName,String programRecordType){
            this.RCTypeName = RCTypeName;
            this.RCTypeId = RCTypeId;
            this.PagelayoutName = PagelayoutName;
			this.programRecordType = programRecordType;
        }
    }

}