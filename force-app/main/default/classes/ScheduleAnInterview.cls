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
    
    public static void scheduleInterview(Id interviewEventCandidate, Id interviewId, List<Id> hiringPanelMembers)
    {
        
    }
    
    public static void reScheduleInterview(Id interviewEventCandidate, Id interviewId)
    {
        
    }
    
    
    public static boolean checkInterviewerAvailability(Id hiringPanelMemberId, DateTime availabilityCheckFrom, DateTime availabilityCheckTo)
     {
       //Get all the interviews which are in scheduled/inprogress state for this user on this date.
       //If there is a time conflict , then return false.
        List<EventInterviewSchedule__c> interviewerSchedule = [Select Id, From__c, To__c, Interview_Event__c , Interview__c	, Status__c from EventInterviewSchedule__c 
                                                               where Hiring_Panel_Member__c  =:hiringPanelMemberId and 
                                                               ( Status__c ='Scheduled' OR Status__c ='InProgress') and 
                                                               ((From__c >= :availabilityCheckFrom and From__c <= :availabilityCheckTo) OR
                                                               (To__c >= :availabilityCheckFrom and To__c <= :availabilityCheckTo))];
        if (interviewerSchedule == null || interviewerSchedule.isEmpty())
           return true;
    	return false;
    }
        
    

}