@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class WikiPagePickList extends VisualEditor.DynamicPickList {
  global override VisualEditor.DataRow getDefaultValue() {
    List<Wiki_Page__c> pages = [
      SELECT Name
      FROM Wiki_Page__c
      WITH SECURITY_ENFORCED
      ORDER BY Name ASC
      LIMIT 1
    ];

    if (pages.size() == 0) {
      return new VisualEditor.DataRow('No pages', '');
    }

    Wiki_Page__c page = pages[0];

    return new VisualEditor.DataRow(page.Name, page.Id);
  }

  global override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows pages = new VisualEditor.DynamicPickListRows();

    for (Wiki_Page__c page : [
      SELECT Name
      FROM Wiki_Page__c
      WITH SECURITY_ENFORCED
      ORDER BY Name ASC
    ]) {
      pages.addRow(new VisualEditor.DataRow(page.Name, page.Id));
    }

    if (pages.size() == 0) {
      pages.addRow(new VisualEditor.DataRow('No pages', ''));
    }
    return pages;
  }
}