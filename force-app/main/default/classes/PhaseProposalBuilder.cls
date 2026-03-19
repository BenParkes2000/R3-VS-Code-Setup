public with sharing class PhaseProposalBuilder {
    private PhaseProposalFactory factory;
    private PhaseProposalDataAccess dataAccess;

    public PhaseProposalBuilder() {
        factory = new PhaseProposalFactory();
        dataAccess = new PhaseProposalDataAccess();
    }

    public PhaseProposal Build(Id phaseId) {
        Phase__c phase = dataAccess.getPhases(phaseId);
        List<Project_Feature__c> features = dataAccess.getFeatures(phaseId);
        //List<Third_Party_Service__c> services = dataAccess.getServices(phaseId);
        //List<Salesforce_License__c> licenses = dataAccess.getLicesnses(phaseId);

        PhaseProposal proposal = new PhaseProposal(phase);
        proposal.Features = factory.createFeatures(features);
        proposal.OptionalFeatures = factory.createOptionalFeatures(features);
        proposal.Files = dataAccess.getFiles(phaseId);
        //proposal.Services = factory.createServices(services);
        //proposal.TeamMembers = factory.createTeamMembers(dataAccess.getProjectTeamMembers(phaseId));
        // proposal.Assumptions = factory.createAssumptions(features);
        //proposal.Licenses = factory.createLicenses(licenses);

        return proposal;
    }
}