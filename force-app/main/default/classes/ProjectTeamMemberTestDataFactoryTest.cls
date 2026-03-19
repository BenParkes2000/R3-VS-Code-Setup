@isTest
public class ProjectTeamMemberTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        User user = UserTestDataFactory.create('test@r3.digital', 'Test', 'User');
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Act
        Id memberId = ProjectTeamMemberTestDataFactory.create(projectId, user.Id);

        // Assert
        Project_Team_Member__c member = [SELECT Project__c, User__c, Role__c FROM Project_Team_Member__c WHERE Id = :memberId];
        System.assertEquals(projectId, member.Project__c);
        System.assertEquals(user.Id, member.User__c);
        System.assertEquals('Developer', member.Role__c);
    }
}