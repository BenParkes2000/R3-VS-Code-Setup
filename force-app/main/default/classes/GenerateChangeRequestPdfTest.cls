@isTest
private class GenerateChangeRequestPdfTest {
  @isTest
  private static void testChangeRequestPDFCreation() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'GBP',
        Status = 'Draft'
      );
      insert testContract;

      Project__c testProject = new Project__c(
        Name = 'Test Project',
        Status__c = 'Kick off',
        Account__c = testAccount.Id,
        Start_Date__c = Date.newInstance(2024, 1, 1),
        End_Date__c = Date.newInstance(2024, 31, 3),
        Vendor__c = 'Salesforce',
        Support_Type__c = 'MSA'
      );
      insert testProject;

      Project_Feature__c testFeature = new Project_Feature__c(
        Project__c = testProject.Id,
        Name = 'Test Feature'
      );
      insert testFeature;

      Work_Item__c testWI = new Work_Item__c(
        Subject__c = 'Test Work Item',
        Project__c = testProject.Id,
        Feature__c = testFeature.Id,
        Status__c = 'Ready',
        Est_Time__c = 4,
        Contract__c = testContract.Id,
        Type__c = 'Work Item'
      );
      insert testWI;

      // Add the Contract Id to a list for the Invocable method
      List<Id> contractIds = new List<Id>();
      contractIds.add(testContract.Id);

      // Simulate a PageReference for getContentAsPDF()
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', testContract.Id);
      pref.setRedirect(true);

      // Set the simulated PageReference for getContentAsPDF()
      Test.setCurrentPage(pref);

      // Act
      // Call the Invocable method to generate the PDF
      Test.startTest();
      GenerateChangeRequestPdf.generatePdf(contractIds);
      Test.stopTest();

      // Assert
      // Query ContentVersion records
      List<ContentVersion> contentVersions = [
        SELECT
          Id,
          ContentDocumentId,
          Title,
          PathOnClient,
          VersionData,
          ContentLocation
        FROM ContentVersion
        WHERE PathOnClient LIKE 'contract-%.pdf'
      ];

      // Verify the records were created
      Assert.areEqual(
        1,
        contentVersions.size(),
        'ContentVersion records were not created'
      );
      for (ContentVersion cv : contentVersions) {
        Assert.areEqual(
          testContract.Name + '.pdf',
          cv.Title,
          'The Title was not set correctly.'
        );
        Assert.areEqual(
          'contract-' + testContract.Id + '.pdf',
          cv.PathOnClient,
          'The PathOnClient was not set correctly.'
        );
        Assert.areEqual(
          'Test',
          cv.VersionData.toString(),
          'The VersionData was not set correctly.' + cv.VersionData.toString()
        );
        Assert.areEqual(
          'S',
          cv.ContentLocation,
          'The ContentLocation was not set correctly.'
        );
      }

      // Collect the ContentDocumentId values
      Set<Id> contentDocumentIds = new Set<Id>();
      for (ContentVersion contentVersion : contentVersions) {
        contentDocumentIds.add(contentVersion.ContentDocumentId);
      }

      // Query ContentDocumentLink records using IN operator
      List<ContentDocumentLink> contentDocumentLinks = [
        SELECT Id, LinkedEntityId, ShareType, Visibility
        FROM ContentDocumentLink
        WHERE
          ContentDocumentId IN :contentDocumentIds
          AND LinkedEntityId = :testContract.Id
      ];

      // Verify the records were created
      Assert.areEqual(
        1,
        contentDocumentLinks.size(),
        'ContentDocumentLink records were not created'
      );
      for (ContentDocumentLink cdl : contentDocumentLinks) {
        Assert.areEqual(
          testContract.Id,
          cdl.LinkedEntityId,
          'The LinkedEntityId was not set correctly.'
        );
        Assert.areEqual(
          'V',
          cdl.ShareType,
          'The ShareType was not set correctly.'
        );
      }
    }
  }

  @isTest
  private static void testRepeatedChangeRequestPDFCreation() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'GBP',
        Status = 'Draft'
      );
      insert testContract;

      Project__c testProject = new Project__c(
        Name = 'Test Project',
        Status__c = 'Kick off',
        Account__c = testAccount.Id,
        Start_Date__c = Date.newInstance(2024, 1, 1),
        End_Date__c = Date.newInstance(2024, 31, 3),
        Vendor__c = 'Salesforce',
          Support_Type__c = 'MSA'
      );
      insert testProject;

      Project_Feature__c testFeature = new Project_Feature__c(
        Project__c = testProject.Id,
        Name = 'Test Feature'
      );
      insert testFeature;

      Work_Item__c testWI = new Work_Item__c(
        Subject__c = 'Test Work Item',
        Project__c = testProject.Id,
        Feature__c = testFeature.Id,
        Status__c = 'Ready',
        Est_Time__c = 4,
        Contract__c = testContract.Id,
        Type__c = 'Work Item'
      );
      insert testWI;

      // Add the Contract Id to a list for the Invocable method
      List<Id> contractIds = new List<Id>();
      contractIds.add(testContract.Id);

      // Simulate a PageReference for getContentAsPDF()
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', testContract.Id);
      pref.setRedirect(true);

      // Set the simulated PageReference for getContentAsPDF()
      Test.setCurrentPage(pref);
      // Call the Invocable method to generate the PDF a first time
      GenerateChangeRequestPdf.generatePdf(contractIds);
      ContentVersion firstGenPdfContentVersion = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE PathOnClient LIKE 'contract-%.pdf'
      ];
      Id firstGenPdfContentDocumentLinkId = [
        SELECT Id
        FROM ContentDocumentLink
        WHERE
          ContentDocumentId = :firstGenPdfContentVersion.ContentDocumentId
          AND LinkedEntityId = :testContract.Id
      ]
      .Id;

      // Act
      // Call the Invocable method to generate the PDF a second time
      Test.startTest();
      GenerateChangeRequestPdf.generatePdf(contractIds);
      Test.stopTest();

      // Assert
      // Query ContentVersion records
      List<ContentVersion> contentVersionsCreatedBySecondRequest = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE
          PathOnClient LIKE 'contract-%.pdf'
          AND Id != :firstGenPdfContentVersion.Id
      ];

      // Verify the records were created
      Assert.areEqual(
        1,
        contentVersionsCreatedBySecondRequest.size(),
        'Unexpected number of ContentVersion records created by second PDF generation request'
      );

      // Query ContentDocumentLink records (note cannot filter on Id on this SObject,
      // can only filter on ContentDocumentId and LinkedEntityId so cannot filter out the first
      // ContentDocumentLink record based on Id)
      List<ContentDocumentLink> contentDocumentLinksCreatedAcrossBothRequests = [
        SELECT Id, ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :testContract.Id
      ];

      // Verify the second request did not add any new ContentDocumentLink records
      Assert.areEqual(
        1,
        contentDocumentLinksCreatedAcrossBothRequests.size(),
        'Unexpected number of ContentDocumentLink records after second PDF generation request'
      );
      Assert.areEqual(
        firstGenPdfContentDocumentLinkId,
        contentDocumentLinksCreatedAcrossBothRequests[0].Id,
        'Unexpected ContentDocumentLink record after second PDF generation request, should have kept just the initial record created by the first request'
      );
      Assert.areEqual(
        firstGenPdfContentVersion.ContentDocumentId,
        contentDocumentLinksCreatedAcrossBothRequests[0].ContentDocumentId,
        'Unexpected ContentDocumentId on the ContentDocumentLink record after second PDF generation request'
      );
    }
  }

  private static User createTestContextUser() {
    return TestUtil.createUserWithProfileAndPermissionSets(
      'Standard User',
      new Set<String>{
        'Edit_Access_on_Contracts',
        'Create_Work_Items',
        'Project_Proposal_Generator'
      }
    );
  }
}