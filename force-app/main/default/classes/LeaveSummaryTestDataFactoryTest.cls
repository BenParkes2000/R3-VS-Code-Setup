@isTest
public class LeaveSummaryTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        User user = UserTestDataFactory.create('test@r3.digtial', 'Test', 'User');

        // Act
        Id summaryId = LeaveSummaryTestDataFactory.create(user.Id, '2020', Date.newInstance(2020, 1, 1), Date.newInstance(2020, 12, 31));

        // Assert
        Leave_Summary__c summary = [SELECT OwnerId, Year__c, Start_Date__c, End_Date__c FROM Leave_Summary__c WHERE Id = :summaryId];
        System.assertEquals(user.Id, summary.OwnerId);
        System.assertEquals('2020', summary.Year__c);
        System.assertEquals(Date.newInstance(2020, 1, 1), summary.Start_Date__c);
        System.assertEquals(Date.newInstance(2020, 12, 31), summary.End_Date__c);
    }
}