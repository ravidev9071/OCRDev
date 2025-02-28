/**
* @File Name          : REMSPortalRolePickListTest.cls
* @Description        : This class for under REMSPortalRolePickList.
* @Author             : Shikha Chaurasia
* @Date               : 29-06-2022
**/

@IsTest public with sharing class REMSPortalRolePickListTest {
    @IsTest() static void getREMSPortalRolePickList() {
        REMSPortalRolePickList portalRoleObj=new REMSPortalRolePickList();
        VisualEditor.DynamicPickListRows rows=portalRoleObj.getValues();
        VisualEditor.DataRow defaultValue=portalRoleObj.getDefaultValue();
        System.assertNotEquals(null, rows);
        //system.assert(!rows.isEmpty());
    }

}