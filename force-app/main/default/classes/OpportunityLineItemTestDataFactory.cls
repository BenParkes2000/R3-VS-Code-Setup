@isTest
public class OpportunityLineItemTestDataFactory {
    public static Id create(Id opportunityId, Id productId) {
        OpportunityLineItem lineItem = new OpportunityLineItem();
        lineItem.OpportunityId = opportunityId;
        lineItem.Quantity = 1;
        lineItem.Product2Id = productId;
        lineItem.TotalPrice = 1;
        insert lineItem;
        return lineItem.Id;
    }
}