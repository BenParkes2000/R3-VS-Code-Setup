@isTest
public class ProjectTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();

        // Act
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Assert
        Project__c project = [SELECT Name, Account__c, Status__c, Start_Date__c, End_Date__c FROM Project__c WHERE Id = :projectId];
        System.assertEquals('test project', project.Name);
        System.assertEquals(accountId, project.Account__c);
        System.assertEquals(ProjectStatusNames.Backlog, project.Status__c);
        System.assertEquals(Date.today(), project.Start_Date__c);
        System.assertEquals((Date.today() + 28), project.End_Date__c);
    }

    @isTest
    public static void test_create_with_name_and_status() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();

        // Act
        Id projectId = ProjectTestDataFactory.create(accountId, 'New Project', ProjectStatusNames.Complete);

        // Assert
        Project__c project = [SELECT Name, Account__c, Status__c, Start_Date__c, End_Date__c FROM Project__c WHERE Id = :projectId];
        System.assertEquals('New Project', project.Name);
        System.assertEquals(accountId, project.Account__c);
        System.assertEquals(ProjectStatusNames.Complete, project.Status__c);
        System.assertEquals(Date.today(), project.Start_Date__c);
        System.assertEquals((Date.today() + 28), project.End_Date__c);
    }

    @isTest
    public static void test_create_with_name_and_status_and_dates() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();

        // Act
        Id projectId = ProjectTestDataFactory.create(accountId, 'New Project', ProjectStatusNames.Complete, Date.newInstance(2020, 1, 1), Date.newInstance(2020, 2, 28));

        // Assert
        Project__c project = [SELECT Name, Account__c, Status__c, Start_Date__c, End_Date__c FROM Project__c WHERE Id = :projectId];
        System.assertEquals('New Project', project.Name);
        System.assertEquals(accountId, project.Account__c);
        System.assertEquals(ProjectStatusNames.Complete, project.Status__c);
        System.assertEquals(Date.newInstance(2020, 1, 1), project.Start_Date__c);
        System.assertEquals(Date.newInstance(2020, 2, 28), project.End_Date__c);
    }
}