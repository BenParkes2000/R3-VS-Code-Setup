@isTest
public class ProjectTestDataFactory {
    public static Id create(Id accountId) {
        return create(accountId, 'test project', ProjectStatusNames.Backlog);
    }

    public static Id create(Id accountId, String name, String status) {
        return create(accountId, name, status, Date.today(), (Date.today() + 28));
    }

    public static Id create(Id accountId, String name, String status, Date startDate, Date endDate) {
        Project__c project = new Project__c();
        project.Name = name;
        project.Account__c = accountId;
        project.Status__c = status;
        project.Introduction__c = 'test';
        project.Challenges__c = 'test';
        project.Payment_Terms__c = 'test';
        project.Start_Date__c = startDate;
        project.End_Date__c = endDate;
        project.Colour__c = ProjectColourNames.RED;
        project.Support_Type__c = 'MSA';
        insert project;
        return project.Id;
    }
}