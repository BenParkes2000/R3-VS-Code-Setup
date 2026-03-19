@isTest
public class WeeklyStatusReportTest {
  @isTest
  public static void testGetters() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Company');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    Project__c project = new Project__c(Id = projectId);
    project.Resource__c = 'OnTrack';
    project.Schedule__c = 'Caution';
    project.Scope__c = 'Impact';
    project.Budget__c = 'OnTrack';
    project.Customer_Sentiment__c = 'Caution';
    project.Project_Update__c = 'Update';
    project.Support_Type__c = 'MSA';
    update project;

    WeeklyStatusReportDataAccess dataAccess = new WeeklyStatusReportDataAccess();

    // Act
    WeeklyStatusReport report = new WeeklyStatusReport(
      dataAccess.getProject(projectId)
    );

    // Assert
    System.assertEquals('Test Company', report.AccountName, 'AccountName');
    System.assertEquals('Test Project', report.ProjectName, 'ProjectName');
    System.assertEquals('OnTrack', report.Resource, 'Resource');
    System.assertEquals('Caution', report.Schedule, 'Schedule');
    System.assertEquals('Impact', report.Scope, 'Scope');
    System.assertEquals('OnTrack', report.Budget, 'Budget');
    System.assertEquals(
      'Caution',
      report.CustomerSentiment,
      'CustomerSentiment'
    );
    System.assertEquals('Impact', report.ProjectStatus, 'ProjectStatus');
    System.assertEquals(
      'Update',
      report.ProjectStatusUpdate,
      'ProjectStatusUpdate'
    );
  }

  @isTest
  public static void testHasPhases() {
    List<WeeklyStatusReport.PhaseRow> phases = new List<WeeklyStatusReport.PhaseRow>();
    WeeklyStatusReport.PhaseRow phase = new WeeklyStatusReport.PhaseRow();
    phase.Name = 'Test Phase';
    phase.StartDate = Date.newInstance(2020, 1, 1);
    phase.EndDate = Date.newInstance(2020, 1, 31);
    phases.add(phase);
    WeeklyStatusReport report = new WeeklyStatusReport(new Project__c());
    report.Phases = phases;
    System.assertEquals(true, report.hasPhases, 'hasPhases');
  }

  @isTest
  public static void testHasNotes() {
    WeeklyStatusReport report = new WeeklyStatusReport(new Project__c());
    System.assertEquals(false, report.hasNotes, 'hasNotes');
    report.Meeting.Notes = 'Notes';
    System.assertEquals(true, report.hasNotes, 'hasNotes');
  }

  @isTest
  public static void testHasRaidLogs() {
    List<WeeklyStatusReport.RaidLogItemRow> raidLogs = new List<WeeklyStatusReport.RaidLogItemRow>();
    WeeklyStatusReport.RaidLogItemRow raidLog = new WeeklyStatusReport.RaidLogItemRow(
      'Reference',
      DateTime.now(),
      'Anna',
      'Update',
      'On Track',
      'Subject',
      false
    );
    raidLogs.add(raidLog);

    WeeklyStatusReport report = new WeeklyStatusReport(new Project__c());
    System.assertEquals(false, report.hasRaidLogs, 'hasRaidLogs');
    report.RaidLogs.add(new WeeklyStatusReport.RaidLogRow('Risk', raidLogs));
    System.assertEquals(true, report.hasRaidLogs, 'hasRaidLogs');
  }

  @isTest
  public static void testHasBlockedWorkItemsAfterConstruction() {
    // Arrange
    WeeklyStatusReport report = new WeeklyStatusReport(new Project__c());

    // Act
    Boolean hasBlockedWIsAfterConstruction = report.hasBlockedWIs;

    // Assert
    Assert.isFalse(
      hasBlockedWIsAfterConstruction,
      'hasBlockedWIs unexpectedly true after construction'
    );
  }

  @isTest
  public static void testHasBlockedWorkItemsAfterBlockedWorkItemAddition() {
    // Arrange
    WeeklyStatusReport report = new WeeklyStatusReport(new Project__c());
    report.BlockedWorkItems.add(new WeeklyStatusReport.WorkItemRow());

    // Act
    Boolean hasBlockedWIsAfterItemAddition = report.hasBlockedWIs;

    // Assert
    Assert.isTrue(
      hasBlockedWIsAfterItemAddition,
      'hasBlockedWIs unexpectedly false after blocked Work Item addition'
    );
  }

  @isTest
  public static void testHasNoBlockedWorkItemsAfterBlockedWorkItemListEmptied() {
    // Arrange
    WeeklyStatusReport report = new WeeklyStatusReport(new Project__c());
    report.BlockedWorkItems.add(new WeeklyStatusReport.WorkItemRow());
    report.BlockedWorkItems.clear();

    // Act
    Boolean hasBlockedWIsAfterItemListEmptied = report.hasBlockedWIs;

    // Assert
    Assert.isFalse(
      hasBlockedWIsAfterItemListEmptied,
      'hasBlockedWIs unexpectedly true after blocked Work Item list emptied'
    );
  }

  @isTest
  public static void testHasProjectPhasesImage() {
    WeeklyStatusReport report = new WeeklyStatusReport(new Project__c());
    System.assertEquals(
      false,
      report.hasProjectPhasesImage,
      'hasProjectPhasesImage'
    );
    report.ProjectPhasesImageId = '000000000000000AAA'; //NOPMD
    System.assertEquals(
      true,
      report.hasProjectPhasesImage,
      'hasProjectPhasesImage'
    );
  }

  @isTest
  public static void testMeetingRowFormatAsList() {
    // Arrange
    WeeklyStatusReport.MeetingRow row = new WeeklyStatusReport.MeetingRow();

    // Act
    List<String> result = row.formatAsList('Hello\nWorld!');

    // Assert
    System.assertEquals(
      new List<String>{ 'Hello', 'World!' },
      result,
      'formatAsList'
    );
  }
}