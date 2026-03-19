public with sharing class ProjectSummaryController {
  @AuraEnabled(cacheable=true)
  public static List<Project_Feature__c> getRows(Id projectId) {
    try {
      return [
        SELECT
          Id,
          Project__c,
          Name,
          CurrencyIsoCode,
          Description__c,
          Est_Cost__c,
          (
            SELECT
              Id,
              Name,
              Feature__c,
              Subject__c,
              Description__c,
              Est_Time__c,
              Is_Optional__c
            FROM Work_Items__r
            ORDER BY Sort_Order__c
          )
        FROM Project_Feature__c
        WHERE Project__c = :projectId
        WITH SECURITY_ENFORCED
        ORDER BY Sort_Order__c
      ];
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }

  @AuraEnabled
  public static void save(Id id, String field, String value) {
    try {
      Schema.SObjectType sobjectType = id.getSobjectType();
      Schema.DescribeSObjectResult objectDescribe = sobjectType.getDescribe(
        SObjectDescribeOptions.DEFERRED
      );
      Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap()
        .get(field)
        .getDescribe();
      Schema.DisplayType dataType = fieldDescribe.getType();

      if (!objectDescribe.isUpdateable()) {
        throw new AuraHandledException('Object is not updateable');
      }

      if (!fieldDescribe.isUpdateable()) {
        throw new AuraHandledException('Field is not updateable');
      }

      SObject record = sobjectType.newSObject(id);

      if (dataType == Schema.DisplayType.DOUBLE) {
        record.put(field, Decimal.valueOf(value));
      } else if (dataType == Schema.DisplayType.BOOLEAN) {
        record.put(field, value == 'true');
      } else {
        record.put(field, value);
      }

      update record; // NOPMD - Suppress the false positive ApexCRUDViolation
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }
}