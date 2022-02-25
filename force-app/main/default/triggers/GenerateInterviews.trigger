trigger GenerateInterviews on  InterviewEventCandidate__c (after insert ) {
    
    //If operation is update , Check if all the related interview are in created state, delete the data.
    //Else throw an exception. Asking to manually delete those.
    //Get the Questionare template
 	 Map<ID, Set<String>> eventLevelMap = new Map<ID, Set<String>>();
     for (InterviewEventCandidate__c participant: Trigger.new) {
         if (participant.InterviewEvent__c != Null){
             if (eventLevelMap.get(participant.InterviewEvent__c) != null)
             {
                 eventLevelMap.put(participant.InterviewEvent__c, New Set<String>());
             }
             Set<String> levelSet = eventLevelMap.get(participant.InterviewEvent__c);
             if (levelSet == null)
                 levelSet = new Set<String>();
             levelSet.add(participant.Candidate_Level__c);
             eventLevelMap.put(participant.InterviewEvent__c, levelSet);
         }
   }

    Map<ID, Map<String, Set<Questionaire__c>>> eventLevelRoundMap = New Map<ID, Map<String, Set<Questionaire__c>>>();
    Map<String, Set<FeedbackItem__c>> feebackItemsMap = new Map<String, Set<FeedbackItem__c>>();
    for (Id eventId : eventLevelMap.keySet()) {
       //Get all the questionaire template - Junction
        List<InterviewEventQuestionaireTemplate__c> ieqts = [Select QuestionaireTemplate__c from InterviewEventQuestionaireTemplate__c where InterviewEvent__c=:eventId];
    	Set<String> qts = New Set<String>();
        for (InterviewEventQuestionaireTemplate__c ieqt : ieqts) {
            qts.add(ieqt.QuestionaireTemplate__c);
        }
        
		//Fetch all Questionaire templates & Corresponding levels
		List<QuestionaireTemplate__c> questionaireTemplates = [Select Id,Candidate_Level__c from QuestionaireTemplate__c where ID IN :qts ];
		Map<String, String> qtLevelMap = new Map<String, String>();
        for (QuestionaireTemplate__c qt : questionaireTemplates)
        {
            qtLevelMap.put(qt.ID, qt.Candidate_Level__c);
        }
          //Get all the rounds for each questionaire template
        List<Questionaire__c> roundQues = [Select Id, Name, QuestionaireTemplate__c, Sort_Order__c from Questionaire__c where QuestionaireTemplate__c IN :qts];
        Set<String> allLevelsForThisEvent = eventLevelMap.get(eventId);
        
        //Get All the FeebackItems for roundQues, and prepare map
        Set<String> qids = New Set<String>();
        for (Questionaire__c q : roundQues)
            qids.add(q.Id);
        
        List<FeedbackItem__c> feedbackItems = [Select Id,Name, Comments__c, Questionaire__c from FeedbackItem__c where Questionaire__c IN :qids];
        for (FeedbackItem__c fbi : feedbackItems)
        {
            if (feebackItemsMap.get(fbi.Questionaire__c) == null)
            {
                feebackItemsMap.put(fbi.Questionaire__c, new Set<FeedbackItem__c>());
            }
            Set<FeedbackItem__c> fbSet = feebackItemsMap.get(fbi.Questionaire__c);
            fbSet.add(fbi);
            feebackItemsMap.put(fbi.Questionaire__c,fbSet);
        }
        
        //Group all the rounds with levels in each event
        Map<String, Set<Questionaire__c>> levelRoundMap = new Map<String, Set<Questionaire__c>>();
        for (Questionaire__c round : roundQues)
        {
           String templateId = round.QuestionaireTemplate__c;
           String templateLevel = qtLevelMap.get(templateId);
           if (levelRoundMap.get(templateLevel) == null)
               levelRoundMap.put(templateLevel,new Set<Questionaire__c>());   
            Set<Questionaire__c> qs = levelRoundMap.get(templateLevel);
            qs.add(round);
            levelRoundMap.put(templateLevel,qs);
        }
        eventLevelRoundMap.put(eventId, levelRoundMap);
	}
    
    
    //Create Interviews & Feedback items now
    // For each candidate that is getting added , get the event.
    // Get the Level of the candidate
    // Find this Level questions ( rounds ) in this event
    // Create interviews and associate to these rounds
   	   List<Interview__c> interviewList = new List<Interview__c>();
       for (InterviewEventCandidate__c participant: Trigger.new) {
         if (participant.InterviewEvent__c != Null){
             String eventId = participant.InterviewEvent__c;
             //Get the level of the candidate for this event
             String level = participant.Candidate_Level__c;
             //Get LevelRoundMap for this Event
             Map<String, Set<Questionaire__c>> levelRoundMap = eventLevelRoundMap.get(eventId);
             //Get set of Questionaire for this Level in this Event
             Set<Questionaire__c> questionaireSetForLevel = levelRoundMap.get(level);
             if (questionaireSetForLevel == null)
                 continue;
             //Create an Interview corresponding to each questionaire
             for (Questionaire__c q : questionaireSetForLevel)
             {
                 Interview__c interview = new Interview__c();
                 interview.Questionaire__c = q.Id;
                 interview.Order__c = q.Sort_Order__c;
                 interview.Candidate__c = participant.Candidate__c;
                 interview.Interview_Event_Candidate__c = participant.Id;
                 interview.Name = q.Name;
                 interviewList.add(interview);
             }
         }
   }
    
    		insert interviewList;
    
    		//For each interview insert FeedbackItems
    		List<FeedbackItem__c> allFeedbackItems = New List<FeedbackITem__c>();
    		for (Interview__c interview : interviewList)
            {
                Set<FeedbackItem__c> feebackTemplateItemsSet =  feebackItemsMap.get(interview.Questionaire__c);
                if (feebackTemplateItemsSet == null)
                    continue;
                for (FeedbackItem__c fbi : feebackTemplateItemsSet)
                {
                    FeedbackItem__c newFbi = fbi.clone(false, false, false, false);
                    newFbi.Interview__c = interview.Id;
                    newFbi.Is_Template__c = false;
                    newFbi.Name = fbi.Name;
                    allFeedbackItems.add(newFbi);
                }
            }
    
    		insert allFeedbackItems;
	
    
}