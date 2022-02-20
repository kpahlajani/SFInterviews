trigger notifyAWSSlack on Event (after insert,after update,before delete) {

for(Event evt: Trigger.new) {
  if(evt.What.Type != 'Interview__c'){
     continue;
  }

  Map<String,String> mp =new Map<String,String>();
  mp.put('custom','loadInteractions');
  mp.put('email',evt.Owner.email);
    
  SlackAWSCallout.myAWSCallout(mp);
  }
}