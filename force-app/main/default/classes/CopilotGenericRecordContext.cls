public with sharing class CopilotGenericRecordContext extends CopilotContext {

    String context = 'CopilotGenericRecordContext Error!';

    public override void buildContext() {

        // Get the object's API name based on the record ID
        String objectApiName = recordId.getSObjectType().getDescribe().getName();

        // Get the label of the object
        String objectLabel = Schema.getGlobalDescribe().get(objectApiName).getDescribe().getLabel();

        // Retrieve all the fields on the object
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>(fieldMap.keySet());

        // Construct the dynamic query
        String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + objectApiName + ' WHERE Id = \'' + recordId + '\' LIMIT 1';

        // Execute the dynamic query and fetch the record
        SObject record = Database.query(query);

        if (record == null) {
            return;
        }

        Set<String> excludedFields = new Set<String>{'id', 'isdeleted', 'systemmodstamp', 'currencyisocode', 'lastvieweddate', 'lastreferenceddate'};
        StringBuilder builder = new StringBuilder();
        builder.appendLine(objectLabel + ' record context:');

        for (String fieldName : fieldMap.keySet()) {

            System.debug('fieldName: ' + fieldName); 

            if (excludedFields.contains(fieldName)) {
                continue;
            }

            if (record.get(fieldName) == null) {
                continue;
            }

            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            String label = fieldDescribe.getLabel();

            System.debug('label: ' + label);
        
            // Check if the field is a reference field
            List<Schema.SObjectType> referencedObjects = fieldDescribe.getReferenceTo();
            if (referencedObjects != null && !referencedObjects.isEmpty() && record.get(fieldName) != null) {
                object value = record.get(fieldName);
                Id relatedId = String.valueOf(value);
                System.debug('Field ' + fieldName + ' is a reference field with ID: ' + relatedId);
                builder.appendLine(label + ': ' + getRecordNameById(relatedId));
            } else {
                builder.appendLine(label + ': ' + String.valueOf(record.get(fieldName)));
            }
        }

        context = builder.toString();
    }

    public static String getRecordNameById(Id recordId) {

        // Get the record's SObject type based on the ID value
        SObjectType objectApiName = recordId.getSObjectType();

        // Construct the dynamic SOQL query
        String query = 'SELECT Name FROM ' + objectApiName + ' WHERE Id = \'' + recordId + '\' LIMIT 1';

        // Execute the dynamic SOQL query and fetch the record
        SObject record = Database.query(query);

        // Retrieve the record's name field value
        String recordName = (record != null) ? (String) record.get('Name') : '';

        return recordName;
    }

    public override String getContext() {
        return this.context;
    }
}