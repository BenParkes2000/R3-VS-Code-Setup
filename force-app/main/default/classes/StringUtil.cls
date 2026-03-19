public with sharing class StringUtil {
  public static String removeBlankLinesFromRichText(String input) {
    return input.replace('<p><br></p>', '');
  }
}