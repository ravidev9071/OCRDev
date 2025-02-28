/**
* @File Name : UpdatePrescriberEnrollment.cls
* @Description : This class is used to update the Office Contact lookup
* @Author : Wilco
* @Last Modified By : Wilco
* @Last Modified On : November 27, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 27, 2024 |   | Initial Version
**/

public class UpdatePrescriberEnrollment {
     
    /**
     * Method to create office contact records
     *
     * @param requests create case records
     */
    
    @invocableMethod
    public static void updateOCLookup(List<updateOCLookups> requests){
        list<Case> casesToUpdate =new List<Case>();
        for(updateOCLookups req:requests){
            case caseRecord= new case(Id = req.caseId,
                                 US_WSREMS__Office_Contact__c=req.primaryOC,
                      US_WSREMS__Secondary_Office_Contact__c=req.secondaryOC);
            casesToUpdate.add(caseRecord);
        }
        try{
                US_WSREMS.REMSAvoidRecursiveCls.stop_tasktrigger = true;
                US_WSREMS.REMSAvoidRecursiveCls.stop_caseUpdate  = true; 
                US_WSREMS.REMSAvoidRecursiveCls.stop_TaskCreation = true;
           update casesToUpdate;
            
        }catch (Exception e){
            system.debug('Error updating Lookup fields:::'+e.getMessage());
           
        }
        
    }
    public class updateOCLookups{
        @InvocableVariable
        public Id caseId;
          @InvocableVariable
        public Id primaryOC;
          @InvocableVariable
        public Id secondaryOC;
    }

}