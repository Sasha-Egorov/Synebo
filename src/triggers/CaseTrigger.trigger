/**
 * Created by Alex on 06.09.2021.
 */

trigger CaseTrigger on Case (after update) {
    CaseTriggerHandler caseTrigger = new CaseTriggerHandler();
    caseTrigger.run();

}