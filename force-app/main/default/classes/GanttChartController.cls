public with sharing class GanttChartController {
  @AuraEnabled
  public static String getEntityType(Id recordId) {
    return recordId.getSobjectType().getDescribe().getName();
  }

  @AuraEnabled
  public static List<GanttChartTaskTransformer> getTasks(Id recordId) {
    String entityType = getEntityType(recordId);

    switch on entityType {
      when 'Account' {
        List<String> projectStatuses = new List<String>{
          ProjectStatusNames.Estimate,
          ProjectStatusNames.KickOff,
          ProjectStatusNames.InProgress,
          ProjectStatusNames.Uat,
          ProjectStatusNames.HyperCare,
          ProjectStatusNames.Support
        };

        List<SObject> projectList = new List<SObject>(
          Database.query(
            'SELECT Id, Name, Start_Date__c, End_Date__c, Duration__c ' +
              'FROM Project__c ' +
              'WHERE Account__c = :recordId ' +
              'AND Status__c IN :projectStatuses ' +
              'AND Start_Date__c != NULL ' +
              'AND End_Date__c != NULL ' +
              'ORDER BY Sort_Order__c ASC'
          )
        );

        return appendProjectWorkItemStats(projectList);
      }
      when 'Project__c' {
        List<SObject> phaseList = new List<SObject>(
          Database.query(
            'SELECT Id, Name, Start_Date__c, End_Date__c, Duration__c, Milestone_Date__c, ' +
              '(SELECT Id, Name, Subject__c, Est_Time__c, Scheduled_Start__c, Scheduled_End__c FROM Work_Items__r ORDER BY Sort_Order__c ASC) ' +
              'FROM Phase__c ' +
              'WHERE Project__c = :recordId ' +
              'AND ((Start_Date__c != NULL AND End_Date__c != NULL) OR Milestone_Date__c != NULL) ' +
              'ORDER BY Sort_Order__c ASC'
          )
        );

        return appendPhaseWorkItemStats(phaseList);
      }
      when else {
        throw new AuraHandledException(
          'Unsupported object type: ' + entityType
        );
      }
    }
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  private static List<GanttChartTaskTransformer> appendPhaseWorkItemStats(
    List<SObject> phaseList
  ) {
    List<Id> phaseIds = new List<Id>();

    for (SObject phase : phaseList) {
      phaseIds.add(phase.Id);
    }

    List<Work_Item__c> workItemList = [
      SELECT Id, Est_Time__c, Status__c, Project_Phase__c
      FROM Work_Item__c
      WHERE
        Project_Phase__c IN :phaseIds
        AND Status__c IN (
          :WorkItemStatusNames.Approved,
          :WorkItemStatusNames.Blocked,
          :WorkItemStatusNames.InProgress,
          :WorkItemStatusNames.Implemented,
          :WorkItemStatusNames.Accepted,
          :WorkItemStatusNames.Rejected,
          :WorkItemStatusNames.Deployed
        )
        AND Est_Time__c != NULL
    ];

    Map<Id, Decimal> phaseTotalHoursMap = new Map<Id, Decimal>();

    for (Work_Item__c workItem : workItemList) {
      if (!phaseTotalHoursMap.containsKey(workItem.Project_Phase__c)) {
        phaseTotalHoursMap.put(workItem.Project_Phase__c, 0);
      }

      phaseTotalHoursMap.put(
        workItem.Project_Phase__c,
        (phaseTotalHoursMap.get(workItem.Project_Phase__c) +
        workItem.Est_Time__c)
      );
    }

    List<GanttChartTaskTransformer> phases = new List<GanttChartTaskTransformer>();

    for (SObject phase : phaseList) {
      phases.add(
        new GanttChartTaskTransformer(phase, phaseTotalHoursMap.get(phase.Id))
      );
    }

    return phases;
  }

  private static List<GanttChartTaskTransformer> appendProjectWorkItemStats(
    List<SObject> projectList
  ) {
    List<GanttChartTaskTransformer> projects = new List<GanttChartTaskTransformer>();

    for (SObject project : projectList) {
      projects.add(new GanttChartTaskTransformer(project, 0));
    }

    return projects;
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexCRUDViolation')
  @AuraEnabled
  public static Boolean updateDates(
    Id recordId,
    String startDate,
    String endDate,
    String milestoneDate
  ) {
    try {
      SObject obj = recordId.getSobjectType().newSObject(recordId);

      if (String.isNotBlank(startDate) && String.isNotBlank(endDate)) {
        obj.put('Start_Date__c', Date.valueOf(startDate));
        obj.put('End_Date__c', Date.valueOf(endDate));
      } else if (String.isNotBlank(milestoneDate)) {
        obj.put('Milestone_Date__c', Date.valueOf(milestoneDate));
      }

      update obj;

      return true;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled
  public static Boolean updateWorkItem(
    Id recordId,
    String startDate,
    String endDate
  ) {
    try {
      SObject obj = recordId.getSobjectType().newSObject(recordId);

      if (String.isNotBlank(startDate) && String.isNotBlank(endDate)) {
        obj.put('Scheduled_Start__c', Date.valueOf(startDate));
        // obj.put('Est_Time__c', estimatedTime);
        obj.put('Scheduled_End__c', Date.valueOf(endDate));
      }

      update obj;

      return true;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled
  public static Boolean updateOrder(List<Id> ids) {
    try {
      List<SObject> sObjectsToUpdate = new List<SObject>();
      Integer sortOrder = 1;

      for (Id id : ids) {
        SObject obj = id.getSobjectType().newSObject(id);
        obj.put('Sort_Order__c', sortOrder);
        sObjectsToUpdate.add(obj);

        sortOrder++;
      }

      update sObjectsToUpdate;

      return true;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}