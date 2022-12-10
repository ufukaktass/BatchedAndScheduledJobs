public class SummarizeOpportunityAmountOfAccount implements Database.Batchable<sObject>, Database.Stateful{
    public String htmlBody = ' ';
    private static List<Messaging.SingleEmailMessage> mailList= new List<Messaging.SingleEmailMessage>();
    public SummarizeOpportunityAmountOfAccount(){
        
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
            'SELECT Id, Name, (SELECT Id, Email, Is_Primary_Contact__c FROM Contacts WHERE Is_Primary_Contact__c = true), (SELECT StageName, Amount FROM Opportunities WHERE CreatedDate = THIS_MONTH) FROM Account'
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> scope){
        //Collecting amount data
        for (Account account : scope) {
            try {
                if(account.Contacts[0].Email != null){
                    Decimal closedWonAmount = 0;
                    Decimal closedLostAmount = 0;
                    Decimal openAmount = 0;
                    for (Opportunity opp : account.Opportunities) {
                        if(opp.Amount != null && opp.StageName != null){
                            if (opp.StageName == 'Closed Won') {
                                closedWonAmount += opp.Amount;
                            }
                            else if (opp.StageName == 'Closed Lost') {
                                closedLostAmount += opp.Amount;
                            }
                            else {
                                openAmount += opp.Amount;
                            }
                        }
                    }
                    htmlBody = '<p>Below is a table of opportunities related to the account: '+account.Name+'</p>'+
                    +'<table style="border:1px double black;">'+
                    +'<tr>'+
                    +'<td scope="col" width="100" bgcolor="grey" align="center" style="font-weight:bold">'+'Account'+'</td>'+
                    +'<td scope="col" width="100" bgcolor="grey" align="center" style="font-weight:bold">'+'Stage'+'</td>'+
                    +'<td scope="col" width="100" bgcolor="grey" align="center" style="font-weight:bold">'+'Amount'+'</td>'+
                    +'</tr>'+
                    +'<tr>'+
                    +'<td width="100">'+account.Name+'</td>'+
                    +'<td width="100"> '+'Closed Won'+'</td>'+
                    +'<td width="100"> '+closedWonAmount+'</td>'+
                    +'</tr>'+
                    +'<tr>'+
                    +'<td width="100">'+account.Name+'</td>'+
                    +'<td width="100">'+'Open'+'</td>'+
                    +'<td width="100">'+openAmount+'</td>'+
                    +'</tr>'+
                    +'<tr>'+
                    +'<td width="100">'+account.Name+'</td>'+
                    +'<td width="100">'+'Closed Lost'+'</td>'+
                    +'<td width="100">'+closedLostAmount+'</td>'+
                    +'</tr>'+
                    +'</table>'+'<br><br><br>'+
                    +'<hr>'+
                    +'Powered by Salesforce'+'<br>'+
                    +'https://www.salesforce.com';

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setHtmlBody(htmlBody);
                    mail.setToAddresses(new String []{account.Contacts[0].Email});
                    mail.setSubject('Opportunity Amounts Report');
                    mailList.add(mail);
                }
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
        Messaging.sendEmail(mailList);
    }
    public void finish(Database.BatchableContext bc){
        
    }

}
