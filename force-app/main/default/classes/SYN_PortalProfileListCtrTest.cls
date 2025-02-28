/**
* @File Name          : REMSPortalProgramPickListTestCtrTest.cls
* @Description        : This class give us control to add dynamic picklist of Profile.
* @TestClass          : 
* @Author             : Thandavakrishna Dindu
* @Date               : 02-12-2022
**/
@isTest
private class SYN_PortalProfileListCtrTest{
    
    @IsTest() 
    static void PortalProfileListCtrTest() {
        List<Profile>  prf = [SELECT Id,Name FROM Profile WHERE UserType ='PowerCustomerSuccess'];
        Test.StartTest();
            SYN_PortalProfileListCtr portalProfileListCtr=new SYN_PortalProfileListCtr();
            VisualEditor.DynamicPickListRows rows=portalProfileListCtr.getValues();
            VisualEditor.DataRow defaultValue=portalProfileListCtr.getDefaultValue();
            System.assertNotEquals(null, rows);
        Test.StopTest();
    }
    }