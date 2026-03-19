@isTest
public class HttpMethodTest {
    @isTest
    public static void test_properties() {
    
        // assert
        System.assertEquals('GET', HttpMethod.GET);
        System.assertEquals('POST', HttpMethod.POST);
        System.assertEquals('PUT', HttpMethod.PUT);
    }
}