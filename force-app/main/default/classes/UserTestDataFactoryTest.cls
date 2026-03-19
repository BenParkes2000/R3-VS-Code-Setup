@isTest
public class UserTestDataFactoryTest {
  @isTest
  public static void test_create() {
    // Act
    User user = UserTestDataFactory.create('test@r3.digital', 'Test', 'User');

    // Assert
    System.assertNotEquals(null, user.Id);
    System.assertEquals('Test', user.FirstName);
    System.assertEquals('User', user.LastName);
    System.assertEquals('test@r3.digital', user.Email);
  }

  @isTest
  public static void test_get_user() {
    // Arrange
    User expectedUser = UserTestDataFactory.create(
      'test@r3.digital',
      'Test',
      'User'
    );
    String username = expectedUser.Username;

    // Act
    User actualUser = UserTestDataFactory.getUser(username);

    // Assert
    System.assertEquals(expectedUser.Id, actualUser.Id);
  }

  @isTest
  public static void test_get_user_not_found() {
    // Act
    User user = UserTestDataFactory.getUser('foo@r3.digital');

    // Assert
    System.assertEquals(null, user);
  }

  @isTest
  public static void test_get_login_profile() {
    // Act
    Id profileId = UserTestDataFactory.getLoginProfile('System Administrator');

    // Assert
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
    ];
    System.assertEquals(profile.Id, profileId);
  }

  @isTest
  public static void test_get_login_profile_exception() {
    try {
      // Act
      UserTestDataFactory.getLoginProfile('Foo');
    } catch (UserTestDataFactory.UserTestDataFactoryException e) {
      // Assert
      System.assertEquals('Unable to find profile: Foo', e.getMessage());
      return;
    }

    System.assert(false);
  }
}