public with sharing class GanttChartTaskTransformer {
  private Id Id; // NOPMD
  private String Name; //NOPMD
  private Date StartDate; //NOPMD
  private Date EndDate; //NOPMD
  private Date MilestoneDate; //NOPMD
  private Integer Duration; //NOPMD
  private Decimal TotalHours; //NOPMD
  private Integer PercentAllocated; //NOPMD
  private List<SObject> WorkItems; //NOPMD

  public GanttChartTaskTransformer(SObject obj, Decimal totalHours) {
    Set<String> objectFields = obj.getSObjectType()
      .getDescribe()
      .fields.getMap()
      .keySet();

    this.Id = obj.Id;
    this.Name = String.valueOf(obj.get('Name'));
    this.StartDate = Date.valueOf(obj.get('Start_Date__c'));
    this.EndDate = Date.valueOf(obj.get('End_Date__c'));
    this.MilestoneDate = (objectFields.contains('milestone_date__c')
      ? Date.valueOf(obj.get('Milestone_Date__c'))
      : null);
    this.Duration = Integer.valueOf(obj.get('Duration__c'));
    this.TotalHours = totalHours;
    this.PercentAllocated = Integer.valueOf(
      this.Duration > 0 &&
        this.TotalHours > 0
        ? (100 /
            Decimal.valueOf(this.Duration) *
            this.TotalHours)
            .round(System.RoundingMode.HALF_UP)
        : 0
    );
    try {
      this.WorkItems = obj.getSObjects('Work_Items__r');
    } catch (SObjectException e) {
      this.WorkItems = new List<SObject>();
    }
  }

  @AuraEnabled
  public Id getId() {
    return this.Id;
  }

  @AuraEnabled
  public String getName() {
    return this.Name;
  }

  @AuraEnabled
  public Date getStartDate() {
    return this.StartDate;
  }

  @AuraEnabled
  public Date getEndDate() {
    return this.EndDate;
  }

  @AuraEnabled
  public Date getMilestoneDate() {
    return this.MilestoneDate;
  }

  @AuraEnabled
  public Integer getDuration() {
    return this.Duration;
  }

  @AuraEnabled
  public Decimal getTotalHours() {
    return this.TotalHours;
  }

  @AuraEnabled
  public Integer getPercentAllocated() {
    return this.PercentAllocated;
  }

  @AuraEnabled
  public List<SObject> getWorkItems() {
    return this.WorkItems;
  }
}