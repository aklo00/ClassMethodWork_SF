trigger UserTrigger on User (after update) {
    new UserTriggerHandler().execute();
}