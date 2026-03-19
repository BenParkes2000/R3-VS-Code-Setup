@isTest
public class PhaseTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Act
        Phase__c phase = PhaseTestDataFactory.create(projectId);
        insert phase;

        // Assert
        System.assertEquals('Phase X', phase.Name);
        System.assertEquals(projectId, phase.Project__c);
        System.assertEquals(Date.today(), phase.Start_Date__c);
        System.assertEquals((Date.today() + 28), phase.End_Date__c);
    }

    @isTest
    public static void test_create_with_name() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Act
        Phase__c phase = PhaseTestDataFactory.create(projectId, 'Phase 1');
        insert phase;

        // Assert
        System.assertEquals('Phase 1', phase.Name);
    }

    @isTest
    public static void test_create_with_dates() {
        // Arrange
        final Date START_DATE = Date.newInstance(2020, 1, 1);
        final Date END_DATE = Date.newInstance(2020, 2, 28);

        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Act
        Phase__c phase = PhaseTestDataFactory.createWithDates(projectId, START_DATE, END_DATE);
        insert phase;

        // Assert
        System.assertEquals(START_DATE, phase.Start_Date__c);
        System.assertEquals(END_DATE, phase.End_Date__c);
    }

    @isTest
    public static void test_create_milestone() {
        // Arrange
        final Date MILESTONE_DATE = Date.newInstance(2020, 1, 1);

        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Act
        Phase__c phase = PhaseTestDataFactory.createMilestone(projectId, MILESTONE_DATE);
        insert phase;

        // Assert
        System.assertEquals('Milestone X', phase.Name);
        System.assertEquals(MILESTONE_DATE, phase.Milestone_Date__c);
    }
}