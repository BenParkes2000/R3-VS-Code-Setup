public with sharing class RaidLogUtils {
    public static Id getActionRecordTypeId {
        get {
            return getRecordTypeIdByName('Action');
        }
    }

    public static Id getDecisionRecordTypeId {
        get {
            return getRecordTypeIdByName('Decision');
        }
    }

    public static Id getIssueRecordTypeId {
        get {
            return getRecordTypeIdByName('Issue');
        }
    }

    public static Id getRiskRecordTypeId {
        get {
            return getRecordTypeIdByName('Risk');
        }
    }

    private static Id getRecordTypeIdByName(String name) {
        return Schema.SObjectType.RAID_Log__c.getRecordTypeInfosByName().get(name).getRecordTypeId();
    }
}