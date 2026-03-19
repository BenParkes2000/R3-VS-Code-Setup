public class LabelValuePair {
  @AuraEnabled
  public String label { get; set; }

  @AuraEnabled
  public String value { get; set; }

  public LabelValuePair(String label, String value) {
    this.label = label;
    this.value = value;
  }
}