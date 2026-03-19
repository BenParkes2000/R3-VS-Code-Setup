public with sharing class ResourceManagementChartController {
    @TestVisible
    private static Set<String> ACTIVE_STATUSES = new Set<String>{
        ProjectStatusNames.Planning,
        ProjectStatusNames.KickOff,
        ProjectStatusNames.InProgress,
        ProjectStatusNames.Uat,
        ProjectStatusNames.HyperCare,
        ProjectStatusNames.Support
    };

    @TestVisible
    private static Map<Id, List<Date>> leaveDates = new Map<Id, List<Date>>();

    @AuraEnabled(cacheable=false)
    public static List<Project> getProjects(Date startDate, Date endDate, List<String> filteredStatusList, List<Id> filteredUserList) {
        try {
            if (filteredStatusList.size() == 0) {
                filteredStatusList.addAll(ACTIVE_STATUSES);
            }

            if (endDate == null) {
                endDate = startDate.addYears(2);
            }

            if (filteredUserList.size() == 0) {
                List<User> userList = [SELECT Id FROM User WHERE Is_Resource_Assignable__c = TRUE];
                for (User user : userList) {
                    filteredUserList.add(user.Id);
                }
            }

            Map<Id, List<Project_Resource_Assignment__c>> resourceAssignmentsMappedByProject = getResourceAssignmentsMappedByProject(startDate, endDate, filteredStatusList, filteredUserList);

            // Project 1 - Start: 01/01/2022 End: 31/05/2022
            // Project 2 - Start: 01/02/2022 End: 31/05/2022

            // Gantt - Start Date: 01/02/2022
            // Gantt - End Date: 10/06/2022

            System.debug(resourceAssignmentsMappedByProject);

            Set<Id> projectIds = resourceAssignmentsMappedByProject.keySet();

            System.debug(projectIds);

            String queryString = 'SELECT Id, Account__r.Name, Name, Start_Date__c, End_Date__c, Colour__c, Status__c FROM Project__c WHERE Id IN :projectIds ';
            if (filteredUserList.size() > 1) {
                queryString +=
                    'OR (Status__c IN :filteredStatusList ' +
                    'AND ((Start_Date__c >= :startDate ' +
                    'AND Start_Date__c <= :endDate) ' +
                    'OR (End_Date__c >= :startDate ' +
                    'AND End_Date__c <= :endDate))) ';
            }

            queryString += 'ORDER BY Account__r.Name, Name';

            List<Project__c> activeProjectsList = Database.query(queryString);

            System.debug(activeProjectsList);

            List<Project> projects = new List<Project>();

            for (Project__c activeProject : activeProjectsList) {
                Project project = new Project(
                    activeProject.Id,
                    activeProject.Account__c,
                    activeProject.Account__r.Name,
                    activeProject.Name,
                    activeProject.Start_Date__c,
                    activeProject.End_Date__c,
                    activeProject.Colour__c,
                    activeProject.Status__c
                );

                if (resourceAssignmentsMappedByProject.containsKey(activeProject.Id)) {
                    for (Project_Resource_Assignment__c resourceAssignment : resourceAssignmentsMappedByProject.get(activeProject.Id)) {
                        project.appendResourceAssignment(resourceAssignment);
                    }
                }

                projects.add(project);
            }

            return projects;
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @TestVisible
    private static Map<Id, List<Project_Resource_Assignment__c>> getResourceAssignmentsMappedByProject(Date startDate, Date endDate, List<String> filteredStatusList, List<Id> filteredUserList) {
        List<Project_Resource_Assignment__c> resourceAssignmentList = [
            SELECT Id, Project__c, Start_Date__c, End_Date__c, Hours_Per_Day__c, User__c, User__r.Name, Project__r.Account__r.Name, Project__r.Name, Project__r.Start_Date__c, Project__r.End_Date__c
            FROM Project_Resource_Assignment__c
            WHERE
                Project__r.Status__c IN :filteredStatusList
                AND User__c IN :filteredUserList
                AND ((Start_Date__c >= :startDate
                AND Start_Date__c <= :endDate)
                OR (End_Date__c >= :startDate
                AND End_Date__c <= :endDate))
            ORDER BY Project__r.Account__r.Name, Project__r.Name, Start_Date__c, End_Date__c DESC, User__r.Name
        ];

        Map<Id, List<Project_Resource_Assignment__c>> resourceAssignmentsMappedByProject = new Map<Id, List<Project_Resource_Assignment__c>>();

        for (Project_Resource_Assignment__c resourceAssignment : resourceAssignmentList) {
            if (resourceAssignmentsMappedByProject.containsKey(resourceAssignment.Project__c)) {
                resourceAssignmentsMappedByProject.get(resourceAssignment.Project__c).add(resourceAssignment);
            } else {
                resourceAssignmentsMappedByProject.put(resourceAssignment.Project__c, new List<Project_Resource_Assignment__c>{ resourceAssignment });
            }
        }

        return resourceAssignmentsMappedByProject;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        try {
            List<User> userList = [SELECT Id, Name, Project_Team_Role__c FROM User WHERE IsActive = TRUE AND Is_Resource_Assignable__c = TRUE ORDER BY Name];

            if (userList.size() == 0) {
                throw new CustomException('No users found.');
            }

            return userList;
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, List<LeaveDate>> getLeaveDates() {
        try {
            List<Leave_Request__c> leaveRequestList = [
                SELECT Leave_Summary__r.OwnerId, Start_Date__c, End_Date__c, Status__c
                FROM Leave_Request__c
                WHERE Status__c IN (:LeaveRequestStatusNames.SUBMITTED, :LeaveRequestStatusNames.APPROVED)
            ];

            Map<Id, List<LeaveDate>> leaveDates = new Map<Id, List<LeaveDate>>();

            for (Leave_Request__c leaveRequest : leaveRequestList) {
                Id userId = leaveRequest.Leave_Summary__r.OwnerId;
                Date startDate = leaveRequest.Start_Date__c;
                Date endDate = leaveRequest.End_Date__c;
                List<LeaveDate> dates;

                if (leaveDates.containsKey(userId)) {
                    dates = leaveDates.get(userId);
                } else {
                    dates = new List<LeaveDate>();
                }

                while (startDate <= endDate) {
                    dates.add(new LeaveDate(startDate, leaveRequest.Status__c));
                    startDate = startDate.addDays(1);
                }

                leaveDates.put(userId, dates);
            }

            return leaveDates;
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled(cacheable=false)
    public static User getUserPreferences() {
        try {
            return [SELECT Resource_Management_Columns__c, Resource_Management_Expanded_IDs__c, Resource_Management_Scale__c FROM User WHERE Id = :UserInfo.getUserId()];
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled(cacheable=false)
    public static Project getProjectDetails(Id recordId) {
        try {
            Project__c project = [SELECT Id, Account__c, Account__r.Name, Name, Start_Date__c, End_Date__c, Colour__c, Status__c FROM Project__c WHERE Id = :recordId];

            return new Project(project.Id, project.Account__c, project.Account__r.Name, project.Name, project.Start_Date__c, project.End_Date__c, project.Colour__c, project.Status__c);
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled(cacheable=false)
    public static ResourceAssignment getAssignmentDetails(Id recordId) {
        try {
            String entityType = GanttChartController.getEntityType(recordId);

            switch on entityType {
                when 'Project__c' {
                    Project__c project = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Project__c WHERE Id = :recordId];

                    return new ResourceAssignment(null, project.Id, project.Name, null, project.Start_Date__c, project.End_Date__c, null);
                }
                when 'Project_Resource_Assignment__c' {
                    Project_Resource_Assignment__c assignment = [
                        SELECT Id, User__c, Start_Date__c, End_Date__c, Hours_Per_Day__c, Project__c, Project__r.Name
                        FROM Project_Resource_Assignment__c
                        WHERE Id = :recordId
                    ];

                    return new ResourceAssignment(
                        assignment.Id,
                        assignment.Project__c,
                        assignment.Project__r.Name,
                        assignment.User__c,
                        assignment.Start_Date__c,
                        assignment.End_Date__c,
                        assignment.Hours_Per_Day__c
                    );
                }
                when else {
                    throw new CustomException('Unknown entity type.');
                }
            }
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled(cacheable=false)
    public static void updateProject(Id projectId, String name, Date startDate, Date endDate, String status, String colour) {
        try {
            Project__c project = new Project__c(Id = projectId);
            project.Name = name;
            project.Start_Date__c = startDate;
            project.End_Date__c = endDate;
            project.Status__c = status;
            project.Colour__c = colour;
            update project;
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled(cacheable=false)
    public static void saveAssignment(Id projectResourceAssignmentId, Id projectId, Id userId, Date startDate, Date endDate, Decimal hoursPerDay, String projectTeamRole) {
        try {
            Project_Resource_Assignment__c assignment = new Project_Resource_Assignment__c(Id = projectResourceAssignmentId);
            assignment.Project__c = projectId;
            assignment.User__c = userId;
            assignment.Start_Date__c = startDate;
            assignment.End_Date__c = endDate;
            assignment.Hours_Per_Day__c = hoursPerDay;
            upsert assignment;

            if (!String.isEmpty(projectTeamRole) && !isUserInProjectTeam(userId, projectId)) {
                Project_Team_Member__c member = new Project_Team_Member__c();
                member.Project__c = projectId;
                member.User__c = userId;
                member.Role__c = projectTeamRole;
                insert member;
            }
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled(cacheable=false)
    public static void updateAssignmentDates(Id id, Date startDate, Date endDate) {
        try {
            Project_Resource_Assignment__c assignment = new Project_Resource_Assignment__c(Id = id);
            assignment.Start_Date__c = startDate;
            assignment.End_Date__c = endDate;
            update assignment;
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

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

    @TestVisible
    private static Boolean isUserInProjectTeam(Id userId, Id projectId) {
        return [SELECT Id FROM Project_Team_Member__c WHERE User__c = :userId AND Project__c = :projectId].size() > 0;
    }

    public class CustomException extends Exception {
    }

    public class LeaveDate {
        @AuraEnabled
        public Date LeaveDate { get; private set; }

        @AuraEnabled
        public Boolean IsApproved { get; private set; }

        public LeaveDate(Date leaveDate, String status) {
            this.LeaveDate = LeaveDate;
            this.IsApproved = (status == LeaveRequestStatusNames.APPROVED);
        }
    }

    public class Project {
        @AuraEnabled
        public String Id { get; private set; }

        @AuraEnabled
        public String AccountId { get; private set; }

        @AuraEnabled
        public String AccountName { get; private set; }

        @AuraEnabled
        public String Name { get; private set; }

        @AuraEnabled
        public Date StartDate { get; private set; }

        @AuraEnabled
        public Date EndDate { get; private set; }

        @AuraEnabled
        public String Colour { get; private set; }

        @AuraEnabled
        public String Status { get; private set; }

        @AuraEnabled
        public List<Project_Resource_Assignment__c> ResourceAssignments { get; private set; }

        public Project(Id id, Id accountId, String accountName, String name, Date startDate, Date endDate, String colour, String status) {
            this.Id = id;
            this.AccountId = accountId;
            this.AccountName = accountName;
            this.Name = name;
            this.StartDate = startDate;
            this.EndDate = endDate;
            this.Colour = colour;
            this.Status = status;
            this.ResourceAssignments = new List<Project_Resource_Assignment__c>();
        }

        public void appendResourceAssignment(Project_Resource_Assignment__c resourceAssignment) {
            this.ResourceAssignments.add(resourceAssignment);
        }
    }

    public class ResourceAssignment {
        @AuraEnabled
        public Id Id { get; private set; }

        @AuraEnabled
        public Id ProjectId { get; private set; }

        @AuraEnabled
        public String ProjectName { get; private set; }

        @AuraEnabled
        public Id UserId { get; private set; }

        @AuraEnabled
        public Date StartDate { get; private set; }

        @AuraEnabled
        public Date EndDate { get; private set; }

        @AuraEnabled
        public Decimal HoursPerDay { get; private set; }

        public ResourceAssignment(Id id, Id projectId, String projectName, Id userId, Date startDate, Date endDate, Decimal hoursPerDay) {
            this.Id = id;
            this.ProjectId = projectId;
            this.ProjectName = projectName;
            this.UserId = userId;
            this.StartDate = startDate;
            this.EndDate = endDate;
            this.HoursPerDay = hoursPerDay;
        }
    }
}