trigger notifyAWSSlack on Event (after insert,after update,before delete) {
    if(Trigger.newMap!=null) {
        SlackTriggerHandler.refreshForInteractionOwners(Trigger.newMap.values());        
    }
    else if(Trigger.oldMap!=null) {
        SlackTriggerHandler.refreshForInteractionOwners(Trigger.oldMap.values());        
    }
}