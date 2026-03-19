@isTest
public with sharing class GetProjectRAIDLogsControllerTest {
  @testSetup
  static void setupTestData() {
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    Project__c testProject = new Project__c(
      Name = 'Test Project',
      Account__c = testAccount.Id,
      Support_Type__c = 'MSA'
    );
    insert testProject;

    List<Raid_Log__c> testRaidLogs = new List<Raid_Log__c>{
      new Raid_Log__c(
        Status__c = 'Open',
        Type__c = 'Risk',
        Project__c = testProject.Id
      ),
      new Raid_Log__c(
        Status__c = 'Open',
        Type__c = 'Issue',
        Project__c = testProject.Id
      )
    };

    insert testRaidLogs;

    for (Integer i = 0; i < testRaidLogs.size(); i++) {
      if (i == 0) {
        testRaidLogs[i].Type__c = 'Risk';
      } else {
        testRaidLogs[i].Type__c = 'Issue';
      }
    }

    update testRaidLogs;
  }

  @isTest
  static void testGetRaidLogs() {
    // Arrange
    Project__c testProject = [
      SELECT Id
      FROM Project__c
      WHERE Name = 'Test Project'
      LIMIT 1
    ];

    GetProjectRAIDLogsController controller = new GetProjectRAIDLogsController();
    controller.projectId = testProject.Id;
    controller.logType = 'Risk';

    // Act
    Test.startTest();
    List<Raid_Log__c> raidLogs = controller.getRaidLogs();
    Test.stopTest();

    // Assert
    System.assertEquals(
      1,
      raidLogs.size(),
      'Expected one Raid Log to be returned'
    );
    System.assertEquals(
      'Risk',
      raidLogs[0].Type__c,
      'Raid log type does not match'
    );
  }

  @isTest
  static void testGetIsRaidLogsEmpty() {
    // Arrange
    Project__c testProject = [
      SELECT Id
      FROM Project__c
      WHERE Name = 'Test Project'
      LIMIT 1
    ];

    // Instantiate controller and set values
    GetProjectRAIDLogsController controller = new GetProjectRAIDLogsController();
    controller.projectId = testProject.Id;
    controller.logType = 'Assumption';

    // Act
    Test.startTest();
    // Test getIsRaidLogsEmpty method
    Boolean isRaidLogsEmpty = controller.getIsRaidLogsEmpty();
    Test.stopTest();

    // Assert
    System.assertEquals(
      true,
      isRaidLogsEmpty,
      'Expected getIsRaidLogsEmpty to return true'
    );
  }
}