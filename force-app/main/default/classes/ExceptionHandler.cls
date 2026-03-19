public virtual class ExceptionHandler {
  public virtual String getMessage(Exception cause) {
    return cause.getMessage();
  }
}