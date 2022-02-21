public class SlackTriggerHandler{
  public static void refreshForInteractionOwners(List<Event> triggerEvents) {
      if(triggerEvents==null)
          return;
      
      List<Event> events = [SELECT Owner.Email, (SELECT Relation.Email FROM EventRelations where Relation.Type='User') 
                            FROM Event where What.Type IN ('Interview__c') and isChild=false and Id in :triggerEvents];
      
      
      Set<String> emails=new Set<String>();
      for(Event evt: events) 
      {
          emails.add(evt.Owner.Email);
          for(EventRelation evtR:evt.getSObjects('EventRelations')){
              emails.add(evtR.Relation.Email);
          }
      }
      
      System.debug('emails:'+emails);
      
      for(String email:emails) {
          SlackAWSCallout.myAWSCallout(new Map<String,String>{'custom'=>'loadInteractions','email'=> email});
      }
         
 }
 
}