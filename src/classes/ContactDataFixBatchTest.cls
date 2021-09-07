/**
 * Created by Alex on 06.09.2021.
 */

@IsTest
public with sharing class ContactDataFixBatchTest {

    @TestSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Account ' + i,
                    BillingCity = 'Toronto', BillingCountry = 'Canada'));
        }
        insert accounts;

        for (Account account : [
                SELECT Id
                FROM Account
        ]) {
            contacts.add(new Contact(FirstName = 'first',
                    LastName = 'last', AccountId = account.Id));
        }
        insert contacts;
    }

    @IsTest
    static void test() {
        Test.startTest();
        ContactDataFixBatch uca = new ContactDataFixBatch('Canada');
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        System.assertEquals(10, [
                SELECT COUNT()
                FROM Contact
                WHERE MailingCity = 'Toronto'
        ]);
    }
}