@isTest
public class DragAndDropSorterControllerTest {
  @isTest
  public static void testGetRecordsProjectFeatures() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id projectFeature1Id = ProjectFeatureTestDataFactory.create(
      projectId,
      'Feature one'
    );
    Id projectFeature2Id = ProjectFeatureTestDataFactory.create(
      projectId,
      'Feature two'
    );

    // Act
    List<DragAndDropSorterTransformer> records = DragAndDropSorterController.getRecords(
      projectId,
      'Project Feature'
    );

    // Assert
    System.assertEquals(
      projectFeature1Id,
      records[0].getId(),
      'Project feature 1 id'
    );
    System.assertEquals(
      projectFeature2Id,
      records[1].getId(),
      'Project feature 2 id'
    );
    System.assertEquals(
      'Feature one',
      records[0].getName(),
      'Project feature 1 name'
    );
    System.assertEquals(
      'Feature two',
      records[1].getName(),
      'Project feature 2 name'
    );
  }

  @isTest
  public static void testGetRecordsProjectTeamMembers() {
    // Arrange
    User user1 = UserTestDataFactory.create(
      'test1@r3.digital.test',
      'Test1',
      'Name1'
    );
    User user2 = UserTestDataFactory.create(
      'test2@r3.digital.test',
      'Test2',
      'Name2'
    );
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id member1Id = ProjectTeamMemberTestDataFactory.create(projectId, user1.Id);
    Id member2Id = ProjectTeamMemberTestDataFactory.create(projectId, user2.Id);

    Project_Team_Member__c member1 = new Project_Team_Member__c(Id = member1Id);
    member1.Sort_Order__c = 1;
    update member1;

    Project_Team_Member__c member2 = new Project_Team_Member__c(Id = member2Id);
    member2.Sort_Order__c = 2;
    update member2;

    // Act
    List<DragAndDropSorterTransformer> records = DragAndDropSorterController.getRecords(
      projectId,
      'Project Team Member'
    );

    // Assert
    System.assertEquals(member1Id, records[0].getId(), 'Member 1 id');
    System.assertEquals(member2Id, records[1].getId(), 'Member 2 id');
    System.assertEquals(
      'Test1 Name1 - Developer',
      records[0].getName(),
      'Member 1 name'
    );
    System.assertEquals(
      'Test2 Name2 - Developer',
      records[1].getName(),
      'Member 2 name'
    );
  }

  @isTest
  public static void testGetRecordsSalesforceLicenses() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id license1Id = SalesforceLicenseTestDataFactory.create(
      projectId,
      accountId,
      'Salesforce Platform'
    );
    Id license2Id = SalesforceLicenseTestDataFactory.create(
      projectId,
      accountId,
      'Marketing Cloud'
    );

    // Act
    List<DragAndDropSorterTransformer> records = DragAndDropSorterController.getRecords(
      projectId,
      'Salesforce License'
    );

    // Assert
    System.assertEquals(license1Id, records[0].getId(), 'License 1 id');
    System.assertEquals(license2Id, records[1].getId(), 'License 2 id');
    System.assertEquals(
      'Salesforce Platform',
      records[0].getName(),
      'License 1 name'
    );
    System.assertEquals(
      'Marketing Cloud',
      records[1].getName(),
      'License 2 name'
    );
  }

  @isTest
  public static void testGetRecordsWorkItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id projectFeatureId = ProjectFeatureTestDataFactory.create(projectId);
    Id workItem1Id = WorkItemTestDataFactory.create(
      projectId,
      projectFeatureId
    );
    Id workItem2Id = WorkItemTestDataFactory.create(
      projectId,
      projectFeatureId
    );
    Map<Id, Work_Item__c> workItemMap = new Map<Id, Work_Item__c>(
      [
        SELECT Id, Name
        FROM Work_Item__c
        WHERE Id IN (:workItem1Id, :workItem2Id)
      ]
    );

    // Act
    List<DragAndDropSorterTransformer> records = DragAndDropSorterController.getRecords(
      projectFeatureId,
      'Work Item'
    );

    // Assert
    System.assertEquals(workItem1Id, records[0].getId(), 'Work item 1 id');
    System.assertEquals(workItem2Id, records[1].getId(), 'Work item 2 id');
    System.assertEquals(
      workItemMap.get(workItem1Id).Name + ' - test work item',
      records[0].getName(),
      'Work item 1 name'
    );
    System.assertEquals(
      workItemMap.get(workItem2Id).Name + ' - test work item',
      records[1].getName(),
      'Work item 2 name'
    );
  }

  @isTest
  public static void testSort() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id projectFeature1Id = ProjectFeatureTestDataFactory.create(projectId);
    Id projectFeature2Id = ProjectFeatureTestDataFactory.create(projectId);
    Id workItem1Id = WorkItemTestDataFactory.create(
      projectId,
      projectFeature1Id
    );
    Id workItem2Id = WorkItemTestDataFactory.create(
      projectId,
      projectFeature1Id
    );

    // Act
    DragAndDropSorterController.sort(
      new List<Id>{ projectFeature1Id, projectFeature2Id }
    );
    DragAndDropSorterController.sort(new List<Id>{ workItem1Id, workItem2Id });

    // Assert
    List<Project_Feature__c> projectFeatures = [
      SELECT Id, Sort_Order__c
      FROM Project_Feature__c
      ORDER BY Sort_Order__c
    ];
    System.assertEquals(
      projectFeature1Id,
      projectFeatures[0].Id,
      'Project feature 1 id'
    );
    System.assertEquals(
      1,
      projectFeatures[0].Sort_Order__c,
      'Project feature 1 sort order'
    );
    System.assertEquals(
      projectFeature2Id,
      projectFeatures[1].Id,
      'Project feature 2 id'
    );
    System.assertEquals(
      2,
      projectFeatures[1].Sort_Order__c,
      'Project feature 2 sort order'
    );

    List<Work_Item__c> workItems = [
      SELECT Id, Sort_Order__c
      FROM Work_Item__c
      ORDER BY Sort_Order__c
    ];
    System.assertEquals(workItem1Id, workItems[0].Id, 'Work item 1 id');
    System.assertEquals(
      1,
      workItems[0].Sort_Order__c,
      'Work item 1 sort order'
    );
    System.assertEquals(workItem2Id, workItems[1].Id, 'Work item 2 id');
    System.assertEquals(
      2,
      workItems[1].Sort_Order__c,
      'Work item 2 sort order'
    );
  }
}