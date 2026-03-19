@isTest
public class AccountTestDataFactory {
    public static Id create() {
        return create('test account');
    }

    public static Id create(String name) {
        Account account = new Account();
        account.Name = name;
        insert account;
        return account.Id;
    }
}