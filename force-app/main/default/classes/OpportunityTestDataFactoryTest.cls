@isTest
public class OpportunityTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();

        // Act
        Id opportunityId = OpportunityTestDataFactory.create(accountId);

        // Assert
        Opportunity opportunity = [SELECT Name, AccountId, CloseDate, StageName, Pricebook2Id FROM Opportunity WHERE Id = :opportunityId];
        System.assertEquals('test opp', opportunity.Name);
        System.assertEquals(accountId, opportunity.AccountId);
        System.assertEquals(Date.today(), opportunity.CloseDate);
        System.assertEquals('Prospecting', opportunity.StageName);
        System.assertEquals(System.Test.getStandardPricebookId(), opportunity.Pricebook2Id);
    }
}