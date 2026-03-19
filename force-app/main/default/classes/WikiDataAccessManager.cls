public without sharing class WikiDataAccessManager {
    
    public static void updateDocumentLink(Id pageId) {
        List<ContentDocumentLink> existingLinks = [
            SELECT Id, ContentDocumentId, ShareType, Visibility
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :pageId
            AND (ShareType != 'I' OR Visibility != 'AllUsers')
        ];
        
        for(ContentDocumentLink cdl : existingLinks){
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
        }
        
        if(!existingLinks.isEmpty()){
            update existingLinks;
            System.debug('Updated ' + existingLinks.size() + ' existing ContentDocumentLinks to ShareType I and Visibility AllUsers.');
        }
    }

    private static String getTitle(Id recordId) {
        if (recordId.getSObjectType() == User.getSObjectType()) {
          return 'ScratchPad';
        } else {
          return 'Published';
        }
      }

    public static String getLatestContent(Id pageId) {

        final String title = getTitle(pageId);

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :pageId
            LIMIT 1
        ];
        
        if (links.size() > 0) {
            List<ContentVersion> versions = [
                SELECT VersionData, IsLatest
                FROM ContentVersion
                WHERE ContentDocumentId = :links[0].ContentDocumentId AND Title = :title
                ORDER BY IsLatest DESC
                LIMIT 1
            ];
            if (versions.size() > 0) {
                return versions[0].VersionData.toString();
            }
        }
        return null;
    }
}