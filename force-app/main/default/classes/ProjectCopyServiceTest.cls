@isTest
private class ProjectCopyServiceTest {
  @isTest
  static void testCopyProjectPhases() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id oldProjectId = ProjectTestDataFactory.create(accountId);
    Id newProjectId = ProjectTestDataFactory.create(accountId);
    List<Phase__c> oldProjectPhaseList = new List<Phase__c>{
      PhaseTestDataFactory.create(oldProjectId),
      PhaseTestDataFactory.create(oldProjectId)
    };
    insert oldProjectPhaseList;

    // Act
    Test.startTest();
    Map<Id, Id> oldToNewProjectPhaseIdMap = ProjectCopyService.copyProjectPhases(
      oldProjectPhaseList,
      new Map<Id, Id>{ oldProjectId => newProjectId }
    );
    Test.stopTest();

    // Assert
    System.assertEquals(
      2,
      oldToNewProjectPhaseIdMap.size(),
      'oldToNewProjectPhaseIdMap should have 2 entries'
    );

    List<Phase__c> newProjectPhaseList = [
      SELECT Id
      FROM Phase__c
      WHERE Project__c = :newProjectId
    ];

    System.assertEquals(
      2,
      newProjectPhaseList.size(),
      'newProjectPhaseList should have 2 entries'
    );
  }

  @isTest
  static void testCopyProjectFeatures() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id oldProjectId = ProjectTestDataFactory.create(accountId);
    Id newProjectId = ProjectTestDataFactory.create(accountId);

    Phase__c oldProjectPhase = PhaseTestDataFactory.create(oldProjectId);
    insert oldProjectPhase;

    Phase__c newProjectPhase = PhaseTestDataFactory.create(newProjectId);
    insert newProjectPhase;

    Project_Feature__c oldProjectFeature1 = new Project_Feature__c();
    oldProjectFeature1.Name = 'Test Feature 1';
    oldProjectFeature1.Project__c = oldProjectId;
    oldProjectFeature1.Phase__c = oldProjectPhase.Id;

    Project_Feature__c oldProjectFeature2 = new Project_Feature__c();
    oldProjectFeature2.Name = 'Test Feature 2';
    oldProjectFeature2.Project__c = oldProjectId;
    oldProjectFeature2.Phase__c = oldProjectPhase.Id;

    List<Project_Feature__c> oldProjectFeatureList = new List<Project_Feature__c>{
      oldProjectFeature1,
      oldProjectFeature2
    };
    insert oldProjectFeatureList;

    // Act
    Test.startTest();
    Map<Id, Id> oldToNewProjectFeatureIdMap = ProjectCopyService.copyProjectFeatures(
      oldProjectFeatureList,
      new Map<Id, Id>{ oldProjectId => newProjectId },
      new Map<Id, Id>{ oldProjectPhase.Id => newProjectPhase.Id }
    );
    Test.stopTest();

    // Assert
    System.assertEquals(
      2,
      oldToNewProjectFeatureIdMap.size(),
      'oldToNewProjectFeatureIdMap should have 2 entries'
    );

    List<Project_Feature__c> newProjectFeatureList = [
      SELECT Id
      FROM Project_Feature__c
      WHERE Project__c = :newProjectId AND Phase__c = :newProjectPhase.Id
    ];

    System.assertEquals(
      2,
      newProjectFeatureList.size(),
      'newProjectFeatureList should have 2 entries'
    );
  }

  @isTest
  static void testCopyWorkItems() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id oldProjectId = ProjectTestDataFactory.create(accountId);
    Id newProjectId = ProjectTestDataFactory.create(accountId);

    Phase__c oldProjectPhase = PhaseTestDataFactory.create(oldProjectId);
    insert oldProjectPhase;

    Phase__c newProjectPhase = PhaseTestDataFactory.create(newProjectId);
    insert newProjectPhase;

    Project_Feature__c oldProjectFeature = new Project_Feature__c();
    oldProjectFeature.Name = 'Test Feature';
    oldProjectFeature.Project__c = oldProjectId;
    oldProjectFeature.Phase__c = oldProjectPhase.Id;
    insert oldProjectFeature;

    Project_Feature__c newProjectFeature = new Project_Feature__c();
    newProjectFeature.Name = 'Test Feature';
    newProjectFeature.Project__c = newProjectId;
    newProjectFeature.Phase__c = newProjectPhase.Id;
    insert newProjectFeature;

    Work_Item__c workItem1 = new Work_Item__c();
    workItem1.Project__c = oldProjectId;
    workItem1.Project_Phase__c = oldProjectPhase.Id;
    workItem1.Feature__c = oldProjectFeature.Id;
    workItem1.Subject__c = 'Test Work Item 1';
    workItem1.Type__c = 'Work Item';
    workItem1.Status__c = WorkItemStatusNames.Backlog;
    insert workItem1;

    Work_Item__c workItem2 = new Work_Item__c();
    workItem2.Project__c = oldProjectId;
    workItem2.Project_Phase__c = oldProjectPhase.Id;
    workItem2.Feature__c = oldProjectFeature.Id;
    workItem2.Subject__c = 'Test Work Item 2';
    workItem2.Type__c = 'Work Item';
    workItem2.Status__c = WorkItemStatusNames.Backlog;
    insert workItem2;

    List<Work_Item__c> oldWorkItemList = new List<Work_Item__c>{
      workItem1,
      workItem2
    };

    // Act
    Test.startTest();
    Map<Id, Id> oldToNewWorkItemIdMap = ProjectCopyService.copyWorkItems(
      oldWorkItemList,
      new Map<Id, Id>{ oldProjectId => newProjectId },
      new Map<Id, Id>{ oldProjectPhase.Id => newProjectPhase.Id },
      new Map<Id, Id>{ oldProjectFeature.Id => newProjectFeature.Id }
    );
    Test.stopTest();

    // Assert
    System.assertEquals(
      2,
      oldToNewWorkItemIdMap.size(),
      'oldToNewWorkItemIdMap should have 2 entries'
    );

    List<Work_Item__c> newWorkItemList = [
      SELECT Id
      FROM Work_Item__c
      WHERE
        Project__c = :newProjectId
        AND Project_Phase__c = :newProjectPhase.Id
        AND Feature__c = :newProjectFeature.Id
    ];

    System.assertEquals(
      2,
      newWorkItemList.size(),
      'newWorkItemList should have 2 entries'
    );
  }
}