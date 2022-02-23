public with sharing class InterviewCandidatesGridHelper {
    @AuraEnabled(cacheable=true)
    public static List<InterviewEventCandidate__c> getCandidatesList(ID recordId) {
        return [Select Id,Name,Candidate_Name__c,Current_Status__c,Ongoing_Interview__r.Name,Aggregated_Score__c,Ongoing_Interview__r.Scheduled_Start_Time__c, toLabel(Candidate_Level__c) from InterviewEventCandidate__c WHERE InterviewEvent__c = :recordId];
    }
 
}