@isTest
public class WorkItemTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);
        Id featureId = ProjectFeatureTestDataFactory.create(projectId);

        // Act
        Id workItemId = WorkItemTestDataFactory.create(projectId, featureId);

        // Assert
        Work_Item__c workItem = [SELECT Project__c, Feature__c, Status__c FROM Work_Item__c WHERE Id = :workItemId];
        System.assertEquals(projectId, workItem.Project__c);
        System.assertEquals(featureId, workItem.Feature__c);
        System.assertEquals(WorkItemStatusNames.Backlog, workItem.Status__c);
    }

    @isTest
    public static void test_create_with_status() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);
        Id featureId = ProjectFeatureTestDataFactory.create(projectId);

        // Act
        Id workItemId = WorkItemTestDataFactory.create(projectId, featureId, WorkItemStatusNames.Approved, '');

        // Assert
        Work_Item__c workItem = [SELECT Project__c, Feature__c, Status__c FROM Work_Item__c WHERE Id = :workItemId];
        System.assertEquals(projectId, workItem.Project__c);
        System.assertEquals(featureId, workItem.Feature__c);
        System.assertEquals(WorkItemStatusNames.Approved, workItem.Status__c);
    }
}