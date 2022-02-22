public with sharing class HandshakeInformationController {

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getPrviousHandshakeInformation(String recordId) {
        List<Interview__c> interviewEventCandidate = [Select Interview_Event_Candidate__c, Handshake_Information__c  from Interview__c where Id = :recordId];

        String interviewEventCandidateId = interviewEventCandidate.get(0).Interview_Event_Candidate__c;
        String status = 'Completed';
        List<Interview__c> interviews = [Select Id, Handshake_Information__c from Interview__c where Status__c =  'Completed'  and Interview_Event_Candidate__c = :interviewEventCandidateId order by Actual_End_Time__c];
        String previousHandshakeInfromation = '';
        String handshakeInformation = interviewEventCandidate.get(0).Handshake_Information__c;
        for(Interview__c interview : interviews) {
            if(interview.Id != recordId)
            previousHandshakeInfromation = previousHandshakeInfromation + '\n' + interview.Handshake_Information__c;
        }

        Map<String, String> interviewInformation = new Map<String, String>();
        interviewInformation.put('HandshakeInformation', handshakeInformation);
        interviewInformation.put('PreviousHandshakeInformation', previousHandshakeInfromation);
        return interviewInformation;
    }
}