trigger AutoAddMembersToEvent on ActivePanel__c (after insert) {
    
    //Get all the members of this Panel
    //Add all the members to this event with default availability as full time.
	List<String> panelsGettingAdded = New List<String>();
     for (ActivePanel__c panel: Trigger.new) {
        String panelId = panel.Hiring_Panel__c;
        panelsGettingAdded.add(panelId);
   }
    //Get all the members in these panels
    List<HiringPanelMember__c> hpms = [Select HiringPanel__c, User__c, Default_Member_Role__c from HiringPanelMember__c where HiringPanel__c IN :panelsGettingAdded];
	Map<String, Set<HiringPanelMember__c>> panelMemberMap = New Map<String, Set<HiringPanelMember__c>>();
    
    for (HiringPanelMember__c pm : hpms)
    {
        String panelId = pm.HiringPanel__c;
        if (panelMemberMap.get(panelId) == null)
         {
			panelMemberMap.put(panelId, New Set<HiringPanelMember__c>());              
         }
        Set<HiringPanelMember__c> hpm = panelMemberMap.get(panelId);
        hpm.add(pm);
        panelMemberMap.put(panelId, hpm);
    }
    //Now  create availability
    
}