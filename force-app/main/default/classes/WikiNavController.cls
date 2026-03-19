public with sharing class WikiNavController {
  @AuraEnabled
  public static Boolean hasChildPages(Id recordId) {
    try {
      List<Wiki_Page__c> pages = [
        SELECT Id
        FROM Wiki_Page__c
        WHERE Parent_Page__c = :recordId
        WITH SECURITY_ENFORCED
      ];
      return pages.size() > 0;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }

  @AuraEnabled
  public static Boolean isFinalPage(Id spaceId, Id pageId) {
    try {
      List<Wiki_Page__c> pages = [
        SELECT Id
        FROM Wiki_Page__c
        WHERE Wiki_Space__c = :spaceId AND Id != :pageId
        WITH SECURITY_ENFORCED
      ];
      if (pages.size() == 0) {
        return true;
      }
      return false;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }
}