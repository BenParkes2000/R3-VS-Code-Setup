// TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity')
public with sharing class RevenueManagementController {
  @TestVisible
  private static final Set<String> ACTIVE_STATUSES = new Set<String>{
    ProjectStatusNames.Planning,
    ProjectStatusNames.Discovery,
    ProjectStatusNames.KickOff,
    ProjectStatusNames.InProgress,
    ProjectStatusNames.Uat,
    ProjectStatusNames.HyperCare,
    ProjectStatusNames.Support
  };

  @TestVisible
  private static Map<Id, List<Date>> leaveDates = new Map<Id, List<Date>>();

// TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexCRUDViolation')
@AuraEnabled(cacheable=false)
public static List<User> getResourceAssignments(
    Date startDate,
    Date endDate,
    List<String> filteredStatusList,
    List<Id> filteredUserList
) {
    try {
        // null-safety
        if (filteredStatusList == null) filteredStatusList = new List<String>();
        if (filteredUserList == null) filteredUserList = new List<Id>();

        if (filteredStatusList.isEmpty()) {
            filteredStatusList.addAll(ACTIVE_STATUSES);
        }

        if (endDate == null) {
            endDate = startDate.addYears(2);
        }

        if (filteredUserList.isEmpty()) {
            for (User u : [
                SELECT Id
                FROM User
                WHERE Is_Resource_Assignable__c = TRUE
            ]) {
                filteredUserList.add(u.Id);
            }
        }

        List<User> userList = [
            SELECT
                Id,
                Name,
                Standard_Rate__c,
                (
                    SELECT
                        Id,
                        Project__c,
                        Project__r.Account__r.Name,
                        Project__r.Name,
                        Project__r.CurrencyIsoCode,
                        Project__r.Status__c,
                        Project__r.Proposal_Hourly_Rate__c,
                        Rate__c,
                        Assignment_Status__c,
                        Start_Date__c,
                        Hours_Monday__c,
                        Hours_Tuesday__c,
                        Hours_Wednesday__c,
                        Hours_Thursday__c,
                        Hours_Friday__c
                    FROM Project_Resource_Assignments__r
                    WHERE
                        Project__r.Status__c IN :filteredStatusList
                        AND (
                            Project__r.Account__r.Name != 'R3 Digital'
                            OR Project__r.Show_In_Tracker__c = TRUE
                        )
                        AND (
                            (Start_Date__c >= :startDate AND Start_Date__c <= :endDate)
                         OR (Calculated_End_Date__c >= :startDate AND Calculated_End_Date__c <= :endDate)
                        )
                    ORDER BY Start_Date__c DESC, Project__r.Name
                ),
                (
                    SELECT
                        Id,
                        Project__c,
                        Project__r.Name,
                        Start__c,
                        Duration__c
                    FROM Time_Entries__r
                    WHERE
                        Is_Billable__c = TRUE
                        AND Project__c IN (
                            SELECT Project__c
                            FROM Project_Resource_Assignment__c
                            WHERE
                                Project__r.Status__c IN :filteredStatusList
                                AND (
                                    Project__r.Account__r.Name != 'R3 Digital'
                                    OR Project__r.Show_In_Tracker__c = TRUE
                                )
                                AND (
                                    (Start_Date__c >= :startDate AND Start_Date__c <= :endDate)
                                 OR (Calculated_End_Date__c >= :startDate AND Calculated_End_Date__c <= :endDate)
                                )
                                AND User__c IN :filteredUserList
                        )
                )
            FROM User
            WHERE IsActive = TRUE AND Id IN :filteredUserList
            ORDER BY Name
        ];

        return userList;
    } catch (Exception e) {
        throw AuraHandledExceptionFactory.create(e);
    }
}


  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexCRUDViolation, PMD.CyclomaticComplexity')
  @AuraEnabled(cacheable=false)
  public static List<Account> getAccounts(
      Date startDate,
      Date endDate,
      List<String> filteredStatusList,
      List<Id> filteredUserList
  ) {
      try {
          Boolean includeAllProjects = true;

          if (filteredStatusList == null) filteredStatusList = new List<String>();
          if (filteredUserList == null) filteredUserList = new List<Id>();

          if (filteredStatusList.isEmpty()) {
              filteredStatusList.addAll(ACTIVE_STATUSES);
          }

          if (endDate == null) {
              endDate = startDate.addYears(2);
          }

          if (filteredUserList.isEmpty()) {
              for (User u : [
                  SELECT Id
                  FROM User
                  WHERE Is_Resource_Assignable__c = TRUE
              ]) {
                  filteredUserList.add(u.Id);
              }
          } else {
              includeAllProjects = false;
          }

          // 1) Prefilter via Resource Assignments
          //    Allow R3 Digital *only if* the project is flagged Show_In_Tracker__c.
          List<Project_Resource_Assignment__c> raList = [
              SELECT Project__c
              FROM Project_Resource_Assignment__c
              WHERE
                  Project__r.Status__c IN :filteredStatusList
                  AND (
                      Project__r.Account__r.Name != 'R3 Digital'
                      OR Project__r.Show_In_Tracker__c = TRUE
                  )
                  AND (
                      (Start_Date__c >= :startDate AND Start_Date__c <= :endDate)
                  OR (Calculated_End_Date__c >= :startDate AND Calculated_End_Date__c <= :endDate)
                  )
                  AND User__c IN :filteredUserList
          ];

          Set<Id> raIdSet = new Set<Id>();
          for (Project_Resource_Assignment__c ra : raList) {
              raIdSet.add(ra.Project__c);
          }

          // 2) Project superset
          List<Project__c> projectList;
          if (includeAllProjects) {
              projectList = [
                  SELECT
                      Id,
                      Name,
                      Start_Date__c,
                      End_Date__c,
                      Status__c,
                      Colour__c,
                      Account__c,
                      Account__r.Name,
                      Show_In_Tracker__c
                  FROM Project__c
                  WHERE
                      (
                          Status__c IN :filteredStatusList
                          AND Start_Date__c <= :endDate
                          AND End_Date__c >= :startDate
                          AND (
                              Account__r.Name != 'R3 Digital'
                              OR Show_In_Tracker__c = TRUE
                          )
                      )
                      OR Id IN :raIdSet
              ];
          } else {
              projectList = [
                  SELECT
                      Id,
                      Name,
                      Start_Date__c,
                      End_Date__c,
                      Status__c,
                      Colour__c,
                      Account__c,
                      Account__r.Name,
                      Show_In_Tracker__c
                  FROM Project__c
                  WHERE Id IN :raIdSet
              ];
          }

          Set<Id> accountIds = new Set<Id>();
          Set<Id> projectIds = new Set<Id>();
          for (Project__c p : projectList) {
              accountIds.add(p.Account__c);
              projectIds.add(p.Id);
          }

          // 3) Accounts + child projects
          //    Do NOT blanket-exclude R3 Digital; apply the same conditional include at the child level.
          List<Account> accountList = [
              SELECT
                  Id,
                  Name,
                  (
                      SELECT
                          Id,
                          Name,
                          Start_Date__c,
                          End_Date__c,
                          Status__c,
                          Colour__c,
                          Account__c,
                          Proposal_Hourly_Rate__c,
                          Show_In_Tracker__c
                      FROM Projects_R3__r
                      WHERE
                          (
                              Status__c IN :filteredStatusList
                              AND Start_Date__c <= :endDate
                              AND End_Date__c >= :startDate
                              AND (
                                  Account__r.Name != 'R3 Digital'
                                  OR Show_In_Tracker__c = TRUE
                              )
                          )
                          OR Id IN :projectIds
                      ORDER BY Start_Date__c
                  )
              FROM Account
              WHERE Id IN :accountIds
              ORDER BY Name
          ];

          return accountList;
      } catch (Exception e) {
          throw AuraHandledExceptionFactory.create(e);
      }
  }


  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled(cacheable=true)
  public static List<User> getUsers() {
    try {
      List<User> userList = [
        SELECT Id, Name, Standard_Rate__c, Project_Team_Role__c
        FROM User
        WHERE IsActive = TRUE AND Is_Resource_Assignable__c = TRUE
        ORDER BY Name
      ];

      if (userList.size() == 0) {
        throw new CustomException('No users found.');
      }

      return userList;
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled(cacheable=false)
  public static User getUserPreferences() {
    try {
      return [
        SELECT
          Resource_Management_Columns__c,
          Resource_Management_Expanded_IDs__c,
          Resource_Management_Scale__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings(
    'PMD.ApexCRUDViolation, PMD.CognitiveComplexity, PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity'
  )
  @AuraEnabled(cacheable=true)
  public static Map<Id, List<LeaveDate>> getLeaveDates(
    Date filterStartDate,
    Date filterEndDate,
    List<Id> filteredUserList
  ) {
    try {
      if (filterEndDate == null) {
        filterEndDate = filterStartDate.addYears(2);
      }

      if (filteredUserList.size() == 0) {
        List<User> userList = [
          SELECT Id
          FROM User
          WHERE Is_Resource_Assignable__c = TRUE
        ];
        for (User user : userList) {
          filteredUserList.add(user.Id);
        }
      }

      List<Leave_Request__c> leaveRequestList = [
        SELECT
          Leave_Summary__r.OwnerId,
          Leave_Type__c,
          Start_Date__c,
          End_Date__c,
          Status__c,
          Days__c
        FROM Leave_Request__c
        WHERE
          Leave_Summary__r.OwnerId IN :filteredUserList
          AND ((Start_Date__c >= :filterStartDate
          AND Start_Date__c <= :filterEndDate)
          OR (End_Date__c >= :filterStartDate
          AND End_Date__c <= :filterEndDate))
          AND Status__c IN (
            :LeaveRequestStatusNames.SUBMITTED,
            :LeaveRequestStatusNames.APPROVED
          )
      ];

      Map<Id, List<LeaveDate>> leaveDates = new Map<Id, List<LeaveDate>>();

      for (Leave_Request__c leaveRequest : leaveRequestList) {
        List<LeaveDate> dates;
        Id userId = leaveRequest.Leave_Summary__r.OwnerId;
        Date startDate = leaveRequest.Start_Date__c;
        Date endDate = leaveRequest.End_Date__c;
        Decimal hours = leaveRequest.Days__c * 8;
        Decimal dayHours = 0;
        Decimal totalHours = 0;
        DateTime startDT;

        if (leaveDates.containsKey(userId)) {
          dates = leaveDates.get(userId);
        } else {
          dates = new List<LeaveDate>();
        }

        while (startDate <= endDate) {
          startDT = (DateTime) startDate;
          if (!(startDT.format('E') == 'Sat' || startDT.format('E') == 'Sun')) {
            totalHours += 8;
            if (hours >= totalHours) {
              dayHours = 8;
            } else {
              dayHours = 4;
            }
            dates.add(
              new LeaveDate(
                startDate,
                leaveRequest.Status__c,
                leaveRequest.Leave_Type__c,
                dayHours
              )
            );
          }
          startDate = startDate.addDays(1);
        }

        leaveDates.put(userId, dates);
      }

      return leaveDates;
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled(cacheable=false)
  public static Project_Resource_Assignment__c getResourceAssignmentDetails(
    Id id
  ) {
    try {
      return [
        SELECT
          Id,
          Start_Date__c,
          User__c,
          Project__c,
          Rate__c,
          Assignment_Status__c,
          Hours_Monday__c,
          Hours_Tuesday__c,
          Hours_Wednesday__c,
          Hours_Thursday__c,
          Hours_Friday__c
        FROM Project_Resource_Assignment__c
        WHERE Id = :id
        LIMIT 1
      ];
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }

  @AuraEnabled(cacheable=true)
  public static Boolean canEditAssignments() {
      return FeatureManagement.checkPermission('Edit_Revenue_Tracker');
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled(cacheable=false)
  public static Project_Resource_Assignment__c findResourceAssignment(
    Date startDate,
    Id userId,
    Id projectId
  ) {
    try {
      List<Project_Resource_Assignment__c> resourceAssignmentList = [
        SELECT
          Id,
          Start_Date__c,
          User__c,
          Project__c,
          Rate__c,
          Hours_Monday__c,
          Hours_Tuesday__c,
          Hours_Wednesday__c,
          Hours_Thursday__c,
          Hours_Friday__c
        FROM Project_Resource_Assignment__c
        WHERE
          Start_Date__c = :startDate
          AND User__c = :userId
          AND Project__c = :projectId
        LIMIT 1
      ];

      if (resourceAssignmentList.size() == 0) {
        return null;
      }

      return resourceAssignmentList[0];
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexCRUDViolation')
  @AuraEnabled(cacheable=false)
  public static void saveResourceAssignment(
    Id resourceAssignmentId,
    Date startDate,
    Id userId,
    Id projectId,
    Decimal rate,
    String status,
    Decimal hoursMonday,
    Decimal hoursTuesday,
    Decimal hoursWednesday,
    Decimal hoursThursday,
    Decimal hoursFriday
  ) {
    try {
      if (
        resourceAssignmentId == null &&
        findResourceAssignment(startDate, userId, projectId) != null
      ) {
        throw new CustomException(
          'A resource assignment already exists for the selected week.'
        );
      }

      // Calculates total hours + deletes assignment if every day is 0
      Decimal totalHours = (hoursMonday != null ? hoursMonday : 0) + (hoursTuesday != null ? hoursTuesday : 0) + (hoursWednesday != null ? hoursWednesday : 0) + (hoursThursday != null ? hoursThursday : 0) + (hoursFriday != null ? hoursFriday : 0);

      if (resourceAssignmentId != null && totalHours == 0) {
        delete [SELECT Id FROM Project_Resource_Assignment__c WHERE Id = :resourceAssignmentId];
        return;
      }

      Project_Resource_Assignment__c assignment = new Project_Resource_Assignment__c(
        Id = resourceAssignmentId
      );
      assignment.Start_Date__c = startDate;
      assignment.User__c = userId;
      assignment.OwnerId = userId;
      assignment.Project__c = projectId;
      assignment.Rate__c = rate;
      assignment.Assignment_Status__c = status;
      assignment.Hours_Monday__c = hoursMonday;
      assignment.Hours_Tuesday__c = hoursTuesday;
      assignment.Hours_Wednesday__c = hoursWednesday;
      assignment.Hours_Thursday__c = hoursThursday;
      assignment.Hours_Friday__c = hoursFriday;
      upsert assignment;
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled(cacheable=false)
  public static void updateUserColumns(String columns) {
    try {
      User user = new User(Id = UserInfo.getUserId());
      user.Resource_Management_Columns__c = columns;
      update user;
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled(cacheable=false)
  public static void updateUserExpandedIds(String expandedIds) {
    try {
      User user = new User(Id = UserInfo.getUserId());
      user.Resource_Management_Expanded_IDs__c = expandedIds;
      update user;
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @AuraEnabled(cacheable=false)
  public static void updateUserScale(String scale) {
    try {
      User user = new User(Id = UserInfo.getUserId());
      user.Resource_Management_Scale__c = scale;
      update user;
    } catch (Exception e) {
      throw AuraHandledExceptionFactory.create(e);
    }
  }

  public class CustomException extends Exception {
  }

  @TestVisible
  public class LeaveDate {
    @AuraEnabled
    public Date LeaveDate { get; private set; } // NOPMD

    @AuraEnabled
    public Boolean IsApproved { get; private set; } // NOPMD

    @AuraEnabled
    public Boolean IsSickness { get; private set; } // NOPMD

    @AuraEnabled
    public Decimal Hours { get; private set; } // NOPMD

    // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public LeaveDate(
      Date leaveDate,
      String status,
      String type,
      Decimal hours
    ) {
      this.LeaveDate = LeaveDate;
      this.IsApproved = (status == LeaveRequestStatusNames.APPROVED ||
      type == LeaveRequestTypeNames.SICKNESS);
      this.IsSickness = (type == LeaveRequestTypeNames.SICKNESS);
      this.Hours = hours;
    }
  }
}