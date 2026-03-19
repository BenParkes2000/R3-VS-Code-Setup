public with sharing class CopilotController {
    
    @AuraEnabled(cacheable=true)
    public static String getContext(String objectApiName, Id recordId) {
        try {
            CopilotContext context = CopilotContextProvider.getCopilotContext(objectApiName, recordId);
            return context.getContext();
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Copilot_Prompt__c> getPrompts(String objectApiName) {
        try {
            List<Copilot_Prompt__c> prompts = [SELECT Id, Prompt__c FROM Copilot_Prompt__c WHERE Object__c = :objectApiName];
            if (prompts.size() == 0){
                return new List<Copilot_Prompt__c>();
            }
            return prompts;
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled
    public static void handleAction(String objectApiName, Id recordId, String fieldName, String value) {
        try {
            CopilotFieldUpdateService.updateField(objectApiName, recordId, fieldName, value);
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }     
    }
}