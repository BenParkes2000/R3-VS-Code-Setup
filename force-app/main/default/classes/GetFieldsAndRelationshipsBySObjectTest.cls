@IsTest
private class GetFieldsAndRelationshipsBySObjectTest {
    
    @IsTest
    static void testGetFieldsAndRelationshipsWithValidSObject() {
        // Set up the RestRequest
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/SObjectFieldsAndRelationships';
        req.httpMethod = 'GET';
        req.params.put('sObjectName', 'Account');
        RestContext.request = req;
        
        // Call the method
        Test.startTest();
        String result = GetFieldsAndRelationshipsBySObject.getFieldsAndRelationships();
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals('', result, 'Result should not be empty');
        
        // Verify the result contains expected sections
        System.assert(result.contains('Fields:'), 'Result should contain Fields section');
        System.assert(result.contains('Child Relationships:'), 'Result should contain Child Relationships section');
        System.assert(result.contains('Referenced Objects:'), 'Result should contain Referenced Objects section');
        
        // Verify common Account fields are present
        System.assert(result.contains('Name'), 'Result should contain Name field');
        System.assert(result.contains('Id'), 'Result should contain Id field');
    }
    
    @IsTest
    static void testGetFieldsAndRelationshipsWithNoSObject() {
        // Set up the RestRequest without sObjectName parameter
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/SObjectFieldsAndRelationships';
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        // Call the method
        Test.startTest();
        String result = GetFieldsAndRelationshipsBySObject.getFieldsAndRelationships();
        Test.stopTest();
        
        // Verify error message
        System.assertEquals('Please provide an SObject name as a parameter', result, 
            'Should return error message for missing sObject parameter');
    }
    
    @IsTest
    static void testGetFieldsAndRelationshipsWithInvalidSObject() {
        // Set up the RestRequest with invalid sObjectName
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/SObjectFieldsAndRelationships';
        req.httpMethod = 'GET';
        req.params.put('sObjectName', 'InvalidObject');
        RestContext.request = req;
        
        // Call the method
        Test.startTest();
        String result = GetFieldsAndRelationshipsBySObject.getFieldsAndRelationships();
        Test.stopTest();
        
        // Verify error message
        System.assertEquals('Invalid SObject name provided', result, 
            'Should return error message for invalid sObject name');
    }
}