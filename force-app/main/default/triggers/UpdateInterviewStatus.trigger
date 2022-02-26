trigger UpdateInterviewStatus on Interview__c (after update , after insert) {

    //For each interview , get the IEC
    //Get all the interviews for each IEC and update the report on IEC
    List<String> allIECs = New List<String>();
     for(Interview__c interview:Trigger.new)
      {
         allIECs.add(interview.Interview_Event_Candidate__c);
      }
    List<InterviewEventCandidate__c> allCandidates = [Select Id, Total_Interactions__c , Completed_Interactions__c from InterviewEventCandidate__c where Id IN : allIECs];
    Map<String, InterviewEventCandidate__c> iecMap = new Map<String, InterviewEventCandidate__c>();
    for (InterviewEventCandidate__c candidate : allCandidates)
    {
        iecMap.put(candidate.Id, candidate);
    }
    //For each IEC , the total interviews and completed interviews
    List<Interview__c> allInterviews = [Select Id, Status__c, Interview_Event_Candidate__c from Interview__c where Interview_Event_Candidate__c IN :iecMap.keySet()];
    //Capture total and complete info for each IEC
    Map<String, Integer> totalMap = New Map<String, Integer>();
    Map<String, Integer> completedMap = New Map<String, Integer>();
    
    for (Interview__c interview : allInterviews)
    {
        String iec = interview.Interview_Event_Candidate__c;
        if (totalMap.get(iec) == null)
            totalMap.put(iec, 1);
        else
            totalMap.put(iec, totalMap.get(iec)+1);
        
        if (interview.Status__c == 'Completed')
        {
            if (completedMap.get(iec) == null)
           	 completedMap.put(iec, 1);
        	else
             completedMap.put(iec, completedMap.get(iec)+1);
        }
        
    }
    
    //update IEC with this info now,
    List<InterviewEventCandidate__c> iecsToBeUpdated = New List<InterviewEventCandidate__c>();
    
    for (String iec : iecMap.keySet())
    {
        InterviewEventCandidate__c candidate = iecMap.get(iec);
        Integer totalInterviews = 0;
        if (totalMap.containsKey(iec))
            totalInterviews = totalMap.get(iec);
        Integer completedInterviews = 0;
        if (completedMap.containsKey(iec))
            completedInterviews = completedMap.get(iec);
        candidate.Total_Interactions__c = totalInterviews;
        candidate.Completed_Interactions__c = completedInterviews;
        iecsToBeUpdated.add(candidate);
    }
    
  update iecsToBeUpdated;
    
}