/**
* @File Name          : RemsNewAccViaCase.cls
* @Description        : This is used as a Controller for RemsNewAccViaCase (Aura).
* @TestClass          : 
* @Author             : Wilcosource
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    03/12/2022        Chaitanya Nandamuri (Wilco)     OverRides New button on Account and display RecordType to create caseRecord.
**/
public class RemsNewAccViaCase {
    
     private
        static final Map<String, Schema.RecordTypeInfo> mapCaseRecordTypesByDeveloperName =
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    private
        static final Map<String, Schema.RecordTypeInfo> mapAccountRecordTypesByDeveloperName =
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    
    @AuraEnabled
    Public static  List<RCtypeAndRelatedInfoWrapper> getRecordTypeInfo(){
        List<RCtypeAndRelatedInfoWrapper> RCtypeWrapperLst = new List<RCtypeAndRelatedInfoWrapper>();
        for (RecordtypeToPageLayout__mdt  Rctype: [SELECT Id,MasterLabel,NamespacePrefix,Object_Name__c,PageLayout_Name__c,RecordType_Dev_Name__c,
            Record_Type_Label__c FROM RecordtypeToPageLayout__mdt ORDER BY Record_Type_Label__c ASC]){
            String RCtyname = Rctype.Record_Type_Label__c;
            Id RCtypeId = mapCaseRecordTypesByDeveloperName.get(Rctype.RecordType_Dev_Name__c).getRecordTypeId();
            String PGlayoutName = Rctype.PageLayout_Name__c ;
            RCtypeAndRelatedInfoWrapper RCWrap = new RCtypeAndRelatedInfoWrapper(RCtyname ,RCtypeId ,PGlayoutName );
            RCtypeWrapperLst.add(RCWrap);      
        }
         return RCtypeWrapperLst;
    }
    
    Public class RCtypeAndRelatedInfoWrapper{
        @AuraEnabled
        public String RCTypeName;
        @AuraEnabled
        public Id RCTypeId;
        @AuraEnabled
        public String PagelayoutName;
        
        public RCtypeAndRelatedInfoWrapper( String RCTypeName , Id RCTypeId ,String PagelayoutName){
            this.RCTypeName = RCTypeName;
            this.RCTypeId = RCTypeId;
            this.PagelayoutName = PagelayoutName;
        }
    }

}