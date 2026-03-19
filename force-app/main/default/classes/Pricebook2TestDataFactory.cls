@isTest
public class Pricebook2TestDataFactory {
    public static Id create() {
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2020', Description = 'Price Book 2020 Products', IsActive = true);
        insert pb;
        return pb.Id;
    }
}