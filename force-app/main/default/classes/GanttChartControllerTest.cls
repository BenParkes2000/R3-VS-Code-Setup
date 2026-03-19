@isTest
public class GanttChartControllerTest {
    @isTest
    public static void test_get_tasks() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id project1Id = ProjectTestDataFactory.create(accountId, 'Project One', ProjectStatusNames.InProgress);
        Id project2Id = ProjectTestDataFactory.create(accountId, 'Project Two', ProjectStatusNames.HyperCare);
        Id project3Id = ProjectTestDataFactory.create(accountId, 'Project Three', ProjectStatusNames.Complete);
        insert new List<Phase__c>{ PhaseTestDataFactory.create(project1Id), PhaseTestDataFactory.create(project1Id), PhaseTestDataFactory.create(project1Id), PhaseTestDataFactory.create(project2Id), PhaseTestDataFactory.createMilestone(project2Id, Date.today()) };

        // Act
        List<GanttChartTaskTransformer> projectList = GanttChartController.getTasks(accountId);
        List<GanttChartTaskTransformer> project1PhaseList = GanttChartController.getTasks(project1Id);
        List<GanttChartTaskTransformer> project2PhaseList = GanttChartController.getTasks(project2Id);

        // Assert
        System.assertEquals(2, projectList.size()); // The 'Complete' project is omitted
        System.assertEquals(3, project1PhaseList.size());
        System.assertEquals(2, project2PhaseList.size());
    }

    @isTest
    public static void test_update_dates() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        Phase__c phase = PhaseTestDataFactory.create(projectId);
        phase.Start_Date__c = Date.newInstance(2021, 1, 1);
        phase.End_Date__c = Date.newInstance(2021, 1, 31);
        insert phase;

        Phase__c milestone = PhaseTestDataFactory.createMilestone(projectId, Date.newInstance(2021, 4, 1));
        insert milestone;

        Project__c project = new Project__c(Id = projectId);
        project.Start_Date__c = Date.newInstance(2020, 12, 1);
        project.End_Date__c = Date.newInstance(2021, 2, 28);
        update project;

        // Act
        GanttChartController.updateDates(projectId, '2020-12-15', '2021-03-14', null);
        GanttChartController.updateDates(phase.Id, '2021-01-15', '2021-02-14', null);
        GanttChartController.updateDates(milestone.Id, null, null, '2021-04-14');

        // Assert
        project = [SELECT Start_Date__c, End_Date__c FROM Project__c WHERE Id = :projectId];
        System.assertEquals(Date.newInstance(2020, 12, 15), project.Start_Date__c);
        System.assertEquals(Date.newInstance(2021, 3, 14), project.End_Date__c);

        phase = [SELECT Start_Date__c, End_Date__c FROM Phase__c WHERE Id = :phase.Id];
        System.assertEquals(Date.newInstance(2021, 1, 15), phase.Start_Date__c);
        System.assertEquals(Date.newInstance(2021, 2, 14), phase.End_Date__c);

        milestone = [SELECT Milestone_Date__c FROM Phase__c WHERE Id = :milestone.Id];
        System.assertEquals(Date.newInstance(2021, 4, 14), milestone.Milestone_Date__c);
    }

    @isTest
    public static void test_update_order() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id project1Id = ProjectTestDataFactory.create(accountId);
        Id project2Id = ProjectTestDataFactory.create(accountId);
        Phase__c phase1 = PhaseTestDataFactory.create(project1Id);
        Phase__c phase2 = PhaseTestDataFactory.create(project1Id);
        Phase__c phase3 = PhaseTestDataFactory.create(project1Id);
        phase1.Sort_Order__c = 1;
        phase2.Sort_Order__c = 2;
        phase3.Sort_Order__c = 3;
        insert new List<Phase__c>{ phase1, phase2, phase3 };

        Project__c project1 = new Project__c(Id = project1Id);
        Project__c project2 = new Project__c(Id = project2Id);
        project1.Sort_Order__c = 1;
        project2.Sort_Order__c = 2;
        update new List<Project__c>{ project1, project2 };

        // Act
        GanttChartController.updateOrder(new List<Id>{ project2Id, project1Id });
        GanttChartController.updateOrder(new List<Id>{ phase2.Id, phase3.Id, phase1.Id });

        // Assert
        List<Project__c> projectList = [SELECT Id, Sort_Order__c FROM Project__c ORDER BY Sort_Order__c];
        System.assertEquals(project2Id, projectList[0].Id);
        System.assertEquals(project1Id, projectList[1].Id);
        System.assertEquals(1, projectList[0].Sort_Order__c);
        System.assertEquals(2, projectList[1].Sort_Order__c);

        List<Phase__c> phaseList = [SELECT Id, Sort_Order__c FROM Phase__c ORDER BY Sort_Order__c];
        System.assertEquals(phase2.Id, phaseList[0].Id);
        System.assertEquals(phase3.Id, phaseList[1].Id);
        System.assertEquals(phase1.Id, phaseList[2].Id);
        System.assertEquals(1, phaseList[0].Sort_Order__c);
        System.assertEquals(2, phaseList[1].Sort_Order__c);
        System.assertEquals(3, phaseList[2].Sort_Order__c);
    }
}