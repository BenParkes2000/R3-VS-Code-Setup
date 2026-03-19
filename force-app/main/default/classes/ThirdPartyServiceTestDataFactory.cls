@isTest
public class ThirdPartyServiceTestDataFactory {
    public static Third_Party_Service__c create(Id projectId) {
        Third_Party_Service__c service = new Third_Party_Service__c();
        service.Project__c = projectId;
        service.Service__c = 'Gazela Trustpilot Connector';
        service.Description__c = 'Sync Trustpilot ratings to your Salesforce org';
        service.Est_Cost__c = 500;

        return service;
    }
}