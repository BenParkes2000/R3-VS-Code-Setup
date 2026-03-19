@isTest
private class LastViewedProjectController_test 
{
    static testMethod void testController()
    {
        LastViewedProjectController.captureProjectId('1234');
        R3_Settings__c settings = R3_Settings__c.getInstance(UserInfo.getUserId());
        system.assertEquals('1234', settings.projectId__c);
    }
}