@isTest
private class WikiPagePickListTest {
  @isTest
  static void getDefaultValueNoPages() {
    // Test when there are no pages
    WikiPagePickList pickList = new WikiPagePickList();
    Test.startTest();
    VisualEditor.DataRow defaultValue = pickList.getDefaultValue();
    Test.stopTest();

    // Verify the default value is 'No pages'
    System.assertEquals(
      'No pages',
      defaultValue.getLabel(),
      'The label should be "No pages"'
    );
    System.assertEquals(
      '',
      defaultValue.getValue(),
      'The value should be empty'
    );
  }

  @isTest
  static void getDefaultValueWithPages() {
    // Test when there are pages
    Wiki_Space__c space = new Wiki_Space__c(Name = 'Space');
    insert space;
    List<Wiki_Page__c> pages = new List<Wiki_Page__c>();
    pages.add(new Wiki_Page__c(Name = 'Page 1', Wiki_Space__c = space.Id));
    pages.add(new Wiki_Page__c(Name = 'Page 2', Wiki_Space__c = space.Id));
    insert pages;

    WikiPagePickList pickList = new WikiPagePickList();
    Test.startTest();
    VisualEditor.DataRow defaultValue = pickList.getDefaultValue();
    Test.stopTest();

    // Verify the default value is the first page
    System.assertEquals(
      'Page 1',
      defaultValue.getLabel(),
      'The label should be "Page 1"'
    );
    System.assertEquals(
      pages[0].Id,
      defaultValue.getValue(),
      'The value should be the first page'
    );
  }

  @isTest
  static void getValuesNoPages() {
    // Test when there are no pages
    WikiPagePickList pickList = new WikiPagePickList();
    Test.startTest();
    VisualEditor.DynamicPickListRows values = pickList.getValues();
    Test.stopTest();

    // Verify the values contain 'No pages'
    System.assertEquals(1, values.size(), 'There should be one value');
    System.assertEquals(
      'No pages',
      values.get(0).getLabel(),
      'The label should be "No pages"'
    );
    System.assertEquals(
      '',
      values.get(0).getValue(),
      'The value should be empty'
    );
  }

  @isTest
  static void getValuesWithPages() {
    // Test when there are pages
    Wiki_Space__c space = new Wiki_Space__c(Name = 'Space');
    insert space;
    List<Wiki_Page__c> pages = new List<Wiki_Page__c>();
    pages.add(new Wiki_Page__c(Name = 'Page 1', Wiki_Space__c = space.Id));
    pages.add(new Wiki_Page__c(Name = 'Page 2', Wiki_Space__c = space.Id));
    insert pages;

    WikiPagePickList pickList = new WikiPagePickList();
    Test.startTest();
    VisualEditor.DynamicPickListRows values = pickList.getValues();
    Test.stopTest();

    // Verify the values contain all the pages
    System.assertEquals(3, values.size(), 'There should be three values');
    System.assertEquals(
      'Page 1',
      values.get(0).getLabel(),
      'The label should be "Page 1"'
    );
    System.assertEquals(
      pages[0].Id,
      values.get(0).getValue(),
      'The value should be the first page'
    );
    System.assertEquals(
      'Page 2',
      values.get(1).getLabel(),
      'The label should be "Page 2"'
    );
    System.assertEquals(
      pages[1].Id,
      values.get(1).getValue(),
      'The value should be the second page'
    );
  }
}