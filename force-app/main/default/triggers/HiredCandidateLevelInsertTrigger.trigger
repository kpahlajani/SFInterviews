trigger HiredCandidateLevelInsertTrigger on Team_Assignment__c (before insert) {

 Map<ID,Team_Assignment__c> tsCandidateId2TSObj = new  Map<ID,Team_Assignment__c>();
 for(Team_Assignment__c ts:Trigger.new){
   if(ts.Hired_Candidate_Level__c == null)
     tsCandidateId2TSObj.put(ts.Hired_Candidate__c,ts);
 }
 
 for(Hired_Candidate__c hc : [select Id,Candidate_Level__c from Hired_Candidate__c where Id in :tsCandidateId2TSObj.keySet()]){
  tsCandidateId2TSObj.get(hc.Id).Hired_Candidate_Level__c = hc.Candidate_Level__c;
 }
 
}