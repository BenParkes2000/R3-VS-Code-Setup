@isTest
public class WeeklyStatusReportDataAccessTest {
  @isTest
  public static void testGetProject() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<Phase__c> phaseList = new List<Phase__c>{
      PhaseTestDataFactory.create(projectId, 'Phase One'),
      PhaseTestDataFactory.create(projectId, 'Phase Two')
    };
    insert phaseList;

    List<RAID_Log__c> raidLogList = new List<RAID_Log__c>{
      RaidLogTestDataFactory.create(
        projectId,
        RaidLogUtils.getRiskRecordTypeId,
        RaidLogStatusNames.Open,
        RaidLogRatingNames.Low
      ),
      RaidLogTestDataFactory.create(
        projectId,
        RaidLogUtils.getActionRecordTypeId,
        RaidLogStatusNames.Closed,
        RaidLogRatingNames.Strategic
      )
    };
    insert raidLogList;

    // Act
    WeeklyStatusReportDataAccess dataAccess = new WeeklyStatusReportDataAccess();
    Project__c project = dataAccess.getProject(projectId);

    // Assert
    Assert.areEqual('Test Account', project.Account__r.Name, 'Account Name');
    Assert.areEqual('Test Project', project.Name, 'Project Name');
    Assert.areEqual(
      ProjectStatusNames.InProgress,
      project.Status__c,
      'Project Status'
    );
    Assert.areEqual('Test Account', project.Account__r.Name, 'Account Name');
    Assert.areEqual(2, project.Phases__r.size(), 'Phases');
    Assert.areEqual(2, project.RAID_Log__r.size(), 'RAID Log');
  }

  @isTest
  public static void testGetProjectMeetings() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    Project_Meeting__c meeting = ProjectMeetingTestDataFactory.create(
      projectId
    );
    insert meeting;

    // Act
    WeeklyStatusReportDataAccess dataAccess = new WeeklyStatusReportDataAccess();
    Project__c project = dataAccess.getProject(projectId);

    Assert.areEqual(1, project.Project_Meetings__r.size(), 'Project Meetings');
  }

  @isTest
  public static void testGetUATItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<UAT_Feedback__c> uatFeedbackList = new List<UAT_Feedback__c>{
      createInMemoryUATFeedback('Test Feedback 1', 'Open', projectId),
      createInMemoryUATFeedback('Test Feedback 2', 'WIP', projectId),
      createInMemoryUATFeedback('Test Feedback 3', 'Re-Test', projectId),
      createInMemoryUATFeedback('Test Feedback 4', 'Closed', projectId)
    };
    insert uatFeedbackList;

    UAT_Feedback__c openFeedback = [
      SELECT
        Id,
        Status_UAT_Feedback__c,
        Feedback_Subject__c,
        Open_Count__c,
        WIP_Count__c,
        Re_Test_Count__c,
        Closed_Count__c
      FROM UAT_Feedback__c
      WHERE Id = :uatFeedbackList[0].ID
      LIMIT 1
    ];
    UAT_Feedback__c wipFeedback = [
      SELECT
        Id,
        Status_UAT_Feedback__c,
        Feedback_Subject__c,
        Open_Count__c,
        WIP_Count__c,
        Re_Test_Count__c,
        Closed_Count__c
      FROM UAT_Feedback__c
      WHERE Id = :uatFeedbackList[1].ID
      LIMIT 1
    ];
    UAT_Feedback__c reTestFeedback = [
      SELECT
        Id,
        Status_UAT_Feedback__c,
        Feedback_Subject__c,
        Open_Count__c,
        WIP_Count__c,
        Re_Test_Count__c,
        Closed_Count__c
      FROM UAT_Feedback__c
      WHERE Id = :uatFeedbackList[2].ID
      LIMIT 1
    ];
    UAT_Feedback__c closedFeedback = [
      SELECT
        Id,
        Status_UAT_Feedback__c,
        Feedback_Subject__c,
        Open_Count__c,
        WIP_Count__c,
        Re_Test_Count__c,
        Closed_Count__c
      FROM UAT_Feedback__c
      WHERE Id = :uatFeedbackList[3].ID
      LIMIT 1
    ];

    // Act
    WeeklyStatusReportDataAccess dataAccess = new WeeklyStatusReportDataAccess();
    Project__c project = dataAccess.getProject(projectId);

    // Assert
    Assert.areEqual(4, project.UAT_Feedback_Records__r.size(), 'UAT Items');
    Assert.areEqual(
      openFeedback.Open_Count__c,
      project.UAT_Feedback_Records__r[0].Open_Count__c,
      'Open UAT Items'
    );
    Assert.areEqual(
      wipFeedback.WIP_Count__c,
      project.UAT_Feedback_Records__r[1].WIP_Count__c,
      'WIP UAT Items'
    );
    Assert.areEqual(
      reTestFeedback.Re_Test_Count__c,
      project.UAT_Feedback_Records__r[2].Re_Test_Count__c,
      'Re-Test UAT Items'
    );
    Assert.areEqual(
      closedFeedback.Closed_Count__c,
      project.UAT_Feedback_Records__r[3].Closed_Count__c,
      'Closed UAT Items'
    );
  }

  @isTest
  public static void testGetBlockedWorkItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );
    Id featureId = ProjectFeatureTestDataFactory.create(projectId);

    List<String> workItems = new List<String>{
      WorkItemTestDataFactory.create(
        projectId,
        featureId,
        WorkItemStatusNames.Blocked,
        'Testing blocked work item'
      ),
      WorkItemTestDataFactory.create(
        projectId,
        featureId,
        WorkItemStatusNames.Backlog,
        ''
      ),
      WorkItemTestDataFactory.create(
        projectId,
        featureId,
        WorkItemStatusNames.Approved,
        ''
      )
    };
    List<Work_Item__c> workItemList = [
      SELECT Id, Status__c
      FROM Work_Item__c
      WHERE
        Id IN :workItems
        AND Project__c = :projectId
        AND Status__c = :WorkItemStatusNames.Blocked
    ];

    // Act
    WeeklyStatusReportDataAccess dataAccess = new WeeklyStatusReportDataAccess();
    Project__c project = dataAccess.getProject(projectId);

    // Assert
    Assert.areEqual(
      workItemList.size(),
      project.Work_Items__r.size(),
      'Blocked Work Items'
    );
    Assert.areEqual(
      'Blocked',
      project.Work_Items__r[0].Status__c,
      'The status should be Blocked'
    );
  }

  private static UAT_Feedback__c createInMemoryUATFeedback(
    String subject,
    String status,
    Id projectId
  ) {
    String guid = EncodingUtil.convertToHex(Crypto.generateAesKey(128))
      .substring(0, 16);
    User testUser = UserTestDataFactory.create(
      'test-' + guid + '@example.com',
      'Test',
      'User'
    );
    UAT_Feedback__c uatFeedback = new UAT_Feedback__c();
    uatFeedback.Project_UAT__c = projectId;
    uatFeedback.Feedback_Subject__c = subject;
    uatFeedback.Priority__c = 'Low';
    uatFeedback.Status_UAT_Feedback__c = status;
    uatFeedback.Assigned_to_UAT__c = testUser.Id;
    return uatFeedback;
  }
}