public with sharing class EventCapacitySummaryController {
    // Creo una variabile costante
    private static final Set<String> RESERVED_STATUSES = new Set<String>{ 'Confirmed', 'Attended' };

    @AuraEnabled(cacheable=true)
    public static CapacitySummary getSummary(Id eventId) {
        if (eventId == null) {
            throw new AuraHandledException('Event Id is required.');
        }
        // recupero la max capacity dell'evento
        List<Event__c> events = [
            SELECT Id, Max_Capacity__c
            FROM Event__c
            WHERE Id = :eventId
            LIMIT 1
        ];

        if (events.isEmpty()) {
            throw new AuraHandledException('Event not found.');
        }
                
        Integer reservedSeats = [
            SELECT COUNT()
            FROM Invitation__c
            WHERE Event__c = :eventId
            AND Status__c IN :RESERVED_STATUSES
        ];

        Integer waitlistedSeats = [
            SELECT COUNT()
            FROM Invitation__c
            WHERE Event__c = :eventId
            AND Status__c = 'Waitlisted'
        ];


        return new CapacitySummary(events[0].Max_Capacity__c, reservedSeats,waitlistedSeats);
    }

    public class CapacitySummary {
        @AuraEnabled public Integer maxCapacity;
        @AuraEnabled public Integer reservedSeats;
        @AuraEnabled public Integer waitlistedSeats;
        @AuraEnabled public Integer availableSeats;
        @AuraEnabled public Integer occupancyPercentage;
        @AuraEnabled public Boolean hasCapacity;
        @AuraEnabled public String statusLabel;
        @AuraEnabled public String statusTheme;


        public CapacitySummary(Decimal maxCapacityValue, Integer reservedSeatsValue,Integer waitlistedSeatsValue) {
            reservedSeats = reservedSeatsValue == null ? 0 : reservedSeatsValue;
            hasCapacity = maxCapacityValue != null;
            waitlistedSeats = waitlistedSeatsValue == null ? 0 : waitlistedSeatsValue;

            if (!hasCapacity) {
                maxCapacity = null;
                availableSeats = null;
                occupancyPercentage = 0;
                statusLabel = 'Capienza non configurata';
                statusTheme = 'neutral';
                return;
            }

            maxCapacity = Integer.valueOf(maxCapacityValue);
            availableSeats = Math.max(maxCapacity - reservedSeats, 0);
            occupancyPercentage = maxCapacity > 0
                ? Math.min((reservedSeats * 100) / maxCapacity, 100)
                : 100;

            if (reservedSeats >= maxCapacity) {
                statusLabel = 'Sold out';
                statusTheme = 'error';
            } else if (occupancyPercentage >= 80) {
                statusLabel = 'Quasi pieno';
                statusTheme = 'warning';
            } else {
                statusLabel = 'Disponibile';
                statusTheme = 'success';
            }
        }
    }
}
