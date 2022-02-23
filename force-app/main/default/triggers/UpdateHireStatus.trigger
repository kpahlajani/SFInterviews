trigger UpdateHireStatus on Interview__c (after update) {

    List<String> eligibleInterviews = new List<String>();
    List<String> iecs = New List<String>();
    for(Interview__c interview:Trigger.new)
    {
        if(Trigger.isUpdate)
        {
            if(interview.Status__c  == 'InProgress')
            {
                eligibleInterviews.add(interview.Id);
                iecs.add(interview.Interview_Event_Candidate__c);
            }
        }
	}
    
    List<InterviewEventCandidate__c> candidates = [Select Id from InterviewEventCandidate__c where Id IN :iecs];
    List<InterviewEventCandidate__c> candidatesToBeUpdated = New List<InterviewEventCandidate__c>();
    for (InterviewEventCandidate__c candidate : candidates)
    {
        candidate.Hire_Status__c='Evaluation In Progress';
        candidatesToBeUpdated.add(candidate);
    }
    
    update candidatesToBeUpdated;
}