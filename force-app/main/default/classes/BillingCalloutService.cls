public class BillingCalloutService {
    //Implement business and callout logic methods here
    static final ServiceCredentials__c credential = ServiceCredentials__c.getInstance('BillingServiceCredential');
    public static void callBillingService(List<Project__c> projects, Map<Id, Project__c> oldProjectsMap) {
        List<Project__c> projectsToSync = new List<Project__c>();

        for (Project__c projectNew : projects) {
            Project__c oldProject = oldProjectsMap.get(projectNew.Id);
            if (projectNew.Status__c == 'Billable' && oldProject.Status__c != projectNew.Status__c) {
                projectsToSync.add(projectNew);
            }
        }
        
        if (!projectsToSync.isEmpty()) {
            makeCallout(JSON.serialize(projectsToSync));
        }
    }

    @future(callout = true)
    public static void makeCallout(String jsonProjects) {
        List<Project__c> projects = (List<Project__c>)JSON.deserialize(jsonProjects, List<Project__c>.class);
        List<Project__c> projectsToUpdate = new List<Project__c>();
        
        for(Project__c project : projects){
            BillingServiceProxy.InvoicesPortSoap11 invoicePort = new BillingServiceProxy.InvoicesPortSoap11();
            BillingServiceProxy.project extProject = setAndGetExternalProject(project);
            String response = invoicePort.billProject(extProject);
            
            if(response == 'OK'){
                project.Status__c = 'Billed';
                projectsToUpdate.add(project);
            }
        }
        
        if(projectsToUpdate.size() > 0){
            update projectsToUpdate;
        }
    }

    static BillingServiceProxy.project setAndGetExternalProject(Project__c project){
        BillingServiceProxy.project extProject = new BillingServiceProxy.project();
        extProject.projectid = project.ProjectRef__c;
        extProject.billAmount = project.Billable_Amount__c;
        extProject.username = credential.Username__c;
        extProject.password = credential.Password__c;
        
        return extProject;
    }
}