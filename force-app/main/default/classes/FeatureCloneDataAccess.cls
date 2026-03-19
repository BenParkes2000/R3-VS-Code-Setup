public with sharing class FeatureCloneDataAccess {
    public Project_Feature__c getFeature(Id featureId) {
        return [
            SELECT
                Id,
                Name,
                Description__c,
                (SELECT Id, Name, Assumptions__c, Deliverables__c, Description__c, Est_Time__c, Implementation__c, Importance__c, Is_Optional__c, Subject__c, Type__c, Urgency__c FROM Work_Items__r)
            FROM Project_Feature__c
            WHERE Id = :featureId
        ];
    }
}