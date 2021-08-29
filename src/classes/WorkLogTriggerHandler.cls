public with sharing class WorkLogTriggerHandler extends TriggerHandler {

    public WorkLogTriggerHandler() {

    }

    public override void beforeInsert() {
        this.defaultDate((List<WorkLog__c>) Trigger.new);
    }

    private void defaultDate(List<WorkLog__c> newWorkLogList) {
        for (WorkLog__c workLog_i : newWorkLogList) {
            if (workLog_i.Date__c == null) {
                workLog_i.Date__c = Date.TODAY();
            }
        }
    }
}