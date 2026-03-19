@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class WikiController {
  @AuraEnabled(cacheable=true)
  public static List<Wiki_Page__c> getPages() {
    return [
      SELECT Id, Name, Parent_page__c
      FROM Wiki_Page__c
      WITH SECURITY_ENFORCED
    ];
  }

  @AuraEnabled(cacheable=true)
  public static List<Wiki_Page__c> getPagesBySpace(String spaceId) {
    return [
      SELECT Id, Name, Parent_page__c
      FROM Wiki_Page__c
      WHERE Wiki_Space__c = :spaceId
      WITH SECURITY_ENFORCED
      ORDER BY Sort_Order__c ASC
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Wiki_Page__c getHomepageBySpaceId(String spaceId) {
    try {
      List<Wiki_Page__c> pages = [
        SELECT Id, Name, Wiki_Space__r.Name
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

  @AuraEnabled(cacheable=true)
  public static List<LabelValuePair> getSpaces() {
    List<LabelValuePair> spaces = new List<LabelValuePair>();

    for (Wiki_Space__c space : [
      SELECT Id, Name, Description__c
      FROM Wiki_Space__c
      WITH SECURITY_ENFORCED
    ]) {
      spaces.add(new LabelValuePair(space.Name, space.Id));
    }
    return spaces;
  }

  @AuraEnabled
  public static Wiki_Page__c createSpace(
    String spaceName,
    String spaceDescription
  ) {
    try {
      if (
        !Schema.sObjectType.Wiki_Space__c.isCreateable() ||
        !Schema.sObjectType.Wiki_Space__c.fields.Name.isCreateable() ||
        !Schema.sObjectType.Wiki_Space__c.fields.Description__c.isCreateable()
      ) {
        throw new DMLException(
          'Insufficient permissions to create Wiki_Space__c'
        );
      }

      Wiki_Space__c space = new Wiki_Space__c();
      space.Name = spaceName;
      space.Description__c = spaceDescription;
      insert space;

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
      welcome.Wiki_Space__c = space.Id;
      insert welcome;

      return welcome;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }

  @AuraEnabled
  public static Wiki_Page__c createPage(
      String spaceId,
      String parentPageId,
      String pageName
  ) {
      try {
          if (
              !Schema.sObjectType.Wiki_Page__c.isCreateable() ||
              !Schema.sObjectType.Wiki_Page__c.fields.Name.isCreateable() ||
              !Schema.sObjectType.Wiki_Page__c.fields.Wiki_Space__c.isCreateable() ||
              !Schema.sObjectType.Wiki_Page__c.fields.Parent_Page__c.isCreateable()
          ) {
              throw new DMLException(
                  'Insufficient permissions to create Wiki_Page__c'
              );
          }

          // 1️⃣ Create the new Wiki page record
          Wiki_Page__c page = new Wiki_Page__c();
          page.Name = pageName;
          page.Parent_Page__c = parentPageId;
          page.Wiki_Space__c = spaceId;
          insert page;

          // 2️⃣ Fetch default template content from static resource
          String defaultContent = '{}';
          try {
              List<StaticResource> resources = [
                  SELECT Body
                  FROM StaticResource
                  WHERE Name = 'WikiDefaultPageContent'
                  LIMIT 1
              ];
              if (!resources.isEmpty()) {
                  defaultContent = resources[0].Body.toString();
              }
          } catch (Exception e) {
              System.debug('Could not load WikiDefaultPageContent: ' + e.getMessage());
          }

          // 3️⃣ Create an initial file using the default template content
          try {
              ContentVersion cv = new ContentVersion(
                  Title = 'Published',
                  PathOnClient = 'WikiPage.json',
                  VersionData = Blob.valueOf(defaultContent),
                  Description = 'Initial Wiki Page content from template',
                  FirstPublishLocationId = page.Id
              );
              insert cv;

              // 4️⃣ Update link to "Set by Record"
              List<ContentDocumentLink> links = [
                  SELECT Id, ShareType
                  FROM ContentDocumentLink
                  WHERE ContentDocumentId = :cv.ContentDocumentId
                    AND LinkedEntityId    = :page.Id
                  LIMIT 1
              ];
              if (!links.isEmpty()) {
                  ContentDocumentLink link = links[0];
                  link.ShareType = 'I'; // Set by Record
                  update link;
              }
          } catch (Exception e) {
              System.debug('Could not create initial Wiki file: ' + e.getMessage());
          }

          return page;
      } catch (Exception cause) {
          throw AuraHandledExceptionFactory.create(cause);
      }
  }


  @AuraEnabled(cacheable=true)
  public static Wiki_Page__c getPageWithoutContent(Id pageId) {
    try {
      List<Wiki_Page__c> pages = [
        SELECT Name, Wiki_Space__c, Wiki_Space__r.Name
        FROM Wiki_Page__c
        WHERE ID = :pageId
        WITH SECURITY_ENFORCED
      ];

      if (pages.size() == 0) {
        return null;
      }

      return pages[0];
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }

  @AuraEnabled(cacheable=true)
  public static ContentVersion getMostRecentContent(Id pageId) {
    try {
      List<ContentDocumentLink> links = [
        SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :pageId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      if (links.size() > 0) {
        List<ContentVersion> versions = [
          SELECT Title, VersionData
          FROM ContentVersion
          WHERE
            ContentDocumentId = :links[0].ContentDocumentId
            AND Title = 'Published'
          WITH SECURITY_ENFORCED
          ORDER BY CreatedDate DESC
          LIMIT 1
        ];
        if (versions.size() > 0) {
          return versions[0];
        }
      }
      return null;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<ContentVersion> getAllContentVersions(Id pageId) {
    try {
      List<ContentDocumentLink> links = [
        SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :pageId
        WITH SECURITY_ENFORCED
      ];
      Set<ID> contentDocumentIds = new Set<ID>();
      for (ContentDocumentLink link : links) {
        contentDocumentIds.add(link.ContentDocumentId);
      }
      if (links.size() > 0) {
        List<ContentVersion> versions = [
          SELECT
            VersionNumber,
            Title,
            VersionData,
            CreatedDate,
            OwnerId,
            Owner.Name,
            PublishStatus
          FROM ContentVersion
          WHERE ContentDocumentId IN :contentDocumentIds
          WITH SECURITY_ENFORCED
        ];
        return versions;
      }
      return null;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }

  @AuraEnabled
  public static Boolean deletePage(Id pageId) {
    try {
      delete pageId.getSobjectType().newSObject(pageId);
      return true;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }
}