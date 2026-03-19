public with sharing class ProjectCopyAction {
  @InvocableMethod(
    label='Copy Project'
    description='Copy a project and its related records'
  )
  public static void execute(List<Request> requests) {
    // Create map of old Project ID to new Project ID
    Map<Id, Id> oldToNewProjectIdMap = new Map<Id, Id>();

    for (Request request : requests) {
      oldToNewProjectIdMap.put(request.oldProjectId, request.newProjectId);
    }

    // Get old projects and related records
    Set<Id> oldProjectIds = oldToNewProjectIdMap.keySet();
    List<Phase__c> oldProjectPhaseList = getProjectPhases(oldProjectIds);
    List<Project_Feature__c> oldProjectFeatureList = getProjectFeatures(
      oldProjectIds
    );
    List<Work_Item__c> oldWorkItemList = getWorkItems(oldProjectIds);

    // Create new Project Phases
    Map<Id, Id> oldToNewProjectPhaseIdMap = ProjectCopyService.copyProjectPhases(
      oldProjectPhaseList,
      oldToNewProjectIdMap
    );

    // Create new Project Features
    Map<Id, Id> oldToNewProjectFeatureIdMap = ProjectCopyService.copyProjectFeatures(
      oldProjectFeatureList,
      oldToNewProjectIdMap,
      oldToNewProjectPhaseIdMap
    );

    // Create new Work Items
    ProjectCopyService.copyWorkItems(
      oldWorkItemList,
      oldToNewProjectIdMap,
      oldToNewProjectPhaseIdMap,
      oldToNewProjectFeatureIdMap
    );
  }

  private static List<Phase__c> getProjectPhases(Set<Id> projectIds) {
    return [
      SELECT
        Id,
        CreatedById,
        CurrencyIsoCode,
        Description__c,
        End_Date__c,
        LastModifiedById,
        Milestone_Date__c,
        Name,
        Notes__c,
        Project__c,
        RecordTypeId,
        Sort_Order__c,
        Stage__c,
        Start_Date__c,
        Status__c,
        Total_Effort__c
      FROM Phase__c
      WHERE Project__c IN :projectIds
      WITH SECURITY_ENFORCED
    ];
  }

  private static List<Project_Feature__c> getProjectFeatures(
    Set<Id> projectIds
  ) {
    return [
      SELECT
        Id,
        CreatedById,
        CurrencyIsoCode,
        Description__c,
        Is_Template__c,
        LastModifiedById,
        Name,
        Original_Est_Hrs__c,
        Phase__c,
        Project__c,
        Sort_Order__c,
        Total_Effort__c
      FROM Project_Feature__c
      WHERE Project__c IN :projectIds
      WITH SECURITY_ENFORCED
    ];
  }

  private static List<Work_Item__c> getWorkItems(Set<Id> projectIds) {
    return [
      SELECT
        Acceptance_Criteria__c,
        Assigned_To__c,
        Assumptions__c,
        Blocked_Reason__c,
        Client_Data_Template_Name__c,
        CreatedById,
        CurrencyIsoCode,
        Deliverables__c,
        Description__c,
        Documentation_URL__c,
        Est_Overrun_Reason__c,
        Est_Time__c,
        Feature__c,
        Implementation__c,
        Importance__c,
        Is_Optional__c,
        Is_Template__c,
        LastModifiedById,
        Link__c,
        Notify_client_of_status_changes__c,
        Process_Diagram_URL__c,
        Product_Owner2__c,
        Project__c,
        Project_Phase__c,
        Related_Work_Item__c,
        Scheduled_End__c,
        Scheduled_Start__c,
        Sort_Order__c,
        Status__c,
        Subject__c,
        Total_Est__c,
        Type__c,
        Urgency__c,
        User_Story__c
      FROM Work_Item__c
      WHERE Project__c IN :projectIds
      WITH SECURITY_ENFORCED
    ];
  }

  public class Request {
    @InvocableVariable(
      label='Old Project ID'
      description='The ID of the project to copy'
    )
    public Id oldProjectId;

    @InvocableVariable(
      label='New Project ID'
      description='The ID of the new project'
    )
    public Id newProjectId;
  }
}