@isTest
public class RevenueManagementControllerTest {
  @isTest
  public static void testGetResourceAssignments() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'FirstName',
      'LastName'
    );
    user.Standard_Rate__c = 150;
    update user;

    Id accountId = AccountTestDataFactory.create('Test Account');

    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<Project_Resource_Assignment__c> resourceAssignmentList = new List<Project_Resource_Assignment__c>{
      ProjectResourceAssignmentTestDataFactory.create(
        user.Id,
        projectId,
        150,
        Date.today().toStartofWeek(),
        8,
        6,
        4,
        0,
        0
      ),
      ProjectResourceAssignmentTestDataFactory.create(
        user.Id,
        projectId,
        125,
        Date.today().addDays(7).toStartofWeek(),
        4,
        4,
        4,
        4,
        4
      )
    };
    insert resourceAssignmentList;

    // Act
    Test.startTest();
    List<User> resourceAssignments = RevenueManagementController.getResourceAssignments(
      Date.today().addDays(-7),
      null,
      new List<String>(),
      new List<String>()
    );
    Test.stopTest();

    // Assert
    for (User resourceAssignment : resourceAssignments) {
      if (resourceAssignment.Id == user.Id) {
        System.assertEquals(
          2,
          resourceAssignment.Project_Resource_Assignments__r.size(),
          'User should have 2 resource assignments'
        );
        System.assertEquals(
          resourceAssignmentList[1].Id,
          resourceAssignment.Project_Resource_Assignments__r[0].Id,
          'First resource assignment should be the second one created'
        );
        System.assertEquals(
          resourceAssignmentList[0].Id,
          resourceAssignment.Project_Resource_Assignments__r[1].Id,
          'Second resource assignment should be the first one created'
        );
      } else {
        System.assertEquals(
          0,
          resourceAssignment.Project_Resource_Assignments__r.size(),
          'User should have no resource assignments'
        );
      }
    }
  }

  @isTest
  public static void testGetLeaveDates() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'FirstName',
      'LastName'
    );
    user.Standard_Rate__c = 150;
    update user;

    Leave_Summary__c summary = new Leave_Summary__c(OwnerId = user.Id);
    insert summary;

    Leave_Request__c request = new Leave_Request__c(
      Leave_Summary__c = summary.Id,
      Leave_Type__c = 'Annual Leave',
      Start_Date__c = Date.newInstance(2024, 1, 1),
      Days__c = 2,
      Status__c = 'Approved'
    );
    insert request;

    // Act
    Map<Id, List<RevenueManagementController.LeaveDate>> response = RevenueManagementController.getLeaveDates(
      Date.newInstance(2024, 1, 1),
      null,
      new List<String>()
    );

    // Assert
    System.assert(
      response.containsKey(user.Id),
      'Response should contain user Id'
    );
    List<RevenueManagementController.LeaveDate> leaveDates = response.get(
      user.Id
    );
    System.assertEquals(2, leaveDates.size(), 'User should have 2 leave dates');
    System.assertEquals(
      Date.newInstance(2024, 1, 1),
      leaveDates[0].LeaveDate,
      'First leave date should be 2024-01-01'
    );
    System.assert(
      leaveDates[0].IsApproved,
      'First leave date should be approved'
    );
    System.assert(
      !leaveDates[0].IsSickness,
      'First leave date should not be sickness'
    );
  }

  @isTest
  public static void testGetUserPreferences() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'LastName',
      'System Administrator'
    );
    user.Resource_Management_Columns__c = '1;2;3';
    user.Resource_Management_Scale__c = 'week';
    update user;

    // Act
    User preferences;

    Test.startTest();
    System.runAs(user) {
      preferences = RevenueManagementController.getUserPreferences();
    }
    Test.stopTest();

    // Assert
    System.assertEquals(
      '1;2;3',
      preferences.Resource_Management_Columns__c,
      'Columns should be set'
    );
    System.assertEquals(
      'week',
      preferences.Resource_Management_Scale__c,
      'Scale should be set'
    );
  }

  @isTest
  public static void testGetResourceAssignmentDetails() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'FirstName',
      'LastName'
    );
    user.Standard_Rate__c = 150;
    update user;

    Id accountId = AccountTestDataFactory.create('Test Account');

    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    Project_Resource_Assignment__c resourceAssignment = ProjectResourceAssignmentTestDataFactory.create(
      user.Id,
      projectId,
      150,
      Date.newInstance(2022, 8, 1),
      8,
      6,
      4,
      0,
      0
    );
    insert resourceAssignment;

    // Act
    Test.startTest();
    Project_Resource_Assignment__c response = RevenueManagementController.getResourceAssignmentDetails(
      resourceAssignment.Id
    );
    Test.stopTest();

    // Assert
    System.assertEquals(resourceAssignment.Id, response.Id, 'IDs should match');
    System.assertEquals(
      resourceAssignment.Start_Date__c,
      response.Start_Date__c,
      'Start date should match'
    );
    System.assertEquals(user.Id, response.User__c, 'User ID should match');
    System.assertEquals(
      projectId,
      response.Project__c,
      'Project ID should match'
    );
    System.assertEquals(150, response.Rate__c, 'Rate should match');
    System.assertEquals(
      8,
      response.Hours_Monday__c,
      'Monday hours should match'
    );
    System.assertEquals(
      6,
      response.Hours_Tuesday__c,
      'Tuesday hours should match'
    );
    System.assertEquals(
      4,
      response.Hours_Wednesday__c,
      'Wednesday hours should match'
    );
    System.assertEquals(
      0,
      response.Hours_Thursday__c,
      'Thursday hours should match'
    );
    System.assertEquals(
      0,
      response.Hours_Friday__c,
      'Friday hours should match'
    );
  }

  @isTest
  public static void testGetResourceAssignmentDetailsException() {
    try {
      RevenueManagementController.getResourceAssignmentDetails(
        '000000000000000000'
      );
    } catch (AuraHandledException e) {
      System.assert(true, 'Exception should be thrown');
      return;
    }

    System.assert(false, 'Exception should be thrown');
  }

  @isTest
  public static void testFindResourceAssignment() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'FirstName',
      'LastName'
    );
    user.Standard_Rate__c = 150;
    update user;

    Id accountId = AccountTestDataFactory.create('Test Account');

    Id project1Id = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );
    Id project2Id = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    List<Project_Resource_Assignment__c> resourceAssignmentList = new List<Project_Resource_Assignment__c>{
      ProjectResourceAssignmentTestDataFactory.create(
        user.Id,
        project1Id,
        150,
        Date.newInstance(2022, 8, 1),
        4,
        4,
        4,
        4,
        4
      ),
      ProjectResourceAssignmentTestDataFactory.create(
        user.Id,
        project2Id,
        150,
        Date.newInstance(2022, 8, 8),
        8,
        8,
        8,
        8,
        8
      )
    };
    insert resourceAssignmentList;

    // Act
    Test.startTest();
    Project_Resource_Assignment__c response = RevenueManagementController.findResourceAssignment(
      Date.newInstance(2022, 8, 8),
      user.Id,
      project2Id
    );
    Test.stopTest();

    // Assert
    System.assertEquals(
      resourceAssignmentList[1].Id,
      response.Id,
      'IDs should match'
    );
    System.assertEquals(
      Date.newInstance(2022, 8, 8),
      response.Start_Date__c,
      'Start date should match'
    );
    System.assertEquals(user.Id, response.User__c, 'User ID should match');
    System.assertEquals(
      project2Id,
      response.Project__c,
      'Project ID should match'
    );
    System.assertEquals(150, response.Rate__c, 'Rate should match');
    System.assertEquals(
      8,
      response.Hours_Monday__c,
      'Monday hours should match'
    );
    System.assertEquals(
      8,
      response.Hours_Tuesday__c,
      'Tuesday hours should match'
    );
    System.assertEquals(
      8,
      response.Hours_Wednesday__c,
      'Wednesday hours should match'
    );
    System.assertEquals(
      8,
      response.Hours_Thursday__c,
      'Thursday hours should match'
    );
    System.assertEquals(
      8,
      response.Hours_Friday__c,
      'Friday hours should match'
    );
  }

  @isTest
  public static void testFindResourceAssignmentNotFound() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'FirstName',
      'LastName'
    );
    update user;

    Id accountId = AccountTestDataFactory.create('Test Account');

    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    // Act
    Test.startTest();
    Project_Resource_Assignment__c response = RevenueManagementController.findResourceAssignment(
      Date.newInstance(2022, 8, 8),
      user.Id,
      projectId
    );
    Test.stopTest();

    // Assert
    System.assertEquals(null, response, 'Response should be null');
  }

  @isTest
  public static void testSaveResourceAssignment() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'FirstName',
      'LastName'
    );
    user.Standard_Rate__c = 150;
    update user;

    Id accountId = AccountTestDataFactory.create('Test Account');

    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    final Date startDate = Date.newInstance(2022, 8, 1);
    final Decimal rate = 150;
    final String status = 'Confirmed';
    final Decimal hoursMon = 1;
    final Decimal hoursTue = 2;
    final Decimal hoursWed = 3;
    final Decimal hoursThu = 4;
    final Decimal hoursFri = 5;

    // Act
    Test.startTest();
    RevenueManagementController.saveResourceAssignment(
      null,
      startDate,
      user.Id,
      projectId,
      rate,
      status,
      hoursMon,
      hoursTue,
      hoursWed,
      hoursThu,
      hoursFri
    );
    Test.stopTest();

    // Assert
    System.assertEquals(
      1,
      [
        SELECT COUNT()
        FROM Project_Resource_Assignment__c
        WHERE
          Start_Date__c = :startDate
          AND User__c = :user.Id
          AND Project__c = :projectId
      ],
      'Resource assignment should be created'
    );
  }

  @isTest
  public static void testSaveResourceAssignmentUpdateExisting() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'FirstName',
      'LastName'
    );
    user.Standard_Rate__c = 150;
    update user;

    Id accountId = AccountTestDataFactory.create('Test Account');

    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    Project_Resource_Assignment__c resourceAssignment = ProjectResourceAssignmentTestDataFactory.create(
      user.Id,
      projectId,
      150,
      Date.newInstance(2022, 8, 1),
      1,
      2,
      3,
      4,
      5
    );
    insert resourceAssignment;

    // Act
    Test.startTest();
    RevenueManagementController.saveResourceAssignment(
      resourceAssignment.Id,
      Date.newInstance(2022, 8, 1),
      user.Id,
      projectId,
      150,
      'Confirmed',
      8,
      7,
      6,
      5,
      4
    );
    Test.stopTest();

    // Assert
    Project_Resource_Assignment__c response = [
      SELECT
        Hours_Monday__c,
        Hours_Tuesday__c,
        Hours_Wednesday__c,
        Hours_Thursday__c,
        Hours_Friday__c
      FROM Project_Resource_Assignment__c
      WHERE Id = :resourceAssignment.Id
    ];
    System.assertEquals(
      8,
      response.Hours_Monday__c,
      'Monday hours should match'
    );
    System.assertEquals(
      7,
      response.Hours_Tuesday__c,
      'Tuesday hours should match'
    );
    System.assertEquals(
      6,
      response.Hours_Wednesday__c,
      'Wednesday hours should match'
    );
    System.assertEquals(
      5,
      response.Hours_Thursday__c,
      'Thursday hours should match'
    );
    System.assertEquals(
      4,
      response.Hours_Friday__c,
      'Friday hours should match'
    );
  }

  @isTest
  public static void testSaveResourceAssignmentException() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'FirstName',
      'LastName'
    );
    update user;

    Id accountId = AccountTestDataFactory.create('Test Account');

    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    Project_Resource_Assignment__c resourceAssignment = ProjectResourceAssignmentTestDataFactory.create(
      user.Id,
      projectId,
      150,
      Date.newInstance(2022, 8, 1),
      1,
      2,
      3,
      4,
      5
    );
    insert resourceAssignment;

    // Act
    Test.startTest();

    try {
      RevenueManagementController.saveResourceAssignment(
        null,
        Date.newInstance(2022, 8, 1),
        user.Id,
        projectId,
        150,
        'Confirmed',
        8,
        7,
        6,
        5,
        4
      );
    } catch (AuraHandledException e) {
      // Assert
      System.assertEquals(
        'A resource assignment already exists for the selected week.',
        e.getMessage(),
        'Exception message should match'
      );
      return;
    }

    Test.stopTest();

    // If we get here, the test failed
    System.assert(false, 'Exception should be thrown');
  }

  @isTest
  public static void testUpdateUserColumns() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'FirstName',
      'LastName'
    );
    user.Resource_Management_Columns__c = '1;2;3';
    update user;

    // Act
    Test.startTest();
    System.runAs(user) {
      RevenueManagementController.updateUserColumns('4;5;6');
    }
    Test.stopTest();

    // Assert
    System.assertEquals(
      '4;5;6',
      [SELECT Resource_Management_Columns__c FROM User WHERE Id = :user.Id]
      .Resource_Management_Columns__c,
      'Columns should be updated'
    );
  }

  @isTest
  public static void testUpdateUserScale() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.pdd.test',
      'FirstName',
      'LastName'
    );
    user.Resource_Management_Scale__c = 'week';
    update user;

    // Act
    Test.startTest();
    System.runAs(user) {
      RevenueManagementController.updateUserScale('month');
    }
    Test.stopTest();

    // Assert
    System.assertEquals(
      'month',
      [SELECT Resource_Management_Scale__c FROM User WHERE Id = :user.Id]
      .Resource_Management_Scale__c,
      'Scale should be updated'
    );
  }
}