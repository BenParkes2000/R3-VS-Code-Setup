@isTest
private class TimesheetHelperTest {
  private final static String BILLABLE_EVENT_COLOUR = 'green';
  private final static String DEFAULT_EVENT_COLOUR = 'blue';
  private final static String DRAFT_EVENT_COLOUR = 'grey';
  private final static String DRAFT_PROJECT_NAME = 'Draft Time Entry';
  private final static String NON_BILLABLE_EVENT_COLOUR = 'orange';
  private final static String RECORD_NAME = 'Test Record';
  private final static String USER_ID = UserInfo.getUserId();
  private final static String WORK_ITEM_TYPE = 'Work Item';
  private final static Integer NUM_OF_DAYS = 180;

  @TestSetup
  static void setup() {
    Timesheet_Settings__c settings = new Timesheet_Settings__c();
    settings.Billable_Event_Colour__c = BILLABLE_EVENT_COLOUR;
    settings.Default_Event_Colour__c = DEFAULT_EVENT_COLOUR;
    settings.Draft_Event_Colour__c = DRAFT_EVENT_COLOUR;
    settings.Draft_Project_Name__c = DRAFT_PROJECT_NAME;
    settings.Non_Billable_Event_Colour__c = NON_BILLABLE_EVENT_COLOUR;
    settings.Number_Of_Days__c = NUM_OF_DAYS;
    insert settings;

    Account account = new Account();
    account.Name = RECORD_NAME;
    insert account;

    Project__c project = new Project__c();
    project.Name = DRAFT_PROJECT_NAME;
    project.Account__c = account.Id;
    project.Start_Date__c = Date.today();
    project.End_Date__c = Date.today().addDays(1);
    project.Support_Type__c = 'MSA';
    insert project;

    Time_Entry__c timeEntry = new Time_Entry__c();
    timeEntry.User__c = USER_ID;
    timeEntry.Start__c = DateTime.now().addHours(1);
    timeEntry.Stop__c = DateTime.now().addHours(2);
    insert timeEntry;
  }

  @isTest
  static void testGetTimeEntryName() {
    Time_Entry__c timeEntry = [SELECT Id, Name FROM Time_Entry__c LIMIT 1];
    Test.startTest();
    String timeEntryName = TimesheetHelper.getTimeEntryName(timeEntry.Id);
    Test.stopTest();
    System.assertEquals(
      timeEntryName,
      timeEntry.Name,
      'The method should return the time entry name'
    );
  }

  @isTest
  static void testGetSchedulerEvents() {
    Id projectId = [SELECT Id FROM Project__c LIMIT 1].Id;

    Event testEvent = new Event();
    testEvent.EndDateTime = DateTime.now().addHours(3);
    testEvent.StartDateTime = DateTime.now().addHours(2);
    testEvent.Subject = RECORD_NAME;
    testEvent.OwnerId = USER_ID;
    insert testEvent;

    Project_Feature__c feature = new Project_Feature__c();
    feature.Name = RECORD_NAME;
    feature.Project__c = projectId;
    insert feature;

    Work_Item__c workItem = new Work_Item__c();
    workItem.Type__c = WORK_ITEM_TYPE;
    workItem.Feature__c = feature.Id;
    workItem.Project__c = projectId;
    insert workItem;

    Time_Entry__c timeEntryNonBillable = new Time_Entry__c();
    timeEntryNonBillable.Work_Item__c = workItem.Id;
    timeEntryNonBillable.Is_Billable__c = false;
    timeEntryNonBillable.User__c = USER_ID;
    timeEntryNonBillable.Start__c = DateTime.now().addHours(3);
    timeEntryNonBillable.Stop__c = DateTime.now().addHours(4);

    Time_Entry__c timeEntryBillable = new Time_Entry__c();
    timeEntryBillable.Work_Item__c = workItem.Id;
    timeEntryBillable.Is_Billable__c = true;
    timeEntryBillable.User__c = USER_ID;
    timeEntryBillable.Start__c = DateTime.now().addHours(4);
    timeEntryBillable.Stop__c = DateTime.now().addHours(5);
    insert new List<Time_Entry__c>{ timeEntryNonBillable, timeEntryBillable };

    Test.startTest();
    List<DhtmlxSchedulerEvent> result = TimesheetHelper.getSchedulerEvents();
    Test.stopTest();

    System.assertEquals(
      4,
      result.size(),
      'The method should return four events'
    );
    for (DhtmlxSchedulerEvent event : result) {
      if (event.type == 'Event') {
        System.assertEquals(
          DEFAULT_EVENT_COLOUR,
          event.color,
          'The event should be default'
        );
      }
      if (event.type != 'Event' && String.isBlank(event.work_item_id)) {
        System.assertEquals(
          DRAFT_EVENT_COLOUR,
          event.color,
          'The event should be draft'
        );
      }
      if (!String.isBlank(event.work_item_id) && event.is_billable == false) {
        System.assertEquals(
          NON_BILLABLE_EVENT_COLOUR,
          event.color,
          'The event should be non-billable'
        );
      }
      if (!String.isBlank(event.work_item_id) && event.is_billable) {
        System.assertEquals(
          BILLABLE_EVENT_COLOUR,
          event.color,
          'The event should be billable'
        );
      }
    }
  }
}