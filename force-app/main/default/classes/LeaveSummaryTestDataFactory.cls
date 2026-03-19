// TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
@SuppressWarnings('PMD.ApexSharingViolations')
public class LeaveSummaryTestDataFactory {
  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexCRUDViolation')
  public static Id create(
    Id ownerId,
    String year,
    Date startDate,
    Date endDate
  ) {
    Leave_Summary__c summary = new Leave_Summary__c();
    summary.OwnerId = ownerId;
    summary.Year__c = year;
    summary.Start_Date__c = startDate;
    summary.End_Date__c = endDate;
    insert summary;
    return summary.Id;
  }
}