@isTest
public class Product2TestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Act
        Id productId = Product2TestDataFactory.create();

        // Assert
        Product2 product = [SELECT Name, ProductCode, Description, IsActive, Family FROM Product2 WHERE Id = :productId];
        System.assertEquals('name', product.Name);
        System.assertEquals('P100', product.ProductCode);
        System.assertEquals('description', product.Description);
        System.assertEquals(true, product.IsActive);
        System.assertEquals(Product2TestDataFactory.NONE, product.Family);
    }

    @isTest
    public static void test_create_third_party_service_product() {
        // Act
        Id productId = Product2TestDataFactory.createThirdPartyServiceProduct();

        // Assert
        Product2 product = [SELECT Family FROM Product2 WHERE Id = :productId];
        System.assertEquals(Product2TestDataFactory.THIRD_PARTY_SERVICE, product.Family);
    }

    @isTest
    public static void test_create_with_family() {
        // Act
        Id productId = Product2TestDataFactory.create('Other Family');

        // Assert
        Product2 product = [SELECT Family FROM Product2 WHERE Id = :productId];
        System.assertEquals('Other Family', product.Family);
    }
}