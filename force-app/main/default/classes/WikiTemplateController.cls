public without sharing class WikiTemplateController {
  @AuraEnabled(cacheable=true)
  public static List<Wiki_Page_Template__c> getTemplates() {
    try {
      List<Wiki_Page_Template__c> templates = [
        SELECT Id, Name, Folder__c
        FROM Wiki_Page_Template__c
        WHERE Status__c = 'Active'
        WITH SECURITY_ENFORCED
      ];

      if (templates.isEmpty()) {
        return null;
      }

      return templates;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }

  @AuraEnabled
  public static Boolean useTemplate(Id templateId, Id pageId) {
    try {
      String content = WikiEditorPageController.getPage(templateId);
      WikiEditorPageController.updatePage(pageId, content);
      return true;
    } catch (Exception cause) {
      throw AuraHandledExceptionFactory.create(cause);
    }
  }
}