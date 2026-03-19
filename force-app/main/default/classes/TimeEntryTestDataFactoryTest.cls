@isTest
public class TimeEntryTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);
        Id featureId = ProjectFeatureTestDataFactory.create(projectId);
        Id workItemId = WorkItemTestDataFactory.create(projectId, featureId);

        // Act
        Id timeEntryId = TimeEntryTestDataFactory.create(projectId, workItemId);

        // Assert
        Time_Entry__c timeEntry = [SELECT Work_Item__c, Project__c, Start__c FROM Time_Entry__c WHERE Id = :timeEntryId];
        System.assertEquals(workItemId, timeEntry.Work_Item__c);
        System.assertEquals(projectId, timeEntry.Project__c);
        System.assertNotEquals(null, timeEntry.Start__c);
    }
}