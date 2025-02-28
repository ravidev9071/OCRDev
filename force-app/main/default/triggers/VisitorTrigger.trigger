trigger VisitorTrigger on Visitor (after insert, after update, after delete) {
    /*
    if(trigger.isInsert) {
        for(Visitor visitor : trigger.new) {
            VisitAccess.insertVisitAccess(new Visit(id=visitor.VisitId), visitor.AssigneeId, 'edit');
        }
    }
    
    if(trigger.isUpdate) {
         for(Visitor visitor : trigger.new) {
            Visitor oldVisitor = trigger.oldMap.get(visitor.Id);
            VisitAccess.updateVisitAccess(new Visit(id=oldVisitor.VisitId), new Visit(id=visitor.VisitId), visitor.AssigneeId, 'edit');
        }
    }
    
    if(trigger.isDelete) {
        for(Visitor visitor : trigger.old) {
            VisitAccess.deleteVisitAccess(new Visit(id=visitor.VisitId), visitor.AssigneeId);
        }
    }*/
}