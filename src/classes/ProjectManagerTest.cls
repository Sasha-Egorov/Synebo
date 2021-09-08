/**
 * Created by Alex on 08.09.2021.
 */

@IsTest
public with sharing class ProjectManagerTest {

    @IsTest
    static void testGetProjectList() {
        String status = 'New';
        RestRequest request = new RestRequest();
        request.requestURI = 'https://yourInstance.my.salesforce.com/services/apexrest/Project?status=' + status;
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<Project__c> projects = ProjectManager.getProjectList();
        List<Project__c> projectsResult = [
                SELECT Id, Status__c
                FROM Project__c
                WHERE Status__c = 'New'
        ];
        System.assertEquals(projectsResult.size(), projects.size());

    }

    @IsTest
    static void testCreateProject() {

        RestRequest request = new RestRequest();
        request.requestURI = 'https://yourInstance.my.salesforce.com//services/apexrest/Project/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"Name":"Name","Status__c":"Open","Priority__c":"High","email": "test1@me.com"}');
        RestContext.request = request;
        Id thisProjectId = ProjectManager.createProject();
        Project__c thisProject = [
                SELECT Id
                FROM Project__c
                WHERE Name = 'Name'
                LIMIT 1
        ];
        System.assertEquals(thisProjectId, thisProject.Id);
    }
}