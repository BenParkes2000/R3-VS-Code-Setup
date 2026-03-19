@isTest
private class DiagramEditorControllerTest {
    @isTest
    static void testGetDiagramData() {
        // Create a test Account record
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Diagram__c record
        Diagram__c testDiagram = new Diagram__c(Data__c = '{}', Account__c = testAccount.Id);
        insert testDiagram;

        // Call the method to be tested
        String result = DiagramEditorController.getDiagramData(testDiagram.Id);

        // Assert that the returned data is as expected
        System.assertEquals('{}', result);
    }

    @isTest
    static void testUpdateDiagram() {
        // Create a test Account record
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Diagram__c record
        Diagram__c testDiagram = new Diagram__c(Data__c = '{}', Account__c = testAccount.Id);
        insert testDiagram;

        // Call the method to be tested
        String result = DiagramEditorController.updateDiagram(testDiagram.Id, '{"updated": true}');

        // Assert that the update was successful
        System.assertEquals('Success', result);

        // Query the database for the updated record
        Diagram__c updatedDiagram = [SELECT Data__c FROM Diagram__c WHERE Id = :testDiagram.Id];

        // Assert that the data was updated as expected
        System.assertEquals('{"updated": true}', updatedDiagram.Data__c);
    }
}