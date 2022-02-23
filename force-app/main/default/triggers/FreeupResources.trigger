trigger FreeupResources on Interview__c (after update) {

    Map<Id, String> eligibleInterviews = new Map<Id, String>();
    for(Interview__c interview:Trigger.new)
    {
        if(Trigger.isUpdate)
        {
            if((interview.Status__c  != 'Scheduled' && interview.Status__c  != 'InProgress') && ((Trigger.oldMap.get(interview.Id).Status__c)=='Scheduled'))
            {
                eligibleInterviews.put(interview.Id, interview.Status__c);
            }
        }
	}
        System.debug('Eligible interviews ======'+eligibleInterviews);

    List<EventInterviewSchedule__c> matchingSchedules = [Select Id, interview__c from EventInterviewSchedule__c  where interview__c IN :eligibleInterviews.keySet()];
            System.debug('Matching Schedules ======'+matchingSchedules);

    Map<String, Set<EventInterviewSchedule__c>> scheduleMap = new Map<String, Set<EventInterviewSchedule__c>>();
    for (EventInterviewSchedule__c matchingSchedule : matchingSchedules)
    {
		Id interviewId = matchingSchedule.Interview__c;
        if (scheduleMap.get(interviewId) == null)
            scheduleMap.put(interviewId, New Set<EventInterviewSchedule__c>());
        Set<EventInterviewSchedule__c> scheduleSet = scheduleMap.get(interviewId);
        scheduleSet.add(matchingSchedule);
        scheduleMap.put(interviewId, scheduleSet);
    }
    List<EventInterviewSchedule__c> toBeUpdatedEventInterviewSchedules = new  List<EventInterviewSchedule__c>();
    for (Id interview : scheduleMap.keySet())
    {
        String interviewStatus = eligibleInterviews.get(interview);
        Set<EventInterviewSchedule__c> eiss = scheduleMap.get(interview);
        for (EventInterviewSchedule__c eis : eiss)
        {
        	eis.Status__c = interviewStatus;
        	toBeUpdatedEventInterviewSchedules.add(eis);
        }
    }
    System.debug('========='+toBeUpdatedEventInterviewSchedules);
    update toBeUpdatedEventInterviewSchedules;
    
}