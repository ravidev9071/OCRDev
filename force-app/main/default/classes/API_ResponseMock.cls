@isTest
public class API_ResponseMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('if you have sample JSON document that the service would return - paste it here. You must have something you used as the JSON2Apex input?');
        response.setStatusCode(200);
        return response;
    }
}