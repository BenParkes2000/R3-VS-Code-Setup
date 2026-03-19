public with sharing class WorkItemDataAccess {

    public static Work_Item__c getWorkItem(Id recordId) {

        List<Work_Item__c> items = [SELECT Id, Subject__c, Description__c, Documentation_URL__c, Implementation__c FROM Work_Item__c WHERE Id = :recordId];

        if (items.size() == 0) {
            return null;
        }
        return items[0];
    }
}