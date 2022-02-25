trigger UpdateInterviewStatus on Interview__c (before update) {

    if(Trigger.isUpdate) {
        for(Interview__c interview : Trigger.new) {
            if(Trigger.oldMap.get(interview.Id).Status__c!='Scheduled') {
                if(interview.Status__c == 'InProgress') {
                	interview.Status__c.addError('Can not update status');
                }
            }
        }
    }
}