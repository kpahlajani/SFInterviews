trigger notifyAWSSlack on Event (after insert,after update) {

List<Event> interactions =[SELECT Id, Owner.name, Owner.email, WhatId ,StartDateTime, EndDateTime, DurationInMinutes,(SELECT RelationId FROM EventRelations)
                    , typeof what when Interview__c then Candidate__c,Candidate_Name__c,Code_Pair__c,Google_Meet__c end FROM Event WHERE Id in :Trigger.new and What.Type IN ('Interview__c')];
                    
if(interactions.size()==0)
 return;
 
String eventType='NEW_INTERACTION'; 
                    
for(Event evt:interactions) {
    
    Interview__c interview=(Interview__c) evt.what;

    if(Trigger.isUpdate) {
      eventType = 'UPDATED_INTERACTION';
    }
    
    Map<String,String> mp =new Map<String,String>();
    mp.put('eventType',eventType);
    mp.put('email',evt.Owner.email);
    mp.put('role',evt.getSObjects('EventRelations')==null?'Observer':'Main');
    mp.put('startTime',string.valueofGmt(evt.StartDateTime));
    mp.put('endTime',string.valueofGmt(evt.StartDateTime));
    mp.put('duration',''+evt.DurationInMinutes); 
    mp.put('candidateName',interview.get('Candidate_Name__c').toString());  
    mp.put('candidateId',interview.get('Candidate__c').toString());
    mp.put('meetingLink',interview.get('Google_Meet__c').toString());    
    mp.put('codingLink',interview.get('Code_Pair__c').toString());        
    
    
   // SajApx.myAWSCallout(mp);
    

}
}