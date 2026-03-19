public with sharing class MoscowProjectProposalController {
    public ProjectProposal Proposal { get; private set; }
    public Decimal M_Hours { get; private set; }
    public Decimal M_Days { get; private set; }
    public Decimal M_Cost { get; private set; }
    public Decimal MS_Hours { get; private set; }
    public Decimal MS_Days { get; private set; }
    public Decimal MS_Cost { get; private set; }
    public Decimal MSC_Hours { get; private set; }
    public Decimal MSC_Days { get; private set; }
    public Decimal MSC_Cost { get; private set; }
    public Decimal MSCW_Hours { get; private set; }
    public Decimal MSCW_Days { get; private set; }
    public Decimal MSCW_Cost { get; private set; }

    public Integer Year {
        get {
            return System.today().year();
        }
    }

    @TestVisible
    private Id ProjectId {
        get {
            String value = ApexPages.currentPage().getParameters().get('id');

            if (String.isBlank(value)) {
                throw new CustomException('Unable to find param id in query string, therefore, unable to generate MoSCoW Project Proposal');
            }

            return Id.valueOf(value);
        }
    }

    public MoscowProjectProposalController() {
        ProjectProposalBuilder builder = new ProjectProposalBuilder();
        this.Proposal = builder.Build(projectId);
        this.cacheMoscowTotals();
    }

    @TestVisible
    private void cacheMoscowTotals() {
        this.M_Hours = 0;
        this.M_Days = 0;
        this.M_Cost = 0;

        this.MS_Hours = 0;
        this.MS_Days = 0;
        this.MS_Cost = 0;

        this.MSC_Hours = 0;
        this.MSC_Days = 0;
        this.MSC_Cost = 0;

        this.MSCW_Hours = 0;
        this.MSCW_Days = 0;
        this.MSCW_Cost = 0;

        List<String> must = new List<String>{ WorkItemImportanceNames.MUST_HAVE_LABEL };
        List<String> mustShould = new List<String>{ WorkItemImportanceNames.MUST_HAVE_LABEL, WorkItemImportanceNames.SHOULD_HAVE_LABEL };
        List<String> mustShouldCould = new List<String>{ WorkItemImportanceNames.MUST_HAVE_LABEL, WorkItemImportanceNames.SHOULD_HAVE_LABEL, WorkItemImportanceNames.COULD_HAVE_LABEL };
        List<String> mustShouldCouldWont = new List<String>{
            WorkItemImportanceNames.MUST_HAVE_LABEL,
            WorkItemImportanceNames.SHOULD_HAVE_LABEL,
            WorkItemImportanceNames.COULD_HAVE_LABEL,
            WorkItemImportanceNames.WONT_HAVE_LABEL
        };

        for (ProjectProposal.FeatureRow feature : this.Proposal.Features) {
            for (ProjectProposal.WorkItemRow workItem : feature.WorkItems) {
                if (must.contains(WorkItem.MSCW)) {
                    this.M_Hours += workItem.EstTime;
                }

                if (mustShould.contains(WorkItem.MSCW)) {
                    this.MS_Hours += workItem.EstTime;
                }

                if (mustShouldCould.contains(WorkItem.MSCW)) {
                    this.MSC_Hours += workItem.EstTime;
                }

                if (mustShouldCouldWont.contains(WorkItem.MSCW)) {
                    this.MSCW_Hours += workItem.EstTime;
                }
            }
        }

        this.M_Days = this.M_Hours / 8;
        this.M_Cost = this.M_Hours * this.Proposal.ProposalHourlyRate;
        this.MS_Days = this.MS_Hours / 8;
        this.MS_Cost = this.MS_Hours * this.Proposal.ProposalHourlyRate;
        this.MSC_Days = this.MSC_Hours / 8;
        this.MSC_Cost = this.MSC_Hours * this.Proposal.ProposalHourlyRate;
        this.MSCW_Days = this.MSCW_Hours / 8;
        this.MSCW_Cost = this.MSCW_Hours * this.Proposal.ProposalHourlyRate;
    }

    public class CustomException extends Exception {
    }
}