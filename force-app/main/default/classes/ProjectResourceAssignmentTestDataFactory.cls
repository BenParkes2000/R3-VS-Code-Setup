// TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
@SuppressWarnings('PMD.ApexSharingViolations')
public class ProjectResourceAssignmentTestDataFactory {
  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexCRUDViolation')
  public static Id create(
    Id projectId,
    Id userId,
    Date startDate,
    Date endDate,
    Decimal hoursPerDay
  ) {
    Project_Resource_Assignment__c resource = new Project_Resource_Assignment__c();
    resource.Project__c = projectId;
    resource.User__c = userId;
    resource.Start_Date__c = startDate;
    resource.End_Date__c = endDate;
    resource.Hours_Per_Day__c = hoursPerDay;
    insert resource;
    return resource.Id;
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public static Project_Resource_Assignment__c create(
    Id userId,
    Id projectId,
    Decimal rate,
    Date startDate,
    Decimal hoursMonday,
    Decimal hoursTuesday,
    Decimal hoursWednesday,
    Decimal hoursThursday,
    Decimal hoursFriday
  ) {
    Project_Resource_Assignment__c resourceAssignment = new Project_Resource_Assignment__c();
    resourceAssignment.User__c = userId;
    resourceAssignment.Project__c = projectId;
    resourceAssignment.Rate__c = rate;
    resourceAssignment.Start_Date__c = startDate;
    resourceAssignment.Hours_Monday__c = hoursMonday;
    resourceAssignment.Hours_Tuesday__c = hoursTuesday;
    resourceAssignment.Hours_Wednesday__c = hoursWednesday;
    resourceAssignment.Hours_Thursday__c = hoursThursday;
    resourceAssignment.Hours_Friday__c = hoursFriday;

    return resourceAssignment;
  }
}