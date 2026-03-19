public with sharing class TimesheetHelper {
  private static final String SCHEDULER_EVENT_TYPE_TIME_ENTRY = 'Time_Entry__c';
  private static final String SCHEDULER_EVENT_TYPE_EVENT = 'Event';

  @AuraEnabled(cacheable=true)
  public static Timesheet_Settings__c getCustomSettings() {
    return Timesheet_Settings__c.getOrgDefaults();
  }

  @AuraEnabled(cacheable=true)
  public static String getTimeEntryName(Id recordId) {
    return [
      SELECT Name
      FROM Time_Entry__c
      WHERE Id = :recordId
      WITH SECURITY_ENFORCED
    ]
    .Name;
  }

  @AuraEnabled(cacheable=true)
  public static List<DhtmlxSchedulerEvent> getSchedulerEvents() {
    Timesheet_Settings__c settings = getCustomSettings();
    List<DhtmlxSchedulerEvent> schedulerEvents = new List<DhtmlxSchedulerEvent>();
    Integer numOfDays = settings.Number_of_Days__c.intValue();
    Date nDaysAgo = System.today().addDays(-numOfDays);

    for (Time_Entry__c timeEntry : [
      SELECT
        Id,
        Name,
        Description__c,
        Is_Billable__c,
        Start__c,
        Stop__c,
        Work_Item__c
      FROM Time_Entry__c
      WHERE
        User_Is_Current_User__c = TRUE
        AND Start__c != NULL
        AND Start__c > :nDaysAgo
        AND Stop__c != NULL
      WITH SECURITY_ENFORCED
    ]) {
      DhtmlxSchedulerEvent schedulerEvent = new DhtmlxSchedulerEvent();
      schedulerEvent.id = timeEntry.Id;
      schedulerEvent.color = String.isBlank(timeEntry.Work_Item__c)
        ? settings.Draft_Event_Colour__c
        : timeEntry.Is_Billable__c
            ? settings.Billable_Event_Colour__c
            : settings.Non_Billable_Event_Colour__c;
      schedulerEvent.end_date = timeEntry.Stop__c;
      schedulerEvent.info = timeEntry.Name;
      schedulerEvent.is_billable = timeEntry.Is_Billable__c;
      schedulerEvent.readonly = false;
      schedulerEvent.start_date = timeEntry.Start__c;
      schedulerEvent.text = timeEntry.Description__c;
      schedulerEvent.type = SCHEDULER_EVENT_TYPE_TIME_ENTRY;
      schedulerEvent.work_item_id = timeEntry.Work_Item__c;
      schedulerEvents.add(schedulerEvent);
    }

    for (Event event : [
      SELECT Id, Description, EndDateTime, StartDateTime, Subject
      FROM Event
      WHERE OwnerId = :UserInfo.getUserId() AND StartDateTime > :nDaysAgo
      WITH SECURITY_ENFORCED
    ]) {
      DhtmlxSchedulerEvent schedulerEvent = new DhtmlxSchedulerEvent();
      schedulerEvent.id = event.Id;
      schedulerEvent.color = settings.Default_Event_Colour__c;
      schedulerEvent.info = event.Description;
      schedulerEvent.end_date = event.EndDateTime;
      schedulerEvent.readonly = true;
      schedulerEvent.start_date = event.StartDateTime;
      schedulerEvent.text = event.Subject;
      schedulerEvent.type = SCHEDULER_EVENT_TYPE_EVENT;
      schedulerEvents.add(schedulerEvent);
    }

    return schedulerEvents;
  }
}