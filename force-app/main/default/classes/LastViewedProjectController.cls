public class LastViewedProjectController 
{
    @AuraEnabled
    public static void captureProjectId(String projectId) 
    {
        R3_Settings__c settings = R3_Settings__c.getInstance(UserInfo.getUserId());
        if(settings.projectId__c != projectId) 
        {
            // update current project
            settings.SetupOwnerId = UserInfo.getUserId();
            settings.projectId__c = projectId;
            upsert settings;
        }
    }
}