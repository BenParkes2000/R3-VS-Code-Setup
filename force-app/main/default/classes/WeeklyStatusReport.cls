@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class WeeklyStatusReport {
  private Project__c project;

  public List<UATRow> UAT { get; set; } //NOPMD
  public List<UATRow> OpenUATItems { get; set; } //NOPMD
  public List<UATRow> WIPUATItems { get; set; } //NOPMD
  public List<UATRow> ReTestUATItems { get; set; } //NOPMD
  public List<UATRow> ClosedUATItems { get; set; } //NOPMD
  public List<PhaseRow> Phases { get; set; } //NOPMD
  public List<RaidLogRow> CriticalIssueLogs { get; set; } //NOPMD
  public List<RaidLogRow> OpenRiskLogs { get; set; } //NOPMD
  public List<RaidLogRow> OpenActionLogs { get; set; } //NOPMD
  public List<RaidLogRow> OpenIssueLogs { get; set; } //NOPMD
  public List<RaidLogRow> OpenDecisionLogs { get; set; } //NOPMD
  public List<RaidLogRow> ClosedRiskLogs { get; set; } //NOPMD
  public List<RaidLogRow> ClosedActionLogs { get; set; } //NOPMD
  public List<RaidLogRow> ClosedIssueLogs { get; set; } //NOPMD
  public List<RaidLogRow> ClosedDecisionLogs { get; set; } //NOPMD
  public MeetingRow Meeting { get; set; } //NOPMD
  public Id ProjectPhasesImageId { get; set; } //NOPMD
  public List<WorkItemRow> BlockedWorkItems { get; set; } //NOPMD
  public List<RaidLogRow> RaidLogs { get; set; } //NOPMD

  public String AccountName { //NOPMD
    get {
      return this.project.Account__r.Name;
    }
  }

  public String ProjectName { //NOPMD
    get {
      return this.project.Name;
    }
  }

  public String currencySymbol {
    get {
      if (this.project.CurrencyIsoCode == 'USD') {
        return '$';
      } else if (this.project.CurrencyIsoCode == 'GBP') {
        return '£';
      } else if (this.project.CurrencyIsoCode == 'EUR') {
        return '€';
      }

      return '';
    }
  }

  public Decimal TotalPOBudget { //NOPMD
    get {
      return this.project.Total_PO_Budget__c;
    }
  }

  public Decimal TotalActualBillable { //NOPMD
    get {
      return this.project.Total_Actual_Billable__c;
    }
  }

  public Decimal RemainingPOBudget { //NOPMD
    get {
      return this.project.Remaining_PO_Budget__c;
    }
  }

  public Boolean showFinancials {
    get {
      return this.project.Show_Financials__c;
    }
  }

  public String ResourceLabel { //NOPMD
    get {
      return this.project.Resource__c;
    }
  }

  public String Resource { //NOPMD
    get {
      String resource;
      if (this.project.Resource__c == 'On Track') {
        resource = 'OnTrack';
      } else if (this.project.Resource__c == 'Caution') {
        resource = 'Caution';
      } else {
        resource = 'Impact';
      }

      return resource;
    }
  }

  public String ScheduleLabel { //NOPMD
    get {
      return this.project.Schedule__c;
    }
  }

  public String Schedule { //NOPMD
    get {
      String schedule;
      if (this.project.Schedule__c == 'On Track') {
        schedule = 'OnTrack';
      } else if (this.project.Schedule__c == 'Caution') {
        schedule = 'Caution';
      } else {
        schedule = 'Impact';
      }
      return schedule;
    }
  }

  public String ScopeLabel { //NOPMD
    get {
      return this.project.Scope__c;
    }
  }

  public String Scope { //NOPMD
    get {
      String scope;
      if (this.project.Scope__c == 'On Track') {
        scope = 'OnTrack';
      } else if (this.project.Scope__c == 'Caution') {
        scope = 'Caution';
      } else {
        scope = 'Impact';
      }

      return scope;
    }
  }

  public String BudgetLabel { //NOPMD
    get {
      return this.project.Budget__c;
    }
  }

  public String Budget { //NOPMD
    get {
      String budget;
      if (this.project.Budget__c == 'On Track') {
        budget = 'OnTrack';
      } else if (this.project.Budget__c == 'Caution') {
        budget = 'Caution';
      } else {
        budget = 'Impact';
      }

      return budget;
    }
  }

  public String CustomerSentiment { //NOPMD
    get {
      return this.project.Customer_Sentiment__c;
    }
  }

  public String ProjectStatusLabel { //NOPMD
    get {
      return this.project.Project_Status__c;
    }
  }

  public String ProjectStatus { //NOPMD
    get {
      String status;
      if (this.project.Project_Status__c == 'On Track') {
        status = 'OnTrack';
      } else if (this.project.Project_Status__c == 'Caution') {
        status = 'Caution';
      } else {
        status = 'Impact';
      }

      return status;
    }
  }

  public String ProjectStatusUpdate { //NOPMD
    get {
      return this.project.Project_Update__c;
    }
  }

  public Date ProjectReportDate { //NOPMD
    get {
      return this.Meeting.ReportDate;
    }
  }

  public String ProjectReportName { //NOPMD
    get {
      return this.Meeting.ReportName;
    }
  }

  public Boolean hasPhases {
    get {
      return this.Phases.size() > 0;
    }
  }

  public Boolean hasUAT {
    get {
      return this.OpenUATItems.size() > 0;
    }
  }

  public Boolean hasNotes {
    get {
      return !String.isEmpty(this.Meeting.Notes);
    }
  }

  public Boolean hasDemo {
    get {
      return !String.isEmpty(this.Meeting.Demo);
    }
  }

  public Boolean hasHolidays {
    get {
      return !String.isEmpty(this.Meeting.Holidays);
    }
  }

  public Boolean hasNextMeeting {
    get {
      return this.Meeting.NextMeeting != null;
    }
  }

  public Date NextMeeting { //NOPMD
    get {
      return this.Meeting.NextMeeting;
    }
  }

  public Boolean hasBlockedWIs {
    get {
      return this.BlockedWorkItems.size() > 0;
    }
  }

  public Boolean hasCriticalIssueLogs {
    get {
      return this.CriticalIssueLogs.size() > 0;
    }
  }

  public Boolean hasOpenRiskLogs {
    get {
      return this.OpenRiskLogs.size() > 0;
    }
  }

  public Boolean hasOpenActionLogs {
    get {
      return this.OpenActionLogs.size() > 0;
    }
  }

  public Boolean hasOpenIssueLogs {
    get {
      return this.OpenIssueLogs.size() > 0;
    }
  }

  public Boolean hasOpenDecisionLogs {
    get {
      return this.OpenDecisionLogs.size() > 0;
    }
  }

  public Integer hasOpenUATItems {
    get {
      return this.OpenUATItems.size();
    }
  }

  public Integer hasWIPUATItems {
    get {
      return this.WIPUATItems.size();
    }
  }

  public Integer hasReTestUATItems {
    get {
      return this.ReTestUATItems.size();
    }
  }

  public Integer hasClosedUATItems {
    get {
      return this.ClosedUATItems.size();
    }
  }

  public Boolean hasRaidLogs {
    get {
      return this.RaidLogs.size() > 0;
    }
  }

  public Boolean hasProjectPhasesImage {
    get {
      return this.ProjectPhasesImageId != null;
    }
  }

  public WeeklyStatusReport(Project__c project) {
    this.project = project;
    this.UAT = new List<UATRow>();
    this.OpenUATItems = new List<UATRow>();
    this.WIPUATItems = new List<UATRow>();
    this.ReTestUATItems = new List<UATRow>();
    this.ClosedUATItems = new List<UATRow>();
    this.Meeting = new MeetingRow();
    this.CriticalIssueLogs = new List<RaidLogRow>();
    this.OpenRiskLogs = new List<RaidLogRow>();
    this.OpenActionLogs = new List<RaidLogRow>();
    this.OpenIssueLogs = new List<RaidLogRow>();
    this.OpenDecisionLogs = new List<RaidLogRow>();
    this.ClosedRiskLogs = new List<RaidLogRow>();
    this.ClosedActionLogs = new List<RaidLogRow>();
    this.ClosedIssueLogs = new List<RaidLogRow>();
    this.ClosedDecisionLogs = new List<RaidLogRow>();
    this.BlockedWorkItems = new List<WorkItemRow>();
    this.RaidLogs = new List<RaidLogRow>();
  }

  public class UATRow {
    public String Status { get; set; } //NOPMD
    public String Subject { get; set; } //NOPMD
    public Decimal OpenStatusCount { get; set; } //NOPMD
    public Decimal WIPStatusCount { get; set; } //NOPMD
    public Decimal ReTestStatusCount { get; set; } //NOPMD
    public Decimal ClosedStatusCount { get; set; } //NOPMD
  }

  public class PhaseRow {
    public String Name { get; set; } //NOPMD
    public Date StartDate { get; set; } //NOPMD
    public Date EndDate { get; set; } //NOPMD
  }

  public class MeetingRow { //NOPMD
    public Datetime Created { get; set; } //NOPMD
    public String Notes { get; set; } //NOPMD
    public String Demo { get; set; } //NOPMD
    public String Holidays { get; set; } //NOPMD
    public Date NextMeeting { get; set; } //NOPMD
    public String ReportName { get; set; } //NOPMD
    public Date ReportDate { get; set; } //NOPMD

    public List<String> formatAsList(String value) {
      if (String.isBlank(value)) {
        return new List<String>();
      }

      return value.split('\\r\\n|\\n|\\r');
    }
  }

  public class RaidLogRow {
    public String Assignee { get; set; } //NOPMD
    public Datetime CreatedDate { get; set; } //NOPMD
    public String Rating { get; set; } //NOPMD
    public String Reference { get; set; } //NOPMD
    public String Subject { get; set; } //NOPMD
    public String Type { get; set; } //NOPMD
    public String Update_x { get; set; } //NOPMD
    public List<RaidLogItemRow> Items { get; set; } //NOPMD

    public Integer ItemRowCount { //NOPMD
      get {
        return this.Items.size();
      }
    }

    public RaidLogRow(String type, List<RaidLogItemRow> items) {
      this.Type = type;
      this.Items = items;
    }
  }

  public class RaidLogItemRow {
    public String Assignee { get; set; } //NOPMD
    public Datetime CreatedDate { get; set; } //NOPMD
    public String Reference { get; set; } //NOPMD
    public String Rating { get; set; } //NOPMD
    public String Subject { get; set; } //NOPMD
    public String Update_x { get; set; } //NOPMD
    public Boolean ShowType { get; set; } //NOPMD

    public RaidLogItemRow( //NOPMD
      String reference,
      Datetime createdDate,
      String assignee,
      String update_x, //NOPMD
      String rating,
      String subject,
      Boolean showType
    ) {
      this.Rating = rating;
      this.Subject = subject;
      this.ShowType = showType;
      this.Assignee = assignee;
      this.CreatedDate = createdDate;
      this.Reference = reference;
      this.Update_x = update_x;
    }
  }

  public class WorkItemRow {
    public Decimal EstimatedTime { get; set; } //NOPMD
    public String Feature { get; set; } //NOPMD
    public String Reference { get; set; } //NOPMD
    public String Status { get; set; } //NOPMD
    public String Subject { get; set; } //NOPMD
    public Date BlockedDate { get; set; } //NOPMD
    public String BlockedReason { get; set; } //NOPMD
    public String BlockedAge { get; set; } //NOPMD
  }
}