// TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
@SuppressWarnings('PMD.ApexSharingViolations')
public class ProjectTeamMemberTestDataFactory {
  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public static Id create(Id projectId, Id userId) {
    Project_Team_Member__c member = new Project_Team_Member__c();
    member.Project__c = projectId;
    member.User__c = userId;
    member.Role__c = 'Developer';
    insert member;
    return member.Id;
  }
}