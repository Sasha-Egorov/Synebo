/**
 * Created by Alex on 06.09.2021.
 */
@IsTest
public with sharing class ProjectDataFixBatchTest {

    @TestSetup
    static void testSetup() {
        Project__c testProject = new Project__c(
                Name = 'Name'
        );
        insert testProject;

        WorkLog__c testWorkLog = new WorkLog__c(
                Project__c = testProject.Id,
                ActualHours__c = 20.0,
                BillableHours__c = 10.0,
                Description__c = 'WorkLog'
        );
        insert testWorkLog;
    }

    @IsTest
    static void batchTest() {

        WorkLog__c workLogTest = [
                SELECT Id, ActualHours__c, BillableHours__c
                FROM WorkLog__c
                WHERE Description__c = 'WorkLog'
        ];


        Test.startTest();
        ProjectDataFixBatch projectBatch = new ProjectDataFixBatch();
        Id batchJob = Database.executeBatch(projectBatch);
        Test.stopTest();
        Project__c projectTest = [
                SELECT Id, Total_Actual_Hours__c, Total_Billable_Hours__c
                FROM Project__c
                WHERE Name = 'Name'
        ];
        System.assertEquals(projectTest.Total_Actual_Hours__c, workLogTest.ActualHours__c);
        System.assertEquals(projectTest.Total_Billable_Hours__c, workLogTest.BillableHours__c);

    }

}