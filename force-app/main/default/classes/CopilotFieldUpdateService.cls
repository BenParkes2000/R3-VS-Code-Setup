public with sharing class CopilotFieldUpdateService {

    public static void updateField(String objectApiName, Id recordId, String fieldName, String value) {
        // Get the SObjectType based on the objectApiName
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
        
        if (sObjectType == null) {
            throw new CopilotFieldUpdateServiceException('Invalid objectApiName: ' + objectApiName);
        }

        // Create a new instance of the SObject and set the ID
        SObject record = sObjectType.newSObject(recordId);

        // Check if the field exists on the object
        if (!sObjectType.getDescribe().fields.getMap().containsKey(fieldName)) {
            throw new CopilotFieldUpdateServiceException('Invalid fieldName: ' + fieldName);
        }

        // Update the field with the new value
        record.put(fieldName, value);

        // Update the record
        update record;
    }

    public class CopilotFieldUpdateServiceException extends Exception {}
}