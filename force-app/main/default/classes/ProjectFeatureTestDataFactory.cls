@isTest
public class ProjectFeatureTestDataFactory {
    public static Id create(Id projectId) {
        return create(projectId, 'test feature');
    }

    public static Id create(Id projectId, String name) {
        Project_Feature__c feature = new Project_Feature__c();
        feature.Name = name;
        feature.Project__c = projectId;
        insert feature;
        return feature.Id;
    }
}