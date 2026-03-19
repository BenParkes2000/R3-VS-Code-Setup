@IsTest
public with sharing class MicrobatchSelfRegControllerTest {
  @IsTest
  public static void testMicrobatchSelfRegController() {
    System.runAs(TestUtil.getSysAdminUser()) {
      MicrobatchSelfRegController controller = new MicrobatchSelfRegController();
      controller.firstName = 'FirstName';
      controller.lastName = 'LastName';
      controller.email = 'test@force.com';
      controller.communityNickname = 'test';

      // registerUser will always return null when the page isn't accessed as a guest user
      System.assert(
        controller.registerUser() == null,
        'registerUser should return null'
      );
    }
  }
}