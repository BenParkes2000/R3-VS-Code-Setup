@isTest
public class GanttChartTaskTransformerTest {
    @isTest
    public static void test_project() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();

        Project__c project = new Project__c();
        project.Account__c = accountId;
        project.Name = 'Test Project';
        project.Start_Date__c = Date.newInstance(2020, 6, 1);
        project.End_Date__c = Date.newInstance(2020, 12, 31);
        project.Duration__c = 200;
        project.Support_Type__c = 'MSA';
        insert project;

        List<Project__c> projectList = [SELECT Id, Name, Start_Date__c, End_Date__c, Duration__c FROM Project__c WHERE Id = :project.Id];

        // Act
        Test.startTest();
        GanttChartTaskTransformer transformer = new GanttChartTaskTransformer(projectList[0], 50);
        Test.stopTest();

        // Assert
        System.assertEquals(project.Id, transformer.getId());
        System.assertEquals(project.Name, transformer.getName());
        System.assertEquals(project.Start_Date__c, transformer.getStartDate());
        System.assertEquals(project.End_Date__c, transformer.getEndDate());
        System.assertEquals(null, transformer.getMilestoneDate());
        System.assertEquals(200, transformer.getDuration());
        System.assertEquals(50, transformer.getTotalHours());
        System.assertEquals(25, transformer.getPercentAllocated());
    }

    @isTest
    public static void test_phase() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        Phase__c phase = new Phase__c();
        phase.Project__c = projectId;
        phase.Name = 'Test Phase';
        phase.Start_Date__c = Date.newInstance(2021, 11, 29);
        phase.End_Date__c = Date.newInstance(2021, 12, 31);
        phase.Milestone_Date__c = Date.newInstance(2021, 12, 24);
        insert phase;

        List<Phase__c> phaseList = [SELECT Id, Name, Start_Date__c, End_Date__c, Duration__c, Milestone_Date__c FROM Phase__c WHERE Id = :phase.Id];

        // Act
        Test.startTest();
        GanttChartTaskTransformer transformer = new GanttChartTaskTransformer(phaseList[0], 50);
        Test.stopTest();

        // Assert
        System.assertEquals(phase.Id, transformer.getId());
        System.assertEquals(phase.Name, transformer.getName());
        System.assertEquals(phase.Start_Date__c, transformer.getStartDate());
        System.assertEquals(phase.End_Date__c, transformer.getEndDate());
        System.assertEquals(phase.Milestone_Date__c, transformer.getMilestoneDate());
        System.assertEquals(200, transformer.getDuration());
        System.assertEquals(50, transformer.getTotalHours());
        System.assertEquals(25, transformer.getPercentAllocated());
    }
}