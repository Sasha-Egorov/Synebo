/**
 * Created by Alex on 06.09.2021.
 */

global without sharing class ContactDataFixBatch implements Database.Batchable<sObject> {

    private String query;

    public ContactDataFixBatch(String country) {
        country = String.isNotBlank(country) ? country : 'USA';
        this.query = 'SELECT ID, BillingStreet, BillingCity, BillingState, '
                + ' BillingPostalCode, (SELECT ID, MailingStreet, MailingCity, '
                + ' MailingState, MailingPostalCode FROM Contacts) '
                + 'FROM Account '
                + 'WHERE BillingCountry = \'' + country + '\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                this.query
        );
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        // process each batch of records
        List<Contact> contactList = new List<Contact>();
        for (Account account_i : scope) {
            for (Contact contact_i : account_i.contacts) {
                contact_i.MailingStreet = account_i.BillingStreet;
                contact_i.MailingCity = account_i.BillingCity;
                contact_i.MailingState = account_i.BillingState;
                contact_i.MailingPostalCode = account_i.BillingPostalCode;

                // add contact to list to be updated
                contactList.add(contact_i);
            }
        }
        update contactList;
    }
    global void finish(Database.BatchableContext bc) {

        AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];

    }
}