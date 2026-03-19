@IsTest
private class WikiSpaceControllerTest {
  @IsTest
  static void testGetHomepageBySpaceIdNoPages() {
    // Create test data
    Wiki_Space__c space = new Wiki_Space__c(Name = 'Test Space');
    insert space;

    // Call the method being tested
    Wiki_Page__c homepage = WikiSpaceController.getHomepageBySpaceId(space.Id);

    // Verify the result
    System.assertEquals(
      'Welcome',
      homepage.Name,
      'The default homepage should be named "Welcome"'
    );
    System.assertEquals(
      space.Id,
      homepage.Wiki_Space__c,
      'The homepage should belong to the space'
    );
  }

  @IsTest
  static void testGetHomepageBySpaceIdWithPages() {
    // Create test data
    Wiki_Space__c space = new Wiki_Space__c(Name = 'Test Space');
    insert space;

    Wiki_Page__c page1 = new Wiki_Page__c(
      Name = 'Page 1',
      Wiki_Space__c = space.Id,
      Parent_page__c = null,
      Sort_Order__c = 1
    );
    Wiki_Page__c page2 = new Wiki_Page__c(
      Name = 'Page 2',
      Wiki_Space__c = space.Id,
      Parent_page__c = null,
      Sort_Order__c = 2
    );
    insert new List<Wiki_Page__c>{ page1, page2 };

    // Call the method being tested
    Wiki_Page__c homepage = WikiSpaceController.getHomepageBySpaceId(space.Id);

    // Verify the result
    System.assertEquals(
      'Welcome',
      homepage.Name,
      'The first page should be the homepage'
    );
    System.assertEquals(
      space.Id,
      homepage.Wiki_Space__c,
      'The homepage should belong to the space'
    );
  }
}