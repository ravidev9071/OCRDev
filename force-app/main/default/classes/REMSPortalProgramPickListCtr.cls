/**
* @File Name          : REMSPortalProgramPickListCtr.cls
* @Description        : This class give us control to add dynamic picklist of REMS program under LWC property.
* @TestClass          : 
* @Author             : Shikha Chaurasia
* @Date               : 28-05-2022
**/


global class REMSPortalProgramPickListCtr  extends VisualEditor.DynamicPickList{
    global override VisualEditor.DataRow getDefaultValue(){
        List<US_WSREMS__REMS_Program__c> programList=[Select id,Name from US_WSREMS__REMS_Program__c];
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(programList[0].Name, String.ValueOf(programList[0].Id));
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  programPickListValues = new VisualEditor.DynamicPickListRows();
        List<US_WSREMS__REMS_Program__c> programList=[Select id,Name from US_WSREMS__REMS_Program__c];
        for(US_WSREMS__REMS_Program__c programObj:programList)
        {
            VisualEditor.DataRow programPickListValue = new VisualEditor.DataRow(programObj.Name, String.ValueOf(programObj.Id)); 
            programPickListValues.addRow(programPickListValue);
        }
        return programPickListValues;
    }
}