/**
* @File Name : HttpClient.cls
* @Description : This class is responsible for a http callouts.
* @Author : Wilco
* @Last Modified By : Wilco
* @Last Modified On : October 29, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 29, 2024 |   | Initial Version
**/
public class HttpClient {
    
    // Enum for HTTP methods
    public enum HttpMethod {  GET, POST, PUT }

    /**
     * Sends an HTTP request to the specified endpoint and returns the response.
     *
     * @param endpoint The URL to which the request is sent. This should be a valid URL.
     * @param method The HTTP method to be used for the request (e.g., 'GET', 'POST', 'PUT').   
     * @param headers A Map<String, String> containing any additional headers required for the request, 
     *                such as 'Content-Type' or 'Authorization'.
     * @param bodyParams A Map<String, String> containing serialize parameters for generating a query string required for the request, 
     *                 such as 'accessToken' or 'value'.     
     *
     */
    public static HttpResponse sendRequest(HttpMethod method, String endpointUrl, 
                                            Map<String, String> headers , 
                                            Map<String, String> bodyParams) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Set up request method and URL
        request.setEndpoint(endpointUrl);
        request.setMethod(method.name());
        
        // Add headers if provided
        if (headers != null) {
            for (String key : headers.keySet()) {
                request.setHeader(key, headers.get(key));
            }
        }
        
        // Add body parameters for POST, PUT requests
        if ((method == HttpMethod.POST || method == HttpMethod.PUT) && bodyParams != null) {
            request.setBody(serializeParams(bodyParams));
        }
        
        // Sending request
        HttpResponse response = null;
        try {
            if(Test.isRunningTest()){                 
        	 	 response = HttpClientCalloutMock.respond(request);
            }else{
            	response = http.send(request);
            }
        } catch (System.Exception e) {
            System.debug(LoggingLevel.DEBUG,'HTTP Exception: ' + e.getMessage());
        }
        
        return response;
    }

    
    /**
     * Helper method to serialize parameters into a query string
     *    
     * @param params A Map<String, String> containing serialize parameters for generating a query string required for the request, 
     *                 such as 'accessToken' or 'value'.     
     *
     */
    private static String serializeParams(Map<String, String> params) {
        List<String> paramList = new List<String>();
        for (String key : params.keySet()) {
            paramList.add(EncodingUtil.urlEncode(key, 'UTF-8') + '=' + 
                          EncodingUtil.urlEncode(params.get(key), 'UTF-8'));
        }
        return String.join(paramList, '&');
    }
}