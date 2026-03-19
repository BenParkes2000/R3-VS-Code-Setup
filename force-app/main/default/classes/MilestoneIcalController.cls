@RestResource(urlMapping='/milestone-ical')
global without sharing class MilestoneIcalController {
    @HttpGet
    global static void doGet() {
        // Set response content type for iCal
        RestContext.response.addHeader('Content-Type', 'text/calendar; charset=UTF-8');
        
        // Allowed Project statuses
        Set<String> allowedStatuses = new Set<String>{
            'Planning', 'Kick off', 'Discovery', 'In Progress', 'UAT', 'Hyper care', 'Support'
        };
        
        // Get Milestone RecordTypeId
        Id milestoneRecordTypeId = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Phase__c' AND Name = 'Milestone' LIMIT 1
        ].Id;

        // Query future milestones related to projects in the correct statuses
        List<Phase__c> milestones = [
            SELECT Id, Name, Milestone_Date__c, Project__r.Status__c, Project__c, Project__r.Name
            FROM Phase__c
            WHERE RecordTypeId = :milestoneRecordTypeId
            AND Milestone_Date__c >= :Date.today()
            AND Project__r.Status__c IN :allowedStatuses
            ORDER BY Milestone_Date__c ASC
            LIMIT 1000
        ];

        System.debug('Found ' + milestones.size() + ' future milestones.');
        
        // Begin iCalendar
        String ical = 'BEGIN:VCALENDAR\r\n' +
                      'VERSION:2.0\r\n' +
                      'PRODID:-//YOUR-COMPANY//Milestone Calendar//EN\r\n'  +
                      'X-WR-CALNAME:R3 Milestone Calendar\r\n';

        for (Phase__c phase : milestones) {
            String uid = phase.Id + '@yourcompany.com';
            String dtStart = String.valueOf(phase.Milestone_Date__c.year())
                + pad2(phase.Milestone_Date__c.month())
                + pad2(phase.Milestone_Date__c.day());
            String summary = String.escapeSingleQuotes(phase.Project__r.Name + ': ' + phase.Name);
            String description = 'Project Status: ' + (phase.Project__r.Status__c != null ? phase.Project__r.Status__c : 'N/A');
            
            ical += 'BEGIN:VEVENT\r\n' +
                    'UID:' + uid + '\r\n' +
                    'DTSTAMP:' + DateTime.now().formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + '\r\n' +
                    'DTSTART;VALUE=DATE:' + dtStart + '\r\n' +
                    'SUMMARY:' + summary + '\r\n' +
                    'DESCRIPTION:' + description + '\r\n' +
                    'END:VEVENT\r\n';
        }

        ical += 'END:VCALENDAR\r\n';

        RestContext.response.responseBody = Blob.valueOf(ical);
    }

    private static String pad2(Integer i) {
        return (i < 10 ? '0' : '') + String.valueOf(i);
    }
}