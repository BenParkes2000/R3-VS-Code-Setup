// 'global' modifier is required to override inherited global methods from VisualEditor.DynamicPickList
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class NavigationLinkSetPickList extends VisualEditor.DynamicPickList {
  private static List<NavigationLinkSet> cachedNavigationLinkSetList;

  global override VisualEditor.DataRow getDefaultValue() {
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
      'Default Navigation',
      'Default Navigation'
    );
    return defaultValue;
  }

  global override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
    if (Schema.sObjectType.NavigationLinkSet.isAccessible()) {
      if (cachedNavigationLinkSetList == null) {
        cachedNavigationLinkSetList = [
          SELECT MasterLabel, DeveloperName
          FROM NavigationLinkSet
        ];
      }

      for (NavigationLinkSet navigationLinkSet : cachedNavigationLinkSetList) {
        VisualEditor.DataRow value = new VisualEditor.DataRow(
          navigationLinkSet.MasterLabel,
          navigationLinkSet.DeveloperName
        );
        picklistValues.addRow(value);
      }
      return picklistValues;
    } else {
      return null;
    }
  }
}