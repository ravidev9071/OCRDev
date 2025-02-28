/**
* @File Name          : SYN_UserTrigger
* @Handler            : SYN_UserTriggerHanlder
* @Modification Log   :
* Ver       Date            Developer                        Modification
* 1.0    01/18/2023        Ismail (Wilco)             Initial Implementation
**/

trigger SYN_UserTrigger on User (before update) {
    if (trigger.isBefore){
        if (trigger.isUpdate){
		   SYN_UserTriggerHandler.beforeupdateHandler(Trigger.oldMap,Trigger.newMap); 
        }
    }   
}