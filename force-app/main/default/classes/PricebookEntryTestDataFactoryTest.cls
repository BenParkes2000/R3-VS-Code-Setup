@isTest
public class PricebookEntryTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        Id productId = Product2TestDataFactory.create();

        // Act
        Id priceId = PricebookEntryTestDataFactory.create(productId);

        // Assert
        PricebookEntry price = [SELECT IsActive, Product2Id, UnitPrice, Pricebook2Id FROM PricebookEntry WHERE Id = :priceId];
        System.assertEquals(true, price.IsActive);
        System.assertEquals(productId, price.Product2Id);
        System.assertEquals(0, price.UnitPrice);
        System.assertEquals(Test.getStandardPricebookId(), price.Pricebook2Id);
    }
}