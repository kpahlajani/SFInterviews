public with sharing class ProblemsDiscussedController {

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getPreviousProblemsDiscussed(String recordId) {
        List<Interview__c> interviewEventCandidate = [Select Interview_Event_Candidate__c, Problems_Discussed__c  from Interview__c where Id = :recordId];

        String interviewEventCandidateId = interviewEventCandidate.get(0).Interview_Event_Candidate__c;
        String status = 'Completed';
        List<Interview__c> interviews = [Select Id, Problems_Discussed__c from Interview__c where Status__c =  'Completed'  and Interview_Event_Candidate__c = :interviewEventCandidateId order by Actual_End_Time__c];
        String previousProblemDiscussed = '';
        String problemDiscussed = interviewEventCandidate.get(0).Problems_Discussed__c;
        for(Interview__c interview : interviews) {
            if(interview.Id != recordId)
            previousProblemDiscussed = previousProblemDiscussed + '\n' + interview.Problems_Discussed__c;
        }

        Map<String, String> interviewInformation = new Map<String, String>();
        interviewInformation.put('ProblemDiscussed', problemDiscussed);
        interviewInformation.put('PreviousProblemDiscussed', previousProblemDiscussed);
        return interviewInformation;
    }
}