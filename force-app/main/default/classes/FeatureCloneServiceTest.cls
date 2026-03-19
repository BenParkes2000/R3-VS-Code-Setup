@isTest
public class FeatureCloneServiceTest {
    @isTest
    public static void test_clone_feature() {
        // Arrange
        Id account1Id = AccountTestDataFactory.create('Account One');
        Id account2Id = AccountTestDataFactory.create('Account Two');

        Id project1Id = ProjectTestDataFactory.create(account1Id, 'Project One', ProjectStatusNames.Backlog);
        Id project2Id = ProjectTestDataFactory.create(account2Id, 'Project Two', ProjectStatusNames.Backlog);

        Id featureId = ProjectFeatureTestDataFactory.create(project1Id, 'Feature To Clone');
        Id workItemId = WorkItemTestDataFactory.create(project1Id, featureId);

        // Act
        Test.startTest();
        Id clonedFeatureId = new FeatureCloneService().cloneFeature(featureId, project2Id);
        Test.stopTest();

        // Assert
        Project_Feature__c clonedFeature = [SELECT Id, Name, Project__c, (SELECT Id FROM Work_Items__r) FROM Project_Feature__c WHERE Id = :clonedFeatureId];
        System.assertEquals('Feature To Clone', clonedFeature.Name);
        System.assertEquals(project2Id, clonedFeature.Project__c);
        System.assertEquals(1, clonedFeature.Work_Items__r.size());
    }
}