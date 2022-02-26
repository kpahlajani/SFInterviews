public with sharing class InterviewCandidatesGridHelper {
    @AuraEnabled(cacheable=true)
    public static List<InterviewEventCandidate__c> getCandidatesList(ID recordId) {
        return [Select Id,Name,Candidate_Name__c,Current_Status__c,Ongoing_Interview__r.Name,Aggregated_Score__c,Ongoing_Interview__r.Scheduled_Start_Time__c, toLabel(Candidate_Level__c), Current_Interviewers__c from InterviewEventCandidate__c WHERE InterviewEvent__c = :recordId ORDER BY Current_Status__c DESC NULLS LAST, Aggregated_Score__c ASC NULLS LAST];
    }

    @AuraEnabled(cacheable=true)
    public static List<InterviewEventCandidate__c> getCandidateListWithFilter( ID recordId, string searchKey, string columnName){
        List <InterviewEventCandidate__c> candidateList = new List<InterviewEventCandidate__c>();
        string query = 'Select Id,Name,Candidate_Name__c,Current_Status__c, Total_Interactions__c, Completed_Interactions__c, Ongoing_Interview__r.Name,Aggregated_Score__c,Ongoing_Interview__r.Scheduled_Start_Time__c, toLabel(Candidate_Level__c), Current_Interviewers__c from InterviewEventCandidate__c WHERE InterviewEvent__c = :recordId' ; 
        if(!String.isEmpty(searchKey) && !String.isEmpty(columnName)){
            query += ' AND '+columnName+' LIKE \'%'+searchKey+'%\'';
        }
        candidateList = Database.query(query);
        return candidateList;
    }

    @AuraEnabled
    public static List<InterviewEventCandidate__c> getUpdatedCandidatesList(ID recordId, string searchKey, string columnName) {
        return getCandidateListWithFilter(recordId, searchKey, columnName);
    }


 
}