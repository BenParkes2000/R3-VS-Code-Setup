@isTest
private class MoscowProjectProposalControllerTest {
  @isTest
  static void testGetters() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    ApexPages.currentPage().getParameters().put('id', projectId);

    // Act
    Test.startTest();
    MoscowProjectProposalController controller;

    System.runAs(TestUtil.getSysAdminUser()) {
      controller = new MoscowProjectProposalController();
    }
    Test.stopTest();

    // Assert
    System.assertEquals(
      Datetime.now().year(),
      controller.Year,
      'Year should be set to the current year'
    );
    System.assertEquals(
      projectId,
      controller.ProjectId,
      'Project ID should be set to the current project ID'
    );
  }

  @isTest
  static void testCacheMoscowTotals() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();

    Id projectId = ProjectTestDataFactory.create(accountId);
    Project__c project = new Project__c(Id = projectId);
    project.Proposal_Hourly_Rate__c = 125;
    update project;

    Id featureId = ProjectFeatureTestDataFactory.create(projectId);

    WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Backlog,
      WorkItemImportanceNames.MUST_HAVE_VALUE,
      4
    );
    WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Backlog,
      WorkItemImportanceNames.SHOULD_HAVE_VALUE,
      6
    );
    WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Backlog,
      WorkItemImportanceNames.COULD_HAVE_VALUE,
      8
    );
    WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Backlog,
      WorkItemImportanceNames.WONT_HAVE_VALUE,
      10
    );

    ApexPages.currentPage().getParameters().put('id', projectId);

    // Act
    Test.startTest();
    MoscowProjectProposalController controller;

    System.runAs(TestUtil.getSysAdminUser()) {
      controller = new MoscowProjectProposalController();
    }
    Test.stopTest();

    // Assert
    System.assertEquals(4, controller.M_Hours, 'M Hours should be 4');
    System.assertEquals(0.5, controller.M_Days, 'M Days should be 0.5');
    System.assertEquals(500, controller.M_Cost, 'M Cost should be 500');
    System.assertEquals(10, controller.MS_Hours, 'MS Hours should be 10');
    System.assertEquals(1.25, controller.MS_Days, 'MS Days should be 1.25');
    System.assertEquals(1250, controller.MS_Cost, 'MS Cost should be 1250');
    System.assertEquals(18, controller.MSC_Hours, 'MSC Hours should be 18');
    System.assertEquals(2.25, controller.MSC_Days, 'MSC Days should be 2.25');
    System.assertEquals(2250, controller.MSC_Cost, 'MSC Cost should be 2250');
    System.assertEquals(28, controller.MSCW_Hours, 'MSCW Hours should be 28');
    System.assertEquals(3.5, controller.MSCW_Days, 'MSCW Days should be 3.5');
    System.assertEquals(3500, controller.MSCW_Cost, 'MSCW Cost should be 3500');
  }
}