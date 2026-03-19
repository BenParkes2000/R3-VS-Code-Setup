@isTest
private class CreateLeadControllerTest {
  static void testCreateNewLead() {
    // Arrange
    String firstName = 'Test';
    String lastName = 'Lead';
    String phoneNumber = '123-456-7890';
    String emailAddress = 'testlead@example.com';
    String company = 'Test Company';

    // Act
    Test.startTest();
    CreateLeadController.createNewLead(
      firstName,
      lastName,
      phoneNumber,
      emailAddress,
      company
    );
    Test.stopTest();

    // Assert
    List<Lead> createdLeads = [
      SELECT Id, FirstName, LastName, Company, Email, Phone
      FROM Lead
      WHERE FirstName = :firstName AND LastName = :lastName
    ];
    System.assertEquals(
      1,
      createdLeads.size(),
      'Expected one lead to be created'
    );
  }

  @isTest
  static void testCreateLeadForEvent() {
    // Arrange
    String firstName = 'Test';
    String lastName = 'Lead';
    String phoneNumber = '123-456-7890';
    String emailAddress = 'testlead@example.com';
    String company = 'Test Company';
    String dietaryRequirements = 'Vegetarian';
    String sessionSelection = 'Test Session Selection';
    String eventName = 'Test Event';
    String leadType = 'Test Lead Type';

    // Act
    Test.startTest();
    CreateLeadController.createLeadForEvent(
      firstName,
      lastName,
      phoneNumber,
      emailAddress,
      company,
      dietaryRequirements,
      sessionSelection,
      eventName,
      leadType
    );
    Test.stopTest();

    // Assert
    List<Lead> createdLeads = [
      SELECT
        Id,
        FirstName,
        LastName,
        Company,
        Email,
        Phone,
        Description,
        Series_No__c
      FROM Lead
      WHERE FirstName = :firstName AND LastName = :lastName
    ];
    System.assertEquals(
      1,
      createdLeads.size(),
      'Expected one lead to be created'
    );
    System.assertEquals(
      'Dietary Requirements: ' +
      dietaryRequirements +
      '. Session Selection: ' +
      sessionSelection,
      createdLeads[0].Description
    );
    System.assertEquals(
      'Event Name: ' +
      eventName +
      '. ' +
      leadType,
      createdLeads[0].Series_No__c
    );
  }

  @isTest
  static void testCreateLeadMissingRequiredField() {
    // Arrange
    String firstName = 'Test';
    String lastName = null;
    String phoneNumber = '123-456-7890';
    String emailAddress = 'testlead@example.com';
    String company = 'Test Company';

    // Act
    Test.startTest();
    try {
      CreateLeadController.createNewLead(
        firstName,
        lastName,
        phoneNumber,
        emailAddress,
        company
      );
      Test.stopTest();
      System.assert(false, 'Expected an AuraHandledException to be thrown');
    } catch (AuraHandledException e) {
      // Assert
      System.assertEquals(
        CreateLeadController.REQUIRED_FIELDS_ERROR,
        e.getMessage(),
        'Expected error message to match'
      );
    }
  }
}