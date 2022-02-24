trigger UpdateInterviewOverallRating on FeedbackItem__c (after insert, after update) {
    //If this item is not template , then consider this along with peers , and take average
    //Update this average on the Interview Overall Rating
    //Get all the Feedback Items peer to this feedback Item
    //Get the Interview for this Feedback Item
	Set<String> allInterviews = New Set<String>();
    Set<String> feedbackItemIds = New Set<String>();
    for(FeedbackItem__c fi:Trigger.new)
    {
        if (fi.Is_Template__c)
            continue;
        allInterviews.add(fi.Interview__c);
        feedbackItemIds.add(fi.Id);
    }
    //Create map of Interviews to Feedback Items
    Map<String, Set<FeedbackItem__c>> interviewFeedbackItemMap = New Map<String, Set<FeedbackItem__c>>();
    List<FeedbackItem__c> allFeedbackItems = [Select Id, Comments__c,Interview__c , Proficiency_Level__c from FeedbackItem__c where Interview__c IN :allInterviews];
    for (FeedbackItem__c fi : allFeedbackItems)
    {
        if (interviewFeedbackItemMap.get(fi.Interview__c) == null)
            interviewFeedbackItemMap.put(fi.Interview__c, new Set<FeedbackItem__c>());
        Set<FeedbackItem__c> fis = interviewFeedbackItemMap.get(fi.Interview__c);
        fis.add(fi);
        interviewFeedbackItemMap.put(fi.Interview__c, fis);
    }
    
    //Now get all the interviews in the keyset 
    
    List<Interview__c> allInterviewsObjs = [Select Id, Overall_Rating__c from Interview__c where Id IN :interviewFeedbackItemMap.keySet()];
    
    //Iterate interviews , calculate average of feedback items, and update Interview
    List<Interview__c> interviewsToUpdate = New List<Interview__c>();
    for(Interview__c interview : allInterviewsObjs)
    {
        Set<FeedbackItem__c> feedbackItems = interviewFeedbackItemMap.get(interview.Id);
        Integer capturedItems = 1;
        Integer totalScore = 0;
        for(FeedbackItem__c fi : feedbackItems)
        {
            if (fi.Proficiency_Level__c != null)
            {
                System.debug('Considering this item');
              	totalScore+=Integer.valueOf(fi.Proficiency_Level__c);
                capturedItems++;
            }
        }
        if (capturedItems != 1)
            capturedItems--;
        Double finalScore = (Double)totalScore/capturedItems;
        //This needs to be fixed.
        System.debug('Overall Score is ' + finalScore);
        if (finalScore !=0)
        	interview.Overall_Rating__c = ''+Integer.valueOf(''+Math.ceil(finalScore));
        else
          	interview.Overall_Rating__c = '';
        interviewsToUpdate.add(interview);
    }
    update interviewsToUpdate;
}