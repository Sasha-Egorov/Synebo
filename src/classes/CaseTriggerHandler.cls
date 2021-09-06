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

        for (Case case_i : newCaseList) {

            if (Trigger.isUpdate && case_i.Status != oldCaseMap.get(case_i.Id).Status) {

                if (case_i.IsClosed) {
                    for (Case childCase_i : [SELECT CaseNumber, Status, IsClosed FROM Case WHERE ParentId = :case_i.Id]) {
                        if (!childCase_i.IsClosed) {
                            case_i.addError(Label.ChildIsOpen);
                        }
                    }
                }
            }
        }
    }
}