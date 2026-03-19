@isTest
public class AuraHandledExceptionFactoryTest {
  @isTest
  public static void createSuccess() {
    // arrange
    String errorMessage;

    // act
    try {
      throw AuraHandledExceptionFactory.create(new CustomException('test'));
    } catch (Exception cause) {
      errorMessage = cause.getMessage();
    }

    // assert
    System.assertNotEquals(
      null,
      errorMessage,
      'Error message should not be null'
    );
  }

  public class CustomException extends Exception {
  }
}