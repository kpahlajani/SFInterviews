public with sharing class InterviewCandidatesGridHelper {
    @AuraEnabled(cacheable=true)
    public static List<InterviewEventCandidate__c> getCandidatesList(ID recordId) {
        return [Select Id,Candidate_Name__c,Current_Status__c,Ongoing_Interview__r.Name from InterviewEventCandidate__c WHERE InterviewEvent__c = :recordId];
    }
}