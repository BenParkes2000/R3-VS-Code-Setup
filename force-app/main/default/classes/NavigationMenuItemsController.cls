/**
 * A basic controller for fetching NavigationMenuItems.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class NavigationMenuItemsController {
  // public NavigationMenuItemsController() {
  // }

  /**
   * Perform two SOQL queries to determine all the children NavigationMenuItems
   * belonging to the provided menuName and publishedState. This example uses the
   * NavigationLinkSet.MasterLabel for the menuName. One could also use the
   * NavigationLinkSet.Id to ensure referential integrity if the MasterLabel changes.
   *
   * NavigationLinkSet contains both Draft and Live versions of the NavigationMenuItems.
   * Use the publishedState enumeration to filter between them.
   *
   * Cacheable = true allows this function to be wired.
   */
  @AuraEnabled(cacheable=true)
  public static List<NavigationMenuItem> getNavigationMenuItems(
    String menuName,
    String publishedState
  ) {
    if (String.isEmpty(menuName)) {
      return new List<NavigationMenuItem>();
    }

    String networkId = Network.getNetworkId();

    // find the link set belonging to the navigation menuName and active networkId
    if (!Schema.sObjectType.NavigationLinkSet.isAccessible()) {
      throw new AuraHandledException('NavigationLinkSet is not accessible');
    }
    List<NavigationLinkSet> linkSets = [
      SELECT Id
      FROM NavigationLinkSet
      WHERE DeveloperName = :menuName AND NetworkId = :networkId
    ];

    Id linkSetId = linkSets.get(0).Id;

    // collect all the menu items belonging to the link set
    // published state is either Draft or Live
    if (!Schema.sObjectType.NavigationMenuItem.isAccessible()) {
      throw new AuraHandledException('NavigationMenuItem is not accessible');
    }
    return [
      SELECT
        Label,
        Target,
        Type,
        DefaultListViewId,
        AccessRestriction,
        ParentId,
        Position,
        Status,
        TargetPrefs
      FROM NavigationMenuItem
      WHERE NavigationLinkSetId = :linkSetId AND Status = :publishedState
      ORDER BY Position
    ];
  }
}