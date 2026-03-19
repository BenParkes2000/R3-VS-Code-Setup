@isTest
public class Pricebook2TestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Act
        Id pricebookId = Pricebook2TestDataFactory.create();

        // Assert
        Pricebook2 pricebook = [SELECT Name, Description, IsActive FROM Pricebook2 WHERE Id = :pricebookId];
        System.assertEquals('Standard Price Book 2020', pricebook.Name);
        System.assertEquals('Price Book 2020 Products', pricebook.Description);
        System.assertEquals(true, pricebook.IsActive);
    }
}