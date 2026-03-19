public with sharing class ProjectCopyService {
  public static Map<Id, Id> copyProjectPhases(
    List<Phase__c> oldProjectPhaseList,
    Map<Id, Id> oldToNewProjectIdMap
  ) {
    // Insert new Project Phases
    List<Phase__c> newProjectPhaseList = new List<Phase__c>();

    for (Phase__c oldProjectPhase : oldProjectPhaseList) {
      Phase__c newProjectPhase = oldProjectPhase.clone(
        false,
        true,
        false,
        false
      );
      newProjectPhase.Project__c = oldToNewProjectIdMap.get(
        oldProjectPhase.Project__c
      );
      newProjectPhaseList.add(newProjectPhase);
    }

    if (Schema.sObjectType.Phase__c.isCreateable()) {
      insert newProjectPhaseList;
    }

    // Create map of old Project Phase ID to new Project Phase ID
    Map<Id, Id> oldToNewProjectPhaseIdMap = new Map<Id, Id>();

    for (Integer i = 0; i < oldProjectPhaseList.size(); i++) {
      oldToNewProjectPhaseIdMap.put(
        oldProjectPhaseList[i].Id,
        newProjectPhaseList[i].Id
      );
    }

    return oldToNewProjectPhaseIdMap;
  }

  public static Map<Id, Id> copyProjectFeatures(
    List<Project_Feature__c> oldProjectFeatureList,
    Map<Id, Id> oldToNewProjectIdMap,
    Map<Id, Id> oldToNewProjectPhaseIdMap
  ) {
    // Insert new Project Features
    List<Project_Feature__c> newProjectFeatureList = new List<Project_Feature__c>();

    for (Project_Feature__c oldProjectFeature : oldProjectFeatureList) {
      Project_Feature__c newProjectFeature = oldProjectFeature.clone(
        false,
        true,
        false,
        false
      );
      newProjectFeature.Project__c = oldToNewProjectIdMap.get(
        oldProjectFeature.Project__c
      );
      newProjectFeature.Phase__c = oldToNewProjectPhaseIdMap.get(
        oldProjectFeature.Phase__c
      );
      newProjectFeatureList.add(newProjectFeature);
    }

    if (Schema.sObjectType.Project_Feature__c.isCreateable()) {
      insert newProjectFeatureList;
    }

    // Create map of old Project Feature ID to new Project Feature ID
    Map<Id, Id> oldToNewProjectFeatureIdMap = new Map<Id, Id>();

    for (Integer i = 0; i < oldProjectFeatureList.size(); i++) {
      oldToNewProjectFeatureIdMap.put(
        oldProjectFeatureList[i].Id,
        newProjectFeatureList[i].Id
      );
    }

    return oldToNewProjectFeatureIdMap;
  }

  @SuppressWarnings('PMD.ExcessiveParameterList')
  public static Map<Id, Id> copyWorkItems(
    List<Work_Item__c> oldWorkItemList,
    Map<Id, Id> oldToNewProjectIdMap,
    Map<Id, Id> oldToNewProjectPhaseIdMap,
    Map<Id, Id> oldToNewProjectFeatureIdMap
  ) {
    // Insert new Work Items
    List<Work_Item__c> newWorkItemList = new List<Work_Item__c>();

    for (Work_Item__c oldWorkItem : oldWorkItemList) {
      Work_Item__c newWorkItem = oldWorkItem.clone(false, true, false, false);
      newWorkItem.Project__c = oldToNewProjectIdMap.get(oldWorkItem.Project__c);
      newWorkItem.Project_Phase__c = oldToNewProjectPhaseIdMap.get(
        oldWorkItem.Project_Phase__c
      );
      newWorkItem.Feature__c = oldToNewProjectFeatureIdMap.get(
        oldWorkItem.Feature__c
      );
      newWorkItemList.add(newWorkItem);
    }

    if (Schema.sObjectType.Work_Item__c.isCreateable()) {
      insert newWorkItemList;
    }

    // Create map of old Work Item ID to new Work Item ID
    Map<Id, Id> oldToNewWorkItemIdMap = new Map<Id, Id>();

    for (Integer i = 0; i < oldWorkItemList.size(); i++) {
      oldToNewWorkItemIdMap.put(oldWorkItemList[i].Id, newWorkItemList[i].Id);
    }

    return oldToNewWorkItemIdMap;
  }
}