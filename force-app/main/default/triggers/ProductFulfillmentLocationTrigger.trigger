trigger ProductFulfillmentLocationTrigger on ProductFulfillmentLocation (after insert, after update, after delete) {
  /*  if(trigger.isInsert) {
        for(ProductFulfillmentLocation location : trigger.new) {
            ProductFulfillmentLocationAccess.insertAccessToAllLocations(location, 'edit'); 
        }
    }
    
    if(trigger.isUpdate) {
        for(ProductFulfillmentLocation location : trigger.new) {
            ProductFulfillmentLocation oldLocation = trigger.oldMap.get(location.Id);
            ProductFulfillmentLocationAccess.updateAccess(oldLocation, location, 'edit'); 
        }
    }
    
    if(trigger.isDelete) {
        for(ProductFulfillmentLocation location : trigger.old) {
                ProductFulfillmentLocationAccess.deleteAccess(location);
        }
    }*/
}