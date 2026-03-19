@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity')
public with sharing class WeeklyStatusReportFactory {
  public List<WeeklyStatusReport.PhaseRow> createPhases(
    List<Phase__c> phaseList
  ) {
    List<WeeklyStatusReport.PhaseRow> rowList = new List<WeeklyStatusReport.PhaseRow>();

    for (Phase__c phase : phaseList) {
      WeeklyStatusReport.PhaseRow row = new WeeklyStatusReport.PhaseRow();
      row.Name = phase.Name;
      row.StartDate = phase.Start_Date__c;
      row.EndDate = phase.End_Date__c;

      rowList.add(row);
    }

    return rowList;
  }

  public List<WeeklyStatusReport.UATRow> createOpenUATItems(
    List<UAT_Feedback__c> uatList
  ) {
    return this.createUATItems(uatList, UATItemStatusNames.Open);
  }
  public List<WeeklyStatusReport.UATRow> createWIPUATItems(
    List<UAT_Feedback__c> uatList
  ) {
    return this.createUATItems(uatList, UATItemStatusNames.WIP);
  }
  public List<WeeklyStatusReport.UATRow> createReTestUATItems(
    List<UAT_Feedback__c> uatList
  ) {
    return this.createUATItems(uatList, UATItemStatusNames.ReTest);
  }
  public List<WeeklyStatusReport.UATRow> createClosedUATItems(
    List<UAT_Feedback__c> uatList
  ) {
    return this.createUATItems(uatList, UATItemStatusNames.Closed);
  }

  @TestVisible
  private List<WeeklyStatusReport.UATRow> createUATItems(
    List<UAT_Feedback__c> uatList,
    String status
  ) {
    List<WeeklyStatusReport.UATRow> rowList = new List<WeeklyStatusReport.UATRow>();

    for (UAT_Feedback__c uat : uatList) {
      if (status != null && uat.Status_UAT_Feedback__c != status) {
        continue;
      }

      WeeklyStatusReport.UATRow row = new WeeklyStatusReport.UATRow();
      row.Status = uat.Status_UAT_Feedback__c;
      row.Subject = uat.Feedback_Subject__c;
      row.OpenStatusCount = uat.Open_Count__c;
      row.WIPStatusCount = uat.WIP_Count__c;
      row.ReTestStatusCount = uat.Re_Test_Count__c;
      row.ClosedStatusCount = uat.Closed_Count__c;

      rowList.add(row);
    }

    return rowList;
  }

  public WeeklyStatusReport.MeetingRow createMeeting(
    List<Project_Meeting__c> meetingList
  ) {
    WeeklyStatusReport.MeetingRow row = new WeeklyStatusReport.MeetingRow();

    if (meetingList.size() == 0) {
      return row;
    }

    Project_Meeting__c meeting = meetingList[0];

    row.Created = meeting.CreatedDate;
    row.Notes = meeting.Notes__c;
    row.ReportName = meeting.Project_Report_Name__c;
    row.ReportDate = meeting.Weekly_Status_Report_Date__c;
    row.Demo = meeting.Demo__c;
    row.Holidays = meeting.Holidays__c;
    row.NextMeeting = meeting.Date_of_Next_Meeting__c;

    return row;
  }

  public List<WeeklyStatusReport.RaidLogRow> createCriticalIssueLogs(
    List<RAID_Log__c> logList
  ) {
    return this.createRaidLogs(
      logList,
      null,
      RaidLogRatingNames.Critical,
      null
    );
  }

  public List<WeeklyStatusReport.RaidLogRow> createOpenRiskLogs(
    List<RAID_Log__c> logList
  ) {
    return this.createRaidLogs(
      logList,
      RaidLogStatusNames.Open,
      null,
      RaidLogUtils.getRiskRecordTypeId
    );
  }

  public List<WeeklyStatusReport.RaidLogRow> createOpenActionLogs(
    List<RAID_Log__c> logList
  ) {
    return this.createRaidLogs(
      logList,
      RaidLogStatusNames.Open,
      null,
      RaidLogUtils.getActionRecordTypeId
    );
  }

  public List<WeeklyStatusReport.RaidLogRow> createOpenIssueLogs(
    List<RAID_Log__c> logList
  ) {
    return this.createRaidLogs(
      logList,
      RaidLogStatusNames.Open,
      null,
      RaidLogUtils.getIssueRecordTypeId
    );
  }

  public List<WeeklyStatusReport.RaidLogRow> createOpenDecisionLogs(
    List<RAID_Log__c> logList
  ) {
    return this.createRaidLogs(
      logList,
      RaidLogStatusNames.Open,
      null,
      RaidLogUtils.getDecisionRecordTypeId
    );
  }

  public List<WeeklyStatusReport.RaidLogRow> createClosedRiskLogs(
    List<RAID_Log__c> logList
  ) {
    return this.createRaidLogs(
      logList,
      RaidLogStatusNames.Closed,
      null,
      RaidLogUtils.getRiskRecordTypeId
    );
  }

  public List<WeeklyStatusReport.RaidLogRow> createClosedActionLogs(
    List<RAID_Log__c> logList
  ) {
    return this.createRaidLogs(
      logList,
      RaidLogStatusNames.Closed,
      null,
      RaidLogUtils.getActionRecordTypeId
    );
  }

  public List<WeeklyStatusReport.RaidLogRow> createClosedIssueLogs(
    List<RAID_Log__c> logList
  ) {
    return this.createRaidLogs(
      logList,
      RaidLogStatusNames.Closed,
      null,
      RaidLogUtils.getIssueRecordTypeId
    );
  }

  public List<WeeklyStatusReport.RaidLogRow> createClosedDecisionLogs(
    List<RAID_Log__c> logList
  ) {
    return this.createRaidLogs(
      logList,
      RaidLogStatusNames.Closed,
      null,
      RaidLogUtils.getDecisionRecordTypeId
    );
  }

  @SuppressWarnings('PMD.OperationWithLimitsInLoop')
  public List<WeeklyStatusReport.RaidLogRow> createRaidLogs(
    List<RAID_Log__c> source
  ) {
    Map<String, List<WeeklyStatusReport.RaidLogItemRow>> raidLogsByType = new Map<String, List<WeeklyStatusReport.RaidLogItemRow>>();

    for (RAID_Log__c raidLog : source) {
      Boolean isFirstOfType = false;
      String type = [
        SELECT Name, RecordType.DeveloperName
        FROM RecordType
        WHERE Id = :raidLog.RecordTypeId
      ]
      .Name;
      String s1 = raidLog.Name;
      String s2 = s1.substringAfter('-');

      if (raidLog.Status__c == RaidLogStatusNames.Open) {
        if (!raidLogsByType.containsKey(type)) {
          isFirstOfType = true;
          raidLogsByType.put(
            type,
            new List<WeeklyStatusReport.RaidLogItemRow>()
          );
        }

        raidLogsByType.get(type)
          .add(
            new WeeklyStatusReport.RaidLogItemRow(
              s2,
              raidLog.CreatedDate,
              raidLog.Assign_To__r.Name,
              raidLog.Update__c,
              raidLog.Rating__c,
              raidLog.Subject__c,
              isFirstOfType
            )
          );
      }
    }

    List<WeeklyStatusReport.RaidLogRow> target = new List<WeeklyStatusReport.RaidLogRow>();

    for (String raidLogType : raidLogsByType.keySet()) {
      target.add(
        new WeeklyStatusReport.RaidLogRow(
          raidLogType,
          raidLogsByType.get(raidLogType)
        )
      );
    }

    return target;
  }

  private List<WeeklyStatusReport.RaidLogRow> createRaidLogs( //NOPMD
    List<RAID_Log__c> logList,
    String status,
    String rating,
    Id recordTypeId
  ) {
    List<WeeklyStatusReport.RaidLogRow> rowList = new List<WeeklyStatusReport.RaidLogRow>();

    for (RAID_Log__c log : logList) {
      if (status != null && log.Status__c != status) {
        continue;
      }

      if (rating != null && log.Rating__c != rating) {
        continue;
      }

      if (recordTypeId != null && log.RecordTypeId != recordTypeId) {
        continue;
      }
    }

    return rowList;
  }

  public List<WeeklyStatusReport.WorkItemRow> createWorkItems(
    List<Work_Item__c> workItemList,
    String status
  ) {
    List<WeeklyStatusReport.WorkItemRow> rowList = new List<WeeklyStatusReport.WorkItemRow>();

    for (Work_Item__c workItem : workItemList) {
      if (status != null && workItem.Status__c != status) {
        continue;
      }
      WeeklyStatusReport.WorkItemRow row = new WeeklyStatusReport.WorkItemRow();
      row.Status = workItem.Status__c;
      row.Feature = workItem.Feature__r.Name;
      row.Reference = workItem.Name;
      row.Subject = workItem.Subject__c;
      row.EstimatedTime = workItem.Est_Time__c;
      row.BlockedDate = workItem.Set_to_Blocked__c;
      row.BlockedReason = workItem.Blocked_Reason__c;
      row.BlockedAge = workItem.Blocked_Age__c;

      rowList.add(row);
    }

    return rowList;
  }

  public List<WeeklyStatusReport.WorkItemRow> createBlockedWorkItems(
    List<Work_Item__c> blockedList
  ) {
    return this.createWorkItems(blockedList, WorkItemStatusNames.Blocked);
  }
}