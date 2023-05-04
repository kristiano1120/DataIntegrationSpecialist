@restResource(urlMapping='/Projects/*')
global class ProjectRESTService {
    
    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, 
                    String OpportunityId, Date StartDate, Date EndDate, Double Amount, 
                    String Status) {
        
        Savepoint savepoint = Database.setSavepoint();

        try {
            Project__c projectNew = new Project__c();
            projectNew.ProjectRef__c = ProjectRef;
            projectNew.Name = ProjectName;
            projectNew.Opportunity__c = OpportunityId;
            projectNew.Start_Date__c = StartDate;
            projectNew.End_Date__c = EndDate;
            projectNew.Billable_Amount__c = Amount;
            projectNew.Status__c = Status;
            upsert projectNew;            
            Opportunity op = [SELECT Id, DeliveryInstallationStatus__c    
                            FROM Opportunity
                            WHERE Id =: projectNew.Opportunity__c LIMIT 1];
    
            op.DeliveryInstallationStatus__c = 'In progress';
            update op;  

            return 'OK';
        } catch (Exception e) {
            System.debug(e);
            Database.rollback(savepoint);
            return e.getMessage();
        } finally {
            
        }   
    }
        
}