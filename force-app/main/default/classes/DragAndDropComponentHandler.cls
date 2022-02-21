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
}