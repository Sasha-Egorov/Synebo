public with sharing class WorkLogTriggerHandler extends TriggerHandler {

    public WorkLogTriggerHandler() {

    }

    protected override void beforeInsert() {
        this.defaultDate((List<WorkLog__c>) Trigger.new);
    }

    protected override void afterInsert() {
        this.countHours((List<WorkLog__c>) Trigger.new, null);
    }

    protected override void afterUpdate() {
        this.countHours((List<WorkLog__c>) Trigger.new, (Map<Id, WorkLog__c>) Trigger.oldMap);
    }

    protected override void afterDelete() {
        this.countHours(null, (Map<Id, WorkLog__c>) Trigger.oldMap);
    }

    protected override void afterUndelete() {
        this.countHours((List<WorkLog__c>) Trigger.new, null);
    }


    private void defaultDate(List<WorkLog__c> newWorkLogList) {
        for (WorkLog__c workLog_i : newWorkLogList) {
            if (workLog_i.Date__c == null) {
                workLog_i.Date__c = Date.TODAY();
            }
        }
    }

    private void countHours(List<WorkLog__c> newList, Map<Id, WorkLog__c> oldMap) {
        Map<Id, List<Decimal>> projectIdToNumOfContactsMap = new Map<Id, List<Decimal>>();
        List<Project__c> projectsToUpdateList = new List<Project__c>();


        List<WorkLog__c> workLogsToProcessList = (!Trigger.isDelete)
                ? newList
                : oldMap.values();


        for (WorkLog__c workLog_i : workLogsToProcessList) {


            if ((Trigger.isInsert || Trigger.isDelete || Trigger.isUndelete) && workLog_i.Project__c != null) {
                projectIdToNumOfContactsMap.put(workLog_i.Project__c, null);
            }

            if (Trigger.isUpdate && (workLog_i.Project__c != oldMap.get(workLog_i.Id).Project__c ||
                    workLog_i.ActualHours__c != oldMap.get(workLog_i.Id).ActualHours__c)) {
                if (workLog_i.Project__c != null) {
                    projectIdToNumOfContactsMap.put(workLog_i.Project__c, null);
                }
                if (oldMap.get(workLog_i.Id).Project__c != null) {
                    projectIdToNumOfContactsMap.put(oldMap.get(workLog_i.Id).Project__c, null);
                }
            }

        }
        if (projectIdToNumOfContactsMap.isEmpty()) {
            return;
        }

        // Remember to check that Set / List used in a SOQL is not empty.
        // Otherwise SOQL will not return any row but it will be counted in limits.
        List<AggregateResult> aggResList = [
                SELECT SUM(ActualHours__c) sumActualHours, SUM(BillableHours__c) sumBillableHours, Project__c
                FROM WorkLog__c
                WHERE Project__c IN :projectIdToNumOfContactsMap.keySet()
                GROUP BY Project__c
        ];
        if (!aggResList.isEmpty()) {
            for (AggregateResult result_i : aggResList) {
                if (projectIdToNumOfContactsMap.containsKey((Id) result_i.get('Project__c'))) {

                    projectIdToNumOfContactsMap.put((Id) result_i.get('Project__c'), new List<Decimal>{
                            (Decimal) result_i.get('sumActualHours'), (Decimal) result_i.get('sumBillableHours')
                    });
                }
            }
        }

        for (Id projectId_i : projectIdToNumOfContactsMap.keySet()) {

            projectsToUpdateList.add(
                    new Project__c(
                            Id = projectId_i,
                            Total_Actual_hours__c = projectIdToNumOfContactsMap.get(projectId_i).get(0),
                            Total_Billable_hours__c = projectIdToNumOfContactsMap.get(projectId_i).get(1)
                    )
            );


        }
        update projectsToUpdateList;
    }

}
