public with sharing class InvitationCapacityService {
    @InvocableMethod(label='Check Invitation Event Capacity')
    public static List<Response> checkCapacity(List<Request> requests) {
        // Invocable methods must return one response for each request received from Flow.
        List<Response> responses = new List<Response>();

        // Collect unique Event Ids so the class can query each Event only once.
        Set<Id> eventIds = new Set<Id>();
        for (Request req : requests) {
            if (req.eventId != null) {
                eventIds.add(req.eventId);
            }
        }

        // If Flow did not pass any Event Id, return safe default responses.
        if (eventIds.isEmpty()) {
            for (Request req : requests) {
                Response response = new Response();
                response.isCapacityExceeded = false;
                response.reservedSeats = 0;
                response.maxCapacity = null;
                responses.add(response);
            }

            return responses;
        }

        // Load the Event records and their capacity in a map for quick lookup by Id.
        Map<Id, Event__c> eventsById = new Map<Id, Event__c>(
            [SELECT Id, Max_Capacity__c
             FROM Event__c
             WHERE Id IN :eventIds]
        );

        // AggregateResult is used because COUNT/GROUP BY does not return Invitation__c records.
        List<AggregateResult> reservedSeatResults = [
            SELECT Event__c eventId, COUNT(Id) reservedSeats
            FROM Invitation__c
            WHERE Event__c IN :eventIds
            AND Status__c IN ('Confirmed', 'Attended')
            GROUP BY Event__c
        ];

        // Convert aggregate rows into a normal map: Event Id -> reserved seats count.
        Map<Id, Integer> reservedSeatsByEventId = new Map<Id, Integer>();
        for (AggregateResult result : reservedSeatResults) {
            Id eventId = (Id) result.get('eventId');
            Integer reservedSeats = (Integer) result.get('reservedSeats');

            reservedSeatsByEventId.put(eventId, reservedSeats);
        }

        // Build one Response for each Request.
        for (Request req : requests) {
            // Start from safe defaults. These values are returned if the Event is missing
            // or if the Event has no configured capacity.
            Response response = new Response();
            response.isCapacityExceeded = false;
            response.reservedSeats = 0;
            response.maxCapacity = null;

            // Look up the Event related to the current Flow request.
            Event__c eventRecord = eventsById.get(req.eventId);
            if (eventRecord != null) {
                // If the aggregate query did not return a row for this Event,
                // no Confirmed/Attended invitations exist yet, so the count is zero.
                Integer reservedSeats = reservedSeatsByEventId.containsKey(req.eventId)
                    ? reservedSeatsByEventId.get(req.eventId)
                    : 0;

                response.reservedSeats = reservedSeats;

                if (eventRecord.Max_Capacity__c != null) {
                    // Max_Capacity__c is a Number field, so Apex exposes it as Decimal.
                    // The Flow output expects an Integer, so convert it before assigning.
                    Integer maxCapacity = Integer.valueOf(eventRecord.Max_Capacity__c);
                    response.maxCapacity = maxCapacity;

                    // This method is called by an after-save Flow, so the current record
                    // is already included in reservedSeats. Capacity is exceeded only
                    // when the count is greater than the maximum capacity.
                    response.isCapacityExceeded = reservedSeats > maxCapacity;
                }
            }
            responses.add(response);
        }

        return responses;
    }

    // Input shape exposed to Flow as Apex Action input fields.
    public class Request {
        @InvocableVariable(required=true)
        public Id eventId;

        @InvocableVariable
        public Id invitationId;
    }

    // Output shape exposed to Flow as Apex Action output fields.
    public class Response {
        @InvocableVariable
        public Boolean isCapacityExceeded;

        @InvocableVariable
        public Integer reservedSeats;

        @InvocableVariable
        public Integer maxCapacity;
    }
}
