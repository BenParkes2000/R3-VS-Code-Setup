@isTest
public class ResourceManagementChartControllerTest {
    @isTest
    public static void test_project_append_resource_assignment() {
        // Arrange
        ResourceManagementChartController.Project project = new ResourceManagementChartController.Project(
            '000000000000000AAA',
            '000000000000000AAB',
            'Acme',
            'Website',
            Date.today(),
            Date.today(),
            ProjectColourNames.GREEN,
            ProjectStatusNames.InProgress
        );

        // Act
        project.appendResourceAssignment(new Project_Resource_Assignment__c());

        // Assert
        System.assertEquals(1, project.ResourceAssignments.size());
    }

    @isTest
    public static void test_get_projects() {
        // Arrange
        final Date START_DATE = Date.newInstance(2021, 10, 28);
        final Date END_DATE = Date.newInstance(2021, 11, 2);

        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        Id account1Id = AccountTestDataFactory.create('Acme');
        Id account2Id = AccountTestDataFactory.create('Trek Travel');
        Id project1Id = ProjectTestDataFactory.create(account1Id, 'Sales', ProjectStatusNames.InProgress, START_DATE, END_DATE);
        Id project2Id = ProjectTestDataFactory.create(account2Id, 'Website', ProjectStatusNames.InProgress, START_DATE, END_DATE); // No resources, but should still be included
        Id project3Id = ProjectTestDataFactory.create(account2Id, 'Complete', ProjectStatusNames.Complete, START_DATE, END_DATE); // Not active, so should be omitted
        Id resourceId = ProjectResourceAssignmentTestDataFactory.create(project1Id, user.Id, START_DATE, END_DATE, 4);

        Project__c project1 = new Project__c(Id = project1Id);
        project1.Colour__c = ProjectColourNames.GREEN;
        update project1;

        // Act
        List<ResourceManagementChartController.Project> projectList = ResourceManagementChartController.getProjects(START_DATE, null, new List<String>(), new List<Id>());

        // Assert
        System.assertEquals(2, projectList.size());
        System.assertEquals(project1Id, projectList[0].Id);
        System.assertEquals(account1Id, projectList[0].AccountId);
        System.assertEquals('Acme', projectList[0].AccountName);
        System.assertEquals('Sales', projectList[0].Name);
        System.assertEquals(START_DATE, projectList[0].StartDate);
        System.assertEquals(END_DATE, projectList[0].EndDate);
        System.assertEquals(ProjectColourNames.GREEN, projectList[0].Colour);
        System.assertEquals(ProjectStatusNames.InProgress, projectList[0].Status);
        System.assertEquals(1, projectList[0].ResourceAssignments.size());
        System.assertEquals(resourceId, projectList[0].ResourceAssignments[0].Id);
        System.assertEquals(project2Id, projectList[1].Id);
        System.assertEquals(account2Id, projectList[1].AccountId);
        System.assertEquals(0, projectList[1].ResourceAssignments.size());
    }

    @isTest
    public static void test_get_resource_assignments_mapped_by_project() {
        // Arrange
        final Date START_DATE = Date.newInstance(2021, 10, 28);
        final Date END_DATE = Date.newInstance(2021, 11, 2);

        User user1 = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        User user2 = UserTestDataFactory.create('mdennis@r3.digital.invalid', 'Mick', 'Dennis');
        List<Id> userList = new List<Id>();
        userList.add(user1.Id);
        userList.add(user2.Id);

        Id account1Id = AccountTestDataFactory.create('Acme');
        Id account2Id = AccountTestDataFactory.create('Trek Travel');

        Id project1Id = ProjectTestDataFactory.create(account1Id, 'Sales', ProjectStatusNames.InProgress, START_DATE, END_DATE);
        Id project2Id = ProjectTestDataFactory.create(account2Id, 'Website', ProjectStatusNames.InProgress, START_DATE, END_DATE); // No resources, but should still be included

        Id resource1Id = ProjectResourceAssignmentTestDataFactory.create(project1Id, user1.Id, START_DATE, END_DATE, 4);
        Id resource2Id = ProjectResourceAssignmentTestDataFactory.create(project2Id, user1.Id, START_DATE, END_DATE, 4);
        Id resource3Id = ProjectResourceAssignmentTestDataFactory.create(project2Id, user2.Id, START_DATE, END_DATE, 4);

        // Act
        Map<Id, List<Project_Resource_Assignment__c>> resourceMap = ResourceManagementChartController.getResourceAssignmentsMappedByProject(
            START_DATE,
            END_DATE,
            new List<String>(ResourceManagementChartController.ACTIVE_STATUSES),
            userList
        );

        // Assert
        System.assertEquals(2, resourceMap.size());
        System.assert(resourceMap.containsKey(project1Id));
        System.assert(resourceMap.containsKey(project2Id));
        System.assertEquals(1, resourceMap.get(project1Id).size());
        System.assertEquals(2, resourceMap.get(project2Id).size());
    }

