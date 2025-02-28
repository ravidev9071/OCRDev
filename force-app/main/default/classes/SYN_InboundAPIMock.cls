@isTest
public class SYN_InboundAPIMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"access_token":"2345678gftrhfgf", "refresh_token":"9889iiuyt67788uuii","expires_in":4,"refresh_token_expires_in":null}');
     //   response.setBody('if you have sample JSON document that the service would return - paste it here. You must have something you used as the JSON2Apex input?');
        response.setStatusCode(200);
        return response;
    }
    
}