trigger UpdateInterviewEventCandidateInterviewersAndStatusUpdate on Interview__c (after update, after insert) {

    // Case 1 : If interview is updated to in progress, 
    	// Check there should be only one interview that is in progress - To be done later
     	// Update IEC current status to In progress - Yes
     	// update ongoing interview to this interview in iec - Yes , can be combined with in progress
     	// Update interviewers in IEC - Yes , can be combined with in progress.
    
    // Case 2 : If interview is updated to scheduled
    	// Check that there is no In progress interview at this point for this candidate.
    	// Update ongoing interview in iec to this interview
    	// update interviewers
    
    // Case 3 : If interview is updated to any other state.
    	// Move ongoing to previous and clear interviewers
    	// In all other cases update the status to waiting.
    
    Map<String, String> iecStatusMap = new Map<String, String>();
    Map<String, Set<String>> iecInterviewersMap = new Map<String, Set<String>>();
    Map<String, Interview__c> interviewMap = New Map<String, Interview__c>();
    List<String> iecIds = New List<String>();
    for(Interview__c interview:Trigger.new)
    {
        if(interview.Status__c  == 'InProgress' || interview.Status__c  == 'Scheduled')
         {
            String status = 'Scheduled';
            if (interview.Status__c =='InProgress')
				status = 'In Progress';
                iecStatusMap.put(interview.Interview_Event_Candidate__c, status);
         }else
         {
            iecStatusMap.put(interview.Interview_Event_Candidate__c, 'Waiting');
         }
        interviewMap.put(interview.Id, interview);
        iecIds.add(interview.Interview_Event_Candidate__c);
	}
    
    List<EventInterviewSchedule__c> availableSchedules = [Select Id, Status__c, From__c, To__c, Hiring_Panel_Member__r.User_Name__c ,Interview__c, Interview__r.Interview_Event_Candidate__c from EventInterviewSchedule__c where Interview__c IN :interviewMap.keySet()];
    Map<String, Set<EventInterviewSchedule__c>> allInterviewSchedules = New Map<String, Set<EventInterviewSchedule__c>>();
    List<InterviewEventCandidate__c> iecs = [Select Id,Current_Status__c, Ongoing_Interview__c from InterviewEventCandidate__c where Id IN :iecIds];
    Map<String, InterviewEventCandidate__c> iecsMap = New Map<String, InterviewEventCandidate__c>();
    for (InterviewEventCandidate__c iec : iecs)
    {
        iecsMap.put(iec.Id, iec);
    }
    
    
    //Group schedules by interview 
    for (EventInterviewSchedule__c schedule : availableSchedules)
     {
         String interviewId = schedule.Interview__c;
         if (!allInterviewSchedules.containsKey(interviewId))
         {
             allInterviewSchedules.put(interviewId, New Set<EventInterviewSchedule__c>());
         }
         Set<EventInterviewSchedule__c> interviewSchedules = allInterviewSchedules.get(interviewId);
         interviewSchedules.add(schedule);
         allInterviewSchedules.put(interviewId, interviewSchedules);
     }
    List<InterviewEventCandidate__c> candidatesToBeUpdated = New List<InterviewEventCandidate__c>();
    //Now iterate each interview and collect the IECs to be updated.
    System.debug('====='+iecsMap);
    System.debug('==Interview Map==='+interviewMap);
    system.debug('Status map is .....' + iecStatusMap);
    for (String interviewId : interviewMap.keySet())
    {
        String iecId = interviewMap.get(interviewId).Interview_Event_Candidate__c;
        InterviewEventCandidate__c candidate = iecsMap.get(iecId);
        Set<EventInterviewSchedule__c> interviewSchedules = allInterviewSchedules.get(interviewId);
        //when EIC is created , interviews are generated without interviewers , hence return if there are no schedules available.
        if (interviewSchedules == null || interviewSchedules.isEmpty())
        {
            System.debug('All the schedules are null or empty....l...');
            continue;
        }
        
        if (candidate != null)
        {
            System.debug('Candidate to be updated .......');
            candidate.Current_Status__c = iecStatusMap.get(iecId);
            System.debug('Updated the status of the candidate as .......'+iecStatusMap.get(iecId));
            List<String> interviewers = New List<String>();
            for (EventInterviewSchedule__c schedule : interviewSchedules)
            {
                String user = schedule.Hiring_Panel_Member__r.User_Name__c;
                System.debug('User getting assigned is ........'+user);
                interviewers.add(user);
               // interviewers.remove(null);
            }
            string interviewersStr = string.join(interviewers,',');
                            System.debug('User getting assigned is .......Final String.'+interviewersStr);
            candidate.Current_Interviewers__c = interviewersStr;
            Id ongoingInterview = candidate.Ongoing_Interview__c;
            Interview__c ongoingInterviewObj = interviewMap.get(interviewId);
            if (ongoingInterview != null)
            {
               candidate.Previous_Interview__c = ongoingInterview;
            }
            //Set New ongoing interview
            if (ongoingInterviewObj.Status__c == 'Scheduled' || ongoingInterviewObj.Status__c == 'InProgress')
            	candidate.Ongoing_Interview__c = interviewId;
            else
               candidate.Ongoing_Interview__c = null;

       }
        candidatesToBeUpdated.add(candidate);
    }
    update candidatesToBeUpdated;
    
}