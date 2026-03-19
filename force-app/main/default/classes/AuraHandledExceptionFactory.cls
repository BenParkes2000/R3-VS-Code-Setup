public class AuraHandledExceptionFactory {
  @SuppressWarnings('PMD.AvoidDebugStatements')
  public static AuraHandledException create(Exception cause) {
    System.debug(LoggingLevel.ERROR, cause);
    ExceptionHandler handler = newInstance(cause);
    String message = handler.getMessage(cause);
    AuraHandledException error = new AuraHandledException(message);
    error.setMessage(message);
    return error;
  }

  private static ExceptionHandler newInstance(Exception cause) {
    try {
      Type handlerType = getType(cause);
      return (ExceptionHandler) handlerType.newInstance();
    } catch (Exception ignore) {
      return new ExceptionHandler();
    }
  }

  private static Type getType(Exception cause) {
    return Type.forName(getTypeName(cause));
  }

  private static String getTypeName(Exception cause) {
    return cause.getTypeName() + 'Handler';
  }
}