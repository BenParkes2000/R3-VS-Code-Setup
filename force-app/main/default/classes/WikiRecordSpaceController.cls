public with sharing class WikiRecordSpaceController {
  @AuraEnabled(cacheable=true)
  public static Wiki_Record_Page__c getHomepage(String recordId) {
    try {
      List<Wiki_Record_Page__c> pages = [
        SELECT Id, Name
        FROM Wiki_Record_Page__c
        WHERE Record_ID__c = :recordId AND Parent_page__c = NULL
        WITH SECURITY_ENFORCED
        ORDER BY Sort_Order__c ASC
        LIMIT 1
      ];

      if (pages.size() == 0) {
        return null;
      }

      return pages[0];
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }
}