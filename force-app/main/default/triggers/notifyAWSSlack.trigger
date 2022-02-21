trigger notifyAWSSlack on Event (after insert,after update,before delete) {
    if(Trigger.newMap!=null) {
        system.debug('open up for demo');
   //     SlackTriggerHandler.refreshForInteractionOwners(Trigger.newMap.values());        
    }
    else if(Trigger.oldMap!=null) {
        system.debug('open up for demo');
     //   SlackTriggerHandler.refreshForInteractionOwners(Trigger.oldMap.values());        
    }
}