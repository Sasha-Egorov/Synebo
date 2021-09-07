/**
 * Created by Alex on 07.09.2021.
 */

@IsTest
public with sharing class CaseTriggerHandlerTest {

    @TestSetup
    static void testSetup() {
        Case parentCaseTest = new Case(
                Subject = 'testSubject',
                Status = 'New'
        );
        insert parentCaseTest;

        Case childCaseTest = new Case(
                Subject = 'testChildSubject',
                Status = 'New',
                ParentId = parentCaseTest.Id
        );
        insert childCaseTest;
    }

    @IsTest
    static void validateCloseCasesTest() {
        Case parentCaseTest = [
                SELECT Id, Status
                FROM Case
                WHERE Subject = 'testSubject'
        ];

        Case childCaseTest = [
                SELECT Id
                FROM Case
                WHERE ParentId = :parentCaseTest.Id
        ];
        parentCaseTest.Status = 'Closed';

        try {
            update parentCaseTest;
            System.assert(false, System.Label.ChildIsOpen);
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.ChildIsOpen));
        }

        childCaseTest.Status = 'Closed';
        update childCaseTest;

        try {
            update parentCaseTest;
        } catch (Exception ex) {
            System.assert(false, System.Label.ChildIsOpen);
        }
    }
}