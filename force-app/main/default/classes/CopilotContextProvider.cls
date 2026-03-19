public class CopilotContextProvider {

    private static Map<String, Type> registeredContexts = new Map<String, Type>();

    static {
        //registeredContexts.put('Project__c', CopilotProjectContext.class);
        //registeredContexts.put('Project_Feature__c', CopilotProjectFeatureContext.class);
        //registeredContexts.put('Phase__c', CopilotPhaseContext.class);
        //registeredContexts.put('Work_Item__c', CopilotWorkItemContext.class);
        //registeredContexts.put('Lead', CopilotLeadContext.class);
        //registeredContexts.put('Contact', CopilotContactContext.class);
        //registeredContexts.put('Account', CopilotAccountContext.class);
        registeredContexts.put('EmailMessage', CopilotEmailMessageContext.class);
    }

    public static CopilotContext getCopilotContext(String objectApiName, Id recordId) {

        Type contextType = registeredContexts.get(objectApiName);
        CopilotContext context;

        if (contextType == null) {
            context = new CopilotGenericRecordContext();
        } else {
            context = (CopilotContext) contextType.newInstance();
        }

        context.setRecordId(recordId);
        context.buildContext();
        return context;
    }

    public class CopilotContextProviderException extends Exception {}
}