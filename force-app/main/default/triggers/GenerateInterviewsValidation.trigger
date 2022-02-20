trigger GenerateInterviewsValidation on InterviewEventCandidate__c (before insert, before update) {
Map<ID, Set<String>> eventLevelMap = new Map<ID, Set<String>>();
     Map<ID, Set<String>> candidateEventMap = new Map<ID, Set<String>>();
     for (InterviewEventCandidate__c participant: Trigger.new) {
         if (participant.InterviewEvent__c != Null){
             if (eventLevelMap.get(participant.InterviewEvent__c) != null)
             {
                 eventLevelMap.put(participant.InterviewEvent__c, New Set<String>());
             }
             if (candidateEventMap.get(participant.Candidate__c) != null)
             {
                 candidateEventMap.put(participant.Candidate__c, New Set<String>());
             }
             Set<String> levelSet = eventLevelMap.get(participant.InterviewEvent__c);
             Set<String> eventSet = candidateEventMap.get(participant.Candidate__c);
              if (eventSet == null)
                 eventSet = new Set<String>();
             if (levelSet == null)
                 levelSet = new Set<String>();
             levelSet.add(participant.Candidate_Level__c);
             eventSet.add(participant.InterviewEvent__c);
             candidateEventMap.put(participant.Candidate__c, eventSet);
             eventLevelMap.put(participant.InterviewEvent__c, levelSet);
         }
   }
    
    
    //Get all existing participants for these events
    List<InterviewEventCandidate__c> existingParticipants = [Select Id, InterviewEvent__c, Candidate__c from InterviewEventCandidate__c where InterviewEvent__c IN :eventLevelMap.keySet()];
    for (InterviewEventcandidate__c iec : existingParticipants)
    {
        String candidateId = iec.Candidate__c;
        String eventId = iec.InterviewEvent__c;
        Set<String> eventIds = candidateEventMap.get(candidateId);
        if (eventIds == null || eventIds.isEmpty())
            continue;
        if (eventIds.contains(eventId))
        {
            throw new SFInterviewException('Candidate is already part of this event');
        }
        
    }
}