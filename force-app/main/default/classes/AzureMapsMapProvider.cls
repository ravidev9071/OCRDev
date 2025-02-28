/**
* @File Name : AzureMapsMapProvider.cls
* @Description : This class is responsible for a api callout and return the map coordinates.
* @Author : Wilco
* @Last Modified By : Wilco
* @Last Modified On : October 29, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 29, 2024 |   | Initial Version
**/

public without sharing class AzureMapsMapProvider implements IMapProvider {

    /** 
     * This enum constant value is used for api callout query params.     
     */
    public enum QueryParams{
        ENCODED_QUERY,
        SUBSCRIPTION_KEY,
        US
    }

    /** 
     * This enum constant value is used for api callout response params.     
     */
    public enum ResponseParams{
        results,
        position,
        lon,
        lat
    }

    /**
     * Retrieves the geographical location (latitude and longitude) based on the given context.
     *
     * This method interacts with the provided MapContext to extract the prescriber or pharamacy address
     * geolocation. 
     *
     * @param context The MapContext object containing the searchText of address to fetch geolocation.     * 
     *         The context object containing the latitude and longitude. If the location 
     *         cannot be determined, the method may return null.
     *      
     */
	public void mapCoordinates(MapContext context) {		
        
		AppSetting__c endPointUrl = AppSetting__c.getInstance(String.valueOf(ProviderFactory.MapProvider.AZURE_MAPS_ENDPOINTURL));
        AppSetting__c endpointAccessToken = AppSetting__c.getInstance(String.valueOf(ProviderFactory.MapProvider.AZURE_MAPS_ACCESSTOKEN));
        if(endPointUrl != null && endPointUrl.value__c != null && endpointAccessToken != null && endpointAccessToken.value__c != null){
            string subscriptionKey = endpointAccessToken.value__c; 
            // Encode the query string for URL
            String encodedQuery = EncodingUtil.urlEncode(context.searchText+' '+QueryParams.US, 'UTF-8');
            string strEndpointURL = endPointUrl.value__c.replace(String.valueOf(QueryParams.ENCODED_QUERY),encodedQuery);
            strEndpointURL = strEndpointURL.replace(String.valueOf(QueryParams.SUBSCRIPTION_KEY),subscriptionKey);
            HttpResponse response ;
            
            // Sending a GET request
            if(Test.isRunningtest()){
                HTTPRequest request;
                response = HttpClientCalloutMock.respond(request);
            }else {           
                response = HttpClient.sendRequest(HttpClient.HttpMethod.GET, strEndpointURL, null, null);
            }
                
            // If the request is successful, parse the JSON response.
            if(response.getStatusCode() == 200 && !String.isBlank(response.getBody())) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if(!results.isEmpty()){
                    List<Object> address = (List<Object>) results.get(String.valueOf(ResponseParams.results));
                
                    for(Object feature: address) {
                    map<string,Object> mapFeature = (map<string,Object>) feature;
                        if(mapFeature.containskey(String.valueOf(ResponseParams.position))){
                            map<string,Object> mapPosition = (map<string,object>)mapFeature.get(String.valueOf(ResponseParams.position));                
                            context.longitude = (decimal) mapPosition.get(String.valueOf(ResponseParams.lon));
                            context.latitude = (decimal) mapPosition.get(String.valueOf(ResponseParams.lat));

                            break;
                        }
                    }
                }
            }
            else{
                system.debug(LoggingLevel.ERROR, 'Http response '+ response.getStatusCode() );
            }
        }
    }
}