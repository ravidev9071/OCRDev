/**
* @File Name : IMapProvider.cls
* @Description : This interface class is a method signature for mapCoordinates.
* @Author : Wilco
* @Last Modified By : Wilco
* @Last Modified On : October 29, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 29, 2024 |   | Initial Version
**/

public interface IMapProvider {	
	/**
	 * Maps the coordinates from the given context.
	 *
	 * This method takes in a context object which contains the necessary
	 * data to perform the mapping of coordinates. The implementation should
	 * ensure that the context is validated and transformed as needed.
	 *
	 * @param context An instance of MapContext providing the necessary context
	 *                for mapping the coordinates. This context should not be null.
	 *                It may contain properties like searchText.
	 */
	 void mapCoordinates(MapContext context);
}