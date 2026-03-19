public with sharing class ProjectProposalController {
  public ProjectProposal proposal { get; private set; }

  public Integer year {
    get {
      return System.today().year();
    }
  }

  private Id projectId {
    get {
      String value = ApexPages.currentPage().getParameters().get('id');

      if (String.isBlank(value)) {
        throw new CustomException(
          'Unable to find param id in query string, therefore, unable to generate Project Proposal'
        );
      }

      return Id.valueOf(value);
    }
  }

  public ProjectProposalController() {
    ProjectProposalBuilder builder = new ProjectProposalBuilder();
    this.proposal = builder.build(this.projectId);
  }

  public class CustomException extends Exception {
  }
}