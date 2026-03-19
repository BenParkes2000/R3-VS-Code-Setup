public with sharing class RetrieveCarouselCustomMetadata {
  @AuraEnabled(cacheable=true)
  public static List<sObject> getRecords(String customMetadataType) {
    // Check if the Custom Metadata Type is provided
    if (String.isBlank(customMetadataType)) {
      System.debug('Custom Metadata Type not provided');
      AuraHandledException e1 = new AuraHandledException(
        'Custom Metadata Type not provided'
      );
      e1.setMessage('Custom Metadata Type not provided');
      throw e1;
    }

    // Get the SObjectType from the global describe
    Schema.sObjectType sObjectType = Schema.getGlobalDescribe()
      .get(customMetadataType);
    // Check if the provided Custom Metadata Type is valid/exists
    if (sObjectType == null) {
      AuraHandledException e2 = new AuraHandledException(
        'Invalid object type: ' + customMetadataType
      );
      e2.setMessage('Invalid object type: ' + customMetadataType);
      throw e2;
    }

    // Check if the user has access to the object
    Schema.DescribeSObjectResult describe = sObjectType.getDescribe();
    if (!describe.isAccessible()) {
      AuraHandledException e3 = new AuraHandledException(
        'User does not have access to object: ' + customMetadataType
      );
      e3.setMessage(
        'User does not have access to object: ' + customMetadataType
      );
      throw e3;
    }

    // We need to use a query string to allow for a dynamic Custom Metadata Type
    String query =
      'SELECT Id, Slide_Number__c, Client_Name__c, Content_Key__c FROM ' +
      customMetadataType +
      ' ORDER BY Slide_Number__c';
    try {
      // PMD warning about SOQL injection is not applicable here as we check if the Custom Metadata Type is valid
      @SuppressWarnings('PMD.ApexSOQLInjection')
      List<sObject> records = Database.query(query);
      return records;
    } catch (QueryException e) {
      AuraHandledException e4 = new AuraHandledException(
        'Error executing query: ' + e.getMessage()
      );
      e4.setMessage('Error executing query: ' + e.getMessage());
      throw e4;
    }
  }
}