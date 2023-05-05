@isTest
private class BillingCalloutServiceTest {
  //Implement mock callout tests here
  @testSetup
    static void setup(){
        ServiceCredentials__c credential = new ServiceCredentials__c();
        credential.Name = 'BillingServiceCredential';
        credential.Username__c = 'usernameTest';
        credential.Password__c = 'passwordTest';
        insert credential;
        
        Account acc = new Account();
        acc.Name = 'Test Account 1';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.Type = 'New Project';
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.Amount = 50000;
        insert opp;
        
        Project__c project = new Project__c();
        project.Name = 'Test Project 1';
        project.ProjectRef__c = 'Testproject1ref';
        project.Billable_Amount__c = 50000;
        project.Status__c = 'Running';
        project.Opportunity__c =opp.Id;
        insert project;       
    }
    
    @isTest
    static void testBillingCalloutFailure(){
        List<Project__c> projects = [SELECT Id FROM Project__c WHERE Name = 'Test Project 1'];
        for(Project__c proj : projects){
            proj.Status__c = 'Running';
        }
    
        Test.startTest();
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
        update projects;
        Test.stopTest();
        
        projects = [SELECT Status__c FROM Project__c WHERE Name = 'Test Project 1'];
        Assert.areEqual('Running', projects[0].Status__c);
    }
    
    @isTest
    static void testBillingCalloutSuccess(){
        List<Project__c> projects = [SELECT Id FROM Project__c WHERE Name = 'Test Project 1'];
        for(Project__c proj : projects){
            proj.Status__c = 'Billable';
        }
    
        Test.startTest();
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        update projects;
        Test.stopTest();
        
        projects = [SELECT Status__c FROM Project__c WHERE Name = 'Test Project 1'];
        Assert.areEqual('Billed', projects[0].Status__c);
    }
}