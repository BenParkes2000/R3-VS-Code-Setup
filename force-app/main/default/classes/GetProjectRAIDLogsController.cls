public with sharing class GetProjectRAIDLogsController {
  public List<Raid_Log__c> raidLogs;
  public Id projectId { get; set; }
  public String logType { get; set; }

  public Boolean getIsRaidLogsEmpty() {
    return (raidLogs == null || raidLogs.isEmpty());
  }

  public List<Raid_Log__c> getRaidLogs() {
    if (!Schema.sObjectType.Raid_Log__c.isAccessible()) {
      throw new CustomException(
        'You do not have permission to access Raid_Log__c records.'
      );
    }
    raidLogs = [
      SELECT Name, Status__c, Type__c, Rating__c
      FROM Raid_Log__c
      WHERE
        Status__c = 'Open'
        AND Type__c = :logType
        AND Project__c = :projectId
      ORDER BY Rating__c ASC
    ];
    return raidLogs;
  }

  public class CustomException extends Exception {
  }
}