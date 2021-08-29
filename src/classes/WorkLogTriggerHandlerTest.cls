@IsTest
public with sharing class WorkLogTriggerHandlerTest {

    @IsTest
    static void specifyDateTest() {
        // when
        WorkLog__c testWorkLog = new WorkLog__c(
                Type__c = 'Issue',
                ActualHours__c = 12
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

}