public with sharing class PhaseProposalFactory {
    private final String THIRD_PARTY_SERVICE = 'Third-Party Service';

    public List<PhaseProposal.FeatureRow> createFeatures(List<Project_Feature__c> features) {
        return createFeatureRows(features, false);
    }

    public List<PhaseProposal.FeatureRow> createOptionalFeatures(List<Project_Feature__c> features) {
        return createFeatureRows(features, true);
    }

    private List<PhaseProposal.FeatureRow> createFeatureRows(List<Project_Feature__c> features, Boolean isOptional) {
        List<PhaseProposal.FeatureRow> featureRows = new List<PhaseProposal.FeatureRow>();

        for(Project_Feature__c feature : features) {
            List<PhaseProposal.WorkItemRow> workItems = new List<PhaseProposal.WorkItemRow>();
            Boolean isFirstRow = true;
            for(Work_Item__c workItem : feature.Work_Items__r) {
                if(workItem.Is_Optional__c == isOptional) {
                    workItems.add(new PhaseProposal.WorkItemRow(workItem, isFirstRow));
                    isFirstRow = false;
                }
            }
            if(workItems.size() > 0) {
                featureRows.add(new PhaseProposal.FeatureRow(feature, workItems));
            }
        }
        return featureRows;
    }

    public List<PhaseProposal.AssumptionRow> createAssumptions(List<Project_Feature__c> features) {
        List<PhaseProposal.AssumptionRow> assumptionRows = new List<PhaseProposal.AssumptionRow>();

        for(Project_Feature__c feature : features) {
            String assumptions = '';
            for(Work_Item__c workItem : feature.Work_Items__r) {
                if(String.isNotBlank(workItem.Assumptions__c)) {
                    assumptions += workItem.Assumptions__c.replace('<p><br></p>', '');
                }
            }
            if(String.isNotEmpty(assumptions)) {
                assumptionRows.add(new PhaseProposal.AssumptionRow(feature.Name, assumptions));
            }
        }
        return assumptionRows;
    }

    public List<PhaseProposal.ServiceRow> createServices(List<Third_Party_Service__c> source) {
        List<PhaseProposal.ServiceRow> target = new List<PhaseProposal.ServiceRow>();
        for(Third_Party_Service__c service : source) {
            target.add(createServiceRow(service));
        }
        return target;
    }

    private PhaseProposal.ServiceRow createServiceRow(Third_Party_Service__c source) {
        PhaseProposal.ServiceRow target = new PhaseProposal.ServiceRow();
        target.Name = source.Service__c;
        target.Description = String.isNotBlank(source.Description__c) ? source.Description__c.replace('<p><br></p>', '') : '';
        target.EstCost = source.Est_Cost__c;
        target.CurrencySymbol = CurrencyUtils.getSymbol(source.CurrencyIsoCode);
        return target;
    }

    public List<PhaseProposal.TeamMemberRow> createTeamMembers(List<Project_Team_Member__c> source) {
        List<PhaseProposal.TeamMemberRow> target = new List<PhaseProposal.TeamMemberRow>();
        for(Project_Team_Member__c member : source) {
            target.add(createTeamMemberRow(member));
        }
        return target;
    }

    private PhaseProposal.TeamMemberRow createTeamMemberRow(Project_Team_Member__c source) {
        PhaseProposal.TeamMemberRow target = new PhaseProposal.TeamMemberRow();
        target.Email = source.Email__c;
        target.Phone = source.Phone__c;
        target.Name = source.Name__c;
        target.Role = source.Role__c;
        return target;
    }

    public List<PhaseProposal.LicenseRow> createLicenses(List<Salesforce_License__c> source) {
        List<PhaseProposal.LicenseRow> target = new List<PhaseProposal.LicenseRow>();

        for(Salesforce_License__c license : source) {
            target.add(new PhaseProposal.LicenseRow(license.License__c, license.Quantity__c));
        }
        return target;
    }
}