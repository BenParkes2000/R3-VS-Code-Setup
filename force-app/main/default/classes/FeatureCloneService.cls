public with sharing class FeatureCloneService {
    private FeatureCloneDataAccess dataAccess;

    public FeatureCloneService() {
        this.dataAccess = new FeatureCloneDataAccess();
    }

    public Id cloneFeature(Id sourceFeatureId, Id targetProjectId) {
        // get source project feature with work item sub collection
        Project_Feature__c sourceFeature = dataAccess.getFeature(sourceFeatureId);
        // clone the feature
        Project_Feature__c targetFeature = sourceFeature.clone(false, false, false, false);
        // set the master detail relationship to the new parent project
        targetFeature.Project__c = targetProjectId;
        // insert, to generate a new Id
        insert targetFeature;

        List<Work_Item__c> targetWorkItems = new List<Work_Item__c>();
        for (Work_Item__c sourceWorkItem : sourceFeature.Work_Items__r) {
            // clone work item
            Work_Item__c targetWorkItem = sourceWorkItem.clone(false, false, false, false);
            // set the master detail relationsgip to the new parent feature
            targetWorkItem.Feature__c = targetFeature.Id;
            targetWorkItem.Project__c = targetProjectId;
            // add to collection for saving later
            targetWorkItems.add(targetWorkItem);
        }
        // save cloned work items
        insert targetWorkItems;
        // return new feature ID
        return targetFeature.Id;
    }
}