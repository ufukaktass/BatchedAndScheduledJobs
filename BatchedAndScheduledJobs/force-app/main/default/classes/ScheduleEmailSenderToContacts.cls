public class ScheduleEmailSenderToContacts implements Schedulable {
    public void execute(SchedulableContext sc){
        SummarizeOpportunityAmountOfAccount oppAmount = new SummarizeOpportunityAmountOfAccount();
        Database.executeBatch(oppAmount);
        /*String daily = '0 0 10 ? * * *';
        String everyFriday = '0 0 13 ? * FRI *';
        String lastFridayOfMonth = '0 0 18 ? * 6L *"';*/
        
        //System.Schedule('Opportunity Batch',CRON_EXP, new ScheduleEmailSenderToContacts());
    }
}
