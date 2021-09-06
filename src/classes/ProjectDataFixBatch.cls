/**
 * Created by Alex on 06.09.2021.
 */

global with sharing class ProjectDataFixBatch implements Database.Batchable<sObject> {


    String email;

    public ProjectDataFixBatch(String email) {
        this.email = email;
    }

    public ProjectDataFixBatch() {
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Total_Actual_hours__c, Total_Billable_hours__c, '
                + '(Select Id, ActualHours__c, BillableHours__c '
                + 'FROM WorkLogs__r '
                + 'WHERE ActualHours__c !=null '
                + 'OR BillableHours__c!= null) '
                + 'FROM Project__c '
                + 'WHERE Total_Actual_hours__c = null '
                + 'OR Total_Billable_hours__c = null ');
    }

    global void execute(Database.BatchableContext bc, List<Project__c> projects) {


        for (Project__c project_i : projects) {
            Decimal Total_Actual_hours = 0;
            Decimal Total_Billable_hours = 0;

            for (WorkLog__c workLog_i : project_i.WorkLogs__r) {
                if (workLog_i.ActualHours__c != null) {
                    Total_Actual_hours = Total_Actual_hours + workLog_i.ActualHours__c;
                }
                if (workLog_i.BillableHours__c != null) {
                    Total_Billable_hours = Total_Billable_hours + workLog_i.BillableHours__c;
                }
            }
            project_i.Total_Actual_hours__c = Total_Actual_hours;
            project_i.Total_Billable_hours__c = Total_Billable_hours;

        }
        update projects;

    }
    global void finish(Database.BatchableContext bc) {

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();

        mail.setSubject('Batch');
        mail.setPlainTextBody('Batch apex Status: Completed');


        AsyncApexJob job = [
                SELECT Id, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];
        if (String.isNotBlank(email)) {
            toAddresses.add(email`)`;
        } else {
            toAddresses.add(UserInfo.getUserEmail());
        }
        if (!toAddresses.isEmpty()) {
            mail.setToAddresses(toAddresses);
            emailList.add(mail);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
        }

    }

}