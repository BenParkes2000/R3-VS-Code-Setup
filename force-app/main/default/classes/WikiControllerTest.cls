@isTest
private class WikiControllerTest {
  @isTest
  static void createSpaceTest() {
    // arrange
    // act
    Test.startTest();
    WikiController.createSpace('Test Space', 'Test Description');
    Test.stopTest();

    // assert
    List<Wiki_Space__c> spaces = [
      SELECT Id, Name
      FROM Wiki_Space__c
      WHERE Name = 'Test Space'
    ];
    System.assertEquals(1, spaces.size(), 'The space should be created');
    System.assertEquals(
      'Test Space',
      spaces[0].Name,
      'The space name should match'
    );
  }

  @isTest
  static void createPageTest() {
    // arrange
    Id spaceId = TestDataFactory.createSpace();

    // act
    Test.startTest();
    WikiController.createPage(spaceId, null, 'Test Page');
    Test.stopTest();

    // assert
    List<Wiki_Page__c> pages = [
      SELECT Id, Name, Parent_Page__c, Wiki_Space__c
      FROM Wiki_Page__c
      WHERE Name = 'Test Page'
    ];
    System.assertEquals(1, pages.size(), 'The page should be created');
    System.assertEquals(
      'Test Page',
      pages[0].Name,
      'The page name should match'
    );
    System.assertEquals(
      spaceId,
      pages[0].Wiki_Space__c,
      'The space should match'
    );
  }

  @isTest
  static void getPagesTest() {
    // act
    Test.startTest();
    List<Wiki_Page__c> pages = WikiController.getPages();
    Test.stopTest();

    // assert
    System.assertNotEquals(null, pages, 'The pages should not be null');
  }

  @isTest
  static void getPagesBySpaceTest() {
    // arrange
    Id spaceId = TestDataFactory.createSpace();

    // act
    Test.startTest();
    List<Wiki_Page__c> pages = WikiController.getPagesBySpace(spaceId);
    Test.stopTest();

    // Verify the returned pages
    System.assertNotEquals(null, pages, 'The pages should not be null');
  }

  @isTest
  static void getSpacesTest() {
    // arrange
    TestDataFactory.createSpace();

    Test.startTest();
    List<LabelValuePair> spaces = WikiController.getSpaces();
    Test.stopTest();

    // Verify the returned spaces
    System.assertNotEquals(null, spaces, 'The spaces should not be null');
  }

  @isTest
  static void getPageWithoutContentTest() {
    // arrange
    Id spaceId = TestDataFactory.createSpace();
    Id pageId = TestDataFactory.createPage(spaceId);

    // act
    Test.startTest();
    Wiki_Page__c page = WikiController.getPageWithoutContent(pageId);
    Test.stopTest();

    // assert
    System.assertEquals(pageId, page.Id, 'The page should be returned');
  }

  @isTest
  static void getHomepageBySpaceIdTest() {
    // arrange
    Id spaceId = TestDataFactory.createSpace();
    TestDataFactory.createPage(spaceId);

    // act
    Test.startTest();
    Wiki_Page__c homepage = WikiController.getHomepageBySpaceId(spaceId);
    Test.stopTest();

    // assert
    System.assertNotEquals(null, homepage, 'The homepage should not be null');
    System.assertEquals(
      'Welcome',
      homepage.Name,
      'The homepage name should match'
    );
    System.assertEquals(
      spaceId,
      homepage.Wiki_Space__c,
      'The space should match'
    );
  }

  @isTest
  static void deletePageTest() {
    // arrange
    Id spaceId = TestDataFactory.createSpace();
    Id pageId = TestDataFactory.createPage(spaceId);

    // act
    Test.startTest();
    Boolean isDeleted = WikiController.deletePage(pageId);
    Test.stopTest();

    // assert
    System.assertEquals(true, isDeleted, 'The page should be deleted');
    List<Wiki_Page__c> pages = [SELECT Id FROM Wiki_Page__c WHERE Id = :pageId];
    System.assertEquals(0, pages.size(), 'The page should be deleted');
  }
}