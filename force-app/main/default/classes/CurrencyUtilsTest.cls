@isTest
public class CurrencyUtilsTest {
    @isTest
    public static void test_get_symbol() {
        System.assertEquals('£', CurrencyUtils.getSymbol('GBP'));
        System.assertEquals('€', CurrencyUtils.getSymbol('EUR'));
        System.assertEquals('$', CurrencyUtils.getSymbol('USD'));
        System.assertEquals('£', CurrencyUtils.getSymbol('FOO'));
    }
}