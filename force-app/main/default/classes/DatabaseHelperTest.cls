@isTest
public class DatabaseHelperTest {
    @isTest
    static void testLogSaveResultErrors_NoErrors() {
        // Arrange
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };

        // Perform a successful DML operation
        Database.SaveResult[] saveResults;
        Test.startTest();
        saveResults = Database.insert(accounts, false);
        Test.stopTest();

        // Act
        DatabaseHelper.logSaveResultErrors(saveResults);

        // Assert
        for (Database.SaveResult result : saveResults) {
            System.assert(result.isSuccess(), 'All SaveResults should be successful');
        }
    }

    @isTest
    static void testLogSaveResultErrors_WithErrors() {
        // Arrange
        // Create an account with missing required fields to force an error
        List<Account> accounts = new List<Account>{
            new Account(Name = null) // Missing required Name field
        };

        // Perform a DML operation that causes an error
        Database.SaveResult[] saveResults;
        Test.startTest();
        saveResults = Database.insert(accounts, false);
        Test.stopTest();

        // Act
        DatabaseHelper.logSaveResultErrors(saveResults);

        // Assert
        for (Database.SaveResult result : saveResults) {
            if (!result.isSuccess()) {
                System.assertEquals(
                    StatusCode.REQUIRED_FIELD_MISSING,
                    result.getErrors()[0].getStatusCode(),
                    'The error should indicate a missing required field'
                );
            }
        }
    }

    @isTest
    static void testLogSaveResultErrors_MixedResults() {
        // Arrange
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Valid Account'),
            new Account(Name = null) // Missing Name to cause an error
        };

        // Perform a mixed-result DML operation
        Database.SaveResult[] saveResults;
        Test.startTest();
        saveResults = Database.insert(accounts, false);
        Test.stopTest();

        // Act
        DatabaseHelper.logSaveResultErrors(saveResults);

        // Assert
        for (Database.SaveResult result : saveResults) {
            if (result.isSuccess()) {
                System.assert(result.isSuccess(), 'This result should be successful');
            } else {
                System.assertEquals(
                    StatusCode.REQUIRED_FIELD_MISSING,
                    result.getErrors()[0].getStatusCode(),
                    'The error should indicate a missing required field'
                );
            }
        }
    }
}