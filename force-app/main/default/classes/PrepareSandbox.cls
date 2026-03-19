@SuppressWarnings('PMD')
public with sharing class PrepareSandbox {
  public static void fixUserEmail(String email) {
    String invalidEmail = email + '.invalid';
    List<User> userList = [
      SELECT Id, Email, ProfileId
      FROM User
      WHERE Email = :invalidEmail
    ];

    if (userList.size() == 0) {
      return;
    }

    Profile adminProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = :ProfileName.SysAdmin
      LIMIT 1
    ];

    User user = userList[0];

    // if (user.ProfileId != adminProfile.Id) {
    //     freeUpLicense(user.Id);
    // }

    user.Email = user.Email.removeEndIgnoreCase('.invalid');
    user.ProfileId = adminProfile.Id;
    user.ManagerId = null;

    update user;
  }

  // private static void freeUpLicense(Id userId) {
  //     Profile profile = [SELECT Id FROM Profile WHERE Name = :ProfileName.R3Sales LIMIT 1];
  //     List<User> userList = [SELECT Id FROM User WHERE Id != :userId AND Profile.UserLicense.Name = 'Salesforce' AND ProfileId = :profile.Id AND IsActive = TRUE];

  //     if (userList.size() == 0) {
  //         System.debug('There are no users with the R3 Consultant profile that can be deactivated');
  //         return;
  //     }

  //     User user = userList[0];
  //     user.IsActive = false;
  //     update user;
  // }
}