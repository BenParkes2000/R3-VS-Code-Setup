public with sharing class WikiSpaceTriggerHandler extends TriggerHandler {
  public override void afterInsert() {
    createWelcomePages((List<Wiki_Space__c>) Trigger.new);
  }

  private void createWelcomePages(List<Wiki_Space__c> spaces) {
    if (
      !Schema.sObjectType.Wiki_Page__c.isCreateable() ||
      !Schema.sObjectType.Wiki_Page__c.fields.Name.isCreateable() ||
      !Schema.sObjectType.Wiki_Page__c.fields.Wiki_Space__c.isCreateable()
    ) {
      throw new DMLException('Insufficient permissions to create Wiki_Page__c');
    }

    List<Wiki_Page__c> pages = new List<Wiki_Page__c>();
    for (Wiki_Space__c space : spaces) {
      Wiki_Page__c welcome = new Wiki_Page__c();
      welcome.Name = 'Welcome';
      welcome.Wiki_Space__c = space.Id;
      pages.add(welcome);
    }
    insert pages;
  }
}