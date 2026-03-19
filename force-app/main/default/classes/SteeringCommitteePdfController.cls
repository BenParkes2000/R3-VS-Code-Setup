public without sharing class SteeringCommitteePdfController {
    public Account account { get; private set; }
    public List<ProjectTransformer> projects { get; private set; }
    public Id clientLogoId { get; private set; }
    public Id programPlanId { get; private set; }
    public List<RAID_Log__c> actions { get; private set; }
    public List<RAID_Log__c> decisions { get; private set; }
    public List<RAID_Log__c> issues { get; private set; }
    public List<RAID_Log__c> risks { get; private set; }

    public SteeringCommitteePdfController() {
        Id accountId = ApexPages.currentPage().getParameters().get('id');
        this.account = this.getAccount(accountId);
        this.cacheAccountImageIds();
        this.collateProjects();
        this.collateRaidLogs();
    }

    private Account getAccount(Id accountId) {
        List<String> projectStatuses = new List<String>{ ProjectStatusNames.Estimate, ProjectStatusNames.KickOff, ProjectStatusNames.InProgress, ProjectStatusNames.Uat, ProjectStatusNames.HyperCare };

        List<Account> accountList = [
            SELECT Id, Executive_Summary__c, (SELECT Id, Name, Status__c, Sponsor__r.Name FROM Projects_R3__r WHERE Status__c IN :projectStatuses)
            FROM Account
            WHERE Id = :accountId
        ];

        if (accountList.size() == 0) {
            throw new CustomException('Unable to find account with ID: ' + accountId);
        }

        return accountList[0];
    }

    private void cacheAccountImageIds() {
        List<ContentDocumentLink> documentLinks = [
            SELECT ContentDocument.Title, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :this.account.Id AND ContentDocument.Title IN ('client-logo', 'program-plan') AND ContentDocument.FileType = 'PNG'
        ];

        for (ContentDocumentLink documentLink : documentLinks) {
            Id versionId = documentLink.ContentDocument.LatestPublishedVersionId;

            if (documentLink.ContentDocument.Title == 'client-logo') {
                this.clientLogoId = versionId;
            } else if (documentLink.ContentDocument.Title == 'program-plan') {
                this.programPlanId = versionId;
            }
        }
    }

    private Map<Id, Id> getProjectGanttMap() {
        List<Id> projectIds = this.getProjectIds();

        if (projectIds.isEmpty()) {
            return new Map<Id, Id>();
        }

        List<ContentDocumentLink> documentLinks = [
            SELECT LinkedEntityId, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :projectIds AND ContentDocument.Title IN ('project-plan') AND ContentDocument.FileType = 'PNG'
        ];

        Map<Id, Id> projectGanttMap = new Map<Id, Id>();

        for (ContentDocumentLink documentLink : documentLinks) {
            projectGanttMap.put(documentLink.LinkedEntityId, documentLink.ContentDocument.LatestPublishedVersionId);
        }

        return projectGanttMap;
    }

    private void collateProjects() {
        this.projects = new List<ProjectTransformer>();
        Map<Id, Id> projectGanttMap = this.getProjectGanttMap();
        List<Phase__c> phases = [SELECT Project__c, Name, End_Date__c, Status__c, Notes__c FROM Phase__c WHERE Project__c IN :this.getProjectIds() ORDER BY Project__c, Sort_Order__c];
        Map<Id, List<Phase__c>> projectPhaseMap = new Map<Id, List<Phase__c>>();

        for (Phase__c phase : phases) {
            if (!projectPhaseMap.containsKey(phase.Project__c)) {
                projectPhaseMap.put(phase.Project__c, new List<Phase__c>());
            }

            projectPhaseMap.get(phase.Project__c).add(phase);
        }

        for (Project__c project : this.account.Projects_R3__r) {
            ProjectTransformer transformer = new ProjectTransformer();
            transformer.Name = project.Name;
            transformer.Status = project.Status__c;
            transformer.Sponsor = project.Sponsor__r.Name;

            if (projectGanttMap.containsKey(project.Id)) {
                transformer.ProjectPlanId = projectGanttMap.get(project.Id);
            }

            if (projectPhaseMap.containsKey(project.Id)) {
                transformer.Milestones = projectPhaseMap.get(project.Id);
            }

            this.projects.add(transformer);
        }
    }

    private void collateRaidLogs() {
        List<RAID_Log__c> raidLogs = [
            SELECT Id, CreatedDate, Impact__c, Mitigation_Resolution__c, Rating__c, RecordTypeId, Status__c, Subject__c, Update__c, When__c, Assign_To__r.Name
            FROM RAID_Log__c
            WHERE Project__c IN :this.getProjectIds() AND Status__c IN (:RaidLogStatusNames.Open, :RaidLogStatusNames.Closed)
            ORDER BY When__c, CreatedDate
        ];

        Set<String> actionRatings = new Set<String>{ RaidLogRatingNames.Critical, RaidLogRatingNames.Strategic };

        this.actions = new List<RAID_Log__c>();
        this.decisions = new List<RAID_Log__c>();
        this.issues = new List<RAID_Log__c>();
        this.risks = new List<RAID_Log__c>();

        for (RAID_Log__c log : raidLogs) {
            if (log.RecordTypeId == RaidLogUtils.getActionRecordTypeId && log.Rating__c == RaidLogRatingNames.Strategic) {
                this.actions.add(log);
            } else if (log.RecordTypeId == RaidLogUtils.getDecisionRecordTypeId && log.Status__c == RaidLogStatusNames.Open) {
                this.decisions.add(log);
            } else if (log.RecordTypeId == RaidLogUtils.getIssueRecordTypeId && log.Status__c == RaidLogStatusNames.Open && actionRatings.contains(log.Rating__c)) {
                this.issues.add(log);
            } else if (log.RecordTypeId == RaidLogUtils.getRiskRecordTypeId && log.Status__c == RaidLogStatusNames.Open) {
                this.risks.add(log);
            }
        }
    }

    private List<Id> getProjectIds() {
        List<Id> projectIds = new List<Id>();

        for (Project__c project : this.account.Projects_R3__r) {
            projectIds.add(project.Id);
        }

        return projectIds;
    }

    public class CustomException extends Exception {
    }

    public class ProjectTransformer {
        public String Name { get; set; }
        public String Status { get; set; }
        public String Sponsor { get; set; }
        public Id ProjectPlanId { get; set; }
        public List<Phase__c> Milestones { get; set; }
    }
}