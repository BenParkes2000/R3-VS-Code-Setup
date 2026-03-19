public with sharing class WeeklyStatusReportDataAccess {
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public Project__c getProject(Id projectId) {
    return [
      SELECT
        Name,
        Account__r.Name,
        toLabel(Resource__c),
        toLabel(Schedule__c),
        toLabel(Scope__c),
        toLabel(Budget__c),
        Customer_Sentiment__c,
        Project_Status__c,
        Project_Update__c,
        Status__c,
        Sort_Order__c,
        Closed_Count__c,
        Total_PO_Budget__c,
        Total_Actual_Billable__c,
        Remaining_PO_Budget__c,
        CurrencyIsoCode,
        Show_Financials__c,
        (SELECT Name, Start_Date__c, End_Date__c FROM Phases__r),
        (
          SELECT
            Status_UAT_Feedback__c,
            Feedback_Subject__c,
            Open_Count__c,
            WIP_Count__c,
            Re_Test_Count__c,
            Closed_Count__c
          FROM UAT_Feedback_Records__r
        ),
        (
          SELECT
            Notes__c,
            CreatedDate,
            Project_Report_Name__c,
            Weekly_Status_Report_Date__c,
            Demo__c,
            Holidays__c,
            Date_of_Next_Meeting__c
          FROM Project_Meetings__r
          ORDER BY Weekly_Status_Report_Date__c DESC
          LIMIT 1
        ),
        (
          SELECT
            Assign_To__r.Name,
            Name,
            Rating__c,
            RecordTypeId,
            Subject__c,
            CreatedDate,
            Update__c,
            Status__c
          FROM RAID_Log__r
        ),
        (
          SELECT
            Status__c,
            Feature__r.Name,
            Name,
            Subject__c,
            Est_Time__c,
            Set_to_Blocked__c,
            Blocked_Reason__c,
            Blocked_Age__c
          FROM Work_Items__r
          WHERE Status__c = :WorkItemStatusNames.Blocked
          ORDER BY Status__c, Feature__r.Name, Name
        )
      FROM Project__c
      WHERE Id = :projectId
      ORDER BY Sort_Order__c ASC
    ];
  }
}