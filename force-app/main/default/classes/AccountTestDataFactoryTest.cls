@isTest
public class AccountTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Act
        Id accountId = AccountTestDataFactory.create();

        // Assert
        Account account = [SELECT Name FROM Account WHERE Id = :accountId];
        System.assertEquals('test account', account.Name);
    }

    @isTest
    public static void test_create_with_name() {
        // Act
        Id accountId = AccountTestDataFactory.create('Foo');

        // Assert
        Account account = [SELECT Name FROM Account WHERE Id = :accountId];
        System.assertEquals('Foo', account.Name);
    }
}