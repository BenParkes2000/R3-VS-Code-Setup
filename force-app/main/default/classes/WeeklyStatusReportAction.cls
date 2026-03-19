global class WeeklyStatusReportAction {
    @InvocableMethod(label='Save Weekly Status Reports')
    global static void saveWeeklyStatusReports(List<Id> meetingIds) {
        List<ContentVersion> contentVersionsToAdd = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinksToAdd = new List<ContentDocumentLink>();
        Map<String, Id> pathToMeetingIdMap = new Map<String, Id>();

        List<Project_Meeting__c> meetingList = [SELECT Id, Name, Project__c, Project__r.Name FROM Project_Meeting__c WHERE Id IN :meetingIds];

        if (meetingList.size() == 0) {
            return;
        }

        String reportDate = Datetime.now().format('yyyy-MM-dd');

        for (Project_Meeting__c meeting : meetingList) {
            PageReference pageRef = Page.WeeklyStatusReport;
            pageRef.getParameters().put('id', meeting.Project__c);
            pageRef.setRedirect(true);

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S';
            contentVersion.PathOnClient = 'weekly-status-report-' + meeting.Name + '-' + reportDate + '.pdf';
            contentVersion.Title = 'Weekly Status Report - ' + meeting.Project__r.Name + ' - ' + reportDate;

            if (Test.isRunningTest()) {
                contentVersion.VersionData = Blob.valueOf('Test');
            } else {
                contentVersion.VersionData = pageRef.getContent();
            }

            contentVersionsToAdd.add(contentVersion);
            pathToMeetingIdMap.put(contentVersion.PathOnClient, meeting.Id);
        }

        insert contentVersionsToAdd;

        Set<Id> contentVersionIds = new Set<Id>();

        for (ContentVersion contentVersion : contentVersionsToAdd) {
            contentVersionIds.add(contentVersion.Id);
        }

        List<ContentVersion> contentVersionList = [SELECT PathOnClient, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds];

        for (ContentVersion contentVersion : contentVersionList) {
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.LinkedEntityId = pathToMeetingIdMap.get(contentVersion.PathOnClient);
            contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
            contentDocumentLink.shareType = 'V';

            contentDocumentLinksToAdd.add(contentDocumentLink);
        }

        insert contentDocumentLinksToAdd;
    }
}