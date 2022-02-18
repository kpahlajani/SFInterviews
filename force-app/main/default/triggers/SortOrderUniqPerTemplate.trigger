trigger SortOrderUniqPerTemplate on Questionaire__c (before insert, before update) {
 Map<Id,Decimal>  qt=new Map<Id,Decimal>();
 Map<String,Questionaire__c> inputMap=new  Map<String,Questionaire__c>();

 for(Questionaire__c question: trigger.new){
    qt.put(question.QuestionaireTemplate__c,question.Sort_Order__c);
    inputMap.put(question.QuestionaireTemplate__c+'|'+question.Sort_Order__c,question);
 }
 
 List<Questionaire__c> questions=[select Id,QuestionaireTemplate__c, Sort_Order__c from Questionaire__c where QuestionaireTemplate__c in :qt.keySet() and Sort_Order__c in :qt.values() ];
 
 for(Questionaire__c result: questions){
    if(qt.get(result.QuestionaireTemplate__c)==result.Sort_Order__c){
        inputMap.get(result.QuestionaireTemplate__c+'|'+result.Sort_Order__c).addError('Duplicate Sort Order is not allowed');
    }
 }
 
 return;

}