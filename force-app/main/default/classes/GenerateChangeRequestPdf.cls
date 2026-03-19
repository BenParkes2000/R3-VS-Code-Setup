public without sharing class GenerateChangeRequestPdf {
  @InvocableMethod(label='Generate Change Request PDF')
  public static void generatePdf(List<Id> ids) {
    doPreGenerationSecurityChecks();

    List<ContentVersion> versionsToAddWithLink = new List<ContentVersion>();
    List<ContentVersion> versionsToAddWithoutLink = new List<ContentVersion>();
    Map<String, Id> pathToContractIdMap = new Map<String, Id>();

    for (Contract contract : [
      SELECT Id, Name
      FROM Contract
      WHERE Id IN :ids
      WITH SECURITY_ENFORCED
    ]) {
      ContentVersion version = getContentVersion(contract);

      if (version.ContentDocumentId == null) {
        versionsToAddWithLink.add(version);

        pathToContractIdMap.put(version.PathOnClient, contract.Id);
      } else {
        versionsToAddWithoutLink.add(version);
      }
    }

    if (versionsToAddWithLink.size() > 0) {
      addVersionsWithLink(versionsToAddWithLink, pathToContractIdMap);
    }

    if (versionsToAddWithoutLink.size() > 0) {
      addVersionsWithoutLink(versionsToAddWithoutLink);
    }
  }

  private static void doPreGenerationSecurityChecks() {
    if (!Schema.sObjectType.ContentVersion.isCreateable()) {
      throw new CustomException(
        'You do not have permission to create ContentVersion records.'
      );
    }

    if (!Schema.SObjectType.ContentDocumentLink.isCreateable()) {
      throw new CustomException(
        'You do not have permission to create ContentDocumentLink records.'
      );
    }

    if (!Schema.SObjectType.ContentDistribution.isCreateable()) {
      throw new CustomException(
        'You do not have permission to create ContentDistribution records.'
      );
    }
  }

  private static ContentVersion getContentVersion(Contract contract) {
    String path = 'contract-' + contract.Id + '.pdf';

    List<ContentVersion> versionList = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE PathOnClient = :path AND IsLatest = TRUE
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    ContentVersion version = new ContentVersion();
    version.ContentLocation = 'S';
    version.PathOnClient = path;
    version.Title = contract.Name + '.pdf';

    if (versionList.size() > 0) {
      version.ContentDocumentId = versionList[0].ContentDocumentId;
    } else {
      version.ContentDocumentId = null;
    }

    if (Test.isRunningTest()) {
      version.VersionData = Blob.valueOf('Test');
    } else {
      PageReference pageRef = Page.ChangeRequestItems;
      pageRef.getParameters().put('id', contract.Id);
      pageRef.setRedirect(true);

      version.VersionData = pageRef.getContent();
    }

    return version;
  }

  private static void addVersionsWithLink(
    List<ContentVersion> versionsToAddWithLink,
    Map<String, Id> pathToContractIdMap
  ) {
    Database.insert(versionsToAddWithLink, true, AccessLevel.USER_MODE);

    List<ContentDocumentLink> linksToAdd = getLinks(
      versionsToAddWithLink,
      pathToContractIdMap
    );

    if (linksToAdd.size() > 0) {
      Database.insert(linksToAdd, true, AccessLevel.USER_MODE); // NOPMD
    }
  }

  private static void addVersionsWithoutLink(
    List<ContentVersion> versionsToAddWithoutLink
  ) {
    Database.insert(versionsToAddWithoutLink, true, AccessLevel.USER_MODE);
  }

  private static List<ContentDocumentLink> getLinks(
    List<ContentVersion> versionsAdded,
    Map<String, Id> pathTocontractIdMap
  ) {
    List<ContentDocumentLink> linksToAdd = new List<ContentDocumentLink>();
    Set<Id> versionIds = new Set<Id>();

    for (ContentVersion version : versionsAdded) {
      versionIds.add(version.Id);
    }

    for (ContentVersion version : [
      SELECT PathOnClient, ContentDocumentId
      FROM ContentVersion
      WHERE Id IN :versionIds
      WITH SECURITY_ENFORCED
    ]) {
      Id contractId = pathTocontractIdMap.get(version.PathOnClient);

      // Link to contract
      ContentDocumentLink link = new ContentDocumentLink();
      link.LinkedEntityId = contractId;
      link.ContentDocumentId = version.ContentDocumentId;
      link.ShareType = 'V';
      linksToAdd.add(link);
    }

    return linksToAdd;
  }

  public class CustomException extends Exception {
  }
}