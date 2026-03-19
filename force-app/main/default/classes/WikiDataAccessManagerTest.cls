@isTest
private class WikiDataAccessManagerTest {

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
      String result = WikiDataAccessManager.getLatestContent(testPage.Id);
      Test.stopTest();
  
      // Assert
      System.assertNotEquals(null, result, 'The result should not be null');
      System.assertEquals(
        'Test data',
        result,
        'The content does not match the expected value'
      );
    }


    @isTest static void testUpdateDocumentLink_UpdatesIncorrectLinks() {
        // Step 1: Create a dummy record to simulate the wiki page (can be any object with Id)
        Account testPage = new Account(Name = 'Test Wiki Page');
        insert testPage;

        // Step 2: Create a ContentVersion (this will auto-create ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Sample content')
        );
        insert cv;

        // Get the ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        // Step 3: Create an intentionally incorrect ContentDocumentLink (wrong ShareType and Visibility)
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = testPage.Id,
            ShareType = 'V',        // Viewer, should be 'I'
            Visibility = 'InternalUsers' // Should be 'AllUsers'
        );
        insert cdl;

        // Step 4: Run the method under test
        Test.startTest();
        WikiDataAccessManager.updateDocumentLink(testPage.Id);
        Test.stopTest();

        // Step 5: Assert that the link has been corrected
        ContentDocumentLink updatedCdl = [
            SELECT ShareType, Visibility
            FROM ContentDocumentLink
            WHERE Id = :cdl.Id
        ];

        System.assertEquals('I', updatedCdl.ShareType, 'Expected ShareType to be updated to I');
        System.assertEquals('AllUsers', updatedCdl.Visibility, 'Expected Visibility to be updated to AllUsers');
    }

    @isTest static void testUpdateDocumentLink_NoUpdatesIfAlreadyCorrect() {
        // Create dummy page
        Account testPage = new Account(Name = 'Already Correct Page');
        insert testPage;

        // Create ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Already Correct File',
            PathOnClient = 'CorrectFile.txt',
            VersionData = Blob.valueOf('Correct Content')
        );
        insert cv;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        // Correct link already
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = testPage.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Run method
        Test.startTest();
        WikiDataAccessManager.updateDocumentLink(testPage.Id);
        Test.stopTest();

        // Confirm link has not been unnecessarily updated (still correct)
        ContentDocumentLink unchangedCdl = [
            SELECT ShareType, Visibility
            FROM ContentDocumentLink
            WHERE Id = :cdl.Id
        ];

        System.assertEquals('I', unchangedCdl.ShareType, 'ShareType should remain I');
        System.assertEquals('AllUsers', unchangedCdl.Visibility, 'Visibility should remain AllUsers');
    }
}