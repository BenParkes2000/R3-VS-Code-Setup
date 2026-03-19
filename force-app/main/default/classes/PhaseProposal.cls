// TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class PhaseProposal {
  private Phase__c phase;
  //private Project__c project;

  public List<TeamMemberRow> TeamMembers { get; set; } // NOPMD
  public List<FeatureRow> Features { get; set; } // NOPMD
  public List<FeatureRow> OptionalFeatures { get; set; } // NOPMD
  public List<ServiceRow> Services { get; set; } // NOPMD
  public List<AssumptionRow> Assumptions { get; set; } // NOPMD
  public List<LicenseRow> Licenses { get; set; } // NOPMD

  public List<ContentVersion> Files { get; set; } // NOPMD

  public String AccountName { // NOPMD
    get {
      return this.phase.Project__r.Account__r.Name;
    }
  }

  public String ProjectName { // NOPMD
    get {
      return this.phase.Project__r.Name;
    }
  }

  public String PhaseName { // NOPMD
    get {
      return this.phase.Name;
    }
  }

  public String Stage { // NOPMD
    get {
      return this.phase.Stage__c;
    }
  }

  public Boolean hasTableOfContents {
    get {
      return this.phase.Project__r.Hide_Table_of_Contents__c == false;
    }
  }

  public Boolean hasIntroduction {
    get {
      return String.isNotBlank(this.phase.Description__c);
    }
  }

  public String Introduction { // NOPMD
    get {
      return this.hasIntroduction
        ? this.phase.Description__c.replace('<p><br></p>', '')
        : '';
    }
  }

  public Boolean hasChallenges {
    get {
      return String.isNotBlank(this.phase.Project__r.Challenges__c);
    }
  }

  public String Challenges { // NOPMD
    get {
      return this.hasChallenges
        ? this.phase.Project__r.Challenges__c.replace('<p><br></p>', '')
        : '';
    }
  }

  public Boolean hasRequirements {
    get {
      return this.phase.Project__r.Hide_Our_Approach__c == false;
    }
  }

  public Boolean hasProjectManagementDelivery {
    get {
      return this.phase.Project__r.Hide_Project_Management_Delivery__c == false;
    }
  }

  public Boolean hasTeamMembers {
    get {
      return this.TeamMembers.size() > 0;
    }
  }

  public Boolean hasServices {
    get {
      return this.Services.size() > 0 &&
        this.phase.Project__r.Hide_Services__c == false;
    }
  }

  public Decimal ProjectManagementEstTime { // NOPMD
    get {
      return this.phase.Project__r.Project_Management_Est__c;
    }
  }

  public Decimal TestingEstTime { // NOPMD
    get {
      return this.phase.Project__r.Testing_Est__c;
    }
  }

  public Decimal UATEstTime { // NOPMD
    get {
      return this.phase.Project__r.UAT_Est__c;
    }
  }

  public Decimal HypercareEstTime { // NOPMD
    get {
      return this.phase.Project__r.Hypercare_Est__c;
    }
  }

  public Decimal EstTotalProjectManagement { // NOPMD
    get {
      return ((this.phase.Project__r.Project_Management__c / 100) *
        this.phase.Total_Effort__c)
        .setScale(2, RoundingMode.HALF_UP);
    }
  }

  public Decimal EstTotalTesting { // NOPMD
    get {
      return ((this.phase.Project__r.Testing__c / 100) *
        this.phase.Total_Effort__c)
        .setScale(2, RoundingMode.HALF_UP);
    }
  }

  public Decimal EstTotalUAT { // NOPMD
    get {
      return ((this.phase.Project__r.UAT__c / 100) * this.phase.Total_Effort__c)
        .setScale(2, RoundingMode.HALF_UP);
    }
  }

  public Decimal EstTotalHypercare { // NOPMD
    get {
      return ((this.phase.Project__r.Hypercare__c / 100) *
        this.phase.Total_Effort__c)
        .setScale(2, RoundingMode.HALF_UP);
    }
  }

  public Decimal TotalEffort { // NOPMD
    get {
      return this.phase.Total_Effort__c;
    }
  }

  public Decimal TotalEstTime { // NOPMD
    get {
      return (this.TotalEffort).setScale(2, RoundingMode.HALF_UP);
    }
  }

  public Decimal TotalEstDays { // NOPMD
    get {
      return (this.TotalEstTime / 8).setScale(2, RoundingMode.HALF_UP);
    }
  }

  public Decimal TotalEstCost { // NOPMD
    get {
      return this.TotalEstTime * this.phase.Project__r.Proposal_Hourly_Rate__c;
    }
  }

  public String CurrencySymbol { // NOPMD
    get {
      return CurrencyUtils.getSymbol(this.phase.CurrencyIsoCode);
    }
  }

  public Boolean hasAssumptions {
    get {
      return this.phase.Project__r.Hide_Assumptions__c == false;
    }
  }

  public Boolean hasLicenses {
    get {
      return this.Licenses.size() > 0;
    }
  }

  public Decimal ProposalHourlyRate { // NOPMD
    get {
      return this.phase.Project__r.Proposal_Hourly_Rate__c;
    }
  }

  public PhaseProposal(Phase__c phase) {
    this.phase = phase;
    this.Files = new List<ContentVersion>();
    this.TeamMembers = new List<TeamMemberRow>();
    this.Features = new List<FeatureRow>();
    this.OptionalFeatures = new List<FeatureRow>();
    this.Services = new List<ServiceRow>();
    this.Assumptions = new List<AssumptionRow>();
    this.Licenses = new List<LicenseRow>();
  }
  public class TeamMemberRow {
    public String Role { get; set; } // NOPMD
    public String Name { get; set; } // NOPMD
    public String Email { get; set; } // NOPMD
    public String Phone { get; set; } // NOPMD
  }

  public class FeatureRow {
    public String Name { get; private set; } // NOPMD
    public String Description { get; private set; } // NOPMD
    public Decimal EstTime { get; private set; } // NOPMD
    public List<WorkItemRow> WorkItems { get; private set; } // NOPMD
    public Integer WorkItemRowCount { // NOPMD
      get {
        return WorkItems.size();
      }
    }

    public FeatureRow(Project_Feature__c feature, List<WorkItemRow> workItems) {
      this.Name = feature.Name;
      this.Description = String.isNotBlank(feature.Description__c)
        ? feature.Description__c.replace('<p><br></p>', '')
        : '';
      this.EstTime = 0;
      for (WorkItemRow workItem : workItems) {
        this.EstTime += workItem.EstTime;
      }
      this.WorkItems = workItems;
    }
  }

  public class WorkItemRow {
    public String Subject { get; private set; } // NOPMD
    public String Description { get; private set; } // NOPMD
    public String Name { get; private set; } // NOPMD
    public String MSCW { get; private set; } // NOPMD
    public Decimal EstTime { get; private set; } // NOPMD
    public Boolean ShowFeatureName { get; private set; } // NOPMD
    public Boolean HasDescription { // NOPMD
      get {
        return String.isNotBlank(this.Description);
      }
    }

    public WorkItemRow(Work_Item__c workItem, Boolean showFeatureName) {
      this.Subject = workItem.Subject__c;
      this.Description = String.isNotBlank(workItem.Description__c)
        ? workItem.Description__c.replace('<p><br></p>', '')
        : '';
      this.MSCW = this.getMscwFromImportance(workItem.Importance__c);
      this.EstTime = workItem.Est_Time__c;
      this.ShowFeatureName = showFeatureName;
      this.Name = workItem.Name;
    }

    private String getMscwFromImportance(String importance) {
      if (importance == WorkItemImportanceNames.MUST_HAVE_VALUE) {
        return WorkItemImportanceNames.MUST_HAVE_LABEL;
      } else if (importance == WorkItemImportanceNames.SHOULD_HAVE_VALUE) {
        return WorkItemImportanceNames.SHOULD_HAVE_LABEL;
      } else if (importance == WorkItemImportanceNames.COULD_HAVE_VALUE) {
        return WorkItemImportanceNames.COULD_HAVE_LABEL;
      } else if (importance == WorkItemImportanceNames.WONT_HAVE_VALUE) {
        return WorkItemImportanceNames.WONT_HAVE_LABEL;
      }

      return null;
    }
  }

  public class ServiceRow {
    public String Name { get; set; } // NOPMD
    public String Description { get; set; } // NOPMD
    public Decimal EstCost { get; set; } // NOPMD
    public String CurrencySymbol { get; set; } // NOPMD
    public Boolean HasDescription { // NOPMD
      get {
        return String.isNotBlank(this.Description);
      }
    }
  }

  public class AssumptionRow {
    public String Area { get; private set; } // NOPMD
    public String Assumptions { get; private set; } // NOPMD

    public AssumptionRow(String area, String assumptions) {
      this.Area = area;
      this.Assumptions = assumptions;
    }
  }

  public class LicenseRow {
    public String License { get; private set; } // NOPMD
    public Integer Quantity { get; private set; } // NOPMD

    public LicenseRow(String license, Decimal quantity) {
      this.License = license;
      this.Quantity = Integer.valueOf(quantity);
    }
  }
}