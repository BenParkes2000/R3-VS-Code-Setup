@SuppressWarnings('PMD.ApexCRUDViolation, PMD.ExcessiveParameterList')
public without sharing class CreateLeadController {
  @TestVisible
  private static final String INSUFFICIENT_RECORD_CREATION_PERMISSIONS_ERROR_MESSAGE = System.Label.Insufficient_Record_Creation_Permissions_Error_Message;
  @TestVisible
  private static final String INSUFFICIENT_RECORD_ACCESS_PERMISSIONS_ERROR_MESSAGE = System.Label.Insufficient_Record_Access_Permissions_Error_Message;
  @TestVisible
  private static final String REQUIRED_FIELDS_ERROR = System.Label.Required_Fields_Error_Message;
  @TestVisible
  private static final String FAILED_TO_CREATE_NEW_RECORD_ERROR_MESSAGE = System.Label.Failed_To_Create_Record_Error_Message;
  @TestVisible
  private static final String FAILED_TO_UPDATE_RECORD_ERROR_MESSAGE = System.Label.Failed_To_Update_Record_Error_Message;

  @AuraEnabled
  public static void createNewLead(
    String firstName,
    String lastName,
    String phoneNumber,
    String emailAddress,
    String company
  ) {
    checkIfUserHasPermissions();

    checkRequiredFields(
      firstName,
      lastName,
      phoneNumber,
      emailAddress,
      company
    );

    List<String> leadData = new List<String>{
      firstName,
      lastName,
      phoneNumber,
      emailAddress,
      company
    };

    insertLeadRecord(leadData);
  }

  @AuraEnabled
  public static void createLeadForEvent(
    String firstName,
    String lastName,
    String phoneNumber,
    String emailAddress,
    String company,
    String dietaryRequirements,
    String sessionSelection,
    String eventName,
    String leadType
  ) {
    checkIfUserHasPermissions();

    checkRequiredFields(
      firstName,
      lastName,
      phoneNumber,
      emailAddress,
      company
    );

    List<String> leadData = new List<String>{
      firstName,
      lastName,
      phoneNumber,
      emailAddress,
      company
    };
    List<String> eventInfo = new List<String>{
      dietaryRequirements,
      eventName,
      leadType,
      sessionSelection
    };

    Lead existingLead = checkIfLeadExists(firstName, lastName, emailAddress);

    if (existingLead == null) {
      existingLead = insertLeadRecord(leadData);
    }

    addEventInfoToLead(eventInfo, existingLead);
  }

  private static void checkRequiredFields(
    String firstName,
    String lastName,
    String phoneNumber,
    String emailAddress,
    String company
  ) {
    if (
      String.isBlank(firstName) ||
      String.isBlank(lastName) ||
      String.isBlank(phoneNumber) ||
      String.isBlank(emailAddress) ||
      String.isBlank(company)
    ) {
      AuraHandledException errorMessage = new AuraHandledException(
        REQUIRED_FIELDS_ERROR
      );
      // Required to ensure we get an accurate error message when testing
      errorMessage.setMessage(REQUIRED_FIELDS_ERROR);
      throw errorMessage;
    }
  }

  private static Lead insertLeadRecord(List<String> leadData) {
    Lead newLead = new Lead();
    newLead.FirstName = leadData[0];
    newLead.LastName = leadData[1];
    newLead.Phone = leadData[2];
    newLead.Email = leadData[3];
    newLead.Company = leadData[4];
    try {
      Database.insert(newLead, true, System.AccessLevel.SYSTEM_MODE);
    } catch (DmlException e) {
      throw new AuraHandledException(
        FAILED_TO_CREATE_NEW_RECORD_ERROR_MESSAGE + e.getMessage()
      );
    }
    return newLead;
  }

  private static void addEventInfoToLead(
    List<String> eventInfo,
    Lead existingLead
  ) {
    // We are adding the dietary requirements to the description field and the event name to the series number field. It would be good if we could add these to custom fields.
    Lead leadToBeUpdated = [
      SELECT Id, Description, Series_No__c
      FROM Lead
      WHERE Id = :existingLead.Id
      WITH SYSTEM_MODE
    ];
    if (eventInfo[0] != null) {
      leadToBeUpdated.Description =
        (leadToBeUpdated.Description != null
          ? leadToBeUpdated.Description + '. '
          : '') +
        'Dietary Requirements: ' +
        eventInfo[0];
    }

    leadToBeUpdated.Series_No__c =
      (leadToBeUpdated.Series_No__c != null
        ? leadToBeUpdated.Series_No__c + '. '
        : '') +
      'Event Name: ' +
      eventInfo[1] +
      '. ' +
      eventInfo[2];
    if (eventInfo[3] != null) {
      leadToBeUpdated.Description =
        leadToBeUpdated.Description +
        '. ' +
        'Session Selection: ' +
        eventInfo[3];
    }

    try {
      Database.update(leadToBeUpdated, true, System.Accesslevel.SYSTEM_MODE);
    } catch (DmlException e) {
      throw new AuraHandledException(
        FAILED_TO_UPDATE_RECORD_ERROR_MESSAGE + e.getMessage()
      );
    }
  }

  private static Lead checkIfLeadExists(
    String firstName,
    String lastName,
    String emailAddress
  ) {
    List<Lead> existingLeads = [
      SELECT Id
      FROM Lead
      WHERE
        FirstName = :firstName
        AND LastName = :lastName
        AND Email = :emailAddress
      WITH SYSTEM_MODE
    ];
    if (existingLeads.size() > 0) {
      return existingLeads[0];
    }
    return null;
  }

  private static void checkIfUserHasPermissions() {
    // Check if the user has permission to create a lead
    if (!Schema.sObjectType.Lead.isCreateable()) {
      AuraHandledException errorMessage = new AuraHandledException(
        INSUFFICIENT_RECORD_CREATION_PERMISSIONS_ERROR_MESSAGE
      );
      errorMessage.setMessage(
        INSUFFICIENT_RECORD_CREATION_PERMISSIONS_ERROR_MESSAGE
      );
      throw errorMessage;
    }
    if (!Schema.sObjectType.Lead.isAccessible()) {
      AuraHandledException errorMessage = new AuraHandledException(
        INSUFFICIENT_RECORD_ACCESS_PERMISSIONS_ERROR_MESSAGE
      );
      errorMessage.setMessage(
        INSUFFICIENT_RECORD_ACCESS_PERMISSIONS_ERROR_MESSAGE
      );
      throw errorMessage;
    }
  }
}