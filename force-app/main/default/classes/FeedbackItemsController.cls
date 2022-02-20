public with sharing class FeedbackItemsController {

    @AuraEnabled(cacheable=true)
    public static List<FeedbackItem__c> getFeedbackItems(String recordId) {
        return [SELECT Id, Name, Proficiency_Level__c, Comments__c FROM FeedbackItem__c WHERE Interview__c = :recordId];
    }

    @AuraEnabled
    public static string updateFeedbackItems(Object data) {
        List<FeedbackItem__c> feedbackItemsForUpdate = (List<FeedbackItem__c>) JSON.deserialize(
            JSON.serialize(data),
            List<FeedbackItem__c>.class
        );
        try {
            update feedbackItemsForUpdate;
            return 'Success: contacts updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static void createFeedback(String questionValue, String commentValue, String feedbackNameValue, String proficiencyLevelValue, String interviewId, Integer sortOrderValue){
        try {
            System.debug(questionValue + ' ' + commentValue + ' ' + feedbackNameValue + ' ' + proficiencyLevelValue + ' ' + interviewId + ' ' + sortOrderValue);
            Questionaire__c question = new Questionaire__c();
            question.Name = questionValue;
            question.Sort_Order__c = sortOrderValue;
            insert question;

            FeedbackItem__c feedbackItem = new FeedbackItem__c();
            feedbackItem.Name = feedbackNameValue;
            feedbackItem.Proficiency_Level__c = proficiencyLevelValue;
            feedbackItem.Comments__c = commentValue;
            feedbackItem.Questionaire__c = question.Id;
            feedbackItem.Interview__c = interviewId;

            insert feedbackItem;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}