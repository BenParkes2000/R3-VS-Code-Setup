public with sharing class ProjectProposalFactory {
  public List<ProjectProposal.FeatureRow> createFeatures(
    List<Project_Feature__c> features
  ) {
    return createFeatureRows(features, false);
  }

  public List<ProjectProposal.FeatureRow> createOptionalFeatures(
    List<Project_Feature__c> features
  ) {
    return createFeatureRows(features, true);
  }

  private List<ProjectProposal.FeatureRow> createFeatureRows(
    List<Project_Feature__c> features,
    Boolean isOptional
  ) {
    List<ProjectProposal.FeatureRow> featureRows = new List<ProjectProposal.FeatureRow>();

    for (Project_Feature__c feature : features) {
      List<ProjectProposal.WorkItemRow> workItems = new List<ProjectProposal.WorkItemRow>();
      Boolean isFirstRow = true;
      for (Work_Item__c workItem : feature.Work_Items__r) {
        if (workItem.Is_Optional__c == isOptional) {
          workItems.add(new ProjectProposal.WorkItemRow(workItem, isFirstRow));
          isFirstRow = false;
        }
      }
      if (workItems.size() > 0) {
        featureRows.add(new ProjectProposal.FeatureRow(feature, workItems));
      }
    }
    return featureRows;
  }

  public List<ProjectProposal.AssumptionRow> createAssumptions(
    List<Assumption__c> source
  ) {
    List<ProjectProposal.AssumptionRow> target = new List<ProjectProposal.AssumptionRow>();

    for (Assumption__c assumption : source) {
      target.add(
        new ProjectProposal.AssumptionRow(
          assumption.Area__c,
          assumption.Assumption__c
        )
      );
    }

    return target;
  }

  public List<ProjectProposal.ServiceRow> createServices(
    List<Third_Party_Service__c> source
  ) {
    List<ProjectProposal.ServiceRow> target = new List<ProjectProposal.ServiceRow>();
    for (Third_Party_Service__c service : source) {
      target.add(createServiceRow(service));
    }
    return target;
  }

  private ProjectProposal.ServiceRow createServiceRow(
    Third_Party_Service__c source
  ) {
    ProjectProposal.ServiceRow target = new ProjectProposal.ServiceRow();
    target.Name = source.Service__c;
    target.Description = String.isNotBlank(source.Description__c)
      ? StringUtil.removeBlankLinesFromRichText(source.Description__c)
      : '';
    target.EstCost = source.Est_Cost__c;
    target.CurrencySymbol = CurrencyUtils.getSymbol(source.CurrencyIsoCode);
    return target;
  }

  public List<ProjectProposal.TeamMemberRow> createTeamMembers(
    List<Project_Team_Member__c> source
  ) {
    List<ProjectProposal.TeamMemberRow> target = new List<ProjectProposal.TeamMemberRow>();
    for (Project_Team_Member__c member : source) {
      target.add(createTeamMemberRow(member));
    }
    return target;
  }

  private ProjectProposal.TeamMemberRow createTeamMemberRow(
    Project_Team_Member__c source
  ) {
    ProjectProposal.TeamMemberRow target = new ProjectProposal.TeamMemberRow();
    target.Email = source.Email__c;
    target.Phone = source.Phone__c;
    target.Name = source.Name__c;
    target.Role = source.Role__c;
    return target;
  }

  public List<ProjectProposal.LicenseRow> createLicenses(
    List<Salesforce_License__c> source
  ) {
    List<ProjectProposal.LicenseRow> target = new List<ProjectProposal.LicenseRow>();

    for (Salesforce_License__c license : source) {
      target.add(
        new ProjectProposal.LicenseRow(license.License__c, license.Quantity__c)
      );
    }

    return target;
  }

  public List<ProjectProposal.PersonaRow> createPersonas(
    List<Persona__c> source
  ) {
    List<ProjectProposal.PersonaRow> target = new List<ProjectProposal.PersonaRow>();

    for (Persona__c persona : source) {
      target.add(
        new ProjectProposal.PersonaRow(persona.Name, persona.Description__c)
      );
    }

    return target;
  }

  public List<ProjectProposal.UserStoryRow> createUserStories(
    List<User_Story__c> source
  ) {
    List<ProjectProposal.UserStoryRow> target = new List<ProjectProposal.UserStoryRow>();

    for (User_Story__c userStory : source) {
      target.add(
        new ProjectProposal.UserStoryRow(userStory.User_Story_Title__c)
      );
    }

    return target;
  }

  public List<ProjectProposal.AcceptanceCriteriaRow> createAcceptanceCriterias(
    List<Acceptance_Criteria__c> source
  ) {
    Map<String, List<ProjectProposal.AcceptanceCriteriaItemRow>> acceptanceCriteriasByUserStory = new Map<String, List<ProjectProposal.AcceptanceCriteriaItemRow>>();

    for (Acceptance_Criteria__c acceptanceCriteria : source) {
      Boolean isFirstOfUserStory = false;

      if (
        !acceptanceCriteriasByUserStory.containsKey(
          acceptanceCriteria.User_Story__r.User_Story_Title__c
        )
      ) {
        isFirstOfUserStory = true;
        acceptanceCriteriasByUserStory.put(
          acceptanceCriteria.User_Story__r.User_Story_Title__c,
          new List<ProjectProposal.AcceptanceCriteriaItemRow>()
        );
      }

      acceptanceCriteriasByUserStory.get(
          acceptanceCriteria.User_Story__r.User_Story_Title__c
        )
        .add(
          new ProjectProposal.AcceptanceCriteriaItemRow(
            acceptanceCriteria.Given__c,
            acceptanceCriteria.When__c,
            acceptanceCriteria.Then__c,
            isFirstOfUserStory
          )
        );
    }

    List<ProjectProposal.AcceptanceCriteriaRow> target = new List<ProjectProposal.AcceptanceCriteriaRow>();

    for (String userStory : acceptanceCriteriasByUserStory.keySet()) {
      target.add(
        new ProjectProposal.AcceptanceCriteriaRow(
          userStory,
          acceptanceCriteriasByUserStory.get(userStory)
        )
      );
    }

    return target;
  }

  public List<ProjectProposal.BusinessRequirementRow> createBusinessRequirements(
    List<Business_Requirement__c> source
  ) {
    List<ProjectProposal.BusinessRequirementRow> target = new List<ProjectProposal.BusinessRequirementRow>();

    for (Business_Requirement__c businessRequirement : source) {
      target.add(
        new ProjectProposal.BusinessRequirementRow(
          businessRequirement.Name,
          businessRequirement.Description__c
        )
      );
    }

    return target;
  }

  public List<ProjectProposal.RaidLogRow> createRaidLogs(
    List<RAID_Log__c> source
  ) {
    Map<String, List<ProjectProposal.RaidLogItemRow>> raidLogsByType = new Map<String, List<ProjectProposal.RaidLogItemRow>>();

    for (RAID_Log__c raidLog : source) {
      Boolean isFirstOfType = false;

      if (!raidLogsByType.containsKey(raidLog.Type__c)) {
        isFirstOfType = true;
        raidLogsByType.put(
          raidLog.Type__c,
          new List<ProjectProposal.RaidLogItemRow>()
        );
      }

      raidLogsByType.get(raidLog.Type__c)
        .add(
          new ProjectProposal.RaidLogItemRow(
            raidLog.Rating__c,
            raidLog.Subject__c,
            isFirstOfType
          )
        );
    }

    List<ProjectProposal.RaidLogRow> target = new List<ProjectProposal.RaidLogRow>();

    for (String raidLogType : raidLogsByType.keySet()) {
      target.add(
        new ProjectProposal.RaidLogRow(
          raidLogType,
          raidLogsByType.get(raidLogType)
        )
      );
    }

    return target;
  }
}