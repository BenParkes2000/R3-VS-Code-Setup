public with sharing class DiagramEditorController {
    @RemoteAction
    public static String getDiagramData(String recordId) {
        Diagram__c diagram = [SELECT Data__c FROM Diagram__c WHERE Id = :recordId];
        return diagram.Data__c;
    }

    @RemoteAction
    public static String updateDiagram(String recordId, String diagramData) {
        try {
            Diagram__c diagram = new Diagram__c();
            diagram.Id = recordId;
            diagram.Data__c = diagramData;
            update diagram;
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}