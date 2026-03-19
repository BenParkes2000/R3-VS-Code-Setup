@isTest
public class WeeklyStatusReportFactoryTest {
  @isTest
  public static void testCreatePhases() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    List<Phase__c> phaseList = new List<Phase__c>{
      PhaseTestDataFactory.create(projectId, 'Phase 1'),
      PhaseTestDataFactory.create(projectId, 'Phase 2')
    };

    // Act
    WeeklyStatusReportFactory factory = new WeeklyStatusReportFactory();
    List<WeeklyStatusReport.PhaseRow> rows = factory.createPhases(phaseList);

    // Assert
    System.assertEquals(2, rows.size(), 'There should be 2 rows');
    System.assertEquals(
      'Phase 1',
      rows[0].Name,
      'The first row should be Phase 1'
    );
    System.assertEquals(
      'Phase 2',
      rows[1].Name,
      'The second row should be Phase 2'
    );
  }

  @isTest
  public static void testCreateMeeting() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    List<Project_Meeting__c> meetingList = new List<Project_Meeting__c>{
      ProjectMeetingTestDataFactory.create(projectId)
    };

    // Act
    WeeklyStatusReportFactory factory = new WeeklyStatusReportFactory();
    WeeklyStatusReport.MeetingRow row = factory.createMeeting(meetingList);

    // Assert
    System.assertEquals(
      'Meeting minutes.',
      row.Notes,
      'The notes should be "Meeting minutes."'
    );
    System.assertEquals(
      Date.today(),
      row.ReportDate,
      'The report date should be today'
    );
  }

  @isTest
  public static void testCreateWorkItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id featureId = ProjectFeatureTestDataFactory.create(projectId);
    Id workItem1Id = WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Blocked,
      'Testing blocked work item'
    );
    Id workItem2Id = WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Blocked,
      'Testing blocked work item'
    );
    Id workItem3Id = WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Approved,
      ''
    );
    Id workItem4Id = WorkItemTestDataFactory.create(
      projectId,
      featureId,
      WorkItemStatusNames.Backlog,
      ''
    );

    List<Work_Item__c> workItemList = [
      SELECT
        Status__c,
        Feature__r.Name,
        Name,
        Subject__c,
        Est_Time__c,
        Set_to_Blocked__c,
        Blocked_Reason__c,
        Blocked_Age__c
      FROM Work_Item__c
      WHERE Id IN (:workItem1Id, :workItem2Id, :workItem3Id, :workItem4Id)
    ];

    // Act
    WeeklyStatusReportFactory factory = new WeeklyStatusReportFactory();
    List<WeeklyStatusReport.WorkItemRow> rows = factory.createWorkItems(
      workItemList,
      WorkItemStatusNames.Blocked
    );

    // Assert
    Assert.areEqual(2, rows.size(), 'There should be 2 work item rows');
    Assert.areEqual(
      WorkItemStatusNames.Blocked,
      rows[0].Status,
      'The first work item row should be Blocked'
    );
    Assert.areEqual(
      WorkItemStatusNames.Blocked,
      rows[1].Status,
      'The second work item row should be Blocked'
    );
  }
}