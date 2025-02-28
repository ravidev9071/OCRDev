/**
* @File Name : MapContext.cls
* @Description : This class provides the context for the provider.
* @Author : Wilco
* @Last Modified By : Wilco
* @Last Modified On : October 29, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 29, 2024 |   | Initial Version
**/

public without sharing class MapContext {
	
	// Attributes for map context like latitude, longitude
    public double latitude;
    public double longitude;
	public String searchText;

    /**
     * Constructor for the MapContext class.
     *
     * @param searchText A String representing the search text used to filter or locate data.
     *                   This parameter is utilized to initialize the MapContext instance 
     *                   and may be used in various operations throughout the class.
     *                   It should be a relevant term or phrase based on which the mapping 
     *                   context will be constructed.
     */
	public MapContext(String searchText) {
        this.searchText = searchText;
    }

}