@isTest
public class RetrieveCarouselCustomMetadataTest {
  @isTest
  static void test_get_records_with_null_metadataType() {
    // Act
    Test.startTest();
    AuraHandledException e = null;
    try {
      List<sObject> records = RetrieveCarouselCustomMetadata.getRecords(null);
    } catch (AuraHandledException ex) {
      e = ex;
    }
    Test.stopTest();

    // Assert
    System.assertNotEquals(
      null,
      e,
      'Expected an AuraHandledException to be thrown'
    );
    System.assertEquals(
      'Custom Metadata Type not provided',
      e.getMessage(),
      'Expected an AuraHandledException with the correct message'
    );
  }

  @isTest
  static void testGetRecordsWithInvalidMetadataType() {
    // Act
    Test.startTest();
    AuraHandledException e = null;
    try {
      List<sObject> records = RetrieveCarouselCustomMetadata.getRecords(
        'InvalidType'
      );
    } catch (AuraHandledException ex) {
      e = ex;
    }
    Test.stopTest();

    // Assert
    System.assertNotEquals(
      null,
      e,
      'Expected an AuraHandledException to be thrown'
    );
    System.assertEquals(
      'Invalid object type: InvalidType',
      e.getMessage(),
      'Expected an AuraHandledException with the correct message'
    );
  }

  @isTest(SeeAllData=true)
  static void testGetRecordsWithValidMetadataType() {
    // Arrange
    // Note: You cannot create or modify Custom Metadata records in Apex tests, so we need to use seeAllData=true and create the records manually in your org
    String validMetadataType = 'Test_Carousel_Custom_Metadata__mdt';

    // Act
    Test.startTest();
    List<sObject> records = RetrieveCarouselCustomMetadata.getRecords(
      validMetadataType
    );
    Test.stopTest();

    // Assert
    System.assertNotEquals(null, records, 'Expected records to be returned');
    for (sObject record : records) {
      System.assertNotEquals(
        null,
        record.get('Client_Name__c'),
        'Expected Client_Name__c to be not null'
      );
      System.assertNotEquals(
        null,
        record.get('Content_Key__c'),
        'Expected Content_Key__c to be not null'
      );
      System.assertNotEquals(
        null,
        record.get('Slide_Number__c'),
        'Expected Slide_Number__c to be not null'
      );
    }
  }

  @isTest
  static void test_no_object_access() {
    // Arrange
    String validMetadataType = 'Test_Carousel_Custom_Metadata__mdt';
    // Create a test user
    User testUser = new User(
      Alias = 'tuser',
      Email = 'testuser@test.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User']
      .Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testuser' + DateTime.now().getTime() + '@test.com'
    );
    insert testUser;

    // Query for the Test No Object Access permission set
    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'Test_No_Object_Access'
    ];

    // Assign the permission set to the user
    PermissionSetAssignment psa = new PermissionSetAssignment(
      PermissionSetId = ps.Id,
      AssigneeId = testUser.Id
    );
    insert psa;

    AuraHandledException e = null;

    // Act
    Test.startTest();
    System.runAs(testUser) {
      try {
        List<sObject> records = RetrieveCarouselCustomMetadata.getRecords(
          validMetadataType
        );
      } catch (AuraHandledException ex) {
        e = ex;
      }
    }
    Test.stopTest();
    // Assert
    System.assertNotEquals(
      null,
      e,
      'Expected an AuraHandledException to be thrown'
    );
    System.assertEquals(
      'User does not have access to object: ' + validMetadataType,
      e.getMessage(),
      'Expected an AuraHandledException with the correct message'
    );
  }
}