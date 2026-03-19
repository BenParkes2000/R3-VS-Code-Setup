@RestResource(urlMapping='/SObjectFieldsAndRelationships/*')
global with sharing class GetFieldsAndRelationshipsBySObject {
    
    @HttpGet
    global static String getFieldsAndRelationships() {
        RestRequest req = RestContext.request;
        String sObjectName = req.params.get('sObjectName');
        
        if (String.isBlank(sObjectName)) {
            return 'Please provide an SObject name as a parameter';
        }
        
        try {
            // Get the SObject type from the name
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectName);
            if (sObjType == null) {
                return 'Invalid SObject name provided';
            }
            
            Schema.DescribeSObjectResult describeResult = sObjType.getDescribe();
            
            // Get fields with detailed information
            List<String> fieldDetailsList = new List<String>();
            for(Schema.SObjectField field : describeResult.fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                String fieldDetails = fieldDescribe.getName() + ' {' +
                    'type: ' + fieldDescribe.getType() + ', ' +
                    'length: ' + fieldDescribe.getLength() + ', ' +
                    'required: ' + (!fieldDescribe.isNillable()) + ', ' +
                    'updateable: ' + fieldDescribe.isUpdateable() + ', ' +
                    'createable: ' + fieldDescribe.isCreateable();
                
                // Add picklist values if field is a picklist
                if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST || 
                    fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    List<String> picklistValues = new List<String>();
                    for(Schema.PicklistEntry ple : fieldDescribe.getPicklistValues()) {
                        if(ple.isActive()) {
                            picklistValues.add(ple.getValue());
                        }
                    }
                    fieldDetails += ', picklistValues: [' + String.join(picklistValues, ',') + ']';
                }
                
                fieldDetails += '}';
                fieldDetailsList.add(fieldDetails);
            }
            
            // Get relationships
            List<String> relationshipList = new List<String>();
            for(Schema.ChildRelationship childRel : describeResult.getChildRelationships()) {
                if (childRel.getRelationshipName() != null) {
                    relationshipList.add(childRel.getRelationshipName() + ' {' +
                        'childSObject: ' + childRel.getChildSObject().getDescribe().getName() + ', ' +
                        'field: ' + childRel.getField().getDescribe().getName() + '}');
                }
            }
            
            // Get reference fields (lookup/master-detail)
            List<String> referenceList = new List<String>();
            for(Schema.SObjectField field : describeResult.fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if(fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                    List<String> referenceTo = new List<String>();
                    for(Schema.SObjectType reference : fieldDescribe.getReferenceTo()) {
                        referenceTo.add(reference.getDescribe().getName());
                    }
                    referenceList.add(fieldDescribe.getName() + ' {referenceTo: [' + 
                        String.join(referenceTo, ',') + ']}');
                }
            }
            
            // Combine all lists with section headers
            String result = 'Fields:\n' + String.join(fieldDetailsList, '\n') + '\n\n' +
                          'Child Relationships:\n' + String.join(relationshipList, '\n') + '\n\n' +
                          'Referenced Objects:\n' + String.join(referenceList, '\n');
            
            return result;
            
        } catch(Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}