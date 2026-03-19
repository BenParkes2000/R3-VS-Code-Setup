@IsTest
private class ChangeSpaceModelControllerTest {
  @IsTest
  static void getSpacesNoWikiSpaces() {
    Test.startTest();
    List<Wiki_Space__c> spaces = ChangeSpaceModelController.getSpaces();
    Test.stopTest();

    // Add your assertions here
    System.assertEquals(1, spaces.size(), 'There should be one space');
  }

  @IsTest
  static void getSpacesOneSpace() {
    // arrange
    TestDataFactory.createSpace();

    // act
    Test.startTest();
    List<Wiki_Space__c> spaces = ChangeSpaceModelController.getSpaces();
    Test.stopTest();

    // assert
    System.assertEquals(1, spaces.size(), 'There should be one space');
  }
}