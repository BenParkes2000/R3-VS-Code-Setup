@IsTest
private class GetAListOfSObjectsTest {
    
    @IsTest
    static void testGetSObjectList() {
        // Set up the RestRequest
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/SObjectList';
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        // Call the method
        Test.startTest();
        String result = GetAListOfSObjects.getSObjectList();
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals('', result, 'Result should not be empty');
        
        // Split result into list and verify common SObjects are present
        List<String> sObjectList = result.split(',');
        System.assert(sObjectList.contains('Account'), 'Result should contain Account');
        System.assert(sObjectList.contains('Contact'), 'Result should contain Contact');
        System.assert(sObjectList.contains('User'), 'Result should contain User');
        
        // Verify no duplicates
        Set<String> uniqueObjects = new Set<String>(sObjectList);
        System.assertEquals(sObjectList.size(), uniqueObjects.size(), 'Result should not contain duplicates');
    }
}