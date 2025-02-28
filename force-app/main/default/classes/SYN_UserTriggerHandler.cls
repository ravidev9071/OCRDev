/**
* @File Name          : SYN_UserTriggerHandler.cls
* @Description        : This is used as a Hanlder for User trigger.
* @Trigger            : SYN_UserTrigger
* @Author             : Wilcosource
* @Modification Log   :
* Ver  Date  Developer  Modification
* 1.0  01/19/2023  Ismail (Wilco)  Initial Implementation (updateUser) 
**/
public class SYN_UserTriggerHandler {    

    public static void beforeupdateHandler(Map<Id, User> oldUserMap, Map<id,User> newUserMap) {

        List<Id> userIds = new List<Id>();

        for(User userRec: newUserMap.values()) {

            if(userRec.Program__c != 'Macitentan REMS' && userRec.Email != NULL && userRec.Email != oldUserMap.get(userRec.id).Email && userRec.isPortalEnabled == TRUE && !system.isFuture()) {

                  userRec.UserName = userRec.Email+'.'+userRec.UserName.substringAfterLast('.');
            }
            
        }
         
        
    }
}