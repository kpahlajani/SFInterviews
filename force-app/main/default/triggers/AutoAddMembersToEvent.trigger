trigger AutoAddMembersToEvent on ActivePanel__c (after insert) {
    
    //Get all the members of this Panel
    //Add all the members to this event with default availability as full time.
	Map<String, String> panelsGettingAdded = New Map<String, String>();
     for (ActivePanel__c panel: Trigger.new) {
        String panelId = panel.Hiring_Panel__c;
        String eventId = panel.InterviewEvent__c;
        panelsGettingAdded.put(panelId,eventId);
   }
   
        List<HiringPanelMember__c> hpms = [Select HiringPanel__c, User__c,User__r.Grade__c, Default_Member_Role__c from HiringPanelMember__c where HiringPanel__c IN :panelsGettingAdded.keySet()];
		List<Hiring_Panel_Member_Availability__c> pmas = New List<Hiring_Panel_Member_Availability__c>();
    	for(HiringPanelMember__c hpm : hpms)
        {
            //Create availability and add this member to the event
            String eventId = panelsGettingAdded.get(hpm.HiringPanel__c);
            Hiring_Panel_Member_Availability__c pma = new Hiring_Panel_Member_Availability__c ();
            pma.Available_For_Entire_Event__c = true;
            pma.Hiring_Panel_Member__c = hpm.Id;
            pma.Panel_Member_Grade__c = hpm.User__r.Grade__c;
            pma.Interview_Event__c = eventId;
            pmas.add(pma);
		}
    
    insert pmas;
    
}