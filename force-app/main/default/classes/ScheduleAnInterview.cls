public with sharing class ScheduleAnInterview {
    
    public static Set<Id> getAllAvailableInterviewers(DateTime availabilityCheckFrom, DateTime availabilityCheckTo, Id eventId)
    {
        List<Id> availableInterviewers = New List<Id>();
        //Get all the available interviewers for this event along with their default role.
        List<Hiring_Panel_Member_Availability__c> allAvailableMembersForThisEvent = [Select Id, Override_role__c  from Hiring_Panel_Member_Availability__c where Interview_Event__c =:eventId];
        Map<Id, String> memberRoleMap = New Map<Id, String>();
        for (Hiring_Panel_Member_Availability__c hpma : allAvailableMembersForThisEvent)
        {
            memberRoleMap.put(hpma.Hiring_Panel_Member__c, hpma.Override_role__c );
        }
        //For all of these interviewers check in EventInterviewSchedule
        List<EventInterviewSchedule__c> currentScheduleSnapshot = [Select Id, Hiring_Panel_Member__c, From__c, To__c, Interview_Event__c , Interview__c	, Status__c from EventInterviewSchedule__c 
                                                               where Hiring_Panel_Member__c  IN :memberRoleMap.keySet() and 
                                                               ( Status__c ='Scheduled' OR Status__c ='InProgress') and 
                                                               ((From__c >= :availabilityCheckFrom and From__c <= :availabilityCheckTo) OR
                                                               (To__c >= :availabilityCheckFrom and To__c <= :availabilityCheckTo))];

        // Filter the results
        // Remove the members from the map which are already part of this snapshot
		for (EventInterviewSchedule__c intwSchedule : currentScheduleSnapshot)
            memberRoleMap.remove(intwSchedule.Hiring_Panel_Member__c);
        return memberRoleMap.keySet();
    }
    
    public static void scheduleInterview(Id interviewEventCandidate, Id interviewId, DateTime availabilityCheckFrom, DateTime availabilityCheckTo, List<Id> hiringPanelMembers)
    {
        Interview__c interview = [Select Id, Name from Interview__c where Id=:interviewId];
        if (interview == null)
        {
               	throw new SFInterviewException('Invalid Interview Id');
        }
        InterviewEventCandidate__c iec = [Select Id, InterviewEvent__c  from InterviewEventCandidate__c where Id=:interviewEventCandidate];
		List<HiringPanelMember__c > hiringPanelMembersObj = [Select Id, User_Name__c from HiringPanelMember__c  where Id IN :hiringPanelMembers];
        if (hiringPanelMembersObj == null || hiringPanelMembersObj.isEmpty())
        {
           throw new SFInterviewException('Panel member not found');
        }
        Map<Id, String> panelMemberIdNameMap = new Map<Id, String>();
        for (HiringPanelMember__c member: hiringPanelMembersObj)
        {
            panelMemberIdNameMap.put(member.Id, member.User_Name__c);
        }
        //Get panel members to be assigned to this interview
		//Check for the availability of these members
		Set<Id> allAvailableMembersForThisEvent = getAllAvailableInterviewers(availabilityCheckFrom, availabilityCheckTo, iec.InterviewEvent__c);
		// Throw an exception if any of these members are unavailable
		for (Id panelMemberId : hiringPanelMembers)
        {
            if (!allAvailableMembersForThisEvent.contains(panelMemberId))
            {
            	throw new SFInterviewException('Panel Member is not available : ' + panelMemberIdNameMap.get(panelMemberId));
            }
        }
        //Get the first member in the list which is primary ( non observer )
        HiringPanelMember__c eventOwner = hiringPanelMembersObj.get(0);
        //Create an event 
        Event e = new Event();
        e.Description = interview.Name;
        e.Subject = interview.Name;
        e.OwnerId = eventOwner.User__c;
        e.IsAllDayEvent = false;
        e.IsRecurrence = false;
        e.StartDateTime = availabilityCheckFrom;
        e.EndDateTime = availabilityCheckTo;
        insert e;
        //Add rest of the members as observers
       // for (int i=1; i<hiringPanelMembers)
       // EventRelation er1 = new EventRelation();
       // er1.EventId = e.Id;
       // er1.
       // er1.IsWhat = false;
        //er1.RelationId = contacts.get(0).Id;
        //EventRelation er2 = new EventRelation();
       // er2.EventId = e.Id;
       // er2.IsInvitee = true;
        //er2.IsWhat = false;
       // er2.RelationId = contacts.get(1).Id;
        //List<EventRelation> ers = new List<EventRelation>{er1, er2};
       // insert ers;
        //Assign this event to the primary 
        //Add all other hiring panel members as attendees in the event
        //Make an entry for each hiring panel member in EventInterviewSchedule__c
        //Change corresponding interview status to scheduled.
        //Send an email to attendees.
    }
    
    public static void reScheduleInterview(Id interviewEventCandidate, Id interviewId, DateTime availabilityCheckFrom, DateTime availabilityCheckTo, List<Id> hiringPanelMembers)
    {
        
    }
    
    
    public static boolean checkInterviewerAvailability(List<Id> hiringPanelMemberIds, DateTime availabilityCheckFrom, DateTime availabilityCheckTo)
     {
       //Get all the interviews which are in scheduled/inprogress state for this user on this date.
       //If there is a time conflict , then return false.
        List<EventInterviewSchedule__c> interviewerSchedule = [Select Id, From__c, To__c, Interview_Event__c , Interview__c	, Status__c from EventInterviewSchedule__c 
                                                               where Hiring_Panel_Member__c  IN :hiringPanelMemberIds and 
                                                               ( Status__c ='Scheduled' OR Status__c ='InProgress') and 
                                                               ((From__c >= :availabilityCheckFrom and From__c <= :availabilityCheckTo) OR
                                                               (To__c >= :availabilityCheckFrom and To__c <= :availabilityCheckTo))];
        if (interviewerSchedule == null || interviewerSchedule.isEmpty())
           return true;
    	return false;
    }
        
    

}