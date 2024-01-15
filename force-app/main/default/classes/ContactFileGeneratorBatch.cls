/*
* Author: Brian Horowitz
* Demo Date: 9/15/2023
*
* Description: This batch job runs everyday at 7:00 AM to send an email to the Marketing team containing
* a link to their daily generated Marketing File record. This record contains a .csv with their
* daily digest of Contacts to review. Contacts within this file meet the following criteria:
* They must have a valid email address or phone number, a previous marketing review date that is 3 months greater 
* than today, and belongs to an Account that has been modified in the last 5 business days.
*
*/
public with sharing class ContactFileGeneratorBatch implements Database.Batchable<SObject>, Database.Stateful {
    // Variable that starts off our CSV, and will hold additions to the csv.
    public String csvData = 'Salesforce Id, Last Name, First Name, Email, Phone Number, Account Name, Annual Account Revenue\n';
    // This list will hold any Contacts that are caught by a DML Exception when we attempt to update;
    public List<Contact> dmlExceptionContacts = new List<Contact>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> soqlWhereClauses = new List<String>();
        // Get previous business days according to requirements. We can save a dynamically referenced value for previous business days
        // in custom metadata if we needed to be more flexible around reporting on ranges of previous business days.
        List<DateTime> last5BusinessDays = ContactFileGeneratorUtils.getLastBusinessDays(5);
        // Loop through each business day to supplement our query with WHERE clauses that are dependent on a business days start and end date.
        // This ensures we only query Account records that have been modified within the last 5 business days.
        for (Datetime dt : last5BusinessDays) {
            List<Datetime> startendTimes = ContactFileGeneratorUtils.getBusinessDayStartEndTimes(dt);
            String clause = '(LastModifiedDate >= ' + startendTimes[0].format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND LastModifiedDate <= ' + startendTimes[1].format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ')';
            soqlWhereClauses.add(clause);
        }
        // Once we have our dynamic WHERE clauses ready, join them with an OR clause to supplement our query with various conditions.
        String whereClause = String.join(soqlWhereClauses, ' OR ');

        // LastModifiedDate is a Read-Only field in Salesforce so for testing purposes, we'll set the WHERE clause to adjust for our test data's LastModifiedDate.
        if (Test.isRunningTest()) {
            Datetime today = Datetime.now();
            List<Datetime> startendTimesToday = ContactFileGeneratorUtils.getBusinessDayStartEndTimes(today);
            whereClause = '(LastModifiedDate > ' + startendTimesToday[0].format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ')';
        }

        // Prepare our query and add our WHERE clause at the end of the string. 
        String query = 'SELECT Id, Name, AnnualRevenue, (SELECT Id, Name, FirstName, LastName, Phone, Email, Last_Marketing_Team_Review_Date__c, Reviewed_By_Marketing_Team__c FROM Contacts WHERE Reviewed_By_Marketing_Team__c = false) FROM Account WHERE ' + whereClause;
        // We're utilizing getQueryLocator so we can maximize the amount of records we're working with. Allows us to query for up to 50 million rows.
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> records){
        List<Contact> contactsToUpdate = new List<Contact>();
        // Iterate through each contact within each Account
        for (Account acc : records) {
            // If an Account doesn't have associated Contact records, move on to the next iteration within the loop.
            if (acc.Contacts.size() == 0) {
                continue;
            }

            for (Contact cont : acc.Contacts) {
                // If the Contact has a valid email or phone number, add their information to the stateful csvData variable
                if (ContactFileGeneratorUtils.isValidPhoneNumber(cont.Phone) || ContactFileGeneratorUtils.isValidEmailAddress(cont.Email)) {
                    // Add fields to csvData when one condition is met
                    csvData += cont.Id + ',' + cont.LastName + ',' + cont.FirstName + ',' + cont.Email + ',' + cont.Phone + ',' + acc.Name + ',' + acc.AnnualRevenue + '\n';
                    // Assign Review Date to Contact record to show that this has been evaluated and sent to Marketing.
                    // On update, this will also cause a formula field to update as well, which will prevent this contact 
                    // from appearing within the Query Locator for the next 3 months. 
                    cont.Last_Marketing_Team_Review_Date__c = Date.today();
                    contactsToUpdate.add(cont);
                }
            }
        }

        // Attempt to update contacts. If we hit a DMLException, we'll pass those contacts into our dmlExceptionContacts list
        // to prepare them to be enqueued for a retry attempt asynchronously.
        try {
            update contactsToUpdate;
        } catch(DMLException e) {
            dmlExceptionContacts.addAll(contactsToUpdate);
        }
        
    }

    public void finish(Database.BatchableContext bc){

        // If any contacts weren't able to be updated, enqueue them to be updated after the job.
        if (dmlExceptionContacts.size() > 0) {
            RetryUpdatesQueueable ruq = new RetryUpdatesQueueable(dmlExceptionContacts);
            System.enqueueJob(ruq);
        }
        // Begin creating our .csv file based on what was entered into the csvData variable.
        Blob csvBlob = Blob.valueOf(csvData);
        String fileName = 'Marketing Team Data ' + Datetime.now().format('yyyyMMddHHmmss') + '.csv';

        // Insert a new Marketing File record which will hold today's generated .csv as an attachment.
        // Beforehand, we can also perform a check to see if a Marketing File Record has already been created for today.
        // If there already is one, then we do not continue creating a new Marketing File Record.
        Marketing_File__c mkFile = new Marketing_File__c(Created_Date__c = Date.today());
        insert mkFile;

        // Attach the .csv to the Marketing File record.
        Attachment csvAttachment = new Attachment();
        csvAttachment.Body = csvBlob;
        csvAttachment.Name = fileName;
        csvAttachment.ParentId = mkFile.Id;
        insert csvAttachment;

        
        // Generate Email here
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{'MarketingTeam@Fortune100Company.com'});
        email.setSubject('Recently Modified Contacts: ' + String.valueOf(Date.today()));
        // Get the instance URL and create a URL to the record.
        String instance = Url.getSalesforceBaseUrl().toExternalForm();
        String recordURL = instance + '/lightning/r/Marketing_File__c/' + String.valueOf(mkFile.Id) + '/view';
        email.setHtmlBody('Your daily digest of recently modified Contacts can be viewed by clicking the link below: \n' + recordURL);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        
    }
}