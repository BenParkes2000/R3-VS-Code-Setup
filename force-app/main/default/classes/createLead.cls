public with sharing class createLead {
  public static void createNewLead(
    String firstName,
    String lastName,
    String phoneNumber,
    String email,
    String company
  ) {
    Lead newLead = new Lead();

    newLead.FirstName = firstName;
    newLead.LastName = lastName;
    newLead.Phone = phoneNumber;
    newLead.Email = email;
    newLead.Company = company;

    try {
      insert newLead;
    } catch (DMLException e) {
      System.debug('The following exception has occurred: ' + e.getMessage());
    }
  }
}