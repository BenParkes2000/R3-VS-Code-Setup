@SuppressWarnings('PMD.ExcessiveParameterList, PMD.CyclomaticComplexity')
public with sharing class WikiPageSortController {
  @AuraEnabled
  public static Boolean sortPages(
    Id pageId,
    Integer newIndex,
    Id targetId,
    Id sourceId
  ) {
    try {
      if (
        !Schema.sObjectType.Wiki_Page__c.isUpdateable() ||
        !Schema.sObjectType.Wiki_Page__c.fields.Name.isUpdateable() ||
        !Schema.sObjectType.Wiki_Page__c.fields.Sort_Order__c.isUpdateable() ||
        !Schema.sObjectType.Wiki_Page__c.fields.Parent_Page__c.isUpdateable()
      ) {
        throw new DMLException(
          'Insufficient permissions to create Wiki_Page__c'
        );
      }

      List<Wiki_Page__c> pages = getSortedPages(targetId);
      List<Wiki_Page__c> pagesToUpdate = new List<Wiki_Page__c>();

      if (pages.size() == 0) {
        pagesToUpdate.add(createNewPage(pageId, targetId, newIndex));
      } else {
        pagesToUpdate = updatePageSortOrder(pages, pageId, targetId, newIndex);
      }

      update pagesToUpdate;

      if (sourceId == targetId) {
        return true;
      }

      pages = getSortedPages(sourceId);

      if (pages.size() == 0) {
        return true;
      }

      pagesToUpdate = updatePageSortOrder(pages, pageId, null, null);
      update pagesToUpdate;

      return true;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }

  private static List<Wiki_Page__c> getSortedPages(Id parentId) {
    return [
      SELECT Id, Sort_Order__c
      FROM Wiki_Page__c
      WHERE Parent_Page__c = :parentId
      WITH SECURITY_ENFORCED
      ORDER BY Sort_Order__c ASC
    ];
  }

  private static Wiki_Page__c createNewPage(
    Id pageId,
    Id parentId,
    Integer sortOrder
  ) {
    return new Wiki_Page__c(
      Id = pageId,
      Parent_Page__c = parentId,
      Sort_Order__c = sortOrder
    );
  }

  private static List<Wiki_Page__c> updatePageSortOrder(
    List<Wiki_Page__c> pages,
    Id pageId,
    Id targetId,
    Integer newIndex
  ) {
    Integer sortOrder = 0;
    List<Wiki_Page__c> pagesToUpdate = new List<Wiki_Page__c>();

    for (Wiki_Page__c page : pages) {
      if (page.Id == pageId) {
        // skip if we are moving the page within its current group
        continue;
      }

      if (sortOrder == newIndex) {
        pagesToUpdate.add(createNewPage(pageId, targetId, newIndex));
        sortOrder++;
      }
      pagesToUpdate.add(
        new Wiki_Page__c(Id = page.Id, Sort_Order__c = sortOrder)
      );
      sortOrder++;
    }

    return pagesToUpdate;
  }
}