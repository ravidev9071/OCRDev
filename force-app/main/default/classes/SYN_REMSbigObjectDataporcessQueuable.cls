public class SYN_REMSbigObjectDataporcessQueuable implements Queueable 
{    
    private list<sObject> lstSObjectData;
    private string objAPIName;
    private string dataActionType;
    public SYN_REMSbigObjectDataporcessQueuable(list<sobject> lstObjData, string objectAPIName, string dataActionType)
    {
        this.lstSObjectData = lstObjData;
        this.objAPIName = objectAPIName;
        this.dataActionType = dataActionType;
    }
    public void execute(QueueableContext qc)
    {          
           SYN_REMSBigObjectDataInsertProcess.processInfo(lstSObjectData,objAPIName,dataActionType);
    }
}