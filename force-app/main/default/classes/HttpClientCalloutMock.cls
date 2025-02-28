/**
* @File Name : HttpClientCalloutMock.cls
* @Description : This class is responsible for mock response.
* @Author : Wilco
* @Last Modified By : Wilco
* @Last Modified On : October 29, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 29, 2024 |   | Initial Version
**/
@isTest
public class HttpClientCalloutMock implements HttpCalloutMock {

    public static HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200); 
         // This is the JSON response string, as provided in your example.
         String jsonResponse = '{"summary": {' +
                                    '"query": "pa",' +
                                    '"queryType": "NON_NEAR",' +
                                    '"queryTime": 84,' +
                                    '"numResults": 10,' +
                                    '"offset": 0,' +
                                    '"totalResults": 10361,' +
                                    '"fuzzyLevel": 1' +
                                '},' +
                                '"results": [' +
                                    '{' +
                                        '"type": "Geography",' +
                                        '"id": "mwVJFp0GPo01GaOsAomazg",' +
                                        '"score": 1,' +
                                        '"entityType": "CountrySubdivision",' +
                                        '"matchConfidence": {' +
                                            '"score": 1' +
                                        '},' +
                                        '"address": {' +
                                            '"countrySubdivision": "PA",' +
                                            '"countrySubdivisionName": "Pennsylvania",' +
                                            '"countrySubdivisionCode": "PA",' +
                                            '"countryCode": "US",' +
                                            '"country": "United States",' +
                                            '"countryCodeISO3": "USA",' +
                                            '"freeformAddress": "Pennsylvania"' +
                                        '},' +
                                        '"position": {' +
                                            '"lat": 40.8967,' +
                                            '"lon": -77.83889' +
                                        '},' +
                                        '"viewport": {' +
                                            '"topLeftPoint": {' +
                                                '"lat": 42.51607,' +
                                                '"lon": -80.51985' +
                                            '},' +
                                            '"btmRightPoint": {' +
                                                '"lat": 39.71978,' +
                                                '"lon": -74.68952' +
                                            '}'+
                                        '},' +
                                        '"boundingBox": {' +
                                            '"topLeftPoint": {' +
                                                '"lat": 42.51607,' +
                                                '"lon": -80.51985' +
                                            '},' +
                                            '"btmRightPoint": {' +
                                                '"lat": 39.71978,' +
                                                '"lon": -74.68952' +
                                            '}' +
                                        '},' +
                                        '"dataSources": {' +
                                            '"geometry": {' +
                                                '"id": "00005858-5800-1200-0000-000077361d5b"' +
                                            '}' +
                                        '}' +
                                    '}' +
                                ']}';

        // Set the response body to the mock JSON string.
        response.setBody(jsonResponse);
               
        return response;
    }
    
}