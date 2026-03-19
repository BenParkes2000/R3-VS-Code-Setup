@isTest
public class SteeringCommitteePdfControllerTest {
    @isTest
    public static void test_get_account_exception() {
        // Arrange
        Id invalidId = '000000000000000AAA';
        ApexPages.currentPage().getParameters().put('id', invalidId);

        try {
            // Act
            SteeringCommitteePdfController controller = new SteeringCommitteePdfController();
        } catch (SteeringCommitteePdfController.CustomException e) {
            // Assert
            System.assertEquals('Unable to find account with ID: ' + invalidId, e.getMessage());
            return;
        }

        // If we get here, the exception wasn't thrown
        System.assert(false);
    }

    @isTest
    public static void test_get_account() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        ApexPages.currentPage().getParameters().put('id', accountId);

        // Act
        SteeringCommitteePdfController controller = new SteeringCommitteePdfController();

        // Assert
        System.assertEquals(accountId, controller.account.Id);
    }

    @isTest
    public static void test_collate_projects() {
        // Arrange
        Id account1Id = AccountTestDataFactory.create('Account One');
        Id account2Id = AccountTestDataFactory.create('Account Two');

        // Projects
        Id project1Id = ProjectTestDataFactory.create(account1Id, 'Project One', ProjectStatusNames.KickOff);
        Id project2Id = ProjectTestDataFactory.create(account1Id, 'Project Two', ProjectStatusNames.InProgress);
        Id project3Id = ProjectTestDataFactory.create(account1Id, 'Project Three', ProjectStatusNames.Complete); // Excluded by status
        Id project4Id = ProjectTestDataFactory.create(account2Id, 'Project Four', ProjectStatusNames.InProgress); // Excluded by account

        // Phases
        List<Phase__c> phaseList = new List<Phase__c>{
            PhaseTestDataFactory.create(project1Id, 'Phase 1.1'),
            PhaseTestDataFactory.create(project1Id, 'Phase 1.2'),
            PhaseTestDataFactory.create(project1Id, 'Phase 1.3'),
            PhaseTestDataFactory.create(project2Id, 'Phase 2.1'),
            PhaseTestDataFactory.create(project2Id, 'Phase 2.2'),
            PhaseTestDataFactory.create(project2Id, 'Phase 2.3'),
            PhaseTestDataFactory.create(project3Id, 'Phase 3.1'),
            PhaseTestDataFactory.create(project4Id, 'Phase 4.1')
        };
        insert phaseList;

        ApexPages.currentPage().getParameters().put('id', account1Id);

        // Act
        SteeringCommitteePdfController controller = new SteeringCommitteePdfController();

        // Assert
        System.assertEquals(2, controller.projects.size());
        System.assertEquals('Project One', controller.projects[0].Name);
        System.assertEquals('Project Two', controller.projects[1].Name);
        System.assertEquals(3, controller.projects[0].Milestones.size());
        System.assertEquals(3, controller.projects[1].Milestones.size());
        System.assertEquals('Phase 1.1', controller.projects[0].Milestones[0].Name);
        System.assertEquals('Phase 1.2', controller.projects[0].Milestones[1].Name);
        System.assertEquals('Phase 1.3', controller.projects[0].Milestones[2].Name);
        System.assertEquals('Phase 2.1', controller.projects[1].Milestones[0].Name);
        System.assertEquals('Phase 2.2', controller.projects[1].Milestones[1].Name);
        System.assertEquals('Phase 2.3', controller.projects[1].Milestones[2].Name);
    }

    @isTest
    public static void test_collate_raid_logs() {
        // Arrange
        Id account1Id = AccountTestDataFactory.create('Account One');
        Id account2Id = AccountTestDataFactory.create('Account Two');

        // Projects
        Id project1Id = ProjectTestDataFactory.create(account1Id, 'Project One', ProjectStatusNames.KickOff);
        Id project2Id = ProjectTestDataFactory.create(account1Id, 'Project Two', ProjectStatusNames.InProgress);
        Id project3Id = ProjectTestDataFactory.create(account1Id, 'Project Three', ProjectStatusNames.Complete); // Excluded by status
        Id project4Id = ProjectTestDataFactory.create(account2Id, 'Project Four', ProjectStatusNames.InProgress); // Excluded by account

        // RAID Logs
        List<RAID_Log__c> raidLogs = new List<RAID_Log__c>{
            // Risks
            RaidLogTestDataFactory.create(project1Id, RaidLogUtils.getRiskRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Low),
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getRiskRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Moderate),
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getRiskRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Critical),
            RaidLogTestDataFactory.create(project1Id, RaidLogUtils.getRiskRecordTypeId, RaidLogStatusNames.Closed, RaidLogRatingNames.Critical), // Excluded by status
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getRiskRecordTypeId, RaidLogStatusNames.Archived, RaidLogRatingNames.Critical), // Excluded by status
            RaidLogTestDataFactory.create(project4Id, RaidLogUtils.getRiskRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Critical), // Excluded by project
            // Actions
            RaidLogTestDataFactory.create(project1Id, RaidLogUtils.getActionRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Strategic),
            RaidLogTestDataFactory.create(project1Id, RaidLogUtils.getActionRecordTypeId, RaidLogStatusNames.Closed, RaidLogRatingNames.Strategic),
            RaidLogTestDataFactory.create(project1Id, RaidLogUtils.getActionRecordTypeId, RaidLogStatusNames.Archived, RaidLogRatingNames.Strategic), // Excluded by status
            RaidLogTestDataFactory.create(project1Id, RaidLogUtils.getActionRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Critical), // Excluded by rating
            RaidLogTestDataFactory.create(project3Id, RaidLogUtils.getActionRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Strategic), // Excluded by project
            // Issues
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getIssueRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Critical),
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getIssueRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Strategic),
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getIssueRecordTypeId, RaidLogStatusNames.Closed, RaidLogRatingNames.Strategic), // Excluded by status
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getIssueRecordTypeId, RaidLogStatusNames.Archived, RaidLogRatingNames.Strategic), // Excluded by status
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getIssueRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Low), // Excluded by rating
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getIssueRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Moderate), // Excluded by rating
            RaidLogTestDataFactory.create(project3Id, RaidLogUtils.getIssueRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Critical), // Excluded by project
            // Decisions
            RaidLogTestDataFactory.create(project1Id, RaidLogUtils.getDecisionRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Low),
            RaidLogTestDataFactory.create(project1Id, RaidLogUtils.getDecisionRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Moderate),
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getDecisionRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Critical),
            RaidLogTestDataFactory.create(project1Id, RaidLogUtils.getDecisionRecordTypeId, RaidLogStatusNames.Closed, RaidLogRatingNames.Critical), // Excluded by status
            RaidLogTestDataFactory.create(project2Id, RaidLogUtils.getDecisionRecordTypeId, RaidLogStatusNames.Archived, RaidLogRatingNames.Critical), // Excluded by status
            RaidLogTestDataFactory.create(project4Id, RaidLogUtils.getDecisionRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Critical) // Excluded by project
        };
        insert raidLogs;

        ApexPages.currentPage().getParameters().put('id', account1Id);

        // Act
        SteeringCommitteePdfController controller = new SteeringCommitteePdfController();

        // Assert
        System.assertEquals(3, controller.risks.size());
        System.assertEquals(2, controller.actions.size());
        System.assertEquals(2, controller.issues.size());
        System.assertEquals(3, controller.decisions.size());
    }
}