public class StringBuilder {
    private String content;

    public StringBuilder() {
        content = '';
    }

    public StringBuilder append(String value) {
        //content += value;
        content = String.format('{0}{1}', new String[] { this.content, value });
        return this;
    }

    public StringBuilder appendLine(String value) {
        this.content = String.format('{0}{1}\n', new String[] { this.content, value });
        //content += value + '\n';
        return this;
    }

    public override String toString() {
        return content;
    }
}