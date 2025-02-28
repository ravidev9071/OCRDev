/**
* @File Name : HttpClientTest.cls
* @Description : This class is responsible for code coverage of HttpClient.
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
private class HttpClientTest {

    @isTest
    public static void makeApiCallTestMethod() {
        String endpoint = 'https://atlas.microsoft.com/search/address/json?api-version=1.0';
        
        // Example headers
        Map<String, String> headers = new Map<String, String>{
            'Authorization' => 'Bearer your_access_token',
            'Content-Type' => 'application/json'
        };
        
        // Example body parameters for a POST request
        Map<String, String> bodyParams = new Map<String, String>{
            'key1' => 'value1',
            'key2' => 'value2'
        };
        
        Test.startTest();
        // Sending a POST request
        HttpResponse response = HttpClient.sendRequest(HttpClient.HttpMethod.POST, endpoint, headers, bodyParams);
        Test.stopTest();
        
        Assert.areEqual(200, response.getStatusCode(), 'Expected response'); // Succeeds
       
    }
}