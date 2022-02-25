trigger UpdateStartEndTimeOnInterview on Interview__c (before insert, before update) {
    
      Map<String, Interview__c> interviewsEligibleForDateTimeUpdates = New Map<String, Interview__c>();
    
      for(Interview__c interview:Trigger.new)
      {
          if (interview.Status__c == 'InProgress' || interview.Status__c == 'Scheduled')
          	interviewsEligibleForDateTimeUpdates.put(interview.Id,interview);
      }
        System.debug('-----Updating date time--------'+interviewsEligibleForDateTimeUpdates);

    //Now get all the schedules for these interviews
    List<EventInterviewSchedule__c> availableSchedules = [Select Id, Status__c, From__c, To__c, Hiring_Panel_Member__r.User_Name__c ,Interview__c, Interview__r.Interview_Event_Candidate__c from EventInterviewSchedule__c where Interview__c IN :interviewsEligibleForDateTimeUpdates.keySet()];
    //take any schedule for each interview
    Map<String, EventInterviewSchedule__c> interviewScheuduleMap = New Map<String, EventInterviewSchedule__c>();
    for (EventInterviewSchedule__c schedule : availableSchedules)
    {
        interviewScheuduleMap.put(schedule.Interview__c, schedule);
    }
    List<Interview__c> interviewsToBeUpdated = New List<Interview__c>();
    System.debug('-------------'+interviewScheuduleMap);
    for (String interviewId : interviewsEligibleForDateTimeUpdates.keySet())
    {
        Interview__c interview = interviewsEligibleForDateTimeUpdates.get(interviewId);
        EventInterviewSchedule__c schedule = interviewScheuduleMap.get(interviewId);
        if (schedule.Status__c == 'Scheduled')
        {
            interview.Scheduled_Start_Time__c = schedule.From__c;
            interview.Scheduled_End_Time__c = schedule.To__c;
        }
        
        if (schedule.Status__c == 'InProgress')
            interview.Actual_Start_Time__c = schedule.From__c;
        
        if (schedule.Status__c != 'Scheduled')
           interview.Actual_End_Time__c = schedule.From__c;


            
        
        interviewsToBeUpdated.add(interview);
        
    }
    
//    update interviewsToBeUpdated;

}