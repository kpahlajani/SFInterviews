global class ResourceAllocationRecoGenerator {
    
    global class ResourceShortage{
        global String level;
        global Integer Involvement_Percent,count;
        global Team_Allocation_Template_Item__c linkedTemplateItem=null;
        ResourceShortage(String level,Integer Involvement_Percent,Integer count){
            this.level=level;
            this.Involvement_Percent=Involvement_Percent;
            this.count=count;
        }        
        ResourceShortage(String level,Integer Involvement_Percent,Integer count,Team_Allocation_Template_Item__c linkedTemplateItem){
            this.level=level;
            this.Involvement_Percent=Involvement_Percent;
            this.count=count;
            this.linkedTemplateItem=linkedTemplateItem;
        }
        
        global Override String toString(){
            return '('+this.level+'['+this.Involvement_Percent+'] ->'+this.count+')';
        }
    }
    
    global static Map<String,ResourceShortage> getShortages(ID teamId){
        
        Map<String,ResourceShortage> shortages = new Map<String,ResourceShortage>();
        
        List<Team_Allocation_Template_Item__c> expectedResources = [select tolabel(Level__c) ,Involvement_Percent__c,Count__c from Team_Allocation_Template_Item__c 
                                                                    where Team_Allocation_Template__c in (select Team_Allocation_Template__c from Scrum_Team__c where Id = :teamId)];
        
        List<Team_Assignment__c> existingResources=[SELECT tolabel(Hired_Candidate_Level__c),Involvement_Percent__c  FROM Team_Assignment__c where Scrum_Team__c=:teamId]; // group by over neither decimal nor formula working
        

         
        Map<String,Integer> existingCountByLevel= new Map<String,Integer>();
        for(Team_Assignment__c agg:existingResources){
            String key = agg.Hired_Candidate_Level__c+'|'+agg.Involvement_Percent__c;
            if(existingCountByLevel.containsKey(key)) {
                existingCountByLevel.put(key,existingCountByLevel.get(key)+1);
            }
            else 
              existingCountByLevel.put(key,1);
        }
        
        system.debug('Existing count by level:'+existingCountByLevel);

        for(Team_Allocation_Template_Item__c exp:expectedResources) {             
            String key = exp.Level__c+'|'+exp.Involvement_Percent__c;
            Integer count = (Integer)exp.Count__c;
            
            if(existingCountByLevel.containsKey(key)) {
                if(existingCountByLevel.get(key)>=exp.Count__c){
                    continue;
                }
                else 
                    count -=existingCountByLevel.get(key);
            }
            
            shortages.put(key,new ResourceShortage(exp.Level__c,exp.Involvement_Percent__c.intValue(),count,exp));               
        }
        
        system.debug('Shortages:'+shortages.values());
        return shortages;
    }
    
    @InvocableMethod(
        label='Resource Recommendation Generator'
        description='This function returns recommendations for the resources to allocate to a team.')
     global static List<List<Recommendation>> getResources(List<ResourceRecommendationGenerateRequest> inputRequests){
        List<List<Recommendation>> outputs = new List<List<Recommendation>>();
        
        for (ResourceRecommendationGenerateRequest inputRequest : inputRequests)
        {
          Map<String,ResourceShortage> shortages = getShortages(inputRequest.teamId);
            
          List<Hired_Candidate__c> availableResources=[SELECT Id,Name,Candidate__c,Allocation_Status__c,tolabel(Candidate_Level__c),Employee_Name__c FROM Hired_Candidate__c 
                                                        where Allocation_Status__c in ('Partially Allocated','Unallocated') and Onboarding_Completed__c=true ]; 
           
          Map<String,List<Hired_Candidate__c>> availableMap = new   Map<String,List<Hired_Candidate__c>>();
          for(Hired_Candidate__c hc:availableResources){
              if(hc.Allocation_Status__c=='Unallocated'){
                 if(!availableMap.containsKey(hc.Candidate_Level__c+'|100')) 
                   availableMap.put(hc.Candidate_Level__c+'|100',new List<Hired_Candidate__c>());

                availableMap.get(hc.Candidate_Level__c+'|100').add(hc);
              }
             // available for partial allocation too
            if(!availableMap.containsKey(hc.Candidate_Level__c+'|50')) 
              availableMap.put(hc.Candidate_Level__c+'|50',new List<Hired_Candidate__c>());

            availableMap.get(hc.Candidate_Level__c+'|50').add(hc);
          }
           
           system.debug('Available Resource:'+availableMap.keySet());
           List<Recommendation> recs = new List<Recommendation>(); 
           for (String key: shortages.keySet()) {

                if(availableMap.containsKey(key)){
                    ResourceShortage shortage=shortages.get(key);
                    
                    for (Hired_Candidate__c hc:availableMap.get(key)) {
                        if(shortage.count==0)
                            continue;
                        shortage.count--;
                        Recommendation rec = new Recommendation(
                            Name = hc.Employee_Name__c,
                            Description = 'Fill Shortage of '+shortage.level+' with Allocation '+shortage.Involvement_Percent+'%',
                            Hired_Candidate__c = hc.Id, 
                            Involvement_Percent__c = shortage.Involvement_Percent,
                            Employee_Title__c  = shortage.level,
                            ActionReference = 'Simple_Screen_Flow',
                            Scrum_Team__c = inputRequest.teamId,
                            AcceptanceLabel = 'Allocate',
                            RejectionLabel = 'No Thanks'
                        );
                        recs.add(rec);
                    }
                }
            }
            outputs.add(recs);
            
        }
        return outputs; 
    }
    
    global class ResourceRecommendationGenerateRequest {
        @InvocableVariable(label='Team ID')
        global String teamId;
    }
}