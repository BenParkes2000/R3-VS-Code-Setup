@isTest
private class ProjectResourceAssignmentFactoryTest {
  @isTest
  static void testCreate() {
    // Arrange
    User user = UserTestDataFactory.create('test@r3.digital', 'Test', 'User');
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Date startDate = Date.newInstance(2020, 1, 1);
    Date endDate = Date.newInstance(2020, 1, 31);
    Decimal hoursPerDay = 8;

    // Act
    Id resourceId = ProjectResourceAssignmentTestDataFactory.create(
      projectId,
      user.Id,
      startDate,
      endDate,
      hoursPerDay
    );

    // Assert
    Project_Resource_Assignment__c resource = [
      SELECT Project__c, User__c, Start_Date__c, End_Date__c, Hours_Per_Day__c
      FROM Project_Resource_Assignment__c
      WHERE Id = :resourceId
    ];

    System.assertEquals(
      projectId,
      resource.Project__c,
      'Project ID is not correct'
    );
    System.assertEquals(user.Id, resource.User__c, 'User ID is not correct');
    System.assertEquals(
      startDate,
      resource.Start_Date__c,
      'Start date is not correct'
    );
    System.assertEquals(
      endDate,
      resource.End_Date__c,
      'End date is not correct'
    );
    System.assertEquals(
      hoursPerDay,
      resource.Hours_Per_Day__c,
      'Hours per day is not correct'
    );
  }
}