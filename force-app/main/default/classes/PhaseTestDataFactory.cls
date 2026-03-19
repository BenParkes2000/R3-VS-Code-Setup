public class PhaseTestDataFactory {
  public static Phase__c create(Id projectId) {
    return create(projectId, 'Phase X');
  }

  public static Phase__c create(Id projectId, String name) {
    Phase__c phase = new Phase__c();
    phase.Name = name;
    phase.Project__c = projectId;
    phase.Start_Date__c = Date.today();
    phase.End_Date__c = (Date.today() + 28);

    return phase;
  }

  public static Phase__c createWithDates(
    Id projectId,
    Date startDate,
    Date endDate
  ) {
    Phase__c phase = create(projectId);
    phase.Start_Date__c = startDate;
    phase.End_Date__c = endDate;

    return phase;
  }

  public static Phase__c createMilestone(Id projectId, Date milestoneDate) {
    Phase__c phase = new Phase__c();
    phase.Name = 'Milestone X';
    phase.Project__c = projectId;
    phase.Milestone_Date__c = milestoneDate;

    return phase;
  }
}