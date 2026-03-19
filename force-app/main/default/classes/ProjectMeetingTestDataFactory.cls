@isTest
public class ProjectMeetingTestDataFactory {
  public static Project_Meeting__c create(Id projectId) {
    Project_Meeting__c meeting = new Project_Meeting__c();
    meeting.Project__c = projectId;
    meeting.Attendees__c = 'Bob\nJim';
    meeting.Notes__c = 'Meeting minutes.';
    meeting.Weekly_Status_Report_Date__c = Date.today();

    return meeting;
  }
}