    @isTest
    public static void test_get_users() {
        // Arrange
        User user1 = UserTestDataFactory.create('rtenny@r3.digital.invalid', 'Rhea', 'Tenny');
        User user2 = UserTestDataFactory.create('keriksen@r3.digital.invalid', 'Kara', 'Eriksen');
        User user3 = UserTestDataFactory.create('tnelson@r3.digital.invalid', 'Trina', 'Nelson'); // Not resource assignable

        user3.Is_Resource_Assignable__c = false;
        update user3;

        // Act
        List<User> userList = ResourceManagementChartController.getUsers();

        // Assert
        Boolean user1Found = false;
        Boolean user2Found = false;
        Boolean user3Found = false;

        for (User user : userList) {
            if (user.Id == user1.Id) {
                user1Found = true;
            } else if (user.Id == user2.Id) {
                user2Found = true;
            } else if (user.Id == user3.Id) {
                user3Found = true;
            }
        }

        System.assertEquals(true, user1Found);
        System.assertEquals(true, user2Found);
        System.assertEquals(false, user3Found);
    }

    @isTest
    public static void test_get_leave_dates() {
        // Arrange
        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        Id leaveSummaryId = LeaveSummaryTestDataFactory.create(user.Id, '2021', Date.newInstance(2021, 1, 1), Date.newInstance(2021, 12, 31));
        Id leaveRequest1Id = LeaveRequestTestDataFactory.create(leaveSummaryId, Date.newInstance(2021, 1, 4), 2, LeaveRequestStatusNames.DRAFT); // Not included
        Id leaveRequest2Id = LeaveRequestTestDataFactory.create(leaveSummaryId, Date.newInstance(2021, 4, 5), 2, LeaveRequestStatusNames.SUBMITTED);
        Id leaveRequest3Id = LeaveRequestTestDataFactory.create(leaveSummaryId, Date.newInstance(2021, 7, 5), 2, LeaveRequestStatusNames.APPROVED);

        // Act
        Map<Id, List<ResourceManagementChartController.LeaveDate>> leaveDatesMap = ResourceManagementChartController.getLeaveDates();

        // Assert
        System.assertEquals(1, leaveDatesMap.size());
        System.assertEquals(4, leaveDatesMap.get(user.Id).size());
        System.assertEquals(Date.newInstance(2021, 4, 5), leaveDatesMap.get(user.Id)[0].LeaveDate);
        System.assertEquals(false, leaveDatesMap.get(user.Id)[0].IsApproved);
        System.assertEquals(Date.newInstance(2021, 4, 6), leaveDatesMap.get(user.Id)[1].LeaveDate);
        System.assertEquals(false, leaveDatesMap.get(user.Id)[1].IsApproved);
        System.assertEquals(Date.newInstance(2021, 7, 5), leaveDatesMap.get(user.Id)[2].LeaveDate);
        System.assertEquals(true, leaveDatesMap.get(user.Id)[2].IsApproved);
        System.assertEquals(Date.newInstance(2021, 7, 6), leaveDatesMap.get(user.Id)[3].LeaveDate);
        System.assertEquals(true, leaveDatesMap.get(user.Id)[3].IsApproved);
    }

    @isTest
    public static void test_get_user_preferences() {
        // Arrange
        final String COLUMNS = 'column1;column2';
        final String EXPANDED_IDS = '1;3;5;7;9';
        final String SCALE = 'month';

        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        user.Resource_Management_Columns__c = COLUMNS;
        user.Resource_Management_Expanded_IDs__c = EXPANDED_IDS;
        user.Resource_Management_Scale__c = SCALE;
        update user;

        // Act
        User preferences;

        System.runAs(user) {
            preferences = ResourceManagementChartController.getUserPreferences();
        }

        // Assert
        System.assertEquals(COLUMNS, preferences.Resource_Management_Columns__c);
        System.assertEquals(EXPANDED_IDS, preferences.Resource_Management_Expanded_IDs__c);
        System.assertEquals(SCALE, preferences.Resource_Management_Scale__c);
    }

