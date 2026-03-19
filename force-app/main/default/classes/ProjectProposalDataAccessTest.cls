@isTest
private class ProjectProposalDataAccessTest {
  private static User getConsultantUser() {
    User user;

    System.runAs(TestUtil.getSysAdminUser()) {
      user = TestUtil.createUserWithProfileAndPermissionSets(
        'R3 Consultant',
        new Set<String>{
          'Access_Resource_Planning',
          'Consultant',
          'Create_Features',
          'Create_Work_Items',
          'Full_Project_Permissions',
          'Proposal_Documents',
          'Th_Badge_User',
          'Time_Entry_Access'
        }
      );
    }

    return user;
  }

  @isTest
  static void testGetProject() {
    // Arrange
    Id accountId = AccountTestDataFactory.create('Test Account');
    Id projectId = ProjectTestDataFactory.create(
      accountId,
      'Test Project',
      ProjectStatusNames.InProgress
    );

    // Act
    Test.startTest();
    Project__c project;

    // System.runAs(getConsultantUser()) {
      project = new ProjectProposalDataAccess().getProject(projectId);
    // }
    Test.stopTest();

    // Assert
    System.assertEquals(
      'Test Project',
      project.Name,
      'Project name should be Test Project'
    );
    System.assertEquals(
      'Test Account',
      project.Account__r.Name,
      'Account name should be Test Account'
    );
  }

