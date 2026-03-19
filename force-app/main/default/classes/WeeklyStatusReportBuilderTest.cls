@isTest
public class WeeklyStatusReportBuilderTest {
  @isTest
  public static void testBuild() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );
    Id featureId = ProjectFeatureTestDataFactory.create(projectId);

    List<Phase__c> phaseList = new List<Phase__c>{
      PhaseTestDataFactory.create(projectId, 'Phase One'),
      PhaseTestDataFactory.create(projectId, 'Phase Two')
    };
    insert phaseList;

    WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Backlog,
      ''
    );
    WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Approved,
      ''
    );

    WeeklyStatusReportFactory wsrFactory = new WeeklyStatusReportFactory();
    WeeklyStatusReportDataAccess wsrDataAccess = new WeeklyStatusReportDataAccess();
    Project__c daProject = wsrDataAccess.getProject(projectId);
    List<WeeklyStatusReport.PhaseRow> expectedReportPhaseList = wsrFactory.createPhases(
      daProject.Phases__r
    );

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    System.assertEquals('Test Account', report.AccountName, 'AccountName');
    System.assertEquals('Test Project', report.ProjectName, 'ProjectName');
    System.assertEquals(2, report.Phases.size(), 'Phases');
    System.assertEquals(
      null,
      report.ProjectPhasesImageId,
      'ProjectPhasesImageId'
    );
    Assert.areEqual(
      expectedReportPhaseList.size(),
      report.Phases.size(),
      'Unexpected number of Phases in report'
    );
    for (Integer i = 0; i < report.Phases.size(); ++i) {
      Assert.areEqual(
        expectedReportPhaseList[i].Name,
        report.Phases[i].Name,
        'Unexpected Name on Phase in report Phase list with index ' + i
      );
      Assert.areEqual(
        expectedReportPhaseList[i].StartDate,
        report.Phases[i].StartDate,
        'Unexpected StartDate on Phase in report Phase list with index ' + i
      );
      Assert.areEqual(
        expectedReportPhaseList[i].EndDate,
        report.Phases[i].EndDate,
        'Unexpected EndDate on Phase in report Phase list with index ' + i
      );
    }
  }

  @isTest
  public static void testBuildRaidLogs() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );
    List<RAID_Log__c> raidLogList = new List<RAID_Log__c>{
      RaidLogTestDataFactory.create(
        projectId,
        RaidLogUtils.getRiskRecordTypeId,
        RaidLogStatusNames.Open,
        RaidLogRatingNames.Critical
      ), // Open, Risk, Critical
      RaidLogTestDataFactory.create(
        projectId,
        RaidLogUtils.getActionRecordTypeId,
        RaidLogStatusNames.Open,
        RaidLogRatingNames.Low
      ), // Open, Action
      RaidLogTestDataFactory.create(
        projectId,
        RaidLogUtils.getIssueRecordTypeId,
        RaidLogStatusNames.Open,
        RaidLogRatingNames.Low
      ), // Open, Issue
      RaidLogTestDataFactory.create(
        projectId,
        RaidLogUtils.getDecisionRecordTypeId,
        RaidLogStatusNames.Open,
        RaidLogRatingNames.Low
      ), // Open, Decision
      RaidLogTestDataFactory.create(
        projectId,
        RaidLogUtils.getRiskRecordTypeId,
        RaidLogStatusNames.Closed,
        RaidLogRatingNames.Critical
      ), // Closed, Risk, Critical
      RaidLogTestDataFactory.create(
        projectId,
        RaidLogUtils.getActionRecordTypeId,
        RaidLogStatusNames.Closed,
        RaidLogRatingNames.Strategic
      ), // Closed, Action
      RaidLogTestDataFactory.create(
        projectId,
        RaidLogUtils.getIssueRecordTypeId,
        RaidLogStatusNames.Closed,
        RaidLogRatingNames.Strategic
      ), // Closed, Issue
      RaidLogTestDataFactory.create(
        projectId,
        RaidLogUtils.getDecisionRecordTypeId,
        RaidLogStatusNames.Closed,
        RaidLogRatingNames.Strategic
      ) // Closed, Decision
    };
    insert raidLogList;

    WeeklyStatusReportFactory wsrFactory = new WeeklyStatusReportFactory();
    WeeklyStatusReportDataAccess wsrDataAccess = new WeeklyStatusReportDataAccess();
    Project__c daProject = wsrDataAccess.getProject(projectId);
    List<WeeklyStatusReport.RaidLogRow> expectedReportRaidLogList = wsrFactory.createRaidLogs(
      daProject.RAID_Log__r
    );

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.areEqual(
      expectedReportRaidLogList.size(),
      report.RaidLogs.size(),
      'Unexpected number of RAID Logs in report'
    );
    for (Integer i = 0; i < report.RaidLogs.size(); ++i) {
      Assert.areEqual(
        expectedReportRaidLogList[i].Type,
        report.RaidLogs[i].Type,
        'Unexpected Type on RAID Log in report RAID Log list with index ' + i
      );
      Assert.areEqual(
        expectedReportRaidLogList[i].Rating,
        report.RaidLogs[i].Rating,
        'Unexpected Rating on RAID Log in report RAID Log list with index ' + i
      );
    }
  }

  @isTest
  public static void testBuildMeetings() {
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
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.areEqual('Meeting minutes.', report.Meeting.Notes, 'The notes');
    Assert.areEqual(
      'Weekly Status Report',
      report.Meeting.ReportName,
      'The report name'
    );
    Assert.areEqual(Date.today(), report.Meeting.ReportDate, 'The date');
  }

  @isTest
  public static void testHasBlockedWorkItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );
    Id featureId = ProjectFeatureTestDataFactory.create(projectId);

    WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Blocked,
      'Testing blocked work item'
    );
    WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Backlog,
      ''
    );

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.areEqual(
      'Blocked',
      report.BlockedWorkItems[0].Status,
      'The status should be Blocked'
    );
  }

  @isTest
  public static void testHasNoBlockedWorkItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );
    Id featureId = ProjectFeatureTestDataFactory.create(projectId);

    WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Approved,
      ''
    );
    WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Backlog,
      ''
    );

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.isTrue(
      report.BlockedWorkItems.isEmpty(),
      'There should be no blocked work items'
    );
  }

  @isTest
  public static void testBuildOpenUATItems() {
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
    // Refresh list to retrieve auto-calculated count fields after insert
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

    WeeklyStatusReportFactory wsrFactory = new WeeklyStatusReportFactory();
    wsrFactory.createOpenUATItems(uatFeedbackList);

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.areEqual(1, report.OpenUATItems.size(), 'The count should be 1');
    Assert.areEqual(
      'Open',
      report.OpenUATItems[0].Status,
      'The status should be Open'
    );
    Assert.areEqual(
      openFeedback.Feedback_Subject__c,
      report.OpenUATItems[0].Subject,
      'Unexpected subject on item'
    );
    Assert.areEqual(
      openFeedback.Open_Count__c,
      report.OpenUATItems[0].OpenStatusCount,
      'Unexpected Open count on item'
    );
    Assert.areEqual(
      openFeedback.WIP_Count__c,
      report.OpenUATItems[0].WIPStatusCount,
      'Unexpected WIP status count on item'
    );
    Assert.areEqual(
      openFeedback.Re_Test_Count__c,
      report.OpenUATItems[0].ReTestStatusCount,
      'Unexpected Re-Test status count on item'
    );
    Assert.areEqual(
      openFeedback.Closed_Count__c,
      report.OpenUATItems[0].ClosedStatusCount,
      'Unexpected Closed status count on item'
    );
  }

  @isTest
  public static void testBuildNoOpenUATItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<UAT_Feedback__c> uatFeedbackList = new List<UAT_Feedback__c>{
      createInMemoryUATFeedback('Test Feedback 2', 'WIP', projectId),
      createInMemoryUATFeedback('Test Feedback 3', 'Re-Test', projectId),
      createInMemoryUATFeedback('Test Feedback 4', 'Closed', projectId)
    };
    insert uatFeedbackList;

    WeeklyStatusReportFactory wsrFactory = new WeeklyStatusReportFactory();
    wsrFactory.createUATItems(uatFeedbackList, 'Open');

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.isTrue(
      report.OpenUATItems.isEmpty(),
      'There should be no Open UAT items'
    );
  }

  @isTest
  public static void testBuildWIPUATItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<UAT_Feedback__c> uatFeedbackList = new List<UAT_Feedback__c>{
      createInMemoryUATFeedback('Test Feedback 2', 'WIP', projectId),
      createInMemoryUATFeedback('Test Feedback 1', 'Open', projectId),
      createInMemoryUATFeedback('Test Feedback 3', 'Re-Test', projectId),
      createInMemoryUATFeedback('Test Feedback 4', 'Closed', projectId)
    };
    insert uatFeedbackList;
    // Refresh list to retrieve auto-calculated count fields after insert
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
      WHERE Id = :uatFeedbackList[0].ID
      LIMIT 1
    ];

    WeeklyStatusReportFactory wsrFactory = new WeeklyStatusReportFactory();
    wsrFactory.createWIPUATItems(uatFeedbackList);

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.areEqual(1, report.WIPUATItems.size(), 'The count should be 1');
    Assert.areEqual(
      'WIP',
      report.WIPUATItems[0].Status,
      'The status should be WIP'
    );
    Assert.areEqual(
      wipFeedback.Feedback_Subject__c,
      report.WIPUATItems[0].Subject,
      'Unexpected subject on item'
    );
    Assert.areEqual(
      wipFeedback.WIP_Count__c,
      report.WIPUATItems[0].WIPStatusCount,
      'Unexpected Open count on item'
    );
    Assert.areEqual(
      wipFeedback.WIP_Count__c,
      report.WIPUATItems[0].WIPStatusCount,
      'Unexpected WIP status count on item'
    );
    Assert.areEqual(
      wipFeedback.Re_Test_Count__c,
      report.WIPUATItems[0].ReTestStatusCount,
      'Unexpected Re-Test status count on item'
    );
    Assert.areEqual(
      wipFeedback.Closed_Count__c,
      report.WIPUATItems[0].ClosedStatusCount,
      'Unexpected Closed status count on item'
    );
  }

  @isTest
  public static void testBuildNoWIPUATItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<UAT_Feedback__c> uatFeedbackList = new List<UAT_Feedback__c>{
      createInMemoryUATFeedback('Test Feedback 2', 'Open', projectId),
      createInMemoryUATFeedback('Test Feedback 3', 'Re-Test', projectId),
      createInMemoryUATFeedback('Test Feedback 4', 'Closed', projectId)
    };
    insert uatFeedbackList;

    WeeklyStatusReportFactory wsrFactory = new WeeklyStatusReportFactory();
    wsrFactory.createUATItems(uatFeedbackList, 'WIP');

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.isTrue(
      report.WIPUATItems.isEmpty(),
      'There should be no WIP UAT items'
    );
  }

  @isTest
  public static void testBuildReTestUATItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<UAT_Feedback__c> uatFeedbackList = new List<UAT_Feedback__c>{
      createInMemoryUATFeedback('Test Feedback 3', 'Re-Test', projectId),
      createInMemoryUATFeedback('Test Feedback 1', 'Open', projectId),
      createInMemoryUATFeedback('Test Feedback 2', 'WIP', projectId),
      createInMemoryUATFeedback('Test Feedback 4', 'Closed', projectId)
    };
    insert uatFeedbackList;
    // Refresh list to retrieve auto-calculated count fields after insert
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
      WHERE Id = :uatFeedbackList[0].ID
      LIMIT 1
    ];

    WeeklyStatusReportFactory wsrFactory = new WeeklyStatusReportFactory();
    wsrFactory.createReTestUATItems(uatFeedbackList);

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.areEqual(1, report.ReTestUATItems.size(), 'The count should be 1');
    Assert.areEqual(
      'Re-Test',
      report.ReTestUATItems[0].Status,
      'The status should be Re-Test'
    );
    Assert.areEqual(
      reTestFeedback.Feedback_Subject__c,
      report.ReTestUATItems[0].Subject,
      'Unexpected subject on item'
    );
    Assert.areEqual(
      reTestFeedback.Re_Test_Count__c,
      report.ReTestUATItems[0].ReTestStatusCount,
      'Unexpected Open count on item'
    );
    Assert.areEqual(
      reTestFeedback.WIP_Count__c,
      report.ReTestUATItems[0].WIPStatusCount,
      'Unexpected WIP status count on item'
    );
    Assert.areEqual(
      reTestFeedback.Re_Test_Count__c,
      report.ReTestUATItems[0].ReTestStatusCount,
      'Unexpected Re-Test status count on item'
    );
    Assert.areEqual(
      reTestFeedback.Closed_Count__c,
      report.ReTestUATItems[0].ClosedStatusCount,
      'Unexpected Closed status count on item'
    );
  }

  @isTest
  public static void testBuildNoReTestUATItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<UAT_Feedback__c> uatFeedbackList = new List<UAT_Feedback__c>{
      createInMemoryUATFeedback('Test Feedback 2', 'Open', projectId),
      createInMemoryUATFeedback('Test Feedback 3', 'WIP', projectId),
      createInMemoryUATFeedback('Test Feedback 4', 'Closed', projectId)
    };
    insert uatFeedbackList;

    WeeklyStatusReportFactory wsrFactory = new WeeklyStatusReportFactory();
    wsrFactory.createUATItems(uatFeedbackList, 'Re-Test');

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.isTrue(
      report.ReTestUATItems.isEmpty(),
      'There should be no Re-Test UAT items'
    );
  }

  @isTest
  public static void testBuildClosedUATItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<UAT_Feedback__c> uatFeedbackList = new List<UAT_Feedback__c>{
      createInMemoryUATFeedback('Test Feedback 4', 'Closed', projectId),
      createInMemoryUATFeedback('Test Feedback 1', 'Open', projectId),
      createInMemoryUATFeedback('Test Feedback 2', 'WIP', projectId),
      createInMemoryUATFeedback('Test Feedback 3', 'Re-Test', projectId)
    };
    insert uatFeedbackList;
    // Refresh list to retrieve auto-calculated count fields after insert
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
      WHERE Id = :uatFeedbackList[0].ID
      LIMIT 1
    ];

    WeeklyStatusReportFactory wsrFactory = new WeeklyStatusReportFactory();
    wsrFactory.createClosedUATItems(uatFeedbackList);

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.areEqual(1, report.ClosedUATItems.size(), 'The count should be 1');
    Assert.areEqual(
      'Closed',
      report.ClosedUATItems[0].Status,
      'The status should be Closed'
    );
    Assert.areEqual(
      closedFeedback.Feedback_Subject__c,
      report.ClosedUATItems[0].Subject,
      'Unexpected subject on item'
    );
    Assert.areEqual(
      closedFeedback.Closed_Count__c,
      report.ClosedUATItems[0].ClosedStatusCount,
      'Unexpected open count on item'
    );
    Assert.areEqual(
      closedFeedback.WIP_Count__c,
      report.ClosedUATItems[0].WIPStatusCount,
      'Unexpected WIP status count on item'
    );
    Assert.areEqual(
      closedFeedback.Re_Test_Count__c,
      report.ClosedUATItems[0].ReTestStatusCount,
      'Unexpected Re-Test status count on item'
    );
    Assert.areEqual(
      closedFeedback.Closed_Count__c,
      report.ClosedUATItems[0].ClosedStatusCount,
      'Unexpected Closed status count on item'
    );
  }

  @isTest
  public static void testBuildNoClosedUATItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<UAT_Feedback__c> uatFeedbackList = new List<UAT_Feedback__c>{
      createInMemoryUATFeedback('Test Feedback 2', 'Open', projectId),
      createInMemoryUATFeedback('Test Feedback 3', 'WIP', projectId),
      createInMemoryUATFeedback('Test Feedback 4', 'Re-Test', projectId)
    };
    insert uatFeedbackList;

    WeeklyStatusReportFactory wsrFactory = new WeeklyStatusReportFactory();
    wsrFactory.createUATItems(uatFeedbackList, 'Closed');

    // Act
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    WeeklyStatusReport report = builder.build(projectId);

    // Assert
    Assert.isTrue(
      report.ClosedUATItems.isEmpty(),
      'There should be no Closed UAT items'
    );
  }

  @isTest
  public static void testGetProjectPlanImageId() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);

    // Add a PNG image
    ContentVersion imageVersion = new ContentVersion();
    imageVersion.Title = 'project-phases';
    imageVersion.PathOnClient = '/test-image.png';
    imageVersion.VersionData = Blob.valueOf(
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg=='
    );
    imageVersion.Origin = 'H';
    insert imageVersion;

    ContentDocumentLink imageLink = new ContentDocumentLink();
    imageLink.LinkedEntityId = projectId;
    imageLink.ContentDocumentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :imageVersion.Id
    ]
    .ContentDocumentId;
    imageLink.ShareType = 'V';
    insert imageLink;

    // Act
    Id imageId = new WeeklyStatusReportBuilder()
      .getProjectPlanImageId(projectId);

    // Assert
    System.assertEquals(
      imageVersion.Id,
      imageId,
      'The image ID should be the same as the one we inserted'
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