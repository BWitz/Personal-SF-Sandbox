@isTest
public with sharing class ContactFileGeneratorBatch_Test {
    @TestSetup
    static void makeData(){
        
        List<Account> accountsToInsert = new List<Account>();
        for (Integer i = 1; i <= 50; i++) {
            accountsToInsert.add(new Account(
                name='Account ' + i,
                AnnualRevenue = (1000.00 * i)
            ));
        }
        insert accountsToInsert;
        

        List<Contact> contactsToInsert = new List<Contact>();
        for (Account acc : [SELECT Id, Name FROM Account]) {
            contactsToInsert.add(new Contact(
                FirstName = acc.Name,
                LastName = ' Valid Contact',
                AccountId = acc.Id,
                Last_Marketing_Team_Review_Date__c = Date.today().addDays(-100),
                Phone = '123-456-7890',
                Email = 'Test@Test.com'
            ));

            contactsToInsert.add(new Contact(
                FirstName = acc.Name,
                LastName = ' Invalid Contact',
                AccountId = acc.Id,
                Last_Marketing_Team_Review_Date__c = Date.today().addDays(-1)
            ));
        }

        insert contactsToInsert;

        Account lonelyAccount = new Account(name='Lonely Account', AnnualRevenue=1000.00);

        insert lonelyAccount;

    }

    @isTest
    static void testContactFileGeneratorBatch() {
        Test.startTest();
        ContactFileGeneratorBatch cfgb = new ContactFileGeneratorBatch();
        id batchId = Database.executeBatch(cfgb, 200);
        Test.stopTest();

        Date today = Date.today();
        // We only expect 50 contacts to be updated since only 50 valid contacts were created. Any less / more and this test fails due to improper filtering.
        System.assertEquals(50, [SELECT Id FROM Contact WHERE Last_Marketing_Team_Review_Date__c = :today].size(), 'Expected to find 50 contacts with a Last Marketing Team Review Date value of TODAY. Actual value did not match expected.');
        // There should only be one Marketing File record created for each day. Otherwise, it means that the batch ran multiple times in one day.
        System.assertEquals(1, [SELECT Id, Created_Date__c FROM Marketing_File__c WHERE Created_Date__c = :today].size(), 'Expected to find 1 Marketing File record with a Created Date of TODAY. Actual value did not match expected.');
    }

}