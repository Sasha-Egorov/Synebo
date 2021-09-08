/**
 * Created by Alex on 08.09.2021.
 */
@RestResource(UrlMapping='/Project/*')
global with sharing class ProjectManager {

    public class ProjectWrapper {
        public String name { get; set; }
        public String status { get; set; }
        public String priority { get; set; }
        public String email { get; set; }
    }


    @HttpGet
    global static List<Project__c> getProjectList() {
        RestRequest req = RestContext.request;
        String status = req.params.get('status');

        List<Project__c> newProjectList = [
                SELECT Name, Priority__c, Description__c
                FROM Project__c
                WHERE Status__c = :status
        ];
        return newProjectList;
    }

    @HttpPost
    global static Id createProject() {

        RestRequest request = RestContext.request;
        ProjectWrapper projectData = (ProjectWrapper) JSON.deserialize(request.requestBody.toString(), ProjectWrapper.class);
        Project__c project;
        try {
            Contact contact = [
                    SELECT Id
                    FROM Contact
                    WHERE Email = :projectData.email
                    LIMIT 1
            ];
            project = new Project__c(
                    Name = projectData.name,
                    Status__c = projectData.status,
                    Priority__c = projectData.priority,
                    Contact__c = contact.Id
            );
        } catch (Exception e) {
            Contact newContact = new Contact(LastName = 'UNKNOWN',
                    Email = projectData.email);
            insert newContact;

            project = new Project__c(
                    Name = projectData.name,
                    Status__c = projectData.status,
                    Priority__c = projectData.priority,
                    Contact__c = newContact.Id
            );
        }
        insert project;
        return project.Id;
    }
}