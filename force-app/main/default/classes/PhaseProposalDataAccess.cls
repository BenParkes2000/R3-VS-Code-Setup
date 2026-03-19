public with sharing class PhaseProposalDataAccess {
  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public Phase__c getPhases(Id phaseId) {
    return [
      SELECT
        Name,
        Description__c,
        Total_Effort__c,
        Stage__c,
        Project__r.Name,
        Project__r.Account__r.Name,
        Project__r.Introduction__c,
        Project__r.Challenges__c,
        Project__r.Payment_Terms__c,
        Project__r.Project_Management__c,
        Project__r.Project_Management_Est__c,
        Project__r.Testing__c,
        Project__r.Testing_Est__c,
        Project__r.UAT_Est__c,
        Project__r.UAT__c,
        Project__r.Hypercare_Est__c,
        Project__r.Hypercare__c,
        Project__r.Total_Estimate__c,
        Project__r.Total_Est_Days__c,
        Project__r.Total_Feature_Est__c,
        Project__r.Total_Est_Cost__c,
        Project__r.Proposal_Hourly_Rate__c,
        Project__r.Opportunity__c,
        Project__r.Hide_Table_of_Contents__c,
        Project__r.Hide_Requirements__c,
        Project__r.Hide_Services__c,
        Project__r.Hide_Our_Approach__c,
        Project__r.Hide_Project_Management_Delivery__c,
        Project__r.Hide_Assumptions__c,
        Project__r.Vendor__c,
        Project__r.CurrencyIsoCode
      FROM Phase__c
      WHERE Id = :phaseId
    ];
  }

  // public Project__c getProject(Id phaseId) {
  //     return [
  //         SELECT
  //             Name,
  //             Account__r.Name,
  //             Introduction__c,
  //             Challenges__c,
  //             Payment_Terms__c,
  //             Project_Management__c,
  //             Project_Management_Est__c,
  //             Testing__c,
  //             Testing_Est__c,
  //             UAT__c,
  //             Hypercare__c,
  //             Proposal_Hourly_Rate__c,
  //             Opportunity__c,
  //             Hide_Table_of_Contents__c,
  //             Hide_Requirements__c,
  //             Hide_Services__c,
  //             Hide_Our_Approach__c,
  //             Hide_Project_Management_Delivery__c,
  //             Hide_Assumptions__c,
  //             Vendor__c,
  //             CurrencyIsoCode
  //         FROM Project__c
  //         WHERE Id = :phaseId
  //     ];
  // }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public List<ContentVersion> getFiles(Id phaseId) {
    final List<String> allowedFileTypes = new List<String>{
      'GIF',
      'PNG',
      'JPEG',
      'JPG'
    };
    Set<Id> ContentDocumentIds = new Set<Id>(); // NOPMD

    for (ContentDocumentLink link : [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :phaseId
    ]) {
      ContentDocumentIds.add(link.ContentDocumentId);
    }

    return [
      SELECT Id, ContentDocumentId, VersionData, Description, FileType, Title
      FROM ContentVersion
      WHERE
        ContentDocumentId IN :ContentDocumentIds
        AND FileType IN :allowedFileTypes
        AND IsLatest = TRUE
    ];
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public List<Project_Feature__c> getFeatures(Id phaseId) {
    return [
      SELECT
        Name,
        Description__c,
        Total_Est__c,
        Work_Item_Count__c,
        (
          SELECT
            Name,
            Subject__c,
            Description__c,
            Assumptions__c,
            Importance__c,
            Est_Time__c,
            Is_Optional__c
          FROM Work_Items__r
          WHERE Project_Phase__c = :phaseId
          ORDER BY Sort_Order__c, Subject__c
        )
      FROM Project_Feature__c
      WHERE
        Id IN (
          SELECT Feature__c
          FROM Work_Item__c
          WHERE Project_Phase__c = :phaseId
        )
      ORDER BY Sort_Order__c, Name
    ];
  }

  // public List<Salesforce_License__c> getLicesnses(Id phaseId) {
  //     return [SELECT License__c, Quantity__c FROM Salesforce_License__c WHERE Phase__c = :phaseId ORDER BY Sort_Order__c];
  // }

  // public List<Project_Team_Member__c> getProjectTeamMembers(Id phaseId) {
  //     return [SELECT Role__c, Name__c, Email__c, Phone__c FROM Project_Team_Member__c WHERE Phase__c = :phaseId ORDER BY Sort_Order__c];
  // }

  // public List<Third_Party_Service__c> getServices(Id phaseId) {
  //     return [SELECT Service__c, Description__c, Est_Cost__c, CurrencyIsoCode FROM Third_Party_Service__c WHERE Phase__c = :phaseId ORDER BY Sort_Order__c];
  // }
}