    @isTest
    public static void test_get_project_details() {
        // Arrange
        final String ACCOUNT_NAME = 'Acme';
        final String PROJECT_NAME = 'Sales';
        final Date START_DATE = Date.newInstance(2021, 10, 28);
        final Date END_DATE = Date.newInstance(2021, 11, 2);

        Id accountId = AccountTestDataFactory.create(ACCOUNT_NAME);
        Id projectId = ProjectTestDataFactory.create(accountId, PROJECT_NAME, ProjectStatusNames.InProgress, START_DATE, END_DATE);

        // Act
        Test.startTest();
        ResourceManagementChartController.Project project = ResourceManagementChartController.getProjectDetails(projectId);
        Test.stopTest();

        // Assert
        System.assertEquals(projectId, project.Id);
        System.assertEquals(accountId, project.AccountId);
        System.assertEquals(ACCOUNT_NAME, project.AccountName);
        System.assertEquals(PROJECT_NAME, project.Name);
        System.assertEquals(START_DATE, project.StartDate);
        System.assertEquals(END_DATE, project.EndDate);
        System.assertEquals(ProjectColourNames.RED, project.Colour);
        System.assertEquals(ProjectStatusNames.InProgress, project.Status);
    }

    @isTest
    public static void test_get_assignment_details_new() {
        // Arrange
        final Date START_DATE = Date.newInstance(2021, 10, 28);
        final Date END_DATE = Date.newInstance(2021, 11, 2);

        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        Id accountId = AccountTestDataFactory.create('Acme');
        Id projectId = ProjectTestDataFactory.create(accountId, 'Sales', ProjectStatusNames.InProgress, START_DATE, END_DATE);

        // Act
        ResourceManagementChartController.ResourceAssignment assignment = ResourceManagementChartController.getAssignmentDetails(projectId);

        // Assert
        System.assertEquals(null, assignment.Id);
        System.assertEquals(projectId, assignment.ProjectId);
        System.assertEquals('Sales', assignment.ProjectName);
        System.assertEquals(null, assignment.UserId);
        System.assertEquals(START_DATE, assignment.StartDate);
        System.assertEquals(END_DATE, assignment.EndDate);
        System.assertEquals(null, assignment.HoursPerDay);
    }

    @isTest
    public static void test_get_assignment_details_existing() {
        // Arrange
        final Date START_DATE = Date.newInstance(2021, 10, 28);
        final Date END_DATE = Date.newInstance(2021, 11, 2);

        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        Id accountId = AccountTestDataFactory.create('Acme');
        Id projectId = ProjectTestDataFactory.create(accountId, 'Sales', ProjectStatusNames.InProgress, START_DATE, END_DATE);
        Id resourceId = ProjectResourceAssignmentTestDataFactory.create(projectId, user.Id, START_DATE, END_DATE, 4);

        // Act
        ResourceManagementChartController.ResourceAssignment assignment = ResourceManagementChartController.getAssignmentDetails(resourceId);

        // Assert
        System.assertEquals(resourceId, assignment.Id);
        System.assertEquals(projectId, assignment.ProjectId);
        System.assertEquals('Sales', assignment.ProjectName);
        System.assertEquals(user.Id, assignment.UserId);
        System.assertEquals(START_DATE, assignment.StartDate);
        System.assertEquals(END_DATE, assignment.EndDate);
        System.assertEquals(4, assignment.HoursPerDay);
    }

    @isTest
    public static void test_get_assignment_details_exception() {
        // Arrange
        Id accountId = AccountTestDataFactory.create('Acme');

        try {
            // Act
            ResourceManagementChartController.getAssignmentDetails(accountId);
        } catch (AuraHandledException e) {
            // Assert
            System.assertEquals('Unknown entity type.', e.getMessage());
            return;
        }

        // If we get here, the test has failed
        System.assert(false);
    }

