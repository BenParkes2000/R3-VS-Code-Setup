public with sharing class ChangeSpaceModelController {
  @AuraEnabled(cacheable=true)
  public static List<Wiki_Space__c> getSpaces() {
    try {
      List<Wiki_Space__c> spaces = [
        SELECT
          Id,
          Name,
          Description__c,
          (SELECT Id FROM Wiki_Pages__r ORDER BY Sort_Order__c ASC LIMIT 1)
        FROM Wiki_Space__c
        WITH SECURITY_ENFORCED
        ORDER BY Name ASC
      ];

      if (spaces.isEmpty()) {
        spaces.add(new Wiki_Space__c(Name = 'No Spaces Found'));
      }

      return spaces;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }
}