@isTest
public class PhaseProposalDataAccessTest {
    @isTest
    public static void test_get_phases() {
        // Arrange
        Id accountId = AccountTestDataFactory.create('Test Account');
        Id projectId = ProjectTestDataFactory.create(accountId, 'Test Project', ProjectStatusNames.InProgress);
        Phase__c phase = PhaseTestDataFactory.create(projectId, 'Test Phase');

        insert phase;

        Id phaseId = phase.Id;

        // Act
        phase = new PhaseProposalDataAccess().getPhases(phaseId);

        // Assert
        System.assertEquals('Test Phase', phase.Name);
    }

    @isTest
    public static void test_get_features() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);
    }
}