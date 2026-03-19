@isTest
public class RaidLogTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Act
        RAID_Log__c log = RaidLogTestDataFactory.create(projectId, RaidLogUtils.getRiskRecordTypeId, RaidLogStatusNames.Open, RaidLogRatingNames.Low);

        // Assert
        System.assertEquals(projectId, log.Project__c);
        System.assertEquals(RaidLogUtils.getRiskRecordTypeId, log.RecordTypeId);
        System.assertEquals(RaidLogStatusNames.Open, log.Status__c);
        System.assertEquals(RaidLogRatingNames.Low, log.Rating__c);
    }
}