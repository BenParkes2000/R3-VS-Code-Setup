public class DatabaseHelper {
    public static void logSaveResultErrors(Database.SaveResult[] results) {
        for (Database.SaveResult result : results) {
            if (result.isSuccess() == false) {
                for (Database.Error err : result.getErrors()) {
                    System.debug('The following error has occurred:');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
}