public with sharing class CopilotWorkItemContext extends CopilotContext {

    Work_Item__c item;

    public override void buildContext() {
        item = WorkItemDataAccess.getWorkItem(recordId);
    }

    public override String getContext() {

        StringBuilder builder = new StringBuilder();

        builder.appendLine('CONTEXT')
            .appendLine('This is the Work Item Subject: ' + item.Subject__c)
            .appendLine('This is the Work Item Description: ' + item.Description__c)
            .appendLine('This Work Item has a link to this related documentation' + item.Documentation_URL__c)
            .appendLine('This is the Work Item Implementation details: ' + item.Implementation__c);

        return builder.toString();
    }
}