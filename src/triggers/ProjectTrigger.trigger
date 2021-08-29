trigger ProjectTrigger on Project__c (before update, before insert, before delete, after insert, after update) {

    ProjectTriggerHandler projectTrigger = new ProjectTriggerHandler();
    projectTrigger.run();

}