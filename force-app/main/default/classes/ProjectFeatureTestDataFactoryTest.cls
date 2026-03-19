@isTest
public class ProjectFeatureTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Act
        Id featureId = ProjectFeatureTestDataFactory.create(projectId);

        // Assert
        Project_Feature__c feature = [SELECT Name, Project__c FROM Project_Feature__c WHERE Id = :featureId];
        System.assertEquals('test feature', feature.Name);
        System.assertEquals(projectId, feature.Project__c);
    }

    @isTest
    public static void test_create_with_name() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Act
        Id featureId = ProjectFeatureTestDataFactory.create(projectId, 'New Feature');

        // Assert
        Project_Feature__c feature = [SELECT Name FROM Project_Feature__c WHERE Id = :featureId];
        System.assertEquals('New Feature', feature.Name);
    }
}