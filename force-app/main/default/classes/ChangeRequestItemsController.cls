public with sharing class ChangeRequestItemsController {
  public Boolean hasWorkItems { get; private set; }
  public String currencySymbol { get; private set; }
  public List<LineItem> workItems { get; private set; }
  public ChangeRequestContract changeRequest { get; private set; }

  // Constructor
  public ChangeRequestItemsController() {
    Contract con = getContractDataForInitialisation();
    this.workItems = getWorkItems(con.Id);
    this.hasWorkItems = !this.workItems.isEmpty();
    this.currencySymbol = getCurrencySymbol(con.CurrencyIsoCode);
    this.changeRequest = getTotals(this.workItems);
  }

  private static String getCurrencySymbol(String currencyCode) {
    if (currencyCode == 'USD') {
      return '$';
    } else if (currencyCode == 'GBP') {
      return '£';
    } else if (currencyCode == 'EUR') {
      return '€';
    }

    return '';
  }

  private static Contract getContractDataForInitialisation() {
    Id idValue = getContractIdFromPageParams();

    List<Contract> contractList = [
      SELECT Id, CurrencyIsoCode
      FROM Contract
      WHERE Id = :idValue
      WITH SECURITY_ENFORCED
    ];

    if (contractList.isEmpty()) {
      throw new CustomException('Contract not found for ID: ' + idValue);
    }

    return contractList[0];
  }

  private static Id getContractIdFromPageParams() {
    Map<String, String> params = ApexPages.currentPage().getParameters();
    if (!params.containsKey('id') || String.isBlank(params.get('id'))) {
      throw new CustomException(
        'Id page parameter for ChangeRequestItemsController has not been set'
      );
    }

    Id idValue;

    try {
      idValue = Id.valueOf(params.get('id'));
    } catch (Exception e) {
      throw new CustomException(
        'Id page parameter for ChangeRequestItemsController is not a valid ID'
      );
    }
    if (idValue.getSObjectType() != Contract.SObjectType) {
      throw new CustomException(
        'Id page parameter for ChangeRequestItemsController is not a Contract ID'
      );
    }
    return idValue;
  }

  private static List<LineItem> getWorkItems(Id contractId) {
    List<LineItem> lineItemList = new List<LineItem>();

    for (Work_Item__c workItem : [
      SELECT Subject__c, Est_Time__c
      FROM Work_Item__c
      WHERE Contract__c = :contractId
      WITH SECURITY_ENFORCED
      ORDER BY Subject__c
    ]) {
      LineItem lineItem = new LineItem();
      lineItem.subject = workItem.Subject__c;
      lineItem.unitPrice = 125;
      lineItem.estHours = workItem.Est_Time__c;
      lineItem.totalPrice = (lineItem.unitPrice * lineItem.estHours);

      lineItemList.add(lineItem);
    }

    return lineItemList;
  }

  private static ChangeRequestContract getTotals(List<LineItem> lineItemList) {
    ChangeRequestContract changeRequest = new ChangeRequestContract();
    changeRequest.totalHours = 0;
    changeRequest.TotalPrice = 0;

    for (LineItem li : lineItemList) {
      changeRequest.totalHours += li.estHours;
      changeRequest.totalPrice += (li.unitPrice * li.estHours);
    }

    return changeRequest;
  }

  public Integer year {
    get {
      return System.today().year();
    }
  }

  public class CustomException extends Exception {
  }

  public class LineItem {
    @AuraEnabled
    public String subject { get; set; }

    @AuraEnabled
    public Decimal unitPrice { get; set; }

    @AuraEnabled
    public Decimal estHours { get; set; }

    @AuraEnabled
    public Decimal totalPrice { get; set; }
  }

  public class ChangeRequestContract {
    @AuraEnabled
    public Decimal totalHours { get; set; }

    @AuraEnabled
    public Decimal totalPrice { get; set; }
  }
}