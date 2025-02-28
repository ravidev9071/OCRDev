@isTest
public class SYN_Incontact_Batch_Mock implements HttpCalloutMock  {
    //incontactapi/services/v23.0/contacts/
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        if(request.getEndpoint().contains('incontactapi/services/v23.0/contacts/')) {
            response.setBody('{"contactStart":"2014-09-15T07:00:00.000Z","lastUpdateTime":"2014-09-16T07:00:00.000Z"}');
            
        } else{
            response.setBody('{"access_token":"2345678gftrhfgf","refresh_token":"9889iiuyt67788uuii","token_type":"Bearer","expires_in":4,"refresh_token_expires_in":null}');
            
        }
        
        return response;
    }
}