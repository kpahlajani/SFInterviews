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
}