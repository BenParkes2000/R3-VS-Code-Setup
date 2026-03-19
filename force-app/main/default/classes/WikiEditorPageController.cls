@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class WikiEditorPageController {

  @TestVisible
  private static String getTitle(Id recordId) {
    if (recordId.getSObjectType() == User.getSObjectType()) {
      return 'ScratchPad';
    } else {
      return 'Published';
    }
  }

  @SuppressWarnings('PMD.CyclomaticComplexity')
  @RemoteAction
  global static String uploadImage(
    Id pageId,
    String fileName,
    String base64Data
  ) {
    try {
      if (
        !Schema.sObjectType.ContentVersion.isCreateable() ||
        !Schema.sObjectType.ContentVersion.fields.Title.isCreateable() ||
        !Schema.sObjectType.ContentVersion.fields.Description.isCreateable() ||
        !Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable() ||
        !Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable() ||
        !Schema.sObjectType.ContentVersion.fields.FirstPublishLocationId.isCreateable()
      ) {
        throw new DMLException(
          'Insufficient permissions to create ContentVersion'
        );
      }

      ContentVersion cv = new ContentVersion();
      cv.Title = fileName;
      cv.PathOnClient = fileName;
      cv.VersionData = EncodingUtil.base64Decode(base64Data);
      cv.FirstPublishLocationId = pageId;
      cv.Description = 'Image for Wiki Content';
      insert cv;
      return '/sfc/servlet.shepherd/version/download/' + cv.Id;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }

  @RemoteAction
  global static String getPage(Id pageId) {
      final String title = getTitle(pageId);

      List<ContentDocumentLink> links = [
          SELECT ContentDocumentId
          FROM ContentDocumentLink
          WHERE LinkedEntityId = :pageId
          WITH SECURITY_ENFORCED
          LIMIT 1
      ];
      if (!links.isEmpty()) {
          List<ContentVersion> versions = [
              SELECT VersionData, CreatedDate, Title, PublishStatus
              FROM ContentVersion
              WHERE ContentDocumentId = :links[0].ContentDocumentId
                AND Title = :title   
              WITH SECURITY_ENFORCED
              ORDER BY CreatedDate DESC
              LIMIT 1
          ];
          if (!versions.isEmpty()) {
              return versions[0].VersionData.toString();
          }
      }
      return getDefaultPageContent();
  }

  private static String getDefaultPageContent() {
    List<StaticResource> resources = [
      SELECT Id, Body
      FROM StaticResource
      WHERE Name = 'WikiDefaultPageContent'
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    if (resources.size() > 0) {
      return resources[0].Body.toString();
    }

    return null;
  }

  @RemoteAction
  global static Boolean updatePage(Id pageId, String content) {
    final String title = getTitle(pageId);
    Id contentDocumentId = getExisingContentDocumentId(pageId);
    ContentVersion cv = new ContentVersion();
    cv.PathOnClient = 'WikiPage.json';
    cv.Title = title;
    cv.VersionData = Blob.valueOf(content);
    cv.Description = 'Wiki Content';
    if (ContentDocumentId != null) {
      cv.ContentDocumentId = ContentDocumentId;
    } else {
      cv.FirstPublishLocationId = pageId;
    }
    insert cv;

    // 🔹 Ensure "Set by Record" (ShareType = 'I') from the first save
    try {
        List<ContentDocumentLink> links = [
            SELECT Id, ShareType
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :cv.ContentDocumentId
              AND LinkedEntityId = :pageId
            LIMIT 1
        ];

        if (links.isEmpty()) {
            // if Salesforce hasn't yet created the link, make it manually
            ContentDocumentLink newLink = new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId    = pageId,
                ShareType         = 'I',   // "Set by Record"
                Visibility        = 'AllUsers'
            );
            insert newLink;
        } else {
            // link exists – update it if needed
            ContentDocumentLink link = links[0];
            if (link.ShareType != 'I') {
                link.ShareType = 'I';
                update link;
            }
        }
    } catch (Exception e) {
        System.debug('Could not set ShareType: ' + e.getMessage());
    }

    return true;
  }

  private static Id getExisingContentDocumentId(Id pageId) {
    List<ContentDocumentLink> links = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :pageId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    if (links.size() > 0) {
      return links[0].ContentDocumentId;
    }
    return null;
  }
}