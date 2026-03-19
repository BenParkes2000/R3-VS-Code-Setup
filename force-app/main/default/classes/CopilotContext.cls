public abstract class CopilotContext {

    protected Id recordId;

    public CopilotContext() { }

    public void setRecordId(Id recordId) {
        this.recordId = recordId;
    }

    public abstract void buildContext();

    public abstract String getContext();
}