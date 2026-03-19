public class CurrencyUtils {
    public static String getSymbol(String isoCode) {
        switch on isoCode {
            when 'EUR' {
                return CurrencySymbolNames.EUR;
            }
            when 'USD' {
                return CurrencySymbolNames.USD;
            }
            when else {
                return CurrencySymbolNames.GBP;
            }
        }
    }
}