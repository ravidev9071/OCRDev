/*  Created by: Wilco
    Description: This Trigger will be inserting record in Big Object
    
*/

trigger OnAsyncRequestTrigger on AsyncRequest__e (after insert) {

    Map<String, list<sObject>> objectListMap = new Map<String, list<sObject>>();
    for(AsyncRequest__e asyncRecord : trigger.new) {
        String mapKey = asyncRecord.Object_API_Name__c+'#'+asyncRecord.Action_Type__c;
        list<sObject> lstSObjectData = (List<sObject>) JSON.deserialize(asyncRecord.Serialized_List__c, List<sObject>.class);
        //Check if the key exists in the map
        if (objectListMap.containsKey(mapKey)) {
            //If the key exists, update the existing list and add it back to the map
           List<sObject> existingList = objectListMap.get(mapKey);
            existingList.addAll(lstSObjectData);
            objectListMap.put(mapKey, existingList);
        } else {
            objectListMap.put(mapKey, lstSObjectData);
        }
    }

    for (String key : objectListMap.keySet()) {
        String objAPIName = key.substringBefore('#');
        String dataActionType = key.substringAfter('#');
        SYN_REMSBigObjectDataInsertProcess.processInfo(objectListMap.get(key),objAPIName,dataActionType);
    }
    
    
}