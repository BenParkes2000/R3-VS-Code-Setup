public with sharing class DragAndDropSorterTransformer {
    private Id Id;
    private String Name;

    public DragAndDropSorterTransformer(SObject obj) {
        this.Id = obj.Id;

        Schema.SObjectType objectType = obj.getSObjectType();

        if (objectType == Project_Feature__c.SObjectType) {
            this.Name = String.valueOf(obj.get('Name'));
        } else if (objectType == Project_Team_Member__c.SObjectType) {
            this.Name = String.valueOf(obj.get('Name__c'));

            String role = String.valueOf(obj.get('Role__c'));

            if (!String.isBlank(role)) {
                this.Name += ' - ' + role;
            }
        } else if (objectType == Salesforce_License__c.SObjectType) {
            this.Name = String.valueOf(obj.get('License__c'));
        } else if (objectType == Work_Item__c.SObjectType) {
            this.Name = String.valueOf(obj.get('Name')) + ' - ' + String.valueOf(obj.get('Subject__c'));
        }
    }

    @AuraEnabled
    public Id getId() {
        return this.Id;
    }

    @AuraEnabled
    public String getName() {
        return this.Name;
    }
}