public with sharing class LookupController {
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';
        List<String> statuses = new List<String>{ 'Approved', 'In Progress', 'Implemented' };

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING Work_Item__c(Id, Subject__c, Project_Name__c WHERE Status__c IN :statuses AND Assigned_To__c = :UserInfo.getUserId() ORDER BY Priority__c DESC)
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Work Items & convert them into LookupSearchResult
        Work_Item__c[] workItems = (List<Work_Item__c>) searchResults[0];
        for (Work_Item__c workItem : workItems) {
            results.add(new LookupSearchResult(workItem.Id, 'Work Item', 'custom:custom67', workItem.Subject__c, workItem.Project_Name__c));
        }

        return results;
    }
}