    @isTest
    public static void test_update_project() {
        // Arrange
        final String NAME_BEFORE = 'Sales';
        final String STATUS_BEFORE = ProjectStatusNames.InProgress;
        final Date START_DATE_BEFORE = Date.newInstance(2021, 10, 28);
        final Date END_DATE_BEFORE = Date.newInstance(2021, 11, 2);
        final String COLOUR_BEFORE = ProjectColourNames.BLUE;

        final String NAME_AFTER = 'Sales v2';
        final String STATUS_AFTER = ProjectStatusNames.Uat;
        final Date START_DATE_AFTER = Date.newInstance(2021, 11, 28);
        final Date END_DATE_AFTER = Date.newInstance(2021, 12, 2);
        final String COLOUR_AFTER = ProjectColourNames.RED;

        Id accountId = AccountTestDataFactory.create('Acme');
        Id projectId = ProjectTestDataFactory.create(accountId, NAME_BEFORE, STATUS_BEFORE, START_DATE_BEFORE, END_DATE_BEFORE);
        Project__c project = new Project__c(Id = projectId);
        project.Colour__c = COLOUR_BEFORE;
        update project;

        // Act
        Test.startTest();
        ResourceManagementChartController.updateProject(projectId, NAME_AFTER, START_DATE_AFTER, END_DATE_AFTER, STATUS_AFTER, COLOUR_AFTER);
        Test.stopTest();

        // Assert
        List<Project__c> projectList = [SELECT Name, Start_Date__c, End_Date__c, Status__c, Colour__c FROM Project__c WHERE Id = :projectId];

        System.assertEquals(NAME_AFTER, projectList[0].Name);
        System.assertEquals(START_DATE_AFTER, projectList[0].Start_Date__c);
        System.assertEquals(END_DATE_AFTER, projectList[0].End_Date__c);
        System.assertEquals(STATUS_AFTER, projectList[0].Status__c);
        System.assertEquals(COLOUR_AFTER, projectList[0].Colour__c);
    }

    @isTest
    public static void test_save_assignment_new() {
        // Arrange
        final Date START_DATE = Date.newInstance(2021, 10, 28);
        final Date END_DATE = Date.newInstance(2021, 11, 2);
        final Decimal HOURS_PER_DAY = 4;

        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        Id accountId = AccountTestDataFactory.create('Acme');
        Id projectId = ProjectTestDataFactory.create(accountId, 'Sales', ProjectStatusNames.InProgress, START_DATE, END_DATE);

        // Act
        Test.startTest();
        ResourceManagementChartController.saveAssignment(null, projectId, user.Id, START_DATE, END_DATE, HOURS_PER_DAY, null);
        Test.stopTest();

        // Assert
        List<Project_Resource_Assignment__c> assignmentList = [
            SELECT Start_Date__c, End_Date__c, Hours_Per_Day__c
            FROM Project_Resource_Assignment__c
            WHERE Project__c = :projectId AND User__c = :user.Id
        ];

        System.assertEquals(1, assignmentList.size());
        System.assertEquals(START_DATE, assignmentList[0].Start_Date__c);
        System.assertEquals(END_DATE, assignmentList[0].End_Date__c);
        System.assertEquals(HOURS_PER_DAY, assignmentList[0].Hours_Per_Day__c);
    }

    @isTest
    public static void test_save_assignment_existing() {
        // Arrange
        final Date START_DATE_BEFORE = Date.newInstance(2021, 10, 28);
        final Date END_DATE_BEFORE = Date.newInstance(2021, 11, 2);
        final Decimal HOURS_PER_DAY_BEFORE = 4;

        final Date START_DATE_AFTER = Date.newInstance(2021, 11, 28);
        final Date END_DATE_AFTER = Date.newInstance(2021, 12, 2);
        final Decimal HOURS_PER_DAY_AFTER = 6;

        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        Id accountId = AccountTestDataFactory.create('Acme');
        Id projectId = ProjectTestDataFactory.create(accountId, 'Sales', ProjectStatusNames.InProgress, START_DATE_BEFORE, END_DATE_BEFORE);
        Id assignmentId = ProjectResourceAssignmentTestDataFactory.create(projectId, user.Id, START_DATE_BEFORE, END_DATE_BEFORE, HOURS_PER_DAY_BEFORE);

        // Act
        Test.startTest();
        ResourceManagementChartController.saveAssignment(assignmentId, projectId, user.Id, START_DATE_AFTER, END_DATE_AFTER, HOURS_PER_DAY_AFTER, null);
        Test.stopTest();

        // Assert
        List<Project_Resource_Assignment__c> assignmentList = [SELECT Project__c, User__c, Start_Date__c, End_Date__c, Hours_Per_Day__c FROM Project_Resource_Assignment__c WHERE Id = :assignmentId];

        System.assertEquals(projectId, assignmentList[0].Project__c);
        System.assertEquals(user.Id, assignmentList[0].User__c);
        System.assertEquals(START_DATE_AFTER, assignmentList[0].Start_Date__c);
        System.assertEquals(END_DATE_AFTER, assignmentList[0].End_Date__c);
        System.assertEquals(HOURS_PER_DAY_AFTER, assignmentList[0].Hours_Per_Day__c);
    }

