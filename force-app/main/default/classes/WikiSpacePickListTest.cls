@IsTest
private class WikiSpacePickListTest {
  @IsTest
  static void testGetDefaultValue() {
    // Create test data
    Wiki_Space__c space = new Wiki_Space__c(Name = 'Test Space');
    insert space;

    // Call the method being tested
    WikiSpacePickList pickList = new WikiSpacePickList();
    VisualEditor.DataRow defaultValue = pickList.getDefaultValue();

    // Verify the result
    System.assertEquals(
      'Test Space',
      defaultValue.getLabel(),
      'The label should be the name of the space'
    );
    System.assertEquals(
      space.Id,
      defaultValue.getValue(),
      'The value should be the ID of the space'
    );
  }

  @IsTest
  static void getDefaultValueNoWikiSpace() {
    // Call the method being tested
    WikiSpacePickList pickList = new WikiSpacePickList();
    VisualEditor.DataRow defaultValue = pickList.getDefaultValue();

    // Verify the result
    System.assertEquals(
      'No spaces',
      defaultValue.getLabel(),
      'The label should be "No spaces"'
    );
    System.assertEquals(
      '',
      defaultValue.getValue(),
      'The value should be an empty string'
    );
  }

  @IsTest
  static void testGetValues() {
    // Create test data
    Wiki_Space__c space1 = new Wiki_Space__c(Name = 'Space 1');
    Wiki_Space__c space2 = new Wiki_Space__c(Name = 'Space 2');
    insert new List<Wiki_Space__c>{ space1, space2 };

    // Call the method being tested
    WikiSpacePickList pickList = new WikiSpacePickList();
    VisualEditor.DynamicPickListRows values = pickList.getValues();

    // Verify the result
    System.assertEquals(2, values.size(), 'There should be two spaces');
    System.assertEquals(
      'Space 1',
      values.get(0).getLabel(),
      'The first label should be the name of the first space'
    );
    System.assertEquals(
      space1.Id,
      values.get(0).getValue(),
      'The first value should be the ID of the first space'
    );
    System.assertEquals(
      'Space 2',
      values.get(1).getLabel(),
      'The second label should be the name of the second space'
    );
    System.assertEquals(
      space2.Id,
      values.get(1).getValue(),
      'The second value should be the ID of the second space'
    );
  }

  @IsTest
  static void getValuesNoWikiSpaces() {
    // Call the method being tested
    WikiSpacePickList pickList = new WikiSpacePickList();
    VisualEditor.DynamicPickListRows values = pickList.getValues();

    // Verify the result
    System.assertEquals(1, values.size(), 'There should be one value');
    System.assertEquals(
      'No spaces',
      values.get(0).getLabel(),
      'The label should be "No spaces"'
    );
    System.assertEquals(
      '',
      values.get(0).getValue(),
      'The value should be an empty string'
    );
  }
}