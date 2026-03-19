public with sharing class WeeklyStatusReportBuilder {
  private WeeklyStatusReportFactory factory;
  private WeeklyStatusReportDataAccess dataAccess;

  public WeeklyStatusReportBuilder() {
    this.factory = new WeeklyStatusReportFactory();
    this.dataAccess = new WeeklyStatusReportDataAccess();
  }

  public WeeklyStatusReport build(Id projectId) {
    Project__c project = dataAccess.getProject(projectId);

    WeeklyStatusReport report = new WeeklyStatusReport(project);
    report.OpenUATItems = factory.createOpenUATItems(
      project.UAT_Feedback_Records__r
    );
    report.WIPUATItems = factory.createWIPUATItems(
      project.UAT_Feedback_Records__r
    );
    report.ReTestUATItems = factory.createReTestUATItems(
      project.UAT_Feedback_Records__r
    );
    report.ClosedUATItems = factory.createClosedUATItems(
      project.UAT_Feedback_Records__r
    );
    report.Phases = factory.createPhases(project.Phases__r);
    report.Meeting = factory.createMeeting(project.Project_Meetings__r);
    report.CriticalIssueLogs = factory.createCriticalIssueLogs(
      project.RAID_Log__r
    );
    report.OpenRiskLogs = factory.createOpenRiskLogs(project.RAID_Log__r);
    report.OpenActionLogs = factory.createOpenActionLogs(project.RAID_Log__r);
    report.OpenIssueLogs = factory.createOpenIssueLogs(project.RAID_Log__r);
    report.OpenDecisionLogs = factory.createOpenDecisionLogs(
      project.RAID_Log__r
    );
    report.ClosedRiskLogs = factory.createClosedRiskLogs(project.RAID_Log__r);
    report.ClosedActionLogs = factory.createClosedActionLogs(
      project.RAID_Log__r
    );
    report.ClosedIssueLogs = factory.createClosedIssueLogs(project.RAID_Log__r);
    report.ClosedDecisionLogs = factory.createClosedDecisionLogs(
      project.RAID_Log__r
    );
    report.BlockedWorkItems = factory.createBlockedWorkItems(
      project.Work_Items__r
    );
    report.ProjectPhasesImageId = this.getProjectPlanImageId(projectId);
    report.RaidLogs = factory.createRaidLogs(project.RAID_Log__r);

    return report;
  }

  @TestVisible
  @SuppressWarnings('PMD.ApexCRUDViolation')
  private Id getProjectPlanImageId(Id projectId) {
    List<ContentDocumentLink> documentLinks = [
      SELECT ContentDocument.Title, ContentDocument.LatestPublishedVersionId
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :projectId
        AND ContentDocument.Title = 'project-phases'
        AND ContentDocument.FileType = 'PNG'
      LIMIT 1
    ];

    if (documentLinks.size() == 0) {
      return null;
    }

    return documentLinks[0].ContentDocument.LatestPublishedVersionId;
  }
}