public class BillingCalloutService {
    //Implement business and callout logic methods here
    public static void callBillingService(List<Project__c> projects) {
        /* static final ServiceCredentials__c credential = ServiceCredentials__c.getInstance(BILLING_SERVICE_CREDENTIAL_NAME);
        List<BillingServiceProxy.BillingData> billingDataList = new List<BillingServiceProxy.BillingData>();
        
        for (Project__c project : projects) {
            if (project.Status__c == 'Billable') {
                BillingServiceProxy.BillingData billingData = new BillingServiceProxy.BillingData();
                billingData.ProjectRef = project.ProjectRef__c;
                billingData.Amount = project.Billable_Amount__c;
                billingDataList.add(billingData);
            }
        }
        
        if (!billingDataList.isEmpty()) {
            BillingServiceProxy.BillingServiceSoapProxy billingService = new BillingServiceProxy.BillingServiceSoapProxy();
            billingService.CallBillingService(billingDataList, BillingCredentials__c.getValues('BillingCredentials'));
            
            for (Project__c project : projects) {
                if (project.Status__c == 'Billable') {
                    project.Status__c = 'Facturado';
                }
            }
            
            update projects;
        } */
    }
}