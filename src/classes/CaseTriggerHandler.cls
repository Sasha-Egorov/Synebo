/**
 * Created by Alex on 06.09.2021.
 */

public with sharing class CaseTriggerHandler extends TriggerHandler {

    public CaseTriggerHandler() {
    }

    public override void afterUpdate() {
        this.validateClosedCase((List<Case>) Trigger.new, (Map<Id, Case>) Trigger.oldMap);
    }
    public void validateClosedCase(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {

        for (Case case_i : newCase0List) {

            if (Trigger.isUpdate && case_i.Status != oldCaseMap.get(case_i.Id).Status) {
                System.Debug('start');
                if (case_i.IsClosed) {
                    System.Debug('parent');
                    System.Debug(case_i.IsClosed);

                    for (Case childCase_i : [SELECT CaseNumber, Status, IsClosed FROM Case WHERE ParentId = :case_i.Id]) {
                        System.Debug(!childCase_i.IsClosed);
                        if (!childCase_i.IsClosed) {
                            System.Debug('child');
                            System.Debug(!childCase_i.IsClosed);
                            case_i.addError(Label.ChildIsOpen);
                        }
                    }

                }
            }

        }
    }
}