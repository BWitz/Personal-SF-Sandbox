public with sharing class demoAPICalloutClass {
    public demoAPICalloutClass() {

    }

    @AuraEnabled
    public static string demoLWCCalloutMethod(){
        try {
            Http http = new Http();
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint('callout:dogPictureAPI');
            httpReq.setMethod('GET');
            HttpResponse resp = http.send(httpReq);
            return resp.getBody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}