public with sharing class ProjectProposalBuilder {
  private ProjectProposalFactory factory;
  private ProjectProposalDataAccess dataAccess;

  public ProjectProposalBuilder() {
    factory = new ProjectProposalFactory();
    dataAccess = new ProjectProposalDataAccess();
  }

  public ProjectProposal build(Id projectId) {
    Project__c project = dataAccess.getProject(projectId);
    List<Project_Feature__c> features = dataAccess.getFeatures(projectId);
    List<Third_Party_Service__c> services = dataAccess.getServices(projectId);
    List<Salesforce_License__c> licenses = dataAccess.getLicenses(projectId);
    List<Persona__c> personas = dataAccess.getPersonas(project.Account__c);
    List<User_Story__c> userStories = dataAccess.getUserStories(projectId);
    List<Acceptance_Criteria__c> acceptanceCriterias = dataAccess.getAcceptanceCriterias(
      projectId
    );
    List<Business_Requirement__c> businessRequirements = dataAccess.getBusinessRequirements(
      projectId
    );
    List<RAID_Log__c> raidLogs = dataAccess.getRaidLogs(projectId);
    List<Assumption__c> assumptions = dataAccess.getAssumptions(projectId);

    ProjectProposal proposal = new ProjectProposal(project);
    proposal.features = factory.createFeatures(features);
    proposal.optionalFeatures = factory.createOptionalFeatures(features);
    proposal.files = dataAccess.getFiles(projectId);
    proposal.services = factory.createServices(services);
    proposal.teamMembers = factory.createTeamMembers(
      dataAccess.getProjectTeamMembers(projectId)
    );
    proposal.assumptions = factory.createAssumptions(assumptions);
    proposal.licenses = factory.createLicenses(licenses);
    proposal.personas = factory.createPersonas(personas);
    proposal.userStories = factory.createUserStories(userStories);
    proposal.acceptanceCriterias = factory.createAcceptanceCriterias(
      acceptanceCriterias
    );
    proposal.businessRequirements = factory.createBusinessRequirements(
      businessRequirements
    );
    proposal.raidLogs = factory.createRaidLogs(raidLogs);

    return proposal;
  }
}