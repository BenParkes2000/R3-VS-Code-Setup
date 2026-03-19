@IsTest
private class MilestoneIcalControllerTest {

    // Helper for Milestone record type
    static Id ensureMilestoneRecordType() {
        return [SELECT Id FROM RecordType WHERE SObjectType = 'Phase__c' AND Name = 'Milestone' LIMIT 1].Id;
    }

    // Helper to create a Project__c with all required fields
    static Project__c createProject(String name, String status, Id accountId) {
        Project__c proj = new Project__c(
            Name = name,
            Account__c = accountId,
            Support_Type__c = 'MSA'
        );
        if (status != null) proj.Status__c = status;

        // Assume Start_Date__c and End_Date__c are required if status ≠ Backlog/Estimate
        if (status == null || (status != 'Backlog' && status != 'Estimate')) {
            proj.Start_Date__c = Date.today();
            proj.End_Date__c = Date.today().addDays(30);
        }
        insert proj;
        return proj;
    }

    @IsTest
    static void test_FutureMilestoneReturned() {
        // Create required Account
        Account acc = new Account(Name='Test Account');
        insert acc;

        Id rtId = ensureMilestoneRecordType();
        Project__c p = createProject('Test Project', 'Planning', acc.Id);

        Phase__c phase = new Phase__c(
            Name = 'Milestone Future',
            Milestone_Date__c = Date.today().addDays(7),
            RecordTypeId = rtId,
            Project__c = p.Id
        );
        insert phase;

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/milestone-ical';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        MilestoneIcalController.doGet();
        Test.stopTest();

        String ical = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
        System.assert(ical.contains('Milestone Future'));
        System.assert(ical.contains('Planning'));
        System.assert(ical.contains('BEGIN:VEVENT'));
        System.assert(ical.contains('SUMMARY:Test Project: Milestone Future'));
        System.assert(ical.contains('DESCRIPTION:Project Status: Planning'));
    }

    @IsTest
    static void test_ExcludePastAndWrongStatus() {
        // Create required Account
        Account acc = new Account(Name='Test Account 2');
        insert acc;

        Id rtId = ensureMilestoneRecordType();

        // Past date - should be excluded
        Project__c p1 = createProject('Past Project', 'Planning', acc.Id);
        Phase__c pastPhase = new Phase__c(
            Name = 'Milestone Past',
            Milestone_Date__c = Date.today().addDays(-10),
            RecordTypeId = rtId,
            Project__c = p1.Id
        );

        // Wrong status - should be excluded
        Project__c p2 = createProject('Closed Project', 'Complete', acc.Id);
        Phase__c wrongStatusPhase = new Phase__c(
            Name = 'Milestone Wrong Status',
            Milestone_Date__c = Date.today().addDays(7),
            RecordTypeId = rtId,
            Project__c = p2.Id
        );

        insert new List<Phase__c>{pastPhase, wrongStatusPhase};

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/milestone-ical';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        MilestoneIcalController.doGet();
        Test.stopTest();

        String ical = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
        System.assert(!ical.contains('Milestone Past'), 'Past event should not appear');
        System.assert(!ical.contains('Milestone Wrong Status'), 'Wrong status should not appear');
    }

    @IsTest
    static void test_NoResults() {
        // Remove all Phase__c for this test context (optional - ensures clean slate)
        List<Phase__c> allPhases = [SELECT Id FROM Phase__c];
        if (!allPhases.isEmpty()) delete allPhases;

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/milestone-ical';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        MilestoneIcalController.doGet();
        Test.stopTest();

        String ical = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
        System.assert(ical.startsWith('BEGIN:VCALENDAR'), 'Should start with VCALENDAR');
        System.assert(ical.endsWith('END:VCALENDAR\r\n'), 'Should end with END:VCALENDAR');
        System.assert(!ical.contains('BEGIN:VEVENT'), 'Should not contain any events');
    }

    @IsTest
    static void test_NullProjectStatus() {
        // Create required Account
        Account acc = new Account(Name='Test Account 3');
        insert acc;

        Id rtId = ensureMilestoneRecordType();
        Project__c p = createProject('NoStatus Project', null, acc.Id);
        Phase__c phase = new Phase__c(
            Name = 'Milestone No Status',
            Milestone_Date__c = Date.today().addDays(5),
            RecordTypeId = rtId,
            Project__c = p.Id
        );
        insert phase;

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/milestone-ical';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        MilestoneIcalController.doGet();
        Test.stopTest();

        String ical = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
        // Not in valid statuses, so event should not appear
        System.assert(!ical.contains('Milestone No Status'));
    }

    @IsTest
    static void test_BacklogOrEstimateRequiresNoDates() {
        // Create required Account
        Account acc = new Account(Name='Test Account 4');
        insert acc;

        Id rtId = ensureMilestoneRecordType();
        Project__c p = createProject('Backlog Project', 'Backlog', acc.Id);
        Phase__c phase = new Phase__c(
            Name = 'Milestone Backlog',
            Milestone_Date__c = Date.today().addDays(2),
            RecordTypeId = rtId,
            Project__c = p.Id
        );
        insert phase;

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/milestone-ical';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        MilestoneIcalController.doGet();
        Test.stopTest();

        String ical = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
        // Not in valid statuses, so event should not appear
        System.assert(!ical.contains('Milestone Backlog'));
    }
}