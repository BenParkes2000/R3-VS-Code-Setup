@isTest
private class WikiEditorPageControllerTest {
  @isTest
  static void testUpdatePage() {
    // Arrange
    Wiki_Space__c space = new Wiki_Space__c(Name = 'Space');
    insert space;
    Wiki_Page__c testPage = new Wiki_Page__c(
      Name = 'Test Page',
      Wiki_Space__c = space.Id
    );
    insert testPage;

    // Act
    Test.startTest();
    Boolean isSuccess = WikiEditorPageController.updatePage(
      testPage.Id,
      'Updated Content'
    );
    Test.stopTest();

    // Assert
    System.assert(isSuccess, 'Update should be successful');
    ContentVersion latestCv = [
      SELECT VersionData
      FROM ContentVersion
      WHERE FirstPublishLocationId = :testPage.Id
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    String latestContent = latestCv.VersionData.toString();
    System.assertEquals(
      'Updated Content',
      latestContent,
      'The content should be updated to the new value'
    );
  }

  @isTest
  static void testGetPage() {
    // Arrange
    Wiki_Space__c space = new Wiki_Space__c(Name = 'Space');
    insert space;
    Wiki_Page__c testPage = new Wiki_Page__c(
      Name = 'Test Page',
      Wiki_Space__c = space.Id
    );
    insert testPage;

    ContentVersion cv = new ContentVersion(
      Title = 'Published',
      PathOnClient = 'Test.txt',
      VersionData = Blob.valueOf('Test data'),
      IsMajorVersion = true
    );
    insert cv;

    cv = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
      LIMIT 1
    ];
    ContentDocumentLink cdl = new ContentDocumentLink(
      LinkedEntityId = testPage.Id,
      ContentDocumentId = cv.ContentDocumentId,
      ShareType = 'V'
    );
    insert cdl;

    // Act
    Test.startTest();
    String result = WikiEditorPageController.getPage(testPage.Id);
    Test.stopTest();

    // Assert
    System.assertNotEquals(null, result, 'The result should not be null');
    System.assertEquals(
      'Test data',
      result,
      'The content does not match the expected value'
    );
  }

  @IsTest
  static void testUploadImage() {
    // Arrange
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    String fileName = 'testImage.jpg';
    String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test data'));

    Test.startTest();

    // Act
    String result = WikiEditorPageController.uploadImage(
      testAccount.Id,
      fileName,
      base64Data
    );

    Test.stopTest();

    // Assert
    ContentVersion contentVersion = [
      SELECT Id, Title, PathOnClient, VersionData
      FROM ContentVersion
      WHERE Title = :fileName
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      contentVersion,
      'ContentVersion record should be created'
    );
    System.assertEquals(
      fileName,
      contentVersion.Title,
      'Title should match the file name'
    );
    System.assertEquals(
      '/sfc/servlet.shepherd/version/download/' + contentVersion.Id,
      result,
      'The method should return the correct file download URL'
    );
  }
}