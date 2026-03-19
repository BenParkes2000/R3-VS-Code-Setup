public with sharing class WeeklyStatusReportController {
  public WeeklyStatusReport Report { get; private set; } //NOPMD

  private Id projectId {
    get {
      String value = ApexPages.currentPage().getParameters().get('id');

      if (String.isBlank(value)) {
        throw new CustomException('Unable to find ID in query string');
      }

      return Id.valueOf(value);
    }
  }

  public WeeklyStatusReportController() {
    WeeklyStatusReportBuilder builder = new WeeklyStatusReportBuilder();
    this.Report = builder.build(this.projectId);
  }

  public class CustomException extends Exception {
  }
}