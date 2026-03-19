@isTest
public class TimeEntryTestDataFactory {
    public static Id create(Id projectId, Id workItemId) {
        Time_Entry__c timeEntry = new Time_Entry__c();
        timeEntry.Work_Item__c = workItemId;
        timeEntry.Project__c = projectId;
        timeEntry.Start__c = Datetime.now();
        insert timeEntry;
        return timeEntry.Id;
    }
}