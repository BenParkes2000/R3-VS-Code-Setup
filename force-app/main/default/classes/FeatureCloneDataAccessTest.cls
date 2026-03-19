@isTest
public class FeatureCloneDataAccessTest {
    @isTest
    public static void test_get_feature() {
        // Arrange
        Id accountId = AccountTestDataFactory.create('My Account');
        Id projectId = ProjectTestDataFactory.create(accountId, 'My Project', ProjectStatusNames.InProgress);
        Id featureId = ProjectFeatureTestDataFactory.create(projectId, 'My Feature');
        Id workItemId = WorkItemTestDataFactory.create(projectId, featureId);

        // Act
        Project_Feature__c feature = new FeatureCloneDataAccess().getFeature(featureId);

        // Assert
        System.assertEquals(featureId, feature.Id);
        System.assertEquals('My Feature', feature.Name);
        System.assertEquals(1, feature.Work_Items__r.size());
        System.assertEquals(workItemId, feature.Work_Items__r[0].Id);
    }
}