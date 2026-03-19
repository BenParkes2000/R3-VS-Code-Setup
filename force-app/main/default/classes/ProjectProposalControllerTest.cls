@isTest
private class ProjectProposalControllerTest {
  @isTest
  static void runController() {
    // arrange
    Id accountId = AccountTestDataFactory.create();
    Id product1Id = Product2TestDataFactory.create();
    Id product2Id = Product2TestDataFactory.createThirdPartyServiceProduct();
    PricebookEntryTestDataFactory.create(product1Id);
    PricebookEntryTestDataFactory.create(product2Id);
    Id opportunityId = OpportunityTestDataFactory.create(accountId);
    OpportunityLineItemTestDataFactory.create(opportunityId, product1Id);
    OpportunityLineItemTestDataFactory.create(opportunityId, product2Id);
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id feature1Id = ProjectFeatureTestDataFactory.create(projectId);
    WorkItemTestDataFactory.create(projectId, feature1Id);
    WorkItemTestDataFactory.create(projectId, feature1Id);
    WorkItemTestDataFactory.create(projectId, feature1Id);
    WorkItemTestDataFactory.create(projectId, feature1Id);

    Id feature2Id = ProjectFeatureTestDataFactory.create(projectId);
    WorkItemTestDataFactory.create(projectId, feature2Id);
    WorkItemTestDataFactory.create(projectId, feature2Id);
    WorkItemTestDataFactory.create(projectId, feature2Id);
    WorkItemTestDataFactory.create(projectId, feature2Id);

    PageReference pageRef = Page.ProjectProposal;
    pageRef.getParameters().put('id', projectId);
    Test.setCurrentPage(pageRef);

    // act
    Test.startTest();
    ProjectProposalController controller;

    System.runAs(TestUtil.getSysAdminUser()) {
      controller = new ProjectProposalController();
    }
    Test.stopTest();

    // assert
    System.assertEquals(
      'test account',
      controller.proposal.accountName,
      'Proposal account name should be set'
    );
  }
}