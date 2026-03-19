@isTest
public without sharing class TestUtil {
  private static Integer nextTestUserNumber = 0;

  public static User getSysAdminUser() {
    return [
      SELECT Id
      FROM User
      WHERE Profile.Name = :ProfileName.SysAdmin AND IsActive = TRUE
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
  }

  public static User createStandardUserWithPermissionSets(
    Set<String> permissionSetNames
  ) {
    Id stdUserProfileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
      WITH SYSTEM_MODE
      LIMIT 1
    ]
    .Id;

    String userNumStr = String.valueOf(nextTestUserNumber);
    userNumStr = userNumStr.leftPad(4, '0');
    nextTestUserNumber = Math.mod(nextTestUserNumber + 1, 10000);
    String usrAlias = 'tusr' + userNumStr;

    User testUser = new User(
      FirstName = 'Test',
      LastName = 'User-' + userNumStr,
      Alias = usrAlias,
      Email = usrAlias + '.test@r3.digital.invalid',
      Username = usrAlias + '.test@r3.digital',
      ProfileId = stdUserProfileId,
      TimeZoneSidKey = 'GMT',
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LocaleSidKey = 'en_US',
      ManagerId = getSysAdminUser().Id
    );
    insert testUser;

    List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
    for (PermissionSet ps : [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :permissionSetNames
      WITH SYSTEM_MODE
    ]) {
      psas.add(
        new PermissionSetAssignment(
          AssigneeId = testUser.Id,
          PermissionSetId = ps.Id
        )
      );
    }
    if (!psas.isEmpty()) {
      insert psas;
    }

    return testUser;
  }

  public static User createUserWithProfileAndPermissionSets(
    String profileName,
    Set<String> permissionSetNames
  ) {
    Id userProfileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :profileName
      WITH SYSTEM_MODE
      LIMIT 1
    ]
    .Id;

    String userNumStr = String.valueOf(nextTestUserNumber);
    userNumStr = userNumStr.leftPad(4, '0');
    nextTestUserNumber = Math.mod(nextTestUserNumber + 1, 10000);
    String usrAlias = 'tusr' + userNumStr;

    User testUser = new User(
      FirstName = 'Test',
      LastName = 'User-' + userNumStr,
      Alias = usrAlias,
      Email = usrAlias + '.test@r3.digital.invalid',
      Username = usrAlias + '.test@r3.digital',
      ProfileId = userProfileId,
      TimeZoneSidKey = 'GMT',
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LocaleSidKey = 'en_US',
      ManagerId = getSysAdminUser().Id
    );
    insert testUser;

    assignPermissionSetsToUser(testUser, permissionSetNames);

    return testUser;
  }

  public static void assignPermissionSetsToUser(
    User testUser,
    Set<String> permissionSetNames
  ) {
    if (permissionSetNames != null && !permissionSetNames.isEmpty()) {
      List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
      for (PermissionSet ps : [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :permissionSetNames
        WITH SYSTEM_MODE
      ]) {
        psas.add(
          new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = ps.Id
          )
        );
      }
      if (!psas.isEmpty()) {
        insert psas;
      }
    }
  }
}