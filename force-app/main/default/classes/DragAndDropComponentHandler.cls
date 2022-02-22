public with sharing class DragAndDropComponentHandler {
    
    @AuraEnabled
    public static List<InterviewEventCandidate__c> getAllTask(){
        Id loggedInUserId = UserInfo.getUserId();
        return [Select Id, Name, Candidate_Name__c,Candidate_Level__c,Interview__r.Name from InterviewEventCandidate__c];
    }

    @AuraEnabled
    public static void updateTask(Id interviewCanidateId, Id newInterview){
        InterviewEventCandidate__c updateInterviewRound = new InterviewEventCandidate__c(Id = interviewCanidateId, Interview__c = newInterview);
        Database.update(updateInterviewRound);
    }
    
    @AuraEnabled
    public static Id getSelectedInterviewRoundForCandidate(Id interviewEventCandidate, Id questionaireId)
        {
            //Assumption is for now , no adhoc interview. There will be 1:1 mapping between questionaire and intervew for a given interview event candidate.
            //Get all the interviews for interview event candidate where questionaireId = given Id
            List<Interview__c> interviews = [Select Id from Interview__c where Interview_Event_Candidate__c =:interviewEventCandidate and Questionaire__c=:questionaireId];
            if (interviews.size() > 0)
                return interviews.get(0).Id;
            return '';
        }
    
    @AuraEnabled
    public static void updatePreviousAndOngoingInterview(Id interviewEventCandidate, Id newQuestionaireId)
    {
        InterviewEventCandidate__c candidate = [Select Id,Previous_Interview__c, Ongoing_Interview__c  from InterviewEventCandidate__c where Id=:interviewEventCandidate];
    	Id newInterview = getSelectedInterviewRoundForCandidate(interviewEventCandidate,newQuestionaireId);
        Id ongoingInterview = candidate.Ongoing_Interview__c;
        if (ongoingInterview != null)
        {
           candidate.Previous_Interview__c = ongoingInterview;
        }
        //Set New ongoing interview
        if (newInterview != null)
        {
            candidate.Ongoing_Interview__c = newInterview;
        }
        
        update candidate;
    }
      
}