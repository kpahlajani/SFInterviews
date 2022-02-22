trigger EndEvent on InterviewEvent__c (after update) {

    List<Id> eligibleEvents = new List<Id>();
    for(InterviewEvent__c ie:Trigger.new)
    {
        if(Trigger.isUpdate)
        {
            if((ie.State__c  == 'Completed') && ((Trigger.oldMap.get(ie.Id).State__c)!='Completed'))
            {
                eligibleEvents.add(ie.Id);
            }
        }
	}
    
    
}