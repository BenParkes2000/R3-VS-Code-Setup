@isTest
// This is a test data factory class
public class TestDataFactory {
  public static Id createSpace() {
    Wiki_Space__c space = new Wiki_Space__c();
    space.Name = 'Test Name';
    space.Description__c = 'Test Description';
    insert space;
    return space.Id;
  }

  public static Id createPage(Id spaceId) {
    Wiki_Page__c wikiPage = new Wiki_Page__c();
    wikiPage.Name = 'Test Page';
    wikiPage.Wiki_Space__c = spaceId;
    insert wikiPage;
    return wikiPage.Id;
  }
}