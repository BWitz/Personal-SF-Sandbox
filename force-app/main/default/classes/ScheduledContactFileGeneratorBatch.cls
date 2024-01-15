/*
* Author: Brian Horowitz
* Demo Date: 9/15/2023
*
* Description: This scheduled batch job should be run every day at 7 AM EST.
* To accomplish this, please utilize the Apex Scheduler User Interface or 
* enter the following within an executable context:
*   
* ScheduledContactFileGeneratorBatch scheduledJob = new ScheduledContactFileGeneratorBatch();
* String jobName = scheduledCFGB;
* String cronExp = '0 0 7 * * ?';
* System.schedule(jobName, cronExp, scheduledJob);
*
*
*/

global class ScheduledContactFileGeneratorBatch implements Schedulable{

    global void execute(SchedulableContext context) {
        ContactFileGeneratorBatch cfgb = new ContactFileGeneratorBatch();
        Database.executeBatch(cfgb);
    }

}