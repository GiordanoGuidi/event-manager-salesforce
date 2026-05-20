@IsTest
private class EventCapacitySummaryControllerTest {
    @IsTest
    static void returnsAvailableCapacitySummary() {
        Event__c eventRecord = createEvent(5);
        Guest__c confirmedGuest = createGuest('Confirmed Guest', 'confirmed.summary@example.com');
        Guest__c declinedGuest = createGuest('Declined Guest', 'declined.summary@example.com');

        createInvitation(eventRecord.Id, confirmedGuest.Id, 'Confirmed');
        createInvitation(eventRecord.Id, declinedGuest.Id, 'Declined');

        Test.startTest();
        EventCapacitySummaryController.CapacitySummary summary =
            EventCapacitySummaryController.getSummary(eventRecord.Id);
        Test.stopTest();

        System.assertEquals(5, summary.maxCapacity, 'The summary should expose the configured max capacity.');
        System.assertEquals(1, summary.reservedSeats, 'Only Confirmed and Attended invitations should reserve seats.');
        System.assertEquals(4, summary.availableSeats, 'Available seats should be max capacity minus reserved seats.');
        System.assertEquals(20, summary.occupancyPercentage, 'Occupancy should be returned as an integer percentage.');
        System.assertEquals(true, summary.hasCapacity, 'Configured capacity should be explicit for the LWC.');
        System.assertEquals('Disponibile', summary.statusLabel, 'Low occupancy should be shown as available.');
        System.assertEquals('success', summary.statusTheme, 'Available capacity should use the success theme.');
    }

    @IsTest
    static void returnsAlmostFullCapacitySummary() {
        Event__c eventRecord = createEvent(5);

        createInvitation(eventRecord.Id, createGuest('Guest One', 'almost.one@example.com').Id, 'Confirmed');
        createInvitation(eventRecord.Id, createGuest('Guest Two', 'almost.two@example.com').Id, 'Confirmed');
        createInvitation(eventRecord.Id, createGuest('Guest Three', 'almost.three@example.com').Id, 'Confirmed');
        createInvitation(eventRecord.Id, createGuest('Guest Four', 'almost.four@example.com').Id, 'Confirmed');

        Test.startTest();
        EventCapacitySummaryController.CapacitySummary summary =
            EventCapacitySummaryController.getSummary(eventRecord.Id);
        Test.stopTest();

        System.assertEquals(4, summary.reservedSeats, 'Four confirmed invitations should reserve four seats.');
        System.assertEquals(1, summary.availableSeats, 'One seat should remain available.');
        System.assertEquals(80, summary.occupancyPercentage, 'Four seats out of five should be 80%.');
        System.assertEquals('Quasi pieno', summary.statusLabel, '80% occupancy should be flagged as almost full.');
        System.assertEquals('warning', summary.statusTheme, 'Almost full events should use the warning theme.');
    }

    @IsTest
    static void returnsSoldOutCapacitySummary() {
        Event__c eventRecord = createEvent(1);

        createInvitation(eventRecord.Id, createGuest('Confirmed Guest', 'sold.confirmed@example.com').Id, 'Confirmed');
        createInvitation(eventRecord.Id, createGuest('Attended Guest', 'sold.attended@example.com').Id, 'Attended');

        Test.startTest();
        EventCapacitySummaryController.CapacitySummary summary =
            EventCapacitySummaryController.getSummary(eventRecord.Id);
        Test.stopTest();

        System.assertEquals(2, summary.reservedSeats, 'Confirmed and Attended invitations should both reserve seats.');
        System.assertEquals(0, summary.availableSeats, 'Available seats should never be negative.');
        System.assertEquals(100, summary.occupancyPercentage, 'Displayed occupancy should be capped at 100%.');
        System.assertEquals('Sold out', summary.statusLabel, 'Full or overfilled events should be marked sold out.');
        System.assertEquals('error', summary.statusTheme, 'Sold out events should use the error theme.');
    }

    @IsTest
    static void returnsNotConfiguredWhenCapacityIsMissing() {
        Event__c eventRecord = createEvent(null);

        Test.startTest();
        EventCapacitySummaryController.CapacitySummary summary =
            EventCapacitySummaryController.getSummary(eventRecord.Id);
        Test.stopTest();

        System.assertEquals(false, summary.hasCapacity, 'Missing max capacity should be explicit for the LWC.');
        System.assertEquals(null, summary.maxCapacity, 'Missing max capacity should remain null.');
        System.assertEquals(null, summary.availableSeats, 'Available seats should remain null without max capacity.');
        System.assertEquals(0, summary.occupancyPercentage, 'The progress bar should stay empty without capacity.');
        System.assertEquals('Capienza non configurata', summary.statusLabel, 'The LWC should guide admins to configure capacity.');
        System.assertEquals('neutral', summary.statusTheme, 'Missing capacity should use the neutral theme.');
    }

    private static Event__c createEvent(Integer maxCapacity) {
        Event__c eventRecord = new Event__c(
            Name = 'Capacity Summary Test Event',
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
}
