public with sharing class ScheduleAnInterview {
    
    
    public static Set<Id> getAllAvailableInterviewers(DateTime availabilityCheckFrom, DateTime availabilityCheckTo, Id eventId)
    {
        List<Id> availableInterviewers = New List<Id>();
        //Get all the available interviewers for this event along with their default role.
        List<Hiring_Panel_Member_Availability__c> allAvailableMembersForThisEvent = [Select Id,Hiring_Panel_Member__c, Override_role__c  from Hiring_Panel_Member_Availability__c where Interview_Event__c =:eventId];
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
        Interview__c interview = [Select Id, Name , Status__c from Interview__c where Id=:interviewId];
        if (interview == null)
        {
               	throw new SFInterviewException('Invalid Interview Id');
        }
        if (interview.Status__c != 'Planned')
        {
               	throw new SFInterviewException('Interview cannot be scheduled.Interview must be in planning state.');
        }
        InterviewEventCandidate__c iec = [Select Id, InterviewEvent__c, Candidate_Name__c  from InterviewEventCandidate__c where Id=:interviewEventCandidate];
		List<HiringPanelMember__c > hiringPanelMembersObj = [Select Id, Email__c, User__c, User_Name__c from HiringPanelMember__c  where Id IN :hiringPanelMembers];
        if (hiringPanelMembersObj == null || hiringPanelMembersObj.isEmpty())
        {
           throw new SFInterviewException('Panel member not found');
        }
        Map<Id, String> panelMemberIdNameMap = new Map<Id, String>();
        Map<String, String> userNames = New Map<String, String>();
        for (HiringPanelMember__c member: hiringPanelMembersObj)
        {
            panelMemberIdNameMap.put(member.Id, member.User_Name__c);
            userNames.put(member.User_Name__c, member.Email__c);
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
        e.WhatId = interview.Id;
        e.OwnerId = eventOwner.User__c;
        e.IsAllDayEvent = false;
        e.IsRecurrence = false;
        e.StartDateTime = availabilityCheckFrom;
        e.EndDateTime = availabilityCheckTo;
        insert e;
       //Add rest of the members as observers
       List<EventRelation> attendees = New List<EventRelation>();
        for (Integer index=1; index<hiringPanelMembersObj.size(); index++)
        {
            EventRelation attendee = new EventRelation();
            attendee.EventId = e.Id;
            attendee.RelationId = hiringPanelMembersObj.get(index).User__c;
            attendees.add(attendee);
        }
        insert attendees;
        
        //Make an entry for each hiring panel member in EventInterviewSchedule__c
        List<EventInterviewSchedule__c> schedules = new List<EventInterviewSchedule__c>();
        for (Integer index=0; index<hiringPanelMembersObj.size(); index++)
        {
           EventInterviewSchedule__c schedule = new EventInterviewSchedule__c();
           schedule.Interview__c = interview.Id;
           schedule.From__c = availabilityCheckFrom;
           schedule.To__c = availabilityCheckTo;
           schedule.Hiring_Panel_Member__c = hiringPanelMembersObj.get(index).Id;
           schedule.Interview_Event__c = iec.InterviewEvent__c;
           schedule.Status__c = 'Scheduled';
 		   schedules.add(schedule);
        }
        insert schedules;
        //Change corresponding interview status to scheduled.
		interview.Status__c='Scheduled';
        update interview;

        //Send an email to attendees.
        String Subject = 'Interaction Scheduled with '+ iec.Candidate_Name__c;
        String body = 'Hello $USERNAME,\n\n'+'You have been invited for interation with '+ iec.Candidate_Name__c+'.\n'+
            'Please login to your salesforce account '+
            'to accept the invite.\n'+
            'Please navigate to following URL to access all interview details.\n'+
            URL.getSalesforceBaseUrl().toExternalForm()+'/'+interviewId;
        //SendEmail(userNames,subject,body);
        
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
        
    
    public static void SendEmail(Map<String, String> userNamesEmailMap, String subject, String body) {
         for (String userName : userNamesEmailMap.keySet())
         {
             String emailBody = body;
             emailBody = emailBody.replace('$USERNAME', userName);
             String emailAddress = userNamesEmailMap.get(userName);
             List<String> emailAddresses = new List<String>();
             emailAddresses.add(emailAddress);
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setSaveAsActivity(false);
             mail.setToAddresses(emailAddresses);
             mail.setSenderDisplayName('Recruiter Admin');
             mail.setPlainTextBody(emailBody);
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }
    }
    

}