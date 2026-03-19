@isTest
public class WeeklyStatusReportActionTest {
  @isTest
  public static void testSaveWeeklyStatusReports() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id project1Id = ProjectTestDataFactory.create(
      accountId,
      'Project 1',
      ProjectStatusNames.InProgress
    );
    Id project2Id = ProjectTestDataFactory.create(
      accountId,
      'Project 2',
      ProjectStatusNames.InProgress
    );

    Project_Meeting__c meeting1 = ProjectMeetingTestDataFactory.create(
      project1Id
    );
    insert meeting1;

    Project_Meeting__c meeting2 = ProjectMeetingTestDataFactory.create(
      project2Id
    );
    insert meeting2;

    // Act
    Test.startTest();
    WeeklyStatusReportAction.saveWeeklyStatusReports(
      new List<Id>{ meeting1.Id, meeting2.Id }
    );
    Test.stopTest();

    // Assert
    List<Project_Meeting__c> meetingList = [
      SELECT Id, Name
      FROM Project_Meeting__c
      WHERE Id IN (:meeting1.Id, :meeting2.Id)
      ORDER BY Id
    ];
    List<ContentVersion> contentVersionList = [
      SELECT PathOnClient, Title, VersionData, ContentDocumentId
      FROM ContentVersion
      ORDER BY Id
    ];
    List<ContentDocumentLink> contentDocumentLinkList = [
      SELECT LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN (:meeting1.Id, :meeting2.Id)
      ORDER BY Id
    ];
    String reportDate = Datetime.now().format('yyyy-MM-dd');

    System.assertEquals(
      2,
      contentVersionList.size(),
      'There should be 2 ContentVersion records'
    );
    System.assertEquals(
      'weekly-status-report-' + meetingList[0].Name + '-' + reportDate + '.pdf',
      contentVersionList[0].PathOnClient,
      'The first ContentVersion record should have the correct PathOnClient'
    );
    System.assertEquals(
      'Weekly Status Report - Project 1 - ' + reportDate,
      contentVersionList[0].Title,
      'The first ContentVersion record should have the correct Title'
    );
    System.assertEquals(
      'Test',
      contentVersionList[0].VersionData.toString(),
      'The first ContentVersion record should have the correct VersionData'
    );
    System.assertEquals(
      'weekly-status-report-' + meetingList[1].Name + '-' + reportDate + '.pdf',
      contentVersionList[1].PathOnClient,
      'The second ContentVersion record should have the correct PathOnClient'
    );
    System.assertEquals(
      'Weekly Status Report - Project 2 - ' + reportDate,
      contentVersionList[1].Title,
      'The second ContentVersion record should have the correct Title'
    );
    System.assertEquals(
      'Test',
      contentVersionList[1].VersionData.toString(),
      'The second ContentVersion record should have the correct VersionData'
    );

    System.assertEquals(
      2,
      contentDocumentLinkList.size(),
      'There should be 2 ContentDocumentLink records'
    );

    Set<Id> contentDocumentIds = new Set<Id>();

    for (ContentDocumentLink contentDocumentLink : contentDocumentLinkList) {
      contentDocumentIds.add(contentDocumentLink.ContentDocumentId);
    }

    System.assert(
      contentDocumentIds.contains(contentVersionList[0].ContentDocumentId),
      'ContentDocumentLink record should have the correct ContentDocumentId'
    );
    System.assert(
      contentDocumentIds.contains(contentVersionList[1].ContentDocumentId),
      'ContentDocumentLink record should have the correct ContentDocumentId'
    );
  }
}