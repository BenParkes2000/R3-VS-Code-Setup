@isTest
public class OpportunityLineItemTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id opportunityId = OpportunityTestDataFactory.create(accountId);
        Id productId = Product2TestDataFactory.create();
        Id priceId = PricebookEntryTestDataFactory.create(productId);

        // Act
        Test.startTest();
        Id itemId = OpportunityLineItemTestDataFactory.create(opportunityId, productId);
        Test.stopTest();

        // Assert
        OpportunityLineItem item = [SELECT OpportunityId, Quantity, Product2Id, TotalPrice FROM OpportunityLineItem WHERE Id = :itemId];
        System.assertEquals(opportunityId, item.OpportunityId);
        System.assertEquals(1, item.Quantity);
        System.assertEquals(productId, item.Product2Id);
        System.assertEquals(1, item.TotalPrice);
    }
}