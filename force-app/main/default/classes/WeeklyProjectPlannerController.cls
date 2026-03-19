public with sharing class WeeklyProjectPlannerController {
    @AuraEnabled(cacheable=false)
    public static List<Project_Resource_Assignment__c> getRelatedResourceAssignmentList() {
        try {
            ID userId = UserInfo.getUserId();
            System.debug(userId);
            Date today = System.today();
            Date thisMonday = calcMonday(today, 'current');
            Date nextMonday = calcMonday(today, 'next');

            return [
                SELECT Id, Name, User__c, Project__c, Rate__c, End_Date__c, Start_Date__c, Hours_Monday__c, Hours_Tuesday__c, Hours_Wednesday__c, Hours_Thursday__c, Hours_Friday__c
                FROM Project_Resource_Assignment__c
                WHERE User__c = :userId AND Start_Date__c >= :thisMonday AND Start_Date__c <= :nextMonday.addDays(5)
                ORDER BY Start_Date__c DESC, Name
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static RateWrapper getUserRate(Id userId, Id projectId) {
        try {
            RateWrapper wrapper = new RateWrapper();
            User user = [SELECT Standard_Rate__c, CurrencyIsoCode FROM User WHERE Id = :userId LIMIT 1];
            wrapper.Rate = user.Standard_Rate__c;
            wrapper.CurrencyCode = user.CurrencyIsoCode;

            if (projectId != null) {
                List<Project_Resource_Assignment__c> praList = [
                    SELECT Rate__c
                    FROM Project_Resource_Assignment__c
                    WHERE Project__c = :projectId AND User__c = :userId AND Rate__c != NULL
                    ORDER BY Start_Date__c DESC
                    LIMIT 1
                ];

                if (praList.size() > 0) {
                    wrapper.Rate = praList[0].Rate__c;
                }
            }

            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static Project_Resource_Assignment__c getProjectDetails(Id id) {
        try {
            return [
                SELECT Id, Name, Rate__c, Hours_Monday__c, Hours_Tuesday__c, Hours_Wednesday__c, Hours_Thursday__c, Hours_Friday__c
                FROM Project_Resource_Assignment__c
                WHERE Project__c = :id
                LIMIT 1
            ];
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled(cacheable=false)
    public static Project_Resource_Assignment__c findResourceAssignment(Date startDate, Id userId, Id projectId) {
        try {
            List<Project_Resource_Assignment__c> resourceAssignmentList = [
                SELECT Id, Start_Date__c, User__c, Project__c, Rate__c, Hours_Monday__c, Hours_Tuesday__c, Hours_Wednesday__c, Hours_Thursday__c, Hours_Friday__c
                FROM Project_Resource_Assignment__c
                WHERE Start_Date__c = :startDate AND User__c = :userId AND Project__c = :projectId
                LIMIT 1
            ];

            if (resourceAssignmentList.size() == 0) {
                return null;
            }

            return resourceAssignmentList[0];
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    @AuraEnabled(cacheable=false)
    public static void saveResourceAssignmentList(Date startDate, Id userId, List<ResourceAssignmentWrapper> resourceAssignmentList) {
        try {
            User user = [SELECT Standard_Rate__c, CurrencyIsoCode FROM User WHERE Id = :userId LIMIT 1];

            List<Project_Resource_Assignment__c> resourceAssignmentsToUpsert = new List<Project_Resource_Assignment__c>();
            List<Project_Resource_Assignment__c> resourceAssignmentsToDelete = new List<Project_Resource_Assignment__c>();

            for (ResourceAssignmentWrapper wrapper : resourceAssignmentList) {
                if (wrapper.Id != null && (wrapper.projectId == null || wrapper.hasNoHours())) {
                    resourceAssignmentsToDelete.add(new Project_Resource_Assignment__c(Id = wrapper.Id));
                    continue;
                }
                if (wrapper.Id == null && findResourceAssignment(startDate, userId, wrapper.projectId) != null) {
                    throw new CustomException('A resource assignment already exists for the selected week.');
                }
                if (wrapper.projectId == null) {
                    continue;
                }

                Project_Resource_Assignment__c assignment = new Project_Resource_Assignment__c(Id = wrapper.Id);

                assignment.Start_Date__c = startDate;
                assignment.User__c = userId;
                assignment.OwnerId = UserInfo.getUserId();
                assignment.Id = wrapper.Id;
                assignment.CurrencyIsoCode = user.CurrencyIsoCode;
                assignment.Rate__c = wrapper.Rate;
                assignment.Hours_Monday__c = wrapper.HoursMonday;
                assignment.Hours_Tuesday__c = wrapper.HoursTuesday;
                assignment.Hours_Wednesday__c = wrapper.HoursWednesday;
                assignment.Hours_Thursday__c = wrapper.HoursThursday;
                assignment.Hours_Friday__c = wrapper.HoursFriday;
                resourceAssignmentsToUpsert.add(assignment);
            }

            upsert resourceAssignmentsToUpsert;

            if (resourceAssignmentsToDelete.size() > 0) {
                delete resourceAssignmentsToDelete;
            }
        } catch (Exception e) {
            throw AuraHandledExceptionFactory.create(e);
        }
    }

    public class CustomException extends Exception {
    }

    // public static Date calcNextMonday(Date today, String monday) {
    //     // Known reference Sunday
    //     Date refSunday = Date.newInstance(1900, 1, 7);

    //     // Calculate the number of days from the reference Sunday
    //     Integer daysFromRef = refSunday.daysBetween(today);

    //     // Calculate the day of the week
    //     // daysFromRef mod 7 gives a number between 0 (for Sunday) and 6 (for Saturday)
    //     // We add 1 to shift this to 1 (for Sunday) and 7 (for Saturday)
    //     Integer dayOfWeek = Math.mod(daysFromRef, 7) + 1;

    //     if (monday == 'current') {
    //         return today;
    //     }

    //     // Calculate the number of days until next Monday
    //     // If today is Monday (dayOfWeek == 2), we get 7
    //     // If today is Sunday (dayOfWeek == 1), we get 1
    //     // And so on
    //     Integer daysTillNextMonday = (dayOfWeek >= 2) ? (9 - dayOfWeek) : (2 - dayOfWeek);

    //     // Calculate next Monday's date
    //     return today.addDays(daysTillNextMonday);
    // }

    public static Date calcMonday(Date today, String weekType) {
        // Known reference Sunday
        Date refSunday = Date.newInstance(1900, 1, 7);

        // Calculate the number of days from the reference Sunday
        Integer daysFromRef = refSunday.daysBetween(today);

        // Calculate the day of the week
        // daysFromRef mod 7 gives a number between 0 (for Sunday) and 6 (for Saturday)
        // We add 1 to shift this to 1 (for Sunday) and 7 (for Saturday)
        Integer dayOfWeek = Math.mod(daysFromRef, 7) + 1;

        Integer daysUntilMonday;

        if (weekType == 'next') {
            // Calculate the number of days until next Monday
            // If today is Monday (dayOfWeek == 2), we get 7
            // If today is Sunday (dayOfWeek == 1), we get 1
            // And so on
            daysUntilMonday = (dayOfWeek >= 2) ? (9 - dayOfWeek) : (2 - dayOfWeek);
        } else if (weekType == 'current') {
            // Calculate the number of days to last Monday
            // If today is Monday (dayOfWeek == 2), we get 0
            // If today is Sunday (dayOfWeek == 1), we get 6
            // And so on
            daysUntilMonday = (dayOfWeek >= 2) ? (dayOfWeek - 2) : (6);
            daysUntilMonday = -daysUntilMonday; // We need to subtract days for this case
        } else {
            return null; // Invalid weekType provided
        }

        // Calculate Monday's date
        return today.addDays(daysUntilMonday);
    }

    public class RateWrapper {
        @AuraEnabled
        public Decimal Rate { get; set; }
        @AuraEnabled
        public String CurrencyCode { get; set; }
    }

    public class CustomClass {
        @AuraEnabled
        public Id ID;

        @AuraEnabled
        public String Name;
    }

    public class ResourceAssignmentWrapper {
        @AuraEnabled
        public Id Id { get; set; }
        @AuraEnabled
        public Id projectId { get; set; }
        @AuraEnabled
        public Decimal Rate { get; set; }
        @AuraEnabled
        public Decimal HoursMonday { get; set; }
        @AuraEnabled
        public Decimal HoursTuesday { get; set; }
        @AuraEnabled
        public Decimal HoursWednesday { get; set; }
        @AuraEnabled
        public Decimal HoursThursday { get; set; }
        @AuraEnabled
        public Decimal HoursFriday { get; set; }
        @AuraEnabled
        public String Notes { get; set; }

        public boolean hasNoHours() {
            Decimal total = 0;

            if (this.HoursMonday != null) {
                total += this.HoursMonday;
            }

            if (this.HoursTuesday != null) {
                total += this.HoursTuesday;
            }

            if (this.HoursWednesday != null) {
                total += this.HoursWednesday;
            }

            if (this.HoursThursday != null) {
                total += this.HoursThursday;
            }

            if (this.HoursFriday != null) {
                total += this.HoursFriday;
            }

            return total == 0;
        }
    }
}