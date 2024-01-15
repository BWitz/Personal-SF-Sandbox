@isTest
public with sharing class RetryUpdatesQueueable_Test {

    @isTest
    static void testRetryUpdatesQueueable() {
        // Create Contacts

        List<Contact> contactsToUpdate = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contactsToUpdate.add(new Contact(
                FirstName = 'Test',
                LastName = 'Record ' + i
            ));
        }
        insert contactsToUpdate;

        // Create a DML Exception within the test so we can check if emails send.

        contactsToUpdate[0].Email = 'null';

        System.enqueueJob(new RetryUpdatesQueueable(contactsToUpdate));

        Test.startTest();
        Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE JobType = 'Queueable'];
        Test.stopTest();

        System.assertEquals(1, jobCount, 'The expected jobCount was not equal to one. Verify job queue and variable declarations');
        
        // Verify that email was sent.
        List<Contact> caughtDMLExceptionContact = [SELECT Id FROM Contact WHERE Email = 'null'];
        // If the list is greater than 0, that means the record was updated and no DMLException was caught.
        System.assertEquals(0, caughtDMLExceptionContact.size());
    }
}