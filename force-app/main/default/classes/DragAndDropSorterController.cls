public with sharing class DragAndDropSorterController {
  @AuraEnabled
  public static List<DragAndDropSorterTransformer> getRecords(
    Id recordId,
    String type
  ) {
    String query;

    switch on type {
      when 'Project Feature' {
        query = 'SELECT Id, Name FROM Project_Feature__c WHERE Project__c = :recordId ORDER BY Sort_Order__c';
      }
      when 'Project Team Member' {
        query = 'SELECT Id, Name__c, Role__c FROM Project_Team_Member__c WHERE Project__c = :recordId ORDER BY Sort_Order__c';
      }
      when 'Salesforce License' {
        query = 'SELECT Id, License__c FROM Salesforce_License__c WHERE Project__c = :recordId ORDER BY Sort_Order__c';
      }
      when 'Work Item' {
        query = 'SELECT Id, Name, Subject__c FROM Work_Item__c WHERE Feature__c = :recordId ORDER BY Sort_Order__c';
      }
      when else {
        throw new CustomException('Unsupported object type');
      }
    }

    List<SObject> sobjectList = new List<SObject>(Database.query(query));
    List<DragAndDropSorterTransformer> objList = new List<DragAndDropSorterTransformer>();

    for (SObject obj : sobjectList) {
      objList.add(new DragAndDropSorterTransformer(obj));
    }

    return objList;
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled
  public static void sort(List<Id> ids) {
    List<SObject> sObjectsToUpdate = new List<SObject>();
    Integer sortOrder = 1;

    for (Id id : ids) {
      SObject obj = id.getSobjectType().newSObject(id);
      obj.put('Sort_Order__c', sortOrder);
      sObjectsToUpdate.add(obj);

      sortOrder++;
    }

    update sObjectsToUpdate;
  }

  public class CustomException extends Exception {
  }
}