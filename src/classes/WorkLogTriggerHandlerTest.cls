@IsTest
public with sharing class WorkLogTriggerHandlerTest {

    @IsTest
    static void specifyDateTest() {
        // when
        WorkLog__c testWorkLog = new WorkLog__c(
                Type__c = 'Issue',
                ActualHours__c = 12.0,
                BillableHours__c = 1.0
        );
        insert testWorkLog;

        // then
        testWorkLog = [
                SELECT Id, Date__c
                FROM WorkLog__c
                WHERE Id = :testWorkLog.Id
        ];
        System.assertEquals(Date.TODAY(), testWorkLog.Date__c);
    }


    @IsTest
    static void totalHours() {
        Project__c testProject = new Project__c();
        insert testProject;
        WorkLog__c testWorkLog = new WorkLog__c(
                Type__c = 'Issue',
                ActualHours__c = 12,
                BillableHours__c = 10,
                Project__c = testProject.Id
        );
        insert testWorkLog;

        Project__c resultProject = [
                SELECT Id, Total_Actual_hours__c,Total_Billable_hours__c
                FROM Project__c
                WHERE Id = :testProject.Id
        ];
        System.assertEquals(testWorkLog.ActualHours__c, resultProject.Total_Actual_hours__c);
        System.assertEquals(testWorkLog.BillableHours__c, resultProject.Total_Billable_hours__c);

        testWorkLog.ActualHours__c = 1.0;
        testWorkLog.BillableHours__c = 1.0;
        update testWorkLog;

        resultProject = [
                SELECT Id, Total_Actual_hours__c,Total_Billable_hours__c
                FROM Project__c
                WHERE Id = :testProject.Id
        ];
        System.assertEquals(1.0, resultProject.Total_Actual_hours__c);
        System.assertEquals(1.0, resultProject.Total_Billable_hours__c);
        WorkLog__c testWorkLog2 = new WorkLog__c(
                Type__c = 'Issue',
                BillableHours__c = 10,
                Project__c = testProject.Id
        );
        insert testWorkLog2;

        delete testWorkLog2;

        resultProject = [
                SELECT Id, Total_Actual_hours__c,Total_Billable_hours__c
                FROM Project__c
                WHERE Id = :testProject.Id
        ];
        System.assertEquals(1.0, resultProject.Total_Actual_hours__c);
        System.assertEquals(1.0, resultProject.Total_Billable_hours__c);

        undelete testWorkLog2;
        resultProject = [
                SELECT Id, Total_Actual_hours__c,Total_Billable_hours__c
                FROM Project__c
                WHERE Id = :testProject.Id
        ];
        System.assertEquals(1.0, resultProject.Total_Actual_hours__c);
        System.assertEquals(11.0, resultProject.Total_Billable_hours__c);


    }
}