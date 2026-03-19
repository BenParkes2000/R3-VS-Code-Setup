@isTest(isParallel=true)
public class LookupControllerTest {
    @isTest
    static void test_search_should_return_work_item() {
        List<Id> fixedResults = new List<Id>(1);
        Id workItemId = createWorkItem();
        fixedResults.add(workItemId);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();

        List<LookupSearchResult> results = LookupController.search('wor', selectedIds);

        System.assertEquals(1, results.size());
        System.assertEquals(workItemId, results.get(0).getId());
    }

    @isTest
    static void test_search_should_not_return_work_item() {
        List<Id> fixedResults = new List<Id>(0);
        Id workItemId = createWorkItem();
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();

        List<LookupSearchResult> results = LookupController.search('foo', selectedIds);

        System.assertEquals(0, results.size());
    }

    private static Id createWorkItem() {
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);
        Id featureId = ProjectFeatureTestDataFactory.create(projectId);

        return WorkItemTestDataFactory.create(projectId, featureId, 'In Progress', '');
    }
}