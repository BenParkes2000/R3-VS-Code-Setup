@isTest
public class SalesforceLicenseTestDataFactoryTest {
    @isTest
    public static void test_create() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Act
        Id licenseId = SalesforceLicenseTestDataFactory.create(projectId, accountId);

        // Assert
        Salesforce_License__c license = [SELECT Project__c, License__c, Quantity__c FROM Salesforce_License__c WHERE Id = :licenseId];
        System.assertEquals(projectId, license.Project__c);
        System.assertEquals('Salesforce Platform', license.License__c);
        System.assertEquals(10, license.Quantity__c);
    }

    @isTest
    public static void test_create_with_license_type() {
        // Arrange
        Id accountId = AccountTestDataFactory.create();
        Id projectId = ProjectTestDataFactory.create(accountId);

        // Act
        Id licenseId = SalesforceLicenseTestDataFactory.create(projectId, accountId, 'Marketing Cloud');

        // Assert
        Salesforce_License__c license = [SELECT Project__c, License__c, Quantity__c FROM Salesforce_License__c WHERE Id = :licenseId];
        System.assertEquals(projectId, license.Project__c);
        System.assertEquals('Marketing Cloud', license.License__c);
        System.assertEquals(10, license.Quantity__c);
    }
}