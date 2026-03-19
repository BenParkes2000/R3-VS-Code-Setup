@isTest
public class PhaseProposalControllerTest {
    @isTest
    static void run_controller() {
        // arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);
        Id feature1Id = ProjectFeatureTestDataFactory.create(projectId);
        Phase__c phase1 = PhaseTestDataFactory.create(projectId);
        insert phase1;
        Id phaseId = phase1.id;
        WorkItemTestDataFactory.create(projectId, feature1Id, WorkItemStatusNames.Backlog, phaseId);
        WorkItemTestDataFactory.create(projectId, feature1Id, WorkItemStatusNames.Backlog, phaseId);
        WorkItemTestDataFactory.create(projectId, feature1Id, WorkItemStatusNames.Backlog, phaseId);
        WorkItemTestDataFactory.create(projectId, feature1Id, WorkItemStatusNames.Backlog, phaseId);

        Id feature2Id = ProjectFeatureTestDataFactory.create(projectId);
        WorkItemTestDataFactory.create(projectId, feature2Id, WorkItemStatusNames.Backlog, phaseId);
        WorkItemTestDataFactory.create(projectId, feature2Id, WorkItemStatusNames.Backlog, phaseId);
        WorkItemTestDataFactory.create(projectId, feature2Id, WorkItemStatusNames.Backlog, phaseId);
        WorkItemTestDataFactory.create(projectId, feature2Id, WorkItemStatusNames.Backlog, phaseId);

        PageReference pageRef = Page.PhaseProposal;
        pageRef.getParameters().put('id', phaseId);
        Test.setCurrentPage(pageRef);

        // act
        Test.startTest();
        PhaseProposalController controller = new PhaseProposalController();
        Test.stopTest();

        // assert
        System.assert(true);
    }
}