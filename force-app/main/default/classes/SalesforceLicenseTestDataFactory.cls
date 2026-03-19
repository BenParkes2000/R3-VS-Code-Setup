// TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
@SuppressWarnings('PMD.ApexSharingViolations')
public class SalesforceLicenseTestDataFactory {
  public static Id create(Id projectId, Id accountId) {
    return create(projectId, accountId, 'Salesforce Platform');
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public static Id create(Id projectId, Id accountId, String licenceType) {
    Salesforce_License__c licence = new Salesforce_License__c();
    licence.Project__c = projectId;
    licence.Account__c = accountId;
    licence.License__c = licenceType;
    licence.Quantity__c = 10;
    insert licence;

    return licence.Id;
  }
}