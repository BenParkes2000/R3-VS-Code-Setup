@isTest
private class ProjectCopyActionTest {
  @isTest
  static void testExecute() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id oldProjectId = ProjectTestDataFactory.create(accountId);
    Id newProjectId = ProjectTestDataFactory.create(accountId);

    Phase__c oldProjectPhase = PhaseTestDataFactory.create(oldProjectId);
    insert oldProjectPhase;

    Project_Feature__c oldProjectFeature = new Project_Feature__c();
    oldProjectFeature.Name = 'Test Feature';
    oldProjectFeature.Project__c = oldProjectId;
    oldProjectFeature.Phase__c = oldProjectPhase.Id;
    insert oldProjectFeature;

    WorkItemTestDataFactory.create(
      oldProjectId,
      oldProjectFeature.Id,
      WorkItemStatusNames.Backlog,
      oldProjectPhase.Id
    );

    ProjectCopyAction.Request request = new ProjectCopyAction.Request();
    request.oldProjectId = oldProjectId;
    request.newProjectId = newProjectId;

    // Act
    Test.startTest();
    System.runAs(TestUtil.getSysAdminUser()) {
      ProjectCopyAction.execute(new List<ProjectCopyAction.Request>{ request });
    }
    Test.stopTest();

    // Assert
    System.assertEquals(
      1,
      [SELECT Id FROM Phase__c WHERE Project__c = :newProjectId].size(),
      'New Project should have 1 Phase'
    );

    System.assertEquals(
      1,
      [SELECT Id FROM Project_Feature__c WHERE Project__c = :newProjectId]
        .size(),
      'New Project should have 1 Feature'
    );

    System.assertEquals(
      1,
      [SELECT Id FROM Work_Item__c WHERE Project__c = :newProjectId].size(),
      'New Project should have 1 Work Item'
    );
  }
}