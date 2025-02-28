public class SYN_ContentDocumentLinkTriggerHandler {
    
    public static void onAfterInsert(list<ContentDocumentLink> contDocList) {
        
        
        Set<Id> contDocId = new set<Id>();
        set<Id> contLinkIds = new set<Id>();
        Map<Id,List<ContentDocumentLink>> map_contentVersion=new Map<Id,List<ContentDocumentLink>>();
        List<ReceivedDocument> updateFieldIdInRD = new List<ReceivedDocument>();
        for(ContentDocumentLink cdl : contDocList) { 
            
            Schema.SObjectType sobjType = cdl.LinkedEntityId.getsobjecttype();
            if( String.valueOf(sobjType)=='ReceivedDocument'){
                updateFieldIdInRD.add(
                    
                    new ReceivedDocument(
                        Id = cdl.LinkedEntityId,
                        Related_File_Id__c = cdl.ContentDocumentId
                    )
                );
            }else if( String.valueOf(sobjType)=='DocumentChecklistItem'){
                contDocId.add(cdl.ContentDocumentId);
                contLinkIds.add(cdl.LinkedEntityId);
            }else if(String.valueOf(sobjType)=='j2g_fax__efax__c'){
                if(! map_contentVersion.keyset().contains(cdl.LinkedEntityId)){
                    List<ContentDocumentLink> newList=new List<ContentDocumentLink>();
                    newList.add(cdl);
                    map_contentVersion.put(cdl.LinkedEntityId,newList);
                    
                }else{
                    List<ContentDocumentLink> contentList=map_contentVersion.get(cdl.LinkedEntityId);
                    contentList.add(cdl);
                    map_contentVersion.put(cdl.LinkedEntityId,contentList);
                }
                
            } 
        }
        
        if(!updateFieldIdInRD.isEmpty()){
            
            update updateFieldIdInRD;
        }
        
        if(map_contentVersion.keySet().size()>0){
            getEfaxrecords(map_contentVersion.keySet(),map_contentVersion);
        }
        
        if(contDocId.size()>0){
            
            map<Id,DocumentChecklistItem> mapDocumentDetail=new map<Id,DocumentChecklistItem>([SELECT Id,Name FROM DocumentChecklistItem where Id IN :contLinkIds ]);
            map<Id, ContentDocument> mapContentDocuments = new map<Id, ContentDocument>([SELECT Id, Title, FileExtension FROM ContentDocument WHERE Id IN :contDocId]);
            list<ContentDocument> listUpdate = new list<ContentDocument>();
            for(ContentDocumentLink cdlIterator : contDocList) 
            {
                ContentDocument objCntDoc = mapContentDocuments.get(cdlIterator.ContentDocumentId);
                String strFilename = null;
                if(mapDocumentDetail.containsKey(cdlIterator.LinkedEntityId)){ 
                    strFilename=(mapDocumentDetail.get(cdlIterator.LinkedEntityId)).Name;
                }
                
                if(!String.isBlank(strFilename)) {
                    strFilename +='.'+ objCntDoc.FileExtension;
                    objCntDoc.Title = strFilename;
                    listUpdate.add(objCntDoc);
                } 
            }
            if(!listUpdate.isEmpty()) {
                update listUpdate;
            }
        }
        
        
    }
    
    public static void getEfaxrecords(set<id> efaxrecId, Map<Id,List<ContentDocumentLink>> map_contentVersion){
        Map<Id,ReceivedDocument> received_map=new Map<Id,ReceivedDocument>();
        List<ContentDocumentLink> contentDocumentList=new List<ContentDocumentLink>();
        
        List<j2g_fax__efax__c> faxes=[SELECT Id,Name,j2g_fax__To__c,j2g_fax__From__c,j2g_fax__eFax_Id__c , j2g_fax__TSID__c from j2g_fax__efax__c where Id IN:efaxrecId AND RecordType.Name='Received Fax'];
        for(j2g_fax__efax__c fax:faxes){
            ReceivedDocument rcd=createReceiveDocumentRecord(fax);
            received_map.put(fax.Id,rcd);
        }
        if(received_map.size()>0){
            insert received_map.values();
        }
        
        for(Id efaxsId:received_map.keySet()){
            
            if(received_map.keyset().contains(efaxsId) && map_contentVersion.keyset().contains(efaxsId)){
                for(integer i=0;i< map_contentVersion.get(efaxsId).size(); i++){
                    contentDocumentList.add(createContentDocumentLink((received_map.get(efaxsId)).Id,map_contentVersion.get(efaxsId)[i]));
                }
                
                
            }
            
        }
        if(contentDocumentList.size()>0){
            
            insert contentDocumentList;
        }
        
    }
    
    public static ContentDocumentLink createContentDocumentLink(Id recdocId,  ContentDocumentLink contentDoclinkId){
        
        ContentDocumentLink newclnk = contentDoclinkId.clone();
        newclnk.LinkedEntityId = recdocId;
        newclnk.ShareType = 'I';
        //conClone.add(newclnk);
        return  newclnk;       
    }
    public static ReceivedDocument createReceiveDocumentRecord(j2g_fax__efax__c efaxrec){
        
        ReceivedDocument rd = new ReceivedDocument();
        rd.name = efaxrec.Name;
        rd.Program_Fax_Number__c =  formatPhoneNumber(efaxrec.j2g_fax__To__c);
        rd.Fax_Number__c = efaxrec.j2g_fax__TSID__c; //efaxrec.j2g_fax__From__c;
        rd.DocumentNumber = efaxrec.j2g_fax__eFax_Id__c;
        rd.Status = 'Draft';
        return rd;
    }
    
    public static String formatPhoneNumber (string phoneNumStr){
        
        String PnumFormat ='';
        if (!String.isblank(phoneNumStr)){
            PnumFormat =  phoneNumStr.replaceAll('\\D', '');
            
            // removing 1 from the begining of the phone number
           /* if (phoneNumStr.startsWith('1')){
                PnumFormat = PnumFormat.substring(1);
            }*/
        }
        return PnumFormat;      
    }
}