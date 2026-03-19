@isTest
public class PrepareSandboxJDoeTest {
  @isTest
  public static void testPrepareSandbox() {
    // Arrange
    Profile consultantProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'R3 Consultant'
      LIMIT 1
    ];
    Profile adminProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = :ProfileName.SysAdmin
      LIMIT 1
    ];
    User manager = [
      SELECT Id
      FROM User
      WHERE ProfileId = :adminProfile.Id
      LIMIT 1
    ];

    User user = new User();
    user.FirstName = 'John';
    user.LastName = 'Doe';
    user.Email = 'jdoe@r3.digital.test.invalid';
    user.Alias = 'jdoe';
    user.Username = 'jdoe@r3.digital.test';
    user.EmailEncodingKey = 'UTF-8';
    user.LanguageLocaleKey = 'en_US';
    user.LocaleSidKey = 'en_GB';
    user.ProfileId = consultantProfile.Id;
    user.TimeZoneSidKey = 'Europe/London';
    user.ManagerId = manager.Id;
    insert user;

    // Act
    Test.startTest();
    System.runAs(TestUtil.getSysAdminUser()) {
      Test.testSandboxPostCopyScript(
        new PrepareSandboxJDoe(),
        UserInfo.getOrganizationId(),
        UserInfo.getOrganizationId(),
        UserInfo.getOrganizationName()
      );
    }
    Test.stopTest();

    // Assert
    List<User> userList = [
      SELECT Id, ProfileId
      FROM User
      WHERE Email = 'jdoe@r3.digital.test'
    ];

    System.assertEquals(
      0,
      [SELECT Id FROM User WHERE Email = 'jdoe@r3.digital.test.invalid'].size(),
      'The user with ".invalid" email should no longer exist'
    );
    System.assertEquals(
      1,
      userList.size(),
      'The user email should have had ".invalid" removed'
    );
    System.assertEquals(
      adminProfile.Id,
      userList[0].ProfileId,
      'The user should have been assigned the admin profile'
    );
  }
}