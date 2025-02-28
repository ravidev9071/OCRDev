/**
* @File Name          : REMSPortalProgramPickListTestCtr.cls
* @Description        : This class for under REMSPortalProgramPickListCtr.
* @Author             : Shikha Chaurasia
* @Date               : 29-06-2022
**/

@IsTest 
private class REMSPortalProgramPickListTestCtr {
    
    @IsTest() 
    static void getREMSPortalProgramPickList() {
        US_WSREMS__REMS_Program__c programObj =new US_WSREMS__REMS_Program__c();
        programObj.Name='Test0003';
        insert programObj;   
        REMSPortalProgramPickListCtr portalProgramObj=new REMSPortalProgramPickListCtr();
        VisualEditor.DynamicPickListRows rows=portalProgramObj.getValues();
        VisualEditor.DataRow defaultValue=portalProgramObj.getDefaultValue();
        System.assertNotEquals(null, rows);
    }
    
}