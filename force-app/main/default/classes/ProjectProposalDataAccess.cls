public with sharing class ProjectProposalDataAccess {
  public Project__c getProject(Id projectId) {
    return [
      SELECT
        Name,
        Account__c,
        Account__r.Name,
        Title__c,
        Introduction__c,
        Challenges__c,
        In_Scope__c,
        Out_of_Scope__c,
        Payment_Terms__c,
        Project_Management_Est__c,
        Discovery_Est__c,
        Design_Analysis_Est__c,
        Testing_Est__c,
        UAT_Est__c,
        Training_Documentation_Est__c,
        Hypercare_Est__c,
        Total_Estimate__c,
        Total_Est_Days__c,
        Total_Feature_Est__c,
        Total_Est_Cost__c,
        Proposal_Hourly_Rate__c,
        Hide_Acceptance_Criteria__c,
        Hide_Assumptions__c,
        Hide_Business_Requirements__c,
        Hide_Our_Approach__c,
        Hide_Personas__c,
        Hide_Project_Management_Delivery__c,
        Hide_RAID_Log__c,
        Hide_Requirements__c,
        Hide_Services__c,
        Hide_Table_of_Contents__c,
        Hide_User_Stories__c,
        Vendor__c,
        CurrencyIsoCode,
        Status__c,
        Is_PreSales__c
      FROM Project__c
      WHERE Id = :projectId
      WITH SECURITY_ENFORCED
    ];
  }

  public List<ContentVersion> getFiles(Id projectId) {
    final List<String> allowedFileTypes = new List<String>{
      'GIF',
      'PNG',
      'JPEG',
      'JPG'
    };
    Set<Id> contentDocumentIds = new Set<Id>();

    for (ContentDocumentLink link : [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :projectId
      WITH SECURITY_ENFORCED
    ]) {
      contentDocumentIds.add(link.ContentDocumentId);
    }

    return [
      SELECT Id, ContentDocumentId, VersionData, Description, FileType, Title
      FROM ContentVersion
      WHERE
        ContentDocumentId IN :contentDocumentIds
        AND FileType IN :allowedFileTypes
        AND IsLatest = TRUE
      WITH SECURITY_ENFORCED
    ];
  }

  public List<Project_Feature__c> getFeatures(Id projectId) {
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
            Importance__c,
            Est_Time__c,
            Is_Optional__c
          FROM Work_Items__r
          WHERE Project__c = :projectId
          ORDER BY Sort_Order__c, Subject__c
        )
      FROM Project_Feature__c
      WHERE Project__c = :projectId
      WITH SECURITY_ENFORCED
      ORDER BY Sort_Order__c, Name
    ];
  }

  public List<Salesforce_License__c> getLicenses(Id projectId) {
    return [
      SELECT License__c, Quantity__c
      FROM Salesforce_License__c
      WHERE Project__c = :projectId
      WITH SECURITY_ENFORCED
      ORDER BY Sort_Order__c
    ];
  }

  public List<Project_Team_Member__c> getProjectTeamMembers(Id projectId) {
    return [
      SELECT Role__c, Name__c, Email__c, Phone__c
      FROM Project_Team_Member__c
      WHERE Project__c = :projectId
      WITH SECURITY_ENFORCED
      ORDER BY Sort_Order__c
    ];
  }

  public List<Third_Party_Service__c> getServices(Id projectId) {
    return [
      SELECT Service__c, Description__c, Est_Cost__c, CurrencyIsoCode
      FROM Third_Party_Service__c
      WHERE Project__c = :projectId
      WITH SECURITY_ENFORCED
      ORDER BY Sort_Order__c
    ];
  }

  public List<Persona__c> getPersonas(Id accountId) {
    return [
      SELECT Name, Description__c
      FROM Persona__c
      WHERE Account__c = :accountId
      WITH SECURITY_ENFORCED
      ORDER BY Name
    ];
  }

  public List<User_Story__c> getUserStories(Id projectId) {
    return [
      SELECT User_Story_Title__c
      FROM User_Story__c
      WHERE Project__c = :projectId
      WITH SECURITY_ENFORCED
      ORDER BY User_Story_Title__c
    ];
  }

  public List<Acceptance_Criteria__c> getAcceptanceCriterias(Id projectId) {
    return [
      SELECT User_Story__r.User_Story_Title__c, Given__c, When__c, Then__c
      FROM Acceptance_Criteria__c
      WHERE User_Story__r.Project__c = :projectId
      WITH SECURITY_ENFORCED
      ORDER BY User_Story__r.User_Story_Title__c, Given__c, When__c, Then__c
    ];
  }

  public List<Business_Requirement__c> getBusinessRequirements(Id projectId) {
    return [
      SELECT Name, Description__c
      FROM Business_Requirement__c
      WHERE Project__c = :projectId
      WITH SECURITY_ENFORCED
      ORDER BY Name
    ];
  }

  public List<RAID_Log__c> getRaidLogs(Id projectId) {
    return [
      SELECT Type__c, Rating__c, Subject__c
      FROM RAID_Log__c
      WHERE Project__c = :projectId
      WITH SECURITY_ENFORCED
      ORDER BY Type__c, Rating__c, Subject__c
    ];
  }

  public List<Assumption__c> getAssumptions(Id projectId) {
    return [
      SELECT Area__c, Assumption__c
      FROM Assumption__c
      WHERE Project__c = :projectId
      WITH SECURITY_ENFORCED
      ORDER BY Area__c, Assumption__c
    ];
  }
}