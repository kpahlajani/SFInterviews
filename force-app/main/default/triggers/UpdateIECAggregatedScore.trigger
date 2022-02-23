trigger UpdateIECAggregatedScore on Interview__c (after insert, after update) {

    Set<String> allIECs = New Set<String>();
    Set<String> interviewIds = New Set<String>();
    for(Interview__c interview:Trigger.new)
    {
        allIECs.add(interview.Interview_Event_Candidate__c);
        interviewIds.add(interview.Id);
    }
    //Create map of EIC to Interview
    Map<String, Set<Interview__c>> iecInterviewItemMap = New Map<String, Set<Interview__c>>();
    List<Interview__c> allInterviews = [Select Id,Overall_Rating__c ,Interview_Event_Candidate__c  from Interview__c where Interview_Event_Candidate__c IN :allIECs];
    for (Interview__c interview : allInterviews)
    {
        if (iecInterviewItemMap.get(interview.Interview_Event_Candidate__c) == null)
            iecInterviewItemMap.put(interview.Interview_Event_Candidate__c, new Set<Interview__c>());
        Set<Interview__c> interviews = iecInterviewItemMap.get(interview.Interview_Event_Candidate__c);
        interviews.add(interview);
        iecInterviewItemMap.put(interview.Interview_Event_Candidate__c, interviews);
    }
    
    //Now get all the candidates in the keyset 
    
    List<InterviewEventCandidate__c> allIECObjs = [Select Id, Aggregated_Score__c  from InterviewEventCandidate__c where Id IN :iecInterviewItemMap.keySet()];
    
    //Iterate candidates , calculate average of interview items, and update candidates
    List<InterviewEventCandidate__c> iecsToUpdate = New List<InterviewEventCandidate__c>();
    for(InterviewEventCandidate__c iec : allIECObjs)
    {
        Set<Interview__c> interviews = iecInterviewItemMap.get(iec.Id);
        Integer capturedItems = 1;
        Integer totalScore = 0;
        for(Interview__c interview : interviews)
        {
            if (interview.Overall_Rating__c != null)
            {
                System.debug('Considering this item');
              	totalScore+=Integer.valueOf(interview.Overall_Rating__c);
                capturedItems++;
            }
        }
        if (capturedItems != 1)
            capturedItems--;
        Double finalScore = (Double)totalScore/capturedItems;
        System.debug('Overall Score is ' + finalScore);
        iec.Aggregated_Score__c  = finalScore;
        iecsToUpdate.add(iec);
    }
    update iecsToUpdate;

}