@isTest
private class ProjectCalloutServiceTest {

  @TestSetup
  static void makeData(){
    ServiceTokens__c token = new ServiceTokens__c();
    token.Name = ProjectCalloutService.PROJECT_SERVICE_TOKEN_NAME;
    token.Token__c = 'TestToken';
    insert token;

    Account acc = new Account();
    acc.Name = 'Account Test';
    insert acc;

    List<Opportunity> opps = new List<Opportunity>();
    for (Integer i = 0; i <= 1; i++) {
      Opportunity op = new Opportunity();
      op.AccountId = acc.Id;
      op.Name = 'Opportunity Test' + i;
      op.Type = 'New Project';
      op.CloseDate = Date.today().addDays(7);
      op.StageName = 'Prospecting';
      op.Amount = 10000 + i;
      opps.add(op);
    }
    insert opps;
  }

  @isTest
  static void testPMSCalloutFialure(){
    List<Opportunity> opps= [SELECT Id
                            FROM Opportunity
                            WHERE Type = 'New Project'];

    List<Id> oppIds = new List<Id>();
    for (Opportunity op : opps) {
      op.StageName = 'Closed Won';
      oppIds.add(op.Id);
    }
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
    ProjectCalloutService.PostOpportunityToPMS(oppIds);
    update opps;
    Test.stopTest();                    

    List<Opportunity> opps2 = [SELECT Id
            FROM Opportunity
            WHERE StageName = 'Resubmit Project'];
    Assert.areEqual(1, opps2.size());
  }

  @isTest
    static void testPMSCalloutSucces(){
      List<Opportunity> opps= [SELECT Id
                              FROM Opportunity
                              WHERE Type = 'New Project'];

      List<Id> oppIds = new List<Id>();
      for (Opportunity op : opps) {
        op.StageName = 'Closed Won';
        oppIds.add(op.Id);
      }
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
      ProjectCalloutService.PostOpportunityToPMS(oppIds);
      update opps;
      Test.stopTest();                    

      List<Opportunity> opps2 = [SELECT Id
              FROM Opportunity
              WHERE StageName = 'Submitted Project'];
      Assert.areEqual(1, opps2.size());
    }

}