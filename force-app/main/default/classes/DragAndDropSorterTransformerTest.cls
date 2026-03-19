@isTest
public class DragAndDropSorterTransformerTest {
  @isTest
  public static void testProjectFeature() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id featureId = ProjectFeatureTestDataFactory.create(projectId);

    List<SObject> featureList = new List<SObject>(
      Database.query(
        'SELECT Id, Name FROM Project_Feature__c WHERE Id = :featureId'
      )
    );

    // Act
    DragAndDropSorterTransformer transformer = new DragAndDropSorterTransformer(
      featureList[0]
    );

    // Assert
    System.assertEquals(
      featureId,
      transformer.getId(),
      'Feature ID should be set'
    );
    System.assertEquals(
      featureList[0].get('Name'),
      transformer.getName(),
      'Feature name should be set'
    );
  }

  @isTest
  public static void testProjectTeamMember() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.test',
      'Test',
      'Name'
    );
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id memberId = ProjectTeamMemberTestDataFactory.create(projectId, user.Id);

    List<SObject> teamMemberList = new List<SObject>(
      Database.query(
        'SELECT Id, Name__c, Role__c FROM Project_Team_Member__c WHERE Id = :memberId'
      )
    );

    // Act
    DragAndDropSorterTransformer transformer = new DragAndDropSorterTransformer(
      teamMemberList[0]
    );

    // Assert
    System.assertEquals(
      memberId,
      transformer.getId(),
      'Team member ID should be set'
    );
    System.assertEquals(
      teamMemberList[0].get('Name__c') +
        ' - ' +
        teamMemberList[0].get('Role__c'),
      transformer.getName(),
      'Team member name and role should be concatenated'
    );
  }

  @isTest
  public static void testSalesforceLicense() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id licenseId = SalesforceLicenseTestDataFactory.create(
      projectId,
      accountId
    );

    List<SObject> licenseList = new List<SObject>(
      Database.query(
        'SELECT Id, License__c FROM Salesforce_License__c WHERE Id = :licenseId'
      )
    );

    // Act
    DragAndDropSorterTransformer transformer = new DragAndDropSorterTransformer(
      licenseList[0]
    );

    // Assert
    System.assertEquals(
      licenseId,
      transformer.getId(),
      'License ID should be set'
    );
    System.assertEquals(
      licenseList[0].get('License__c'),
      transformer.getName(),
      'License name should be set'
    );
  }

  @isTest
  public static void testWorkItem() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id featureId = ProjectFeatureTestDataFactory.create(projectId);
    Id workItemId = WorkItemTestDataFactory.create(projectId, featureId);

    List<SObject> workItemList = new List<SObject>(
      Database.query(
        'SELECT Id, Name, Subject__c FROM Work_Item__c WHERE Id = :workItemId'
      )
    );

    // Act
    DragAndDropSorterTransformer transformer = new DragAndDropSorterTransformer(
      workItemList[0]
    );

    // Assert
    System.assertEquals(
      workItemId,
      transformer.getId(),
      'Work Item ID should be set'
    );
    System.assertEquals(
      workItemList[0].get('Name') + ' - ' + workItemList[0].get('Subject__c'),
      transformer.getName(),
      'Work Item name and subject should be concatenated'
    );
  }
}