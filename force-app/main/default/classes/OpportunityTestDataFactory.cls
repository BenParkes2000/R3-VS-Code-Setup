@isTest
public class OpportunityTestDataFactory {
    public static Opportunity create(String name, String stage, Date closeDate) {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = name;
        opportunity.StageName = stage;
        opportunity.CloseDate = closeDate;

        return opportunity;
    }

    public static Id create(Id accountId) {
        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.AccountId = accountId;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.Pricebook2Id = TEst.getStandardPricebookId();
        insert opp;
        return opp.Id;
    }
}