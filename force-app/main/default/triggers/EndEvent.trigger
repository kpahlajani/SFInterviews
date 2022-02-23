trigger EndEvent on InterviewEvent__c (after update) {

    List<Id> eligibleEventIds = new List<Id>();
    for(InterviewEvent__c ie:Trigger.new)
    {
        if(Trigger.isUpdate)
        {
            if((ie.State__c  == 'Completed') && ((Trigger.oldMap.get(ie.Id).State__c)!='Completed'))
            {
                eligibleEventIds.add(ie.Id);
            }
        }
	}

    List<Hired_Candidate__c> hiredCandidates = new List<Hired_Candidate__c>();
    for(InterviewEventCandidate__c iec: [SELECT Id, Candidate_Level__c, Candidate__c  FROM InterviewEventCandidate__c where Hire_status__c='Hired'  and InterviewEvent__c in :eligibleEventIds]){
        hiredCandidates.add(new Hired_Candidate__c(Interview_Event_Candidate__c=iec.Id,Candidate__c=iec.Candidate__c,Candidate_Level__c=iec.Candidate_Level__c,Allocation_Status__c='Unallocated'));
    }

    insert hiredCandidates;
    
}