/**
* @File Name : ProviderFactory.cls
* @Description : This class is responsible for creating instances of different provider classes based on given parameters.
* @Author : Wilco
* @Last Modified By : Wilco
* @Last Modified On : October 29, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 29, 2024 |   | Initial Version
**/

public class ProviderFactory {

    /** 
     * This enum constant value is used for map provider names.     
     */
    public enum MapProvider{
        GOOGLE_MAPS,
        GOOGLE_MAPS_ENDPOINTURL,
        GOOGLE_MAPS_ACCESSTOKEN,
        AZURE_MAPS,
        AZURE_MAPS_ENDPOINTURL,
        AZURE_MAPS_ACCESSTOKEN
    }

    
    /**
     * Gets the map provider instance used for rendering maps.
     *
     * This method returns an instance of a map provider that can be used
     * to display geographical data such as markers, routes, or other
     * geographical features on a map interface.
     *
     * @return MapProvider The current map provider instance.
     *         Returns null if no map provider has been initialized.
     *      
     */
	 public static IMapProvider getMapProvider(String providerName) {
        AppSetting__c endpoint = AppSetting__c.getInstance(providerName);

        if(endpoint == null || endpoint.value__c == null) return null;
        
        Type t = Type.forName(endpoint.value__c);
        IMapProvider provider = (IMapProvider)t.newInstance();
        return provider;
    }
}