@isTest
public class PhaseTest {
    @isTest
    public static void test_duration_formula() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);
        insert new List<Phase__c>{
            PhaseTestDataFactory.createWithDates(projectId, null, null), // No dates
            PhaseTestDataFactory.createWithDates(projectId, Date.newInstance(2021, 2, 1), null), // No end date
            PhaseTestDataFactory.createWithDates(projectId, null, Date.newInstance(2021, 2, 1)), // No start date
            PhaseTestDataFactory.createWithDates(projectId, Date.newInstance(2021, 2, 1), Date.newInstance(2021, 2, 5)), // Mon-Fri (5 days)
            PhaseTestDataFactory.createWithDates(projectId, Date.newInstance(2021, 2, 2), Date.newInstance(2021, 2, 8)), // Tue-Mon (5 days)
            PhaseTestDataFactory.createWithDates(projectId, Date.newInstance(2021, 2, 3), Date.newInstance(2021, 2, 7)), // Wed-Sun (3 days)
            PhaseTestDataFactory.createWithDates(projectId, Date.newInstance(2021, 2, 6), Date.newInstance(2021, 2, 12)), // Sat-Fri (5 days)
            PhaseTestDataFactory.createWithDates(projectId, Date.newInstance(2021, 2, 18), Date.newInstance(2021, 3, 8)) // Thu-Mon (13 days, 3 weekends)
        };

        // Assert
        List<Phase__c> phaseList = [SELECT Id, Duration__c FROM Phase__c];
        System.assertEquals(null, phaseList[0].Duration__c);
        System.assertEquals(null, phaseList[1].Duration__c);
        System.assertEquals(null, phaseList[2].Duration__c);
        System.assertEquals(40, phaseList[3].Duration__c);
        System.assertEquals(40, phaseList[4].Duration__c);
        System.assertEquals(24, phaseList[5].Duration__c);
        System.assertEquals(40, phaseList[6].Duration__c);
        System.assertEquals(104, phaseList[7].Duration__c);
    }
}