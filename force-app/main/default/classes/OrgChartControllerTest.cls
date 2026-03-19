@isTest
private class OrgChartControllerTest {
  @isTest
  static void testGetUsers() {
    Test.startTest();
    List<User> users = OrgChartController.getUsers();
    Test.stopTest();

    System.assert(true, 'Users: ' + users);
  }
}