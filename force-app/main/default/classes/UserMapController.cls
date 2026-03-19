public without sharing class UserMapController {
    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        return [
            SELECT Id, Name, Title, Country, PostalCode, Address
            FROM User
            WHERE IsActive = TRUE AND PostalCode != NULL AND Country != NULL AND UserType = 'Standard'
        ];
    }
}