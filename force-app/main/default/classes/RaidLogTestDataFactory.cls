public class RaidLogTestDataFactory {
  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public static RAID_Log__c create(
    Id projectId,
    Id recordTypeId,
    String status,
    String rating
  ) {
    RAID_Log__c log = new RAID_Log__c();
    log.Project__c = projectId;
    log.RecordTypeId = recordTypeId;
    log.Status__c = status;
    log.Rating__c = rating;

    return log;
  }
}