public class SYN_REMSbigObjectCreateProcessQueuable implements Queueable, Database.AllowsCallouts 
{    
    private string objAPIName;
    public SYN_REMSbigObjectCreateProcessQueuable(string objectAPIName)
    {
        this.objAPIName = objectAPIName;
    }
    public void execute(QueueableContext qc)
    {          
           SYN_REMSBigObjectMetaDataService.createBigObjectMetadata(objAPIName);
    }
}