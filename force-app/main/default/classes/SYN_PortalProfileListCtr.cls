/**
* @File Name          : SYNPortalProfileListCtr .cls
* @Description        : This class give us control to add dynamic picklist of Profile.
* @TestClass          : 
* @Author             : Thandavakrishna Dindu
* @Date               : 17-11-2022
**/


global class SYN_PortalProfileListCtr extends VisualEditor.DynamicPickList{
    global override VisualEditor.DataRow getDefaultValue(){
        List<Profile> profileList=[Select id,Name from Profile];
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(profileList[0].Name, String.ValueOf(profileList[0].Id));
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  profilePickListValues = new VisualEditor.DynamicPickListRows();
        List<Profile> programList=[Select id,Name from Profile];
        for(Profile profileObj:programList)
        {
            VisualEditor.DataRow profilePickListValue = new VisualEditor.DataRow(profileObj.Name, String.ValueOf(profileObj.Id)); 
            profilePickListValues.addRow(profilePickListValue);
        }
        return profilePickListValues;
    }
}