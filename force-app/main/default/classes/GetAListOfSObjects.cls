@RestResource(urlMapping='/SObjectList/*')
global with sharing class GetAListOfSObjects {
    
    @HttpGet
    global static String getSObjectList() {
        // Get list of SObject types
        List<String> sObjectList = new List<String>();
        for(Schema.SObjectType obj : Schema.getGlobalDescribe().Values()) {
            Schema.DescribeSObjectResult objResult = obj.getDescribe();
            sObjectList.add(objResult.getName());
        }
        
        // Convert to comma-separated string
        return String.join(sObjectList, ',');
    }
}