  @isTest
  static void testGetFiles() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);

    // Add a PNG image
    ContentVersion imageVersion = new ContentVersion();
    imageVersion.Title = 'Test Image';
    imageVersion.PathOnClient = '/test-image.png';
    imageVersion.VersionData = Blob.valueOf(
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg=='
    );
    imageVersion.Origin = 'H';
    insert imageVersion;

    ContentDocumentLink imageLink = new ContentDocumentLink();
    imageLink.LinkedEntityId = projectId;
    imageLink.ContentDocumentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :imageVersion.Id
    ]
    .ContentDocumentId;
    imageLink.ShareType = 'V';
    insert imageLink;

    // Add a text file
    ContentVersion textVersion = new ContentVersion();
    textVersion.Title = 'Test Text';
    textVersion.PathOnClient = '/test-text.txt';
    textVersion.VersionData = Blob.valueOf('Hello World!');
    textVersion.Origin = 'H';
    insert textVersion;

    ContentDocumentLink textLink = new ContentDocumentLink();
    textLink.LinkedEntityId = projectId;
    textLink.ContentDocumentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :textVersion.Id
    ]
    .ContentDocumentId;
    textLink.ShareType = 'V';
    insert textLink;

    // Act
    Test.startTest();
    List<ContentVersion> fileList;

    // System.runAs(getConsultantUser()) {
      fileList = new ProjectProposalDataAccess().getFiles(projectId);
    // }
    Test.stopTest();

    // Assert
    System.assertEquals(1, fileList.size(), 'There should be 1 file');
    System.assertEquals(
      'Test Image',
      fileList[0].Title,
      'File title should be Test Image'
    );
    System.assertEquals('PNG', fileList[0].FileType, 'File type should be PNG');
  }

  @isTest
  static void testGetFeatures() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Id feature1Id = ProjectFeatureTestDataFactory.create(
      projectId,
      'Feature One'
    );
    Id feature2Id = ProjectFeatureTestDataFactory.create(
      projectId,
      'Feature Two'
    );
    WorkItemTestDataFactory.create(projectId, feature1Id);
    WorkItemTestDataFactory.create(projectId, feature1Id);
    WorkItemTestDataFactory.create(projectId, feature1Id);
    WorkItemTestDataFactory.create(projectId, feature2Id);

    // Act
    Test.startTest();
    List<Project_Feature__c> featureList;

    // System.runAs(getConsultantUser()) {
      featureList = new ProjectProposalDataAccess().getFeatures(projectId);
    // }
    Test.stopTest();

    // Assert
    System.assertEquals(2, featureList.size(), 'There should be 2 features');
    System.assertEquals('Feature One', featureList[0].Name, 'Feature One');
    System.assertEquals('Feature Two', featureList[1].Name, 'Feature Two');
    System.assertEquals(3, featureList[0].Work_Items__r.size(), 'Feature One');
    System.assertEquals(1, featureList[1].Work_Items__r.size(), 'Feature Two');
  }

  @isTest
  static void testGetLicenses() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    SalesforceLicenseTestDataFactory.create(projectId, accountId);

    // Act
    Test.startTest();
    List<Salesforce_License__c> licenseList = new List<Salesforce_License__c>();

    // System.runAs(getConsultantUser()) {
      licenseList = new ProjectProposalDataAccess().getLicenses(projectId);
    // }
    Test.stopTest();

    // Assert
    System.assertEquals(1, licenseList.size(), 'There should be 1 license');
    System.assertEquals(
      'Salesforce Platform',
      licenseList[0].License__c,
      'License should be Salesforce Platform'
    );
    System.assertEquals(
      10,
      licenseList[0].Quantity__c,
      'Quantity should be 10'
    );
  }

  @isTest
  static void testGetProjectTeamMembers() {
    // Arrange
    User user = UserTestDataFactory.create('test@r3.digital', 'Test', 'User');
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    ProjectTeamMemberTestDataFactory.create(projectId, user.Id);

    // Act
    Test.startTest();
    List<Project_Team_Member__c> memberList = new List<Project_Team_Member__c>();

    // System.runAs(getConsultantUser()) {
      memberList = new ProjectProposalDataAccess()
        .getProjectTeamMembers(projectId);
    // }
    Test.stopTest();

    // Assert
    System.assertEquals(1, memberList.size(), 'There should be 1 member');
    System.assertEquals(
      'Developer',
      memberList[0].Role__c,
      'Role should be Developer'
    );
    System.assertEquals(
      'Test User',
      memberList[0].Name__c,
      'Name should be Test User'
    );
    System.assertEquals(
      'test@r3.digital',
      memberList[0].Email__c,
      'Email should be test@r3.digital'
    );
  }

  @isTest
  static void testGetServices() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);
    Third_Party_Service__c service = ThirdPartyServiceTestDataFactory.create(
      projectId
    );
    insert service;

    // Act
    Test.startTest();
    List<Third_Party_Service__c> serviceList;

    // System.runAs(getConsultantUser()) {
      serviceList = new ProjectProposalDataAccess().getServices(projectId);
    // }
    Test.stopTest();

    // Assert
    System.assertEquals(1, serviceList.size(), 'There should be 1 service');
    System.assertEquals(
      service.Id,
      serviceList[0].Id,
      'Service Id should match'
    );
  }

  @isTest
  static void testGetPersonas() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Persona__c persona = new Persona__c();
    persona.Name = 'Test Persona';
    persona.Account__c = accountId;
    insert persona;

    // Act
    Test.startTest();
    List<Persona__c> personaList = new List<Persona__c>();

    // System.runAs(getConsultantUser()) {
      personaList = new ProjectProposalDataAccess().getPersonas(accountId);
    // }
    Test.stopTest();

    // Assert
    System.assertEquals(1, personaList.size(), 'There should be 1 persona');
    System.assertEquals(
      'Test Persona',
      personaList[0].Name,
      'Persona name should be Test Persona'
    );
  }

  @isTest
  static void testGetUserStories() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);

    Persona__c persona = new Persona__c();
    persona.Name = 'Test Persona';
    persona.Account__c = accountId;
    insert persona;

    User_Story__c userStory = new User_Story__c();
    userStory.Name = 'Test User Story';
    userStory.Project__c = projectId;
    userStory.Persona__c = persona.Id;
    userStory.Goal__c = 'Do something';
    userStory.Outcome__c = 'Get something';
    insert userStory;

    // Act
    Test.startTest();
    List<User_Story__c> userStoryList = new List<User_Story__c>();

    System.runAs(getConsultantUser()) {
      userStoryList = new ProjectProposalDataAccess().getUserStories(projectId);
    }
    Test.stopTest();

    // Assert
    System.assertEquals(
      1,
      userStoryList.size(),
      'There should be 1 user story'
    );
    System.assertEquals(
      'As a Test Persona, I want to Do something so that I can Get something',
      userStoryList[0].User_Story_Title__c,
      'User story title should be As a Test Persona, I want to Do something so that I can Get something'
    );
  }

  @isTest
  static void testGetAcceptanceCriterias() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);

    Persona__c persona = new Persona__c();
    persona.Name = 'Test Persona';
    persona.Account__c = accountId;
    insert persona;

    User_Story__c userStory = new User_Story__c();
    userStory.Name = 'Test User Story';
    userStory.Project__c = projectId;
    userStory.Persona__c = persona.Id;
    userStory.Goal__c = 'Do something';
    userStory.Outcome__c = 'Get something';
    insert userStory;

    Acceptance_Criteria__c acceptanceCriteria = new Acceptance_Criteria__c();
    acceptanceCriteria.User_Story__c = userStory.Id;
    acceptanceCriteria.Given__c = 'Given something';
    acceptanceCriteria.When__c = 'When something';
    acceptanceCriteria.Then__c = 'Then something';
    insert acceptanceCriteria;

    // Act
    Test.startTest();
    List<Acceptance_Criteria__c> acceptanceCriteriaList = new List<Acceptance_Criteria__c>();

    System.runAs(getConsultantUser()) {
      acceptanceCriteriaList = new ProjectProposalDataAccess()
        .getAcceptanceCriterias(projectId);
    }
    Test.stopTest();

    // Assert
    System.assertEquals(
      1,
      acceptanceCriteriaList.size(),
      'There should be 1 acceptance criteria'
    );
    System.assertEquals(
      'Given something',
      acceptanceCriteriaList[0].Given__c,
      'Given something'
    );
    System.assertEquals(
      'When something',
      acceptanceCriteriaList[0].When__c,
      'When something'
    );
    System.assertEquals(
      'Then something',
      acceptanceCriteriaList[0].Then__c,
      'Then something'
    );
  }

  @isTest
  static void testGetBusinessRequirements() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);

    Business_Requirement__c businessRequirement = new Business_Requirement__c();
    businessRequirement.Name = 'Test Business Requirement';
    businessRequirement.Project__c = projectId;
    businessRequirement.Description__c = 'Test Description';
    insert businessRequirement;

    // Act
    Test.startTest();
    List<Business_Requirement__c> businessRequirementList = new List<Business_Requirement__c>();

    System.runAs(getConsultantUser()) {
      businessRequirementList = new ProjectProposalDataAccess()
        .getBusinessRequirements(projectId);
    }
    Test.stopTest();

    // Assert
    System.assertEquals(
      1,
      businessRequirementList.size(),
      'There should be 1 business requirement'
    );
    System.assertEquals(
      'Test Business Requirement',
      businessRequirementList[0].Name,
      'Business requirement name should be Test Business Requirement'
    );
    System.assertEquals(
      'Test Description',
      businessRequirementList[0].Description__c,
      'Business requirement description should be Test Description'
    );
  }

  @isTest
  static void testGetRaidLogs() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);

    RAID_Log__c raidLog = new RAID_Log__c();
    raidLog.Project__c = projectId;
    raidLog.Type__c = 'Risk';
    raidLog.Rating__c = 'Critical';
    raidLog.Status__c = 'Open';
    raidLog.Subject__c = 'Test Subject';
    insert raidLog;

    // Act
    Test.startTest();
    List<RAID_Log__c> raidLogList;

    System.runAs(getConsultantUser()) {
      raidLogList = new ProjectProposalDataAccess().getRaidLogs(projectId);
    }
    Test.stopTest();

    // Assert
    System.assertEquals(1, raidLogList.size(), 'There should be 1 RAID log');
    System.assertEquals(
      'Risk',
      raidLogList[0].Type__c,
      'RAID Log Type should be Risk'
    );
    System.assertEquals(
      'Critical',
      raidLogList[0].Rating__c,
      'RAID Log Rating should be Critical'
    );
    System.assertEquals(
      'Test Subject',
      raidLogList[0].Subject__c,
      'RAID Log Subject should be Test Subject'
    );
  }

  @isTest
  static void testGetAssumptions() {
    // Arrange
    Id accountId = AccountTestDataFactory.create();
    Id projectId = ProjectTestDataFactory.create(accountId);

    Assumption__c assumption = new Assumption__c();
    assumption.Project__c = projectId;
    assumption.Area__c = 'System';
    assumption.Assumption__c = 'Test Assumption';
    insert assumption;

    // Act
    Test.startTest();
    List<Assumption__c> assumptionList = new List<Assumption__c>();

    System.runAs(getConsultantUser()) {
      assumptionList = new ProjectProposalDataAccess()
        .getAssumptions(projectId);
    }
    Test.stopTest();

    // Assert
    System.assertEquals(
      1,
      assumptionList.size(),
      'There should be 1 assumption'
    );
    System.assertEquals(
      'System',
      assumptionList[0].Area__c,
      'Assumption Area should be System'
    );
    System.assertEquals(
      'Test Assumption',
      assumptionList[0].Assumption__c,
      'Assumption should be Test Assumption'
    );
  }
}