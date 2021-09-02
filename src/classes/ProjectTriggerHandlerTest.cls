@isTest
public with sharing class ProjectTriggerHandlerTest {

    @TestSetup
    static void setupTestData() {

        Contact contactTest = new Contact(
                FirstName = 'Sasha',
                LastName = 'Test',
                Email = 'egorovsasha@ukr.net'
        );
        insert contactTest;

        Project__c projectTest = new Project__c(
                Name = 'Test Project',
                Contact__c = contactTest.id,
                Status__c = 'Backlog'
        );

        insert projectTest;
        Issue__c testIssue = new Issue__c(
                Project__c = projectTest.Id,
                Status__c = 'To Do'
        );
        insert testIssue;
    }


    @isTest
    static void validateDeleteProjectTest() {
        // given
        Project__c testProject = [SELECT Id, Name FROM Project__c WHERE Name = 'Test Project' LIMIT 1];

        // when & then
        try {
            delete testProject;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('You are not allowed to close or delete Project if at least one Issue is still open.'));
        }

        Issue__c issueTest = [SELECT Id, Status__c FROM Issue__c WHERE Project__c = :testProject.id LIMIT 1];
        issueTest.Status__c = 'Done';
        update issueTest;

        // when & then
        try {
            delete testProject;
        } catch (Exception ex) {
            System.assert(false, 'Exception was not expected');
        }
    }


    @isTest
    static void validateChangeStatusProjectTest() {
        // given
        Project__c testProject = [SELECT Id, Name FROM Project__c WHERE Name = 'Test Project' LIMIT 1];

        // when & then
        try {
            testProject.Status__c = 'Closed';
            update testProject;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('You are not allowed to close or delete Project if at least one Issue is still open.'));
        }

        Issue__c issueTest = [SELECT Id, Status__c FROM Issue__c WHERE Project__c = :testProject.id LIMIT 1];
        issueTest.Status__c = 'Done';
        update issueTest;

        // when & then
        try {
            testProject.Status__c = 'Closed';
            update testProject;
        } catch (Exception ex) {
            System.assert(false, 'Exception was not expected');
        }

    }


    @isTest
    static void sendEmailTest() {

        Project__c testProject = [SELECT Id, Name FROM Project__c WHERE Name = 'Test Project' LIMIT 1];
        test.startTest();
        testProject.Status__c = 'New';
        update testProject;

        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(0, invocations, 'An email should not be sent');

        testProject.Status__c = 'In Progress';
        update testProject;

        invocations = Limits.getEmailInvocations();
        System.assertEquals(1, invocations, 'An email should be sent');
        test.stopTest();

    }

}