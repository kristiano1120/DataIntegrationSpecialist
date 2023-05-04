trigger ProjectTrigger on Project__c (after update) {
    //Call the Billing Service callout logic here
    List<Project__c> projectsToUpdate = new List<Project__c>();
    
    for (Project__c project : Trigger.new) {
        if (project.Status__c == 'Facturable' && project.Status__c != Trigger.oldMap.get(project.Id).Status__c) {
            projectsToUpdate.add(project);
        }
    }
    
    if (!projectsToUpdate.isEmpty()) {
        BillingCalloutService.callBillingService(projectsToUpdate);
    }
}