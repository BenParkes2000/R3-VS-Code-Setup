public with sharing class WikiSpaceController {
  @AuraEnabled(cacheable=true)
  public static Wiki_Page__c getHomepageBySpaceId(String spaceId) {
    try {
      if (String.isEmpty(spaceId)) {
        return null;
      }

      List<Wiki_Page__c> pages = [
        SELECT Id, Name, Wiki_Space__c, Wiki_Space__r.Name
        FROM Wiki_Page__c
        WHERE Wiki_Space__c = :spaceId AND Parent_page__c = NULL
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

  @AuraEnabled
  public static Wiki_Page__c createHomepage(String spaceId) {
    try {
      if (
        !Schema.sObjectType.Wiki_Page__c.isCreateable() ||
        !Schema.sObjectType.Wiki_Page__c.fields.Name.isCreateable() ||
        !Schema.sObjectType.Wiki_Page__c.fields.Wiki_Space__c.isCreateable()
      ) {
        throw new DMLException(
          'Insufficient permissions to create Wiki_Page__c'
        );
      }

      Wiki_Page__c welcome = new Wiki_Page__c();
      welcome.Name = 'Welcome';
      welcome.Wiki_Space__c = spaceId;
      insert welcome;
      return welcome;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }
}