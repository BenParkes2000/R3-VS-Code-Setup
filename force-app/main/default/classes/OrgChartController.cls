public without sharing class OrgChartController {
  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled(cacheable=true)
  public static List<User> getUsers() {
    List<String> excludedProfiles = new List<String>{
      'Analytics Cloud Security User',
      'Minimum Access - Salesforce',
      'Analytics Cloud Integration User',
      'Sales Insights Integration User',
      'B2BMA Integration User'
    };

    // a list of profiles to include in the org chart
    List<String> includedProfileNames = new List<String>{
      'System Administrator',
      'R3 Consultant',
      'R3 Commercial'
    };

    List<Profile> includedProfiles = [
      SELECT Id
      FROM Profile
      WHERE Name IN :includedProfileNames
    ];

    Set<Id> includedProfileIds = new Set<Id>();
    for (Profile p : includedProfiles) {
      includedProfileIds.add(p.Id);
    }

    // List<Profile> excludedProfileRecords = [
    //   SELECT Id
    //   FROM Profile
    //   WHERE Name IN :excludedProfiles
    // ];

    // Set<Id> excludedProfileIds = new Set<Id>();
    // for (Profile p : excludedProfileRecords) {
    //   excludedProfileIds.add(p.Id);
    // }

    return [
      SELECT
        Id,
        FirstName,
        LastName,
        Title,
        SmallPhotoUrl,
        ManagerId,
        Is_Manager__c
      FROM User
      WHERE
        IsActive = TRUE
        AND UserType = 'Standard'
        AND Exclude_from_Org_Chart__c = FALSE
        AND ProfileId IN :includedProfileIds
      ORDER BY ManagerId, LastName, FirstName
    ];
  }
}