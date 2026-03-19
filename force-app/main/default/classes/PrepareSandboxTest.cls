@isTest
public class PrepareSandboxTest {
  @isTest
  public static void testFixUserEmail() {
    // Arrange
    User user = UserTestDataFactory.create(
      'test@r3.digital.test.invalid',
      'Test',
      'User'
    );

    // Act
    Test.startTest();
    System.runAs(TestUtil.getSysAdminUser()) {
      PrepareSandbox.fixUserEmail('test@r3.digital.test');
    }
    Test.stopTest();

    // Assert
    user = [SELECT Email, ProfileId, ManagerId FROM User WHERE Id = :user.Id];
    Profile adminProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = :ProfileName.SysAdmin
      LIMIT 1
    ];

    System.assertEquals(
      'test@r3.digital.test',
      user.Email,
      'Email should be updated'
    );
    System.assertEquals(
      adminProfile.Id,
      user.ProfileId,
      'Profile should match the admin profile'
    );
    System.assertEquals(null, user.ManagerId, 'Manager should be null');
  }
}