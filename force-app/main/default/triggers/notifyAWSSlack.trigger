trigger notifyAWSSlack on Event (after insert,after update) {


List<Event> interactions = [Select Id from Event where Id in :Trigger.new];
 
if(interactions.size()==0)
 return;
 
String eventType='NEW_INTERACTION';
/*
if(Trigger.isUpdate) {
    Visit oldVisit = Trigger.oldMap.get(visits.get(0).Id);
    
    System.debug(visits.get(0).Id+'::oldVisit.Visitor.Email:'+oldVisit.Visitor.Email);
    
    if(oldVisit.VisitorId != visits.get(0).VisitorId){
        eventType='NEW_INTERACTION';
    }
    else if(oldVisit.Status != visits.get(0).Status 
           && (visits.get(0).Status=='InProgress' || visits.get(0).Status=='Completed')){
        eventType=visits.get(0).Status == 'InProgress'?'START_VISIT':'END_VISIT';
    }
    else 
        return; //no changes to publish
}

Map<String,String> mp =new Map<String,String>();
mp.put('eventType',eventType);
mp.put('visitOn',string.valueofGmt(visits.get(0).PlannedVisitStartTime));
mp.put('email', visits.get(0).Visitor.Email);
mp.put('visitTo', visits.get(0).Place.Name);
mp.put('visitName', visits.get(0).Name);
mp.put('visitId', visits.get(0).Id);
mp.put('visitPriority', visits.get(0).VisitPriority);
mp.put('Status', visits.get(0).Status);
RetailStore rstore=visits.get(0).Place;
mp.put('mapUrlParam', rstore.Street+' '+rstore.City+' '+' '+rstore.State+' '+rstore.Country+' '+rstore.PostalCode);


SajApx.myAWSCallout(mp);
*/
}