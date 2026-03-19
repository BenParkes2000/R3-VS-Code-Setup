@isTest
public class LeaveRequestTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        User user = UserTestDataFactory.create('test@r3.digtial', 'Test', 'User');
        Id summaryId = LeaveSummaryTestDataFactory.create(user.Id, '2020', Date.newInstance(2020, 1, 1), Date.newInstance(2020, 12, 31));

        // Act
        Id requestId = LeaveRequestTestDataFactory.create(summaryId, Date.newInstance(2020, 3, 1), 5, 'Submitted');

        // Assert
        Leave_Request__c request = [SELECT Leave_Summary__c, Start_Date__c, Days__c, Status__c, Leave_Type__c FROM Leave_Request__c WHERE Id = :requestId];
        System.assertEquals(summaryId, request.Leave_Summary__c);
        System.assertEquals(Date.newInstance(2020, 3, 1), request.Start_Date__c);
        System.assertEquals(5, request.Days__c);
        System.assertEquals('Submitted', request.Status__c);
        System.assertEquals('Annual Leave', request.Leave_Type__c);
    }
}