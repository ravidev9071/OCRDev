/**
* @File Name          : MapLocatorSearchController.cls
* @Description        : This class search accounts .
* @TestClass          : MapLocatorSearchController_Test
* @Author             : Wilco
* @Date               : 29-10-2024
**/
public without sharing class MapLocatorSearchController {

    public static decimal dLatitude, dLongitude;
    public static string serviceMap = '';
    public static string outPatientPharmacy = 'Outpatient Pharmacy';
    public static string inPatientPharmacy = 'Inpatient Pharmacy';

     /** 
     * This enum constant value is used for program names.
     * Whenever a new program is added, it should be added to this enum definition, 
     * to support the map locator service for the new program     
     */
    public enum programNameConstant{
        TRYVIO,
        MACI, 
        PIASKY,
        XIAFLEX,
        AVEED
    }

    /** 
     * This enum constant value is used for program constants.     
     */
    public enum programConstants{
        Prescribers,
        Prescriber, 
        Certified
    }

    /** 
     * This enum constant value is used for service map provider names.     
     */
    public enum serviceMapProvider{
        AZURE,
        GOOGLE
    }

     /**
     *
     * This method return the Application Program Name which matches the condition check.
     *
     * @param programName The value is holding short form of application program name.
     *  
     * @return String  An application full program name.
     *
     */
    public static String getProgramName(String programName) {
        if(String.isBlank(programName) || programName.contains(String.valueOf(programNameConstant.TRYVIO))){
            return Label.Tryvio_REMS_Program_Name;
        }else if(programName.contains(String.valueOf(programNameConstant.MACI))){
            return Label.Macitentan_REMS_Program_Name;
        }else if(programName.contains(String.valueOf(programNameConstant.PIASKY))){
            return Label.PiaSky_REMS_Program_Name;
        }else if(programName.contains(String.valueOf(programNameConstant.XIAFLEX))){
            return Label.Xiaflex_REMS_Program_Name;
        }else if(programName.contains(String.valueOf(programNameConstant.AVEED))){
            return Label.AVEED_REMS_Program_Name;
        }
        return Label.Tryvio_REMS_Program_Name;
    }

     /**
     *
     * This method return the Application map provider name which matches the condition check.
     *
     * @param serviceMap The value is holding short form of application map provider name.
     *  
     * @return String  An application full map provider name.
     *
     */
     public static String getServiceMapProvider(String serviceMap) {
        if(String.isBlank(serviceMap) || serviceMap.contains(String.valueOf(serviceMapProvider.AZURE))){
            return String.valueOf(ProviderFactory.MapProvider.AZURE_MAPS);
        }else if(serviceMap.contains(String.valueOf(serviceMapProvider.GOOGLE))){
            return String.valueOf(ProviderFactory.MapProvider.GOOGLE_MAPS);
        }
        return String.valueOf(ProviderFactory.MapProvider.AZURE_MAPS);
    }

    /**
     * Searches for Account records based on specified criteria.
     *
     * This method retrieves a list of Account records that match the provided 
     * inputValue, participantType, searchType, and within a specified radius. 
     * The search may filter accounts based on their attributes and geographic 
     * location, depending on the business logic implemented.
     *
     * @param inputValue The value to search for, which can be an address or zipcode of the Account.
     * @param participantType The type of participant to filter the results, such as 
     *                        'Prescriber' or 'In/Out Pharmacy'.
     * @param searchType The specific type of search to perform, which could influence 
     *                   the parameters used in filtering (e.g., 'Lookup', 'locator').
     * @param radius The radius within which to search for accounts, typically represented 
     *               in miles , to restrict results to nearby accounts.
     * @param appProgramName This parameter is to filter out by program name records.
     *      
     * @return List<Account> A list of Account records that match the search criteria. 
     *                       Returns an empty list if no matching accounts are found.     
     * Example usage:
     * <pre>
     *   List<Account> accounts = searchRecords('1453 JP St, LA, US 90001', 'Prescriber', 'Locator', '50');
     * </pre>
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> searchRecords(String inputValue,String participantType, string searchType, string radius, string appProgramName, string serviceAssigned) {
        List<Id> recordtypeIdList = new List<Id>();
        String queryString = '', baseQuery = '';
        String programName = getProgramName(appProgramName);               
                
        if (!String.isEmpty(participantType)) {
            if(participantType == string.valueOf(programConstants.Prescribers)){
                recordtypeIdList.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(string.valueOf(programConstants.Prescriber)).getRecordTypeId());
            }
            else{
                recordtypeIdList.add(SObjectType.Account.getRecordTypeInfosByName().get(outPatientPharmacy).getRecordTypeId());
                recordtypeIdList.add(SObjectType.Account.getRecordTypeInfosByName().get(inPatientPharmacy).getRecordTypeId());
            }
        }
        
        String statusCertified = string.valueOf(programConstants.Certified);
        List<String> conditions = new List<String>();
      
      
        if (!String.isEmpty(inputValue)) {
            if(searchType.equals('Lookup')) {
                baseQuery =   'Select Id, Name, Recordtype.name, FirstName, LastName, ' +
                                'SYN_Ref_Id__c, ShippingStreet, US_WSREMS__Address_Line_1__c, ' +
                                'US_WSREMS__City__c, US_WSREMS__State__c, US_WSREMS__Zip__c, ' +
                                'ShippingCountry, US_WSREMS__NPI__c, Phone, Fax, Type, ' +
                                'US_WSREMS__National_Provider_Identifier__c ' +
                                'FROM Account WHERE RecordTypeId IN :recordtypeIdList ' +
                                'AND Program_Name__c=\'\'{0}\'\' ' +
                                'AND US_WSREMS__Status__c =\'\'{1}\'\' AND ';
                conditions.add(' Name LIKE \'\'%{2}%\'\'');
                conditions.add(' US_WSREMS__National_Provider_Identifier__c LIKE \'\'%{2}%\'\'');
                conditions.add(' US_WSREMS__NPI__c LIKE \'\'%{2}%\'\'');
                conditions.add(' US_WSREMS__State__c LIKE \'\'%{2}%\'\'');
                conditions.add(' US_WSREMS__Zip__c LIKE \'\'%{2}%\'\'');
                baseQuery = baseQuery +' ('+ String.join(conditions, ' OR ')+') Limit 100';
            } else if(searchType.equals('Locator')) { 
                
                serviceMap = serviceAssigned; 
                getGeolocation(inputValue);
                radius = radius.replace('miles','');                

                baseQuery =  'Select Id,Account__r.Name,Account__r.Recordtype.name,Account__r.FirstName, '+ 
                                'Account__r.LastName, Account__r.SYN_Ref_Id__c,Account__r.ShippingStreet, '+
                                'Account__r.US_WSREMS__Address_Line_1__c, Account__r.US_WSREMS__City__c,'+
                                'Account__r.US_WSREMS__State__c,Account__r.US_WSREMS__Zip__c, '+
                                'Account__r.ShippingCountry,Account__r.US_WSREMS__NPI__c,Account__r.Phone, '+
                                'Account__r.Fax, Account__r.Type,Account__r.US_WSREMS__National_Provider_Identifier__c, '+
                                'DISTANCE(Location__c, GEOLOCATION({3},{4}), \'mi\') miles '+
                                'FROM Lead WHERE Account__r.RecordTypeId IN : recordtypeIdList AND '+
                                'Account__r.Program_Name__c =\'\'{0}\'\' AND Account__r.US_WSREMS__Status__c =\'\'{1}\'\' AND '+       
                                '(DISTANCE(Location__c, GEOLOCATION({3},{4}), \'mi\') < {5}) '+
                                'ORDER BY DISTANCE(Location__c, GEOLOCATION({3},{4}), \'mi\') LIMIT 10';
            }
        }
      
        queryString = String.format(baseQuery, new List<String>{ programName, statusCertified, inputValue, String.valueOf(dLatitude), String.valueOf(dLongitude), radius});
        system.debug(LoggingLevel.DEBUG +'QueryString == '+queryString);
		return Database.query(queryString);
	}

    /**
     * Helper method retrieves the geolocation information for a specified location.
     *    
     * @param searchLocation A string representing the location for which geolocation is to be fetched.
     *                      This could be a city name, a full address, or a set of coordinates.     
     *
     */
    Public static void getGeolocation(string searchLocation){
        
         // Create a map context
        MapContext mapContext = new MapContext(searchLocation); // Example: San Francisco
        // consuming the provider
        IMapProvider provider = ProviderFactory.getMapProvider(getServiceMapProvider(serviceMap));
        provider.mapCoordinates(mapContext);

        dLongitude = (decimal) mapContext.longitude;
        dLatitude = (decimal) mapContext.latitude;        
        
    }
}