    @isTest
    public static void test_save_assignment_with_role() {
        // Arrange
        final Date START_DATE = Date.newInstance(2021, 10, 28);
        final Date END_DATE = Date.newInstance(2021, 11, 2);
        final Decimal HOURS_PER_DAY = 4;
        final String ROLE = 'Consultant';

        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        Id accountId = AccountTestDataFactory.create('Acme');
        Id projectId = ProjectTestDataFactory.create(accountId, 'Sales', ProjectStatusNames.InProgress, START_DATE, END_DATE);
        Id assignmentId = ProjectResourceAssignmentTestDataFactory.create(projectId, user.Id, START_DATE, END_DATE, HOURS_PER_DAY);

        // Act
        Test.startTest();
        ResourceManagementChartController.saveAssignment(assignmentId, projectId, user.Id, START_DATE, END_DATE, HOURS_PER_DAY, ROLE);
        Test.stopTest();

        // Assert
        List<Project_Team_Member__c> memberList = [SELECT Id FROM Project_Team_Member__c WHERE Project__c = :projectId AND User__c = :user.Id AND Role__c = :ROLE];
        System.assertEquals(1, memberList.size());
    }

    @isTest
    public static void test_update_assignment_dates() {
        // Arrange
        final Date START_DATE_BEFORE = Date.newInstance(2021, 10, 28);
        final Date END_DATE_BEFORE = Date.newInstance(2021, 11, 2);

        final Date START_DATE_AFTER = Date.newInstance(2021, 11, 28);
        final Date END_DATE_AFTER = Date.newInstance(2021, 12, 2);

        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        Id accountId = AccountTestDataFactory.create('Acme');
        Id projectId = ProjectTestDataFactory.create(accountId, 'Sales', ProjectStatusNames.InProgress, START_DATE_BEFORE, END_DATE_BEFORE);
        Id assignmentId = ProjectResourceAssignmentTestDataFactory.create(projectId, user.Id, START_DATE_BEFORE, END_DATE_BEFORE, 4);

        // Act
        Test.startTest();
        ResourceManagementChartController.updateAssignmentDates(assignmentId, START_DATE_AFTER, END_DATE_AFTER);
        Test.stopTest();

        // Assert
        List<Project_Resource_Assignment__c> assignmentList = [SELECT Start_Date__c, End_Date__c FROM Project_Resource_Assignment__c WHERE Id = :assignmentId];

        System.assertEquals(START_DATE_AFTER, assignmentList[0].Start_Date__c);
        System.assertEquals(END_DATE_AFTER, assignmentList[0].End_Date__c);
    }

    @isTest
    public static void test_update_user_columns() {
        // Arrange
        final String COLUMNS = 'column1;column2';
        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');

        // Act
        System.runAs(user) {
            ResourceManagementChartController.updateUserColumns(COLUMNS);
        }

        // Assert
        System.assertEquals(COLUMNS, [SELECT Resource_Management_Columns__c FROM User WHERE Id = :user.Id].Resource_Management_Columns__c);
    }

    @isTest
    public static void test_update_user_expanded_ids() {
        // Arrange
        final String EXPANDED_IDS = '1;3;5;7;9';
        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');

        // Act
        System.runAs(user) {
            ResourceManagementChartController.updateUserExpandedIds(EXPANDED_IDS);
        }

        // Assert
        System.assertEquals(EXPANDED_IDS, [SELECT Resource_Management_Expanded_IDs__c FROM User WHERE Id = :user.Id].Resource_Management_Expanded_IDs__c);
    }

    @isTest
    public static void test_update_user_scale() {
        // Arrange
        final String SCALE = 'month';
        User user = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');

        // Act
        System.runAs(user) {
            ResourceManagementChartController.updateUserScale(SCALE);
        }

        // Assert
        System.assertEquals(SCALE, [SELECT Resource_Management_Scale__c FROM User WHERE Id = :user.Id].Resource_Management_Scale__c);
    }

    @isTest
    public static void test_is_user_in_project_team() {
        // Arrange
        User user1 = UserTestDataFactory.create('iwatson@r3.digital.invalid', 'Ivor', 'Watson');
        User user2 = UserTestDataFactory.create('mdennis@r3.digital.invalid', 'Mick', 'Dennis');
        Id accountId = AccountTestDataFactory.create('Acme');
        Id projectId = ProjectTestDataFactory.create(accountId);
        Id memberId = ProjectTeamMemberTestDataFactory.create(projectId, user1.Id);

        // Act
        Boolean isUser1InProjectTeam = ResourceManagementChartController.isUserInProjectTeam(user1.Id, projectId);
        Boolean isUser2InProjectTeam = ResourceManagementChartController.isUserInProjectTeam(user2.Id, projectId);

        // Assert
        System.assertEquals(true, isUser1InProjectTeam);
        System.assertEquals(false, isUser2InProjectTeam);
    }
}