/**
* @author     Rajadurai Kalyanasundaram
* @date       02/02/2023
* @decription Utility class to generate the dynamic inner query
*/
public class SYN_QueryUtil {
 
    /**
    * @method getInnerQuery
    * @param1 ParentObjectName
    * @param2 parentObjectRelationshipfields
    * @param3 Map of child objects API name and relationship name
    * @param4 Set of Id's
    * @param5 Query condition for parent query
    * @description Method  to build the dynamic inner query
    * @return  Query String
    */
    public static String getInnerQuery(String parentObjectAPIName, Map<String, String> objectAndFields, Set<String> parentObjectRelationshipfields, Map<String, String> childObjAPIAndRelName, Map<String, String> childObjectConditions, List<Id> parentRecordIdSet, String parentQueryCondition) {
     
     
        String parentObjFieldsString = '';
        if ( parentObjectRelationshipfields == NULL ) parentObjectRelationshipfields = new Set<String> ();
     
        if(objectAndFields != null && objectAndFields.containsKey(parentObjectAPIName)){
         
            parentObjFieldsString = objectAndFields.get(parentObjectAPIName);
        }else{
         
            parentObjFieldsString = getObjectFields(parentObjectAPIName);
        }
     
        if(parentObjectRelationshipfields != null && parentObjectRelationshipfields.size() > 0){
         
            parentObjFieldsString += ', '+( String.join ( new List<String> ( parentObjectRelationshipfields), ',' + ' ' ) );
        }
     
        List<String> innerQueryStringList = new List<String>();
        String combinedInnerQueryString = '';
        for(String childObjectAPIName : childObjAPIAndRelName.keySet()){
         
            String condition = (childObjectConditions != null && childObjectConditions.containsKey(childObjectAPIName)) ? childObjectConditions.get(childObjectAPIName): '';
            String objectFieldsString = '';         
            if(objectAndFields != null && objectAndFields.containsKey(childObjectAPIName)){
             
                objectFieldsString = objectAndFields.get(childObjectAPIName);
            }         
         
            innerQueryStringList.add('('+getQuery(childObjectAPIName, objectFieldsString, condition, childObjAPIAndRelName.get(childObjectAPIName), NULL)+')');
        }
     
        combinedInnerQueryString = ( String.join ( new List<String> (innerQueryStringList), ',' + ' ' ) );
        String queryValue = 'SELECT ' + parentObjFieldsString + ','+ combinedInnerQueryString + ' FROM '+ parentObjectAPIName +' WHERE Id IN:parentRecordIdSet ';
     
        if(String.isNotBlank(parentQueryCondition)){
         
            // In the parent query, if we have only Order By we don't need to add 'AND' operator       
            if(parentQueryCondition.startsWithIgnoreCase('Order')){
             
                queryValue += ' '+parentQueryCondition;
            }else{
                queryValue += ' AND '+parentQueryCondition;
            }
        }     
        return queryValue;
    } 
 
    /**
    * @method getQuery
    * @param1 Object name
    * @param2 Set of relationship fields
    * @param3 Query condition
    * @param4 Child object relationship name
    * @description Method  to build the dynamic query
    * @return  Query String
    */
    public static String getQuery(String objectName, String fieldString, String condition, String relationshipName, Set<String> relationshipFields ) {
     
        String objFieldsString = '';
        if ( String.isNotBlank(fieldString) ){
         
            objFieldsString = fieldString;
        }else{
         
            objFieldsString = getObjectFields(objectName);
        }
        
        if(relationshipFields != NULL && (!relationshipFields.isEmpty())){
        
            String relFieldString = String.join ( new List<String> ( relationshipFields), ',' + ' ' ) ;
            objFieldsString += ', '+ relFieldString;
        }
     
        List<String> strings = new List<String> ();
        strings.add ( 'SELECT ' );
        strings.add ( objFieldsString );
        strings.add ( 'FROM' );
        // relationshipName -> To build the inner query
        // objectName -> To build direct/parent object query
        if(String.isNotBlank(relationshipName)){
         
            strings.add (relationshipName);
        }else{
         
            strings.add (objectName);
        }
     
        if (!String.IsBlank ( condition ) ) {
         
            strings.add ( condition );
        }
        return String.join (strings, ' ' );
    }
 
    public static String getObjectFields(String objectName){
     
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> items = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
        List<String> selectFields = new list<String>();
     
        if (items != null){
         
            for (Schema.SObjectField ft : items.values()){ // loop through all field tokens (ft)
             
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){
                 
                    selectFields.add(fd.getName());
                }
            }
        }     
        return ( String.join ( new List<String> ( selectFields), ',' + ' ' ) );
    }
}