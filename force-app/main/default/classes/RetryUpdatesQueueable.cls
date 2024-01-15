public class RetryUpdatesQueueable implements Queueable{

    private List<Contact> recordsToRetry;

    public RetryUpdatesQueueable(List<Contact> recordsToRetry) {
        this.recordsToRetry = recordsToRetry;
    }

    public void execute(QueueableContext context) {
        try {
            update recordsToRetry;
        } catch (DMLException e) {
            List<String> erroredDMLAttempts = new List<String>();
            for (Integer i = 0; i < e.getNumDml(); i++) {
                erroredDMLAttempts.add('DML Exception : ' + e.getDmlMessage(i));
            }

            // Create an email containing all the errored DML attempts and send them to an administrator
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'BrianHorowitz.Dev@gmail.com'});
            email.setSubject('DML Exception Notification');
            email.setPlainTextBody(String.join(erroredDMLAttempts, '\n'));
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
}