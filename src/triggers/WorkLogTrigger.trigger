trigger WorkLogTrigger on WorkLog__c (before insert) {

    WorkLogTriggerHandler workLogTrigger = new WorkLogTriggerHandler();
    workLogTrigger.run();

}