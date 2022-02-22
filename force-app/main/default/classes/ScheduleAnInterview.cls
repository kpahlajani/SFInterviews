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
		//Get panel members to be assigned to this interview
		//Check for the availability of these members
		// Throw an exception if any of these members are unavailable
		// Throw an exception if all the members are observers
        //Get the first member in the list which is primary ( non observer )
        //Create an event 
        //Assign this event to the primary 
        //Add all other hiring panel members as attendees in the event
        //Make an entry for each hiring panel member in EventInterviewSchedule__c
        //Change corresponding interview status to scheduled.
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