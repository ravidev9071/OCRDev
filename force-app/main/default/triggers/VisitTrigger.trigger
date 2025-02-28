trigger VisitTrigger on Visit (after insert, after update) {
    /*
    List<VisitShare> visitShares = new List<VisitShare>();
    for(Visit visit : trigger.new) {
        if(trigger.isUpdate) {
             Visit oldVisit = trigger.oldMap.get(visit.Id);
             VisitAccess.updateVisitAccess(oldVisit, visit, 'edit');
        }
        if(trigger.isInsert) {
            VisitAccess.insertVisitAccess(visit, visit.VisitorId, 'edit');
        }
    }*/
}