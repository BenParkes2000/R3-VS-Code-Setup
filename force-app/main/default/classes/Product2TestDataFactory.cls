@isTest
public class Product2TestDataFactory {
    public static String NONE = 'None';
    public static String THIRD_PARTY_SERVICE = 'Third-Party Service';

    public static Id create() {
        return create(NONE);
    }

    public static Id createThirdPartyServiceProduct() {
        return create(THIRD_PARTY_SERVICE);
    }

    public static Id create(String family) {
        Product2 product = new Product2();
        product.Name = 'name';
        product.ProductCode = 'P100';
        product.Description = 'description';
        product.IsActive = true;
        product.Family = family;
        insert product;
        return product.Id;
    }
}