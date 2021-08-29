public with sharing class ProjectTriggerHandler extends TriggerHandler {

    public ProjectTriggerHandler() {

    }

    public override void beforeDelete() {
        this.validateDeleteProject((Map<Id, Project__c>) Trigger.oldMap);
    }
    public override void beforeUpdate() {
        this.validateChangeStatusProject((Map<Id, Project__c>) Trigger.newMap);
    }

    public override void afterUpdate() {
        this.sendEmail((List<Project__c>) Trigger.new, (Map<Id, Project__c>) Trigger.oldMap);
    }


    private void validateDeleteProject(Map<Id, Project__c> oldAccountMap) {

        for (Issue__c ass_i : [
                SELECT Id, Status__c, Project__c
                FROM Issue__c
                WHERE Status__c != 'Done'
                AND Status__c != 'Cancelled'
                AND Project__c IN :oldAccountMap.keySet()
        ]) {
            oldAccountMap.get(ass_i.Project__c).addError('You are not allowed to close or delete Project if at least one Issue is still open.');
        }
    }

    private void sendEmail(List<Project__c> newProjectList, Map<Id, Project__c> oldProjectMap) {

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();

        for (Project__c project_i : [
                SELECT Id, Name, Status__c, Contact__r.Email
                FROM Project__c
                WHERE Id IN :newProjectList
        ]) {
            if (project_i.Status__c == 'In Progress' && oldProjectMap.get(project_i.Id).Status__c == 'New') {
                toAddresses.add(project_i.Contact__r.Email);
                if (project_i.Contact__r.Email != null) {
                    mail.setToAddresses(toAddresses);
                    mail.setSubject('Project status');
                    mail.setPlainTextBody('Project status is changed \nFrom: ' +
                            oldProjectMap.get(project_i.Id).Status__c +
                            ' \nTo: ' + project_i.Status__c);
                    emailList.add(mail);
                }
            }
        }
        if (!emailList.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
        }

    }


    private void validateChangeStatusProject(Map<Id, Project__c> newProjectMap) {

        for (Issue__c ass_i : [
                SELECT Id, Status__c, Project__c
                FROM Issue__c
                WHERE Status__c != 'Done'
                AND Status__c != 'Cancelled'
                AND Project__c IN :newProjectMap.keySet()
        ]) {
            if (newProjectMap.get(ass_i.Project__c).Status__c == 'Closed') {
                newProjectMap.get(ass_i.Project__c).addError('You are not allowed to close or delete Project if at least one Issue is still open.');
            }
        }

    }
}