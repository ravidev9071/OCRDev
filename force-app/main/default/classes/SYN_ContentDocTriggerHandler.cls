public class SYN_ContentDocTriggerHandler {
    
    public static void beforeDeleteHandler(List<ContentDocument> conDocOldList){
        
        if (! FeatureManagement.checkPermission('Allow_User_To_Delete_Files')){
            for(ContentDocument con : conDocOldList){
                con.addError(System.Label.File_Delete_Error_Msg );			
            }
        }
        
    }
}