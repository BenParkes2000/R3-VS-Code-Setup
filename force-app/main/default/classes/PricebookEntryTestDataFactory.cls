@isTest
public class PricebookEntryTestDataFactory {
    public static Id create(Id productId) {
        PricebookEntry price = new PricebookEntry();
        price.IsActive = true;
        price.Product2Id = productId;
        price.UnitPrice = 0;
        price.Pricebook2Id = Test.getStandardPricebookId();
        insert price;
        return price.Id;
    }
}