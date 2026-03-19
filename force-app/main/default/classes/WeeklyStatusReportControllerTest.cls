@isTest
public class WeeklyStatusReportControllerTest {
  @isTest
  public static void test() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );
    ApexPages.currentPage().getParameters().put('id', projectId);

    // Act
    WeeklyStatusReportController controller = new WeeklyStatusReportController();

    // Assert
    System.assertEquals(
      'Test Account',
      controller.Report.AccountName,
      'Account name should be Test Account'
    );
    System.assertEquals(
      'Test Project',
      controller.Report.ProjectName,
      'Project name should be Test Project'
    );
  }

  @isTest
  public static void testException() {
    try {
      // Act
      WeeklyStatusReportController controller = new WeeklyStatusReportController(); //NOPMD
    } catch (WeeklyStatusReportController.CustomException e) {
      // Assert
      System.assertEquals(
        'Unable to find ID in query string',
        e.getMessage(),
        'Exception message should be "Unable to find ID in query string"'
      );
      return;
    }

    // If we get here, the test has failed.
    System.assert(false, 'Expected exception was not thrown');
  }
}