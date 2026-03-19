@isTest
private class StringUtilTest {
  @isTest
  static void testRemoveBlankLinesFromRichText() {
    String input = '<p>Line 1</p><p><br></p><p>Line 2</p>';
    String expected = '<p>Line 1</p><p>Line 2</p>';
    String actual = StringUtil.removeBlankLinesFromRichText(input);

    System.assertEquals(
      expected,
      actual,
      'Expected: ' + expected + ' Actual: ' + actual
    );
  }
}