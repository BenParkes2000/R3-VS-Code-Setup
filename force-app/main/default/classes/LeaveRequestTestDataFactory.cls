// TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
@SuppressWarnings('PMD.ApexSharingViolations')
public class LeaveRequestTestDataFactory {
  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexCRUDViolation')
  public static Id create(
    Id leaveSummaryId,
    Date startDate,
    Decimal days,
    String status
  ) {
    Leave_Request__c request = new Leave_Request__c();
    request.Leave_Summary__c = leaveSummaryId;
    request.Start_Date__c = startDate;
    request.Days__c = days;
    request.Status__c = status;
    request.Leave_Type__c = 'Annual Leave';
    insert request;
    return request.Id;
  }
}