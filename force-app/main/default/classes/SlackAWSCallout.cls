public class SlackAWSCallout {
     @future (callout=true)
     public static void myAWSCallout(Map<String,String> mp)
     {
          //long-running Apex code

      String restAPIURL = 'https://2704u9iaye.execute-api.ap-south-1.amazonaws.com/asyncRecruitProcessor';
      
      HttpRequest httpRequest = new HttpRequest();  
      httpRequest.setMethod('POST');   
      httpRequest.setEndpoint(restAPIURL);  
      httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
      httpRequest.setBody(JSON.serialize(mp));
            
      String response = '';
      try {  
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) {  
                  response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
            } else {  
                  System.debug(' httpResponse ' + httpResponse.getBody() );  
                  throw new CalloutException( httpResponse.getBody() );  
            }   
      } catch( System.Exception e) {  
            System.debug('ERROR: '+ e);  
            throw e;  
      }  
      System.debug(' ** response ** : ' + response );

 }
}