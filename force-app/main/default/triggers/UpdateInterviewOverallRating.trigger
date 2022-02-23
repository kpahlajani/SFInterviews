trigger UpdateInterviewOverallRating on FeedbackItem__c (before insert) {
    
    //If this item is not template , then consider this along with peers , and take average
    //Update this average on the Interview Overall Rating

}