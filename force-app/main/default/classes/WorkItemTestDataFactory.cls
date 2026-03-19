@isTest
public class WorkItemTestDataFactory {
    public static Id create(Id projectId, Id featureId) {
        return create(projectId, featureId, WorkItemStatusNames.Backlog, null, WorkItemImportanceNames.MUST_HAVE_VALUE, 8, null);
    }

    public static Id create(Id projectId, Id featureId, String status, Id phaseId) {
        return create(projectId, featureId, WorkItemStatusNames.Backlog, null, WorkItemImportanceNames.MUST_HAVE_VALUE, 8, phaseId);
    }

    public static Id create(Id projectId, Id featureId, String status, String blockedReason) {
        return create(projectId, featureId, status, blockedReason, WorkItemImportanceNames.MUST_HAVE_VALUE, 8, null);
    }

    public static Id create(Id projectId, Id featureId, String status, String importance, Decimal estimatedTime) {
        return create(projectId, featureId, status, null, importance, estimatedTime, null);
    }

    public static Id create(Id projectId, Id featureId, String status, String blockedReason, String importance, Decimal estimatedTime, Id phaseId) {
        Work_Item__c workItem = new Work_Item__c();
        workItem.Project__c = projectId;
        workItem.Feature__c = featureId;
        workItem.Subject__c = 'test work item';
        workItem.Type__c = 'Work Item';
        workItem.Est_Time__c = estimatedTime;
        workItem.Assigned_To__c = UserInfo.getUserId();
        workItem.Status__c = status;
        workItem.Blocked_Reason__c = blockedReason;
        workItem.Importance__c = importance;
        workItem.Project_Phase__c = phaseId;

        insert workItem;
        return workItem.Id;
    }
}