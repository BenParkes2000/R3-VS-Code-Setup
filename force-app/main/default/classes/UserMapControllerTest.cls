@isTest
private class UserMapControllerTest {
  @isTest
  static void testGetUsers() {
    // Create a test internal user with address information

    User user = UserTestDataFactory.create('test@r3.digital', 'Test', 'User');

    Test.startTest();
    List<User> users = UserMapController.getUsers();
    Test.stopTest();

    Boolean expected = users.size() >= 1;
    System.Assert.isTrue(
      expected,
      'There should be at least 1 active internal user with address information'
    );
  }
}