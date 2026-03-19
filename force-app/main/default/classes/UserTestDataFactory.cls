// TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
@SuppressWarnings('PMD.ApexSharingViolations')
public class UserTestDataFactory {
  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public static User create(String email, String firstName, String lastName) {
    User user = getUser(email);

    if (user != null) {
      return user;
    }

    user = new User();
    user.FirstName = firstName;
    user.LastName = lastName;
    user.Email = email;
    user.Alias = 'Alias';
    user.Username = 'notarealemail.' + Datetime.now().getTime() + '.' + email;
    user.LocaleSidKey = 'en_GB';
    user.TimeZoneSidKey = 'Europe/London';
    user.ProfileId = getLoginProfile('System Administrator (non-API user)');
    user.LanguageLocaleKey = 'en_US';
    user.EmailEncodingKey = 'UTF-8';
    user.Is_Resource_Assignable__c = true;

    insert user;
    return user;
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @TestVisible
  private static User getUser(String username) {
    List<User> userList = [SELECT Id FROM User WHERE Username = :username];

    if (userList.size() == 0) {
      return null;
    }

    return userList[0];
  }

  // TODO: SuppressWarning added as part of Org sync. Refactor and remove on next update.
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @TestVisible
  private static Id getLoginProfile(String profileName) {
    List<Profile> profileList = [
      SELECT Id
      FROM Profile
      WHERE Name = :profileName
    ];

    if (profileList.size() == 0) {
      throw new UserTestDataFactoryException(
        'Unable to find profile: ' + profileName
      );
    }

    return profileList[0].Id;
  }

  public class UserTestDataFactoryException extends Exception {
  }
}