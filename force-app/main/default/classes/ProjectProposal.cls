@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class ProjectProposal {
  private Project__c project;

  public List<TeamMemberRow> teamMembers { get; set; }
  public List<FeatureRow> features { get; set; }
  public List<FeatureRow> optionalFeatures { get; set; }
  public List<ServiceRow> services { get; set; }
  public List<AssumptionRow> assumptions { get; set; }
  public List<LicenseRow> licenses { get; set; }
  public List<PersonaRow> personas { get; set; }
  public List<UserStoryRow> userStories { get; set; }
  public List<AcceptanceCriteriaRow> acceptanceCriterias { get; set; }
  public List<BusinessRequirementRow> businessRequirements { get; set; }
  public List<RaidLogRow> raidLogs { get; set; }

  public List<ContentVersion> files { get; set; }

  public String accountName {
    get {
      return this.project.Account__r.Name;
    }
  }

  public String projectName {
    get {
      if (this.project.Title__c == null) {
        return this.project.Name;
      } else {
        return this.project.Title__c;
      }
    }
  }

  public Boolean hasTableOfContents {
    get {
      return this.project.Hide_Table_of_Contents__c == false;
    }
  }

  public Boolean hasIntroduction {
    get {
      return String.isNotBlank(this.project.Introduction__c);
    }
  }

  public String introduction {
    get {
      return this.hasIntroduction
        ? StringUtil.removeBlankLinesFromRichText(this.project.Introduction__c)
        : '';
    }
  }

  public Boolean hasChallenges {
    get {
      return String.isNotBlank(this.project.Challenges__c);
    }
  }

  public String challenges {
    get {
      return this.hasChallenges
        ? StringUtil.removeBlankLinesFromRichText(this.project.Challenges__c)
        : '';
    }
  }

  public Boolean hasInScope {
    get {
      return String.isNotBlank(this.project.In_Scope__c);
    }
  }

  public String inScope {
    get {
      return this.hasInScope
        ? StringUtil.removeBlankLinesFromRichText(this.project.In_Scope__c)
        : '';
    }
  }

  public Boolean hasOutOfScope {
    get {
      return String.isNotBlank(this.project.Out_of_Scope__c);
    }
  }

  public String outOfScope {
    get {
      return this.hasOutOfScope
        ? StringUtil.removeBlankLinesFromRichText(this.project.Out_of_Scope__c)
        : '';
    }
  }

  public Boolean hasBusinessRequirements {
    get {
      return this.project.Hide_Business_Requirements__c == false &&
        this.businessRequirements.size() > 0;
    }
  }

  public Boolean hasRequirements {
    get {
      return this.project.Hide_Requirements__c == false;
    }
  }

  public Boolean hasPersonas {
    get {
      return this.project.Hide_Personas__c == false && this.personas.size() > 0;
    }
  }

  public Boolean hasAcceptanceCriteria {
    get {
      return this.project.Hide_Acceptance_Criteria__c == false &&
        this.acceptanceCriterias.size() > 0;
    }
  }

  public Boolean hasUserStories {
    get {
      return this.project.Hide_User_Stories__c == false &&
        this.userStories.size() > 0;
    }
  }

  public Boolean hasOurApproach {
    get {
      return this.project.Hide_Our_Approach__c == false;
    }
  }

  public Boolean hasProjectManagementDelivery {
    get {
      return this.project.Hide_Project_Management_Delivery__c == false;
    }
  }

  public Boolean hasRaidLog {
    get {
      return this.project.Hide_RAID_Log__c == false && this.raidLogs.size() > 0;
    }
  }

  public Boolean hasTeamMembers {
    get {
      return this.teamMembers.size() > 0;
    }
  }

  public Boolean hasServices {
    get {
      return this.services.size() > 0 && this.project.Hide_Services__c == false;
    }
  }

  public Boolean hasRecommendedOptions {
    get {
      return this.optionalFeatures.size() > 0;
    }
  }

  public Boolean hasPaymentTerms {
    get {
      return String.isNotBlank(this.project.Payment_Terms__c);
    }
  }

  public String paymentTerms {
    get {
      return this.hasPaymentTerms
        ? StringUtil.removeBlankLinesFromRichText(this.project.Payment_Terms__c)
        : '';
    }
  }

  public Boolean displayProjectManagementEstTime {
    get {
      return this.projectManagementEstTime != 0 && this.project.Is_PreSales__c;
    }
  }

  public Boolean displayDiscoveryEstTime {
    get {
      return this.discoveryEstTime != 0 && this.project.Is_PreSales__c;
    }
  }

  public Boolean displayDesignAnalysisEstTime {
    get {
      return this.designAnalysisEstTime != 0 && this.project.Is_PreSales__c;
    }
  }

  public Boolean displayTestingEstTime {
    get {
      return this.testingEstTime != 0 && this.project.Is_PreSales__c;
    }
  }

  public Boolean displayUATEstTime {
    get {
      return this.uatEstTime != 0 && this.project.Is_PreSales__c;
    }
  }

  public Boolean displayTrainingAndDocumentationEstTime {
    get {
      return this.trainingAndDocumentationEstTime != 0 &&
        this.project.Is_PreSales__c;
    }
  }

  public Boolean displayHypercareEstTime {
    get {
      return this.hypercareEstTime != 0 && this.project.Is_PreSales__c;
    }
  }

  public String status {
    get {
      return this.project.Status__c;
    }
  }

  public Decimal projectManagementEstTime {
    get {
      return this.project.Project_Management_Est__c;
    }
  }

  public Decimal discoveryEstTime {
    get {
      return this.project.Discovery_Est__c;
    }
  }

  public Decimal designAnalysisEstTime {
    get {
      return this.project.Design_Analysis_Est__c;
    }
  }

  public Decimal testingEstTime {
    get {
      return this.project.Testing_Est__c;
    }
  }

  public Decimal uatEstTime {
    get {
      return this.project.UAT_Est__c;
    }
  }

  public Decimal trainingAndDocumentationEstTime {
    get {
      return this.project.Training_Documentation_Est__c;
    }
  }

  public Decimal hypercareEstTime {
    get {
      return this.project.Hypercare_Est__c;
    }
  }

  public Decimal totalEstTime {
    get {
      return this.project.Total_Estimate__c;
    }
  }

  public Decimal totalEstDays {
    get {
      return this.project.Total_Est_Days__c;
    }
  }

  public Decimal totalEstCost {
    get {
      return this.project.Total_Est_Cost__c;
    }
  }

  public String currencySymbol {
    get {
      return CurrencyUtils.getSymbol(this.project.CurrencyIsoCode);
    }
  }

  public Boolean hasAssumptions {
    get {
      return this.project.Hide_Assumptions__c == false &&
        this.assumptions.size() > 0;
    }
  }

  public Boolean hasLicenses {
    get {
      return this.licenses.size() > 0;
    }
  }

  public String vendor {
    get {
      return String.isBlank(this.project.Vendor__c)
        ? 'Salesforce'
        : this.project.Vendor__c;
    }
  }

  public Boolean isVendorSalesforce {
    get {
      return this.project.Vendor__c == ProjectVendorNames.Salesforce;
    }
  }

  public Boolean isVendorHubSpot {
    get {
      return this.project.Vendor__c == ProjectVendorNames.HubSpot;
    }
  }

  public Decimal proposalHourlyRate {
    get {
      return this.project.Proposal_Hourly_Rate__c;
    }
  }

  public Boolean hasAppendix {
    get {
      return this.hasAcceptanceCriteria ||
        this.hasRaidLog ||
        this.hasAssumptions;
    }
  }

  public ProjectProposal(Project__c project) {
    this.project = project;
    this.files = new List<ContentVersion>();
    this.teamMembers = new List<TeamMemberRow>();
    this.features = new List<FeatureRow>();
    this.optionalFeatures = new List<FeatureRow>();
    this.services = new List<ServiceRow>();
    this.assumptions = new List<AssumptionRow>();
    this.licenses = new List<LicenseRow>();
    this.personas = new List<PersonaRow>();
    this.userStories = new List<UserStoryRow>();
    this.acceptanceCriterias = new List<AcceptanceCriteriaRow>();
    this.businessRequirements = new List<BusinessRequirementRow>();
    this.raidLogs = new List<RaidLogRow>();
  }

  public class TeamMemberRow {
    public String role { get; set; }
    public String name { get; set; }
    public String email { get; set; }
    public String phone { get; set; }
  }

  public class FeatureRow {
    public String name { get; private set; }
    public String description { get; private set; }
    public Decimal estTime { get; private set; }
    public List<WorkItemRow> workItems { get; private set; }

    public Integer workItemRowCount {
      get {
        return WorkItems.size();
      }
    }

    public Decimal estDays {
      get {
        return this.estTime / 8;
      }
    }

    public FeatureRow(Project_Feature__c feature, List<WorkItemRow> workItems) {
      this.name = feature.Name;
      this.description = String.isNotBlank(feature.Description__c)
        ? StringUtil.removeBlankLinesFromRichText(feature.Description__c)
        : '';
      this.estTime = feature.Total_Est__c;
      this.workItems = workItems;
    }
  }

  public class WorkItemRow {
    public String subject { get; private set; }
    public String description { get; private set; }
    public String mscw { get; private set; }
    public Decimal estTime { get; private set; }
    public Boolean showFeatureName { get; private set; }

    public Boolean hasDescription {
      get {
        return String.isNotBlank(this.description);
      }
    }

    public WorkItemRow(Work_Item__c workItem, Boolean showFeatureName) {
      this.subject = workItem.Subject__c;
      this.description = String.isNotBlank(workItem.Description__c)
        ? StringUtil.removeBlankLinesFromRichText(workItem.Description__c)
        : '';
      this.mscw = this.getMscwFromImportance(workItem.Importance__c);
      this.estTime = workItem.Est_Time__c;
      this.showFeatureName = showFeatureName;
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
    public String name { get; set; }
    public String description { get; set; }
    public Decimal estCost { get; set; }
    public String currencySymbol { get; set; }

    public Boolean hasDescription {
      get {
        return String.isNotBlank(this.description);
      }
    }
  }

  public class AssumptionRow {
    public String area { get; private set; }
    public String assumption { get; private set; }

    public AssumptionRow(String area, String assumption) {
      this.area = area;
      this.assumption = assumption;
    }
  }

  public class LicenseRow {
    public String license { get; private set; }
    public Integer quantity { get; private set; }

    public LicenseRow(String license, Decimal quantity) {
      this.license = license;
      this.quantity = Integer.valueOf(quantity);
    }
  }

  public class PersonaRow {
    public String name { get; private set; }
    public String description { get; private set; }

    public PersonaRow(String name, String description) {
      this.name = name;
      this.description = description;
    }
  }

  public class UserStoryRow {
    public String title { get; private set; }

    public UserStoryRow(String title) {
      this.title = title;
    }
  }

  public class AcceptanceCriteriaRow {
    public String userStory { get; private set; }
    public List<AcceptanceCriteriaItemRow> items { get; private set; }

    public Integer itemRowCount {
      get {
        return this.items.size();
      }
    }

    public AcceptanceCriteriaRow(
      String userStory,
      List<AcceptanceCriteriaItemRow> items
    ) {
      this.userStory = userStory;
      this.items = items;
    }
  }

  public class AcceptanceCriteriaItemRow {
    public String given { get; private set; }
    public String whenString { get; private set; }
    public String thenString { get; private set; }
    public Boolean showUserStory { get; private set; }

    public AcceptanceCriteriaItemRow( // NOPMD
      String given,
      String whenString,
      String thenString,
      Boolean showUserStory
    ) {
      this.given = given;
      this.whenString = whenString;
      this.thenString = thenString;
      this.showUserStory = showUserStory;
    }
  }

  public class BusinessRequirementRow {
    public String name { get; private set; }
    public String description { get; private set; }

    public BusinessRequirementRow(String name, String description) {
      this.name = name;
      this.description = description;
    }
  }

  public class RaidLogRow {
    public String type { get; private set; }
    public List<RaidLogItemRow> items { get; private set; }

    public Integer itemRowCount {
      get {
        return this.items.size();
      }
    }

    public RaidLogRow(String type, List<RaidLogItemRow> items) {
      this.type = type;
      this.items = items;
    }
  }

  public class RaidLogItemRow {
    public String rating { get; private set; }
    public String subject { get; private set; }
    public Boolean showType { get; private set; }

    public RaidLogItemRow(String rating, String subject, Boolean showType) {
      this.rating = rating;
      this.subject = subject;
      this.showType = showType;
    }
  }
}