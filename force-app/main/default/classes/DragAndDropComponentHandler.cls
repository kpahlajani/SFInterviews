public with sharing class DragAndDropComponentHandler {
    
    @AuraEnabled
    public static List<Task> getAllTask(){
        Id loggedInUserId = UserInfo.getUserId();
        return [Select Id, Owner.Name, Subject, Status, WhoId, WhatId, Who.Name, What.Name, Description from Task where OwnerId = :loggedInUserId];
    }

    @AuraEnabled
    public static void updateTask(Id newTaskId, String newStatus){
        Task updateTask = new Task(Id = newTaskId, Status = newStatus);
        Database.update(updateTask);
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