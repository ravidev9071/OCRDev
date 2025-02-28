@isTest
global class SYN_VeevaAPIAuthJSON_MockCall implements HttpCalloutMock 
{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) 
    {
        StaticResource JSONRes = [SELECT Id, Body FROM StaticResource WHERE Name = 'SYN_VeevaAuthJSON' LIMIT 1];
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSONRes.Body.toString());
        res.setStatusCode(200);
        return res;
    }
}