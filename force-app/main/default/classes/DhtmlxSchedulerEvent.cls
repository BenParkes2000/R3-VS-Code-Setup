@SuppressWarnings(
  'PMD.FieldNamingConventions'
) // 3rd party names are not in our control
public with sharing class DhtmlxSchedulerEvent {
  @AuraEnabled
  public String color;

  @AuraEnabled
  public DateTime end_date;

  @AuraEnabled
  public String id;

  @AuraEnabled
  public String info;

  @AuraEnabled
  public Boolean is_billable;

  @AuraEnabled
  public Boolean readonly;

  @AuraEnabled
  public DateTime start_date;

  @AuraEnabled
  public String text;

  @AuraEnabled
  public String type;

  @AuraEnabled
  public String work_item_id;
}