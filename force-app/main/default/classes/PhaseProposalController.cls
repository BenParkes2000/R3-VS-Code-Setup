public with sharing class PhaseProposalController {
    public PhaseProposal Proposal { get; private set; }

    public Integer Year {
        get {
            return System.today().year();
        }
    }

    public PhaseProposalController() {
        PhaseProposalBuilder builder = new PhaseProposalBuilder();
        this.Proposal = builder.Build(phaseId);
    }

    private Id PhaseId {
        get {
            String value = ApexPages.currentPage().getParameters().get('id');
            if(String.isBlank(value)) {
                throw new CustomException('Unable to find param id in query string, therefore, unable to generate Phase Proposal');
            }
            return Id.valueOf(value);
        }
    }

    public class CustomException extends Exception {
    }
}