/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_gazela_xero_InvoiceTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_gazela_xero_InvoiceTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new gazela_xero__Invoice__c());
    }
}