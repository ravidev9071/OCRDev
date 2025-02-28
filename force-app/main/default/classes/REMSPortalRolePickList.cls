/**
* @File Name          : REMSPortalRolePickList.cls
* @Description        : This class give us control to add dynamic picklist of Portal role under LWC property.
* @TestClass          : 
* @Author             : Shikha Chaurasia
* @Date               : 27-05-2022
**/
 global class REMSPortalRolePickList extends VisualEditor.DynamicPickList{
    
        global override VisualEditor.DataRow getDefaultValue(){
            VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Prescriber', 'PRESCRIBER');
            return defaultValue;
        }
        global override VisualEditor.DynamicPickListRows getValues() {
            VisualEditor.DataRow value1 = new VisualEditor.DataRow('Prescriber', 'PRESCRIBER');
            VisualEditor.DataRow value2 = new VisualEditor.DataRow('Pharmacy', 'PHARMACY');
            VisualEditor.DataRow value3 = new VisualEditor.DataRow('Public', 'Public');
            VisualEditor.DataRow value4 = new VisualEditor.DataRow('Outpatient Pharmacy', 'Outpatient Pharmacy');
            VisualEditor.DataRow value5 = new VisualEditor.DataRow('Inpatient Pharmacy', 'Inpatient Pharmacy');
            VisualEditor.DataRow value6 = new VisualEditor.DataRow('Office Contact', 'Office Contact');


            VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
            myValues.addRow(value1);
            myValues.addRow(value2);
            myValues.addRow(value3);
            myValues.addRow(value4);
            myValues.addRow(value5);
            myValues.addRow(value6);

            return myValues;
        }
    }