@IsTest
private class InvitationCapacityServiceTest {
    @IsTest
    static void returnsNotExceededWhenCapacityIsAvailable() {
        // Arrange
        Event__c eventRecord = createEvent(1);
        Guest__c firstGuest = createGuest('Guest One', 'guest.one@example.com');
        Invitation__c invitation = createInvitation(eventRecord.Id, firstGuest.Id, 'Confirmed');
        InvitationCapacityService.Request request = createRequest(eventRecord.Id, invitation.Id);

        // Act
        Test.startTest();
        List<InvitationCapacityService.Response> responses =
            InvitationCapacityService.checkCapacity(
                new List<InvitationCapacityService.Request>{ request }
            );
        Test.stopTest();

        // Assert
        System.assertEquals(1, responses.size(), 'The service should return one response for one request.');

        InvitationCapacityService.Response response = responses[0];
        System.assertEquals(false, response.isCapacityExceeded, 'One reserved seat should fit an event with capacity one.');
        System.assertEquals(1, response.reservedSeats, 'The confirmed invitation should count as one reserved seat.');
        System.assertEquals(1, response.maxCapacity, 'The response should expose the event max capacity.');
    }


    @IsTest
    static void returnsExceededWhenCapacityIsOverfilled() {
        // Arrange
        Event__c eventRecord = createEvent(1);
        Guest__c firstGuest = createGuest('Guest One', 'guest.one@example.com');
        Guest__c secondGuest = createGuest('Guest Two', 'guest.two@example.com');
        Invitation__c firstInvitation = createInvitation(eventRecord.Id, firstGuest.Id, 'Confirmed');
        Invitation__c secondInvitation = createInvitation(eventRecord.Id, secondGuest.Id, 'Confirmed');
        InvitationCapacityService.Request request = createRequest(eventRecord.Id, secondInvitation.Id);
        

        // Act
        Test.startTest();
        List<InvitationCapacityService.Response> responses =
            InvitationCapacityService.checkCapacity(
                new List<InvitationCapacityService.Request>{ request }
            );
        Test.stopTest();

        // Assert
        System.assertEquals(1, responses.size(), 'The service should return one response for one request.');

        InvitationCapacityService.Response response = responses[0];
        System.assertEquals(true, response.isCapacityExceeded, 'You cannot add another seat the capacity is full.');
        System.assertEquals(2, response.reservedSeats, 'Should count 2 confirmed seats');
        System.assertEquals(1, response.maxCapacity, 'Capacity should remain 1');
    }

    @IsTest
    static void returnsNotExceededWhenInvitationStatusIsNotConfirmed() {
        // Arrange
        Event__c eventRecord = createEvent(1);
        Guest__c firstGuest = createGuest('Guest One', 'guest.one@example.com');
        Guest__c secondGuest = createGuest('Guest Two', 'guest.two@example.com');
        Invitation__c confirmedInvitation = createInvitation(eventRecord.Id, firstGuest.Id, 'Confirmed');
        Invitation__c declinedInvitation = createInvitation(eventRecord.Id, secondGuest.Id, 'Declined');
        InvitationCapacityService.Request request = createRequest(eventRecord.Id, declinedInvitation.Id);
        

        // Act
        Test.startTest();
        List<InvitationCapacityService.Response> responses =
            InvitationCapacityService.checkCapacity(
                new List<InvitationCapacityService.Request>{ request }
            );
        Test.stopTest();

        // Assert
        System.assertEquals(1, responses.size(), 'The service should return one response for one request.');

        InvitationCapacityService.Response response = responses[0];
        System.assertEquals(false, response.isCapacityExceeded, 'One reserved seat should fit an event with capacity one.');
        System.assertEquals(1, response.reservedSeats, 'Should count 1 confirmed seats');
        System.assertEquals(1, response.maxCapacity, 'Capacity should remain 1');
    }


    // Helpers
    private static Event__c createEvent(Integer maxCapacity) {
        Event__c eventRecord = new Event__c(
            Name = 'Capacity Test Event',
            Max_Capacity__c = maxCapacity
        );

        insert eventRecord;
        return eventRecord;
    }

    private static Guest__c createGuest(String lastName, String email) {
        Guest__c guest = new Guest__c(
            Last_Name__c = lastName,
            Email__c = email
        );
        insert guest;
        return guest;
    }

    private static Invitation__c createInvitation(Id eventId, Id guestId, String status) {
        Invitation__c invitation = new Invitation__c(
            Event__c = eventId,
            Guest__c = guestId,
            Status__c = status,
            RSVP_Date__c = Date.today()
        );
        insert invitation;
        return invitation;
    }

    private static InvitationCapacityService.Request createRequest(Id eventId,Id invitationId){
        InvitationCapacityService.Request request = new InvitationCapacityService.Request();
        request.eventId = eventId;
        request.invitationId = invitationId;
        return request;
    }
}
