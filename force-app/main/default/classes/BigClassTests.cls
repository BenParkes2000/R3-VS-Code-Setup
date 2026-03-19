@isTest
public class BigClassTests {

    @isTest
    public static void getValue_Success(){
        
        // arrange
        String expected = 'checkmate';
        
        // act
        String actual = BigClass.getValue(expected);
        
        // assert
        System.assertEquals(expected, actual);
    }
}