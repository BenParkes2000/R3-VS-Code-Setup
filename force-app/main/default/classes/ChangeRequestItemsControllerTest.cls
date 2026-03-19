@isTest
private without sharing class ChangeRequestItemsControllerTest {
  @isTest
  static void testConstructorWithPageParamIdSetToContractWithCurrencyAndRelatedWorkItems() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'GBP',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      Project__c testProject = new Project__c(
        Name = 'Test Project',
        Status__c = 'Kick off',
        Account__c = testAccount.Id,
        Start_Date__c = Date.newInstance(2024, 1, 1),
        End_Date__c = Date.newInstance(2024, 31, 3),
        Vendor__c = 'Salesforce',
        Support_Type__c = 'MSA'
      );
      insert testProject;

      Project_Feature__c testFeature = new Project_Feature__c(
        Project__c = testProject.Id,
        Name = 'Test Feature'
      );
      insert testFeature;

      List<Work_Item__c> relatedWorkItems = new List<Work_Item__c>{
        new Work_Item__c(
          Subject__c = 'Test Work Item C',
          Project__c = testProject.Id,
          Feature__c = testFeature.Id,
          Status__c = 'Ready',
          Est_Time__c = 5,
          Contract__c = testContract.Id,
          Type__c = 'Work Item',
          Description__c = 'Test Description 1'
        ),
        new Work_Item__c(
          Subject__c = 'Test Work Item A',
          Project__c = testProject.Id,
          Feature__c = testFeature.Id,
          Status__c = 'Ready',
          Est_Time__c = 7,
          Contract__c = testContract.Id,
          Type__c = 'Work Item',
          Description__c = 'Test Description 2'
        ),
        new Work_Item__c(
          Subject__c = 'Test Work Item B',
          Project__c = testProject.Id,
          Feature__c = testFeature.Id,
          Status__c = 'Ready',
          Est_Time__c = 11,
          Contract__c = testContract.Id,
          Type__c = 'Work Item',
          Description__c = 'Test Description 3'
        )
      };
      insert relatedWorkItems;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', testContract.Id);
      Test.setCurrentPage(pref);

      // Act
      Test.startTest();
      ChangeRequestItemsController controller = new ChangeRequestItemsController();
      Test.stopTest();

      // Assert
      // Work Item assertions
      Assert.isTrue(
        controller.hasWorkItems,
        'Controller should have work items'
      );
      Assert.areEqual(
        3,
        controller.workItems.size(),
        'Unexpected number of work items on controller'
      );
      // Expecting line items to be ordered by Subject
      Assert.areEqual(
        'Test Work Item A',
        controller.workItems[0].subject,
        'Unexpected 1st work item subject on controller'
      );
      Assert.areEqual(
        7,
        controller.workItems[0].estHours,
        'Unexpected 1st work item estimated time on controller'
      );
      Assert.areEqual(
        'Test Work Item B',
        controller.workItems[1].subject,
        'Unexpected 2nd work item subject on controller'
      );
      Assert.areEqual(
        11,
        controller.workItems[1].estHours,
        'Unexpected 2nd work item estimated time on controller'
      );
      Assert.areEqual(
        'Test Work Item C',
        controller.workItems[2].subject,
        'Unexpected 3rd work item subject on controller'
      );
      Assert.areEqual(
        5,
        controller.workItems[2].estHours,
        'Unexpected 3rd work item estimated time on controller'
      );
      for (Integer i = 0; i < 3; ++i) {
        Assert.areEqual(
          125,
          controller.workItems[i].unitPrice,
          'Unexpected work item unit price on controller'
        );
        Assert.areEqual(
          controller.workItems[i].unitPrice * controller.workItems[i].estHours,
          controller.workItems[i].totalPrice,
          'Unexpected work item total price on controller'
        );
      }
      // Currency assertions
      Assert.areEqual(
        '£',
        controller.currencySymbol,
        'Unexpected currency symbol on controller'
      );
      // Change request assertions
      Assert.isNotNull(
        controller.changeRequest,
        'Change Request should not be null'
      );
      Assert.areEqual(
        23,
        controller.changeRequest.totalHours,
        'Unexpected total hours on controller change request'
      );
      Assert.areEqual(
        125 * 23,
        controller.changeRequest.totalPrice,
        'Unexpected total price on controller change request'
      );
    }
  }

  @isTest
  static void testConstructorWithPageParamIdSetToContractWithoutRelatedWorkItems() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'GBP',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', testContract.Id);
      Test.setCurrentPage(pref);

      // Act
      Test.startTest();
      ChangeRequestItemsController controller = new ChangeRequestItemsController();
      Test.stopTest();

      // Assert
      // Work Item assertions
      Assert.isFalse(
        controller.hasWorkItems,
        'Controller should have work items'
      );
      Assert.isNotNull(
        controller.workItems,
        'Work Items list should not be null'
      );
      Assert.isTrue(
        controller.workItems.isEmpty(),
        'Unexpected number of work items on controller'
      );
      // Currency assertions
      Assert.areEqual(
        '£',
        controller.currencySymbol,
        'Unexpected currency symbol on controller'
      );
      // Change request assertions
      Assert.isNotNull(
        controller.changeRequest,
        'Change Request should not be null'
      );
      Assert.areEqual(
        0,
        controller.changeRequest.totalHours,
        'Unexpected total hours on controller change request'
      );
      Assert.areEqual(
        0,
        controller.changeRequest.totalPrice,
        'Unexpected total price on controller change request'
      );
    }
  }

  @isTest
  static void testConstructorWithPageParamIdSetToContractWithGBPCurrency() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'GBP',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', testContract.Id);
      Test.setCurrentPage(pref);

      // Act
      Test.startTest();
      ChangeRequestItemsController controller = new ChangeRequestItemsController();
      Test.stopTest();

      // Assert
      // Currency assertions
      Assert.areEqual(
        '£',
        controller.currencySymbol,
        'Unexpected currency symbol on controller'
      );
    }
  }

  @isTest
  static void testConstructorWithPageParamIdSetToContractWithUSDCurrency() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'USD',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', testContract.Id);
      Test.setCurrentPage(pref);

      // Act
      Test.startTest();
      ChangeRequestItemsController controller = new ChangeRequestItemsController();
      Test.stopTest();

      // Assert
      // Currency assertions
      Assert.areEqual(
        '$',
        controller.currencySymbol,
        'Unexpected currency symbol on controller'
      );
    }
  }

  @isTest
  static void testConstructorWithPageParamIdSetToContractWithEuroCurrency() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'EUR',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', testContract.Id);
      Test.setCurrentPage(pref);

      // Act
      Test.startTest();
      ChangeRequestItemsController controller = new ChangeRequestItemsController();
      Test.stopTest();

      // Assert
      // Currency assertions
      Assert.areEqual(
        '€',
        controller.currencySymbol,
        'Unexpected currency symbol on controller'
      );
    }
  }
  // Note, the default currency will be assigned to the contract if not explicitly set, and as GBP, USD and EUR are only active currencies in the org,
  // we can't test scenario where empty string symbol is assigned.

  @isTest
  static void testConstructorWithPageParamIdMissing() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'EUR',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Act/Assert
      Test.startTest();
      try {
        new ChangeRequestItemsController();
        Assert.fail('Expected exception to be thrown by contructor');
      } catch (Exception ex) {
        Assert.isTrue(
          ex instanceof ChangeRequestItemsController.CustomException,
          'Unexpected exception type thrown by constructor'
        );
        Assert.areEqual(
          'Id page parameter for ChangeRequestItemsController has not been set',
          ex.getMessage(),
          'Unexpected exception message'
        );
      }
      Test.stopTest();
    }
  }

  @isTest
  static void testConstructorWithPageParamIdNull() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'EUR',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', null);
      Test.setCurrentPage(pref);

      // Act/Assert
      Test.startTest();
      try {
        new ChangeRequestItemsController();
        Assert.fail('Expected exception to be thrown by contructor');
      } catch (Exception ex) {
        Assert.isTrue(
          ex instanceof ChangeRequestItemsController.CustomException,
          'Unexpected exception type thrown by constructor'
        );
        Assert.areEqual(
          'Id page parameter for ChangeRequestItemsController has not been set',
          ex.getMessage(),
          'Unexpected exception message'
        );
      }
      Test.stopTest();
    }
  }

  @isTest
  static void testConstructorWithPageParamIdEmpty() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'EUR',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', '');
      Test.setCurrentPage(pref);

      // Act/Assert
      Test.startTest();
      try {
        new ChangeRequestItemsController();
        Assert.fail('Expected exception to be thrown by contructor');
      } catch (Exception ex) {
        Assert.isTrue(
          ex instanceof ChangeRequestItemsController.CustomException,
          'Unexpected exception type thrown by constructor'
        );
        Assert.areEqual(
          'Id page parameter for ChangeRequestItemsController has not been set',
          ex.getMessage(),
          'Unexpected exception message'
        );
      }
      Test.stopTest();
    }
  }

  @isTest
  static void testConstructorWithPageParamIdWhitespace() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'EUR',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', '  \t  \r\n  ');
      Test.setCurrentPage(pref);

      // Act/Assert
      Test.startTest();
      try {
        new ChangeRequestItemsController();
        Assert.fail('Expected exception to be thrown by contructor');
      } catch (Exception ex) {
        Assert.isTrue(
          ex instanceof ChangeRequestItemsController.CustomException,
          'Unexpected exception type thrown by constructor'
        );
        Assert.areEqual(
          'Id page parameter for ChangeRequestItemsController has not been set',
          ex.getMessage(),
          'Unexpected exception message'
        );
      }
      Test.stopTest();
    }
  }

  @isTest
  static void testConstructorWithPageParamIdNotValid() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'EUR',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', 'ThisIsNotAValidId');
      Test.setCurrentPage(pref);

      // Act/Assert
      Test.startTest();
      try {
        new ChangeRequestItemsController();
        Assert.fail('Expected exception to be thrown by contructor');
      } catch (Exception ex) {
        Assert.isTrue(
          ex instanceof ChangeRequestItemsController.CustomException,
          'Unexpected exception type thrown by constructor'
        );
        Assert.areEqual(
          'Id page parameter for ChangeRequestItemsController is not a valid ID',
          ex.getMessage(),
          'Unexpected exception message'
        );
      }
      Test.stopTest();
    }
  }

  @isTest
  static void testConstructorWithPageParamIdNotAContractId() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'EUR',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', testAccount.Id);
      Test.setCurrentPage(pref);

      // Act/Assert
      Test.startTest();
      try {
        new ChangeRequestItemsController();
        Assert.fail('Expected exception to be thrown by contructor');
      } catch (Exception ex) {
        Assert.isTrue(
          ex instanceof ChangeRequestItemsController.CustomException,
          'Unexpected exception type thrown by constructor'
        );
        Assert.areEqual(
          'Id page parameter for ChangeRequestItemsController is not a Contract ID',
          ex.getMessage(),
          'Unexpected exception message'
        );
      }
      Test.stopTest();
    }
  }

  @isTest
  static void testConstructorWithPageParamIdForAContractNotFound() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'EUR',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;
      String contractIdStr = String.valueOf(testContract.Id);
      delete testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', contractIdStr);
      Test.setCurrentPage(pref);

      // Act/Assert
      Test.startTest();
      try {
        new ChangeRequestItemsController();
        Assert.fail('Expected exception to be thrown by contructor');
      } catch (Exception ex) {
        Assert.isTrue(
          ex instanceof ChangeRequestItemsController.CustomException,
          'Unexpected exception type thrown by constructor'
        );
        Assert.areEqual(
          'Contract not found for ID: ' + contractIdStr,
          ex.getMessage(),
          'Unexpected exception message'
        );
      }
      Test.stopTest();
    }
  }

  @isTest
  static void testYearPropertyReturnsYearForToday() {
    System.runAs(createTestContextUser()) {
      // Arrange
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Contract testContract = new Contract(
        Name = 'Test Contract',
        AccountId = testAccount.Id,
        StartDate = Date.newInstance(2024, 1, 1),
        CurrencyISOCode = 'GBP',
        Status = 'Draft',
        Annual_Vlaue__c = 1234.56
      );
      insert testContract;

      // Set the PageReference parameter
      PageReference pref = Page.ChangeRequestItems;
      pref.getParameters().put('id', testContract.Id);
      Test.setCurrentPage(pref);

      ChangeRequestItemsController controller = new ChangeRequestItemsController();

      // Act
      Test.startTest();
      Integer year = controller.year;
      Test.stopTest();

      // Assert
      // Currency assertions
      Assert.areEqual(
        System.today().year(),
        year,
        'Unexpected year on controller'
      );
    }
  }

  private static User createTestContextUser() {
    return TestUtil.createUserWithProfileAndPermissionSets(
      'Standard User',
      new Set<String>{
        'Edit_Access_on_Contracts',
        'Create_Work_Items',
        'Project_Proposal_Generator'
      }
    );
  }
}