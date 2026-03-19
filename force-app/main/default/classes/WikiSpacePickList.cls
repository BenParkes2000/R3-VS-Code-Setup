@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class WikiSpacePickList extends VisualEditor.DynamicPickList {
  global override VisualEditor.DataRow getDefaultValue() {
    List<Wiki_Space__c> spaces = [
      SELECT Name
      FROM Wiki_Space__c
      WITH SECURITY_ENFORCED
      ORDER BY Name ASC
      LIMIT 1
    ];

    if (spaces.size() == 0) {
      return getNoSpaceRow();
    }

    Wiki_Space__c space = spaces[0];

    return new VisualEditor.DataRow(space.Name, String.valueOf(space.Id));
  }

  global override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows spaces = new VisualEditor.DynamicPickListRows();

    for (Wiki_Space__c space : [
      SELECT Name
      FROM Wiki_Space__c
      WITH SECURITY_ENFORCED
      ORDER BY Name ASC
    ]) {
      spaces.addRow(
        new VisualEditor.DataRow(space.Name, String.valueOf(space.Id))
      );
    }

    if (spaces.size() == 0) {
      spaces.addRow(getNoSpaceRow());
    }

    return spaces;
  }

  global boolean isValid(String attr) {
    return true;
  }

  private VisualEditor.DataRow getNoSpaceRow() {
    return new VisualEditor.DataRow('No spaces', String.valueOf(''));
  }
}