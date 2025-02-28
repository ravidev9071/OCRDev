@isTest
global class WebServiceMockImpl implements WebServiceMock 
{
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) 
           {
               MetadataService.createMetadataResponse_element mockResponse = new MetadataService.createMetadataResponse_element();
               MetadataService.SaveResult[] result = new MetadataService.SaveResult[]{};
               MetadataService.SaveResult sampleRes = new MetadataService.SaveResult();
               mockResponse.result = result;
      // docSample.EchoStringResponse_element respElement = 
       //    new docSample.EchoStringResponse_element();
       //respElement.EchoStringResult = 'Mock response';
       response.put('response_x', mockResponse); 
           }
}