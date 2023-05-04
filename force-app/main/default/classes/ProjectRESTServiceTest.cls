@isTest
private class ProjectRESTServiceTest {
  
  @TestSetup
  static void makeData(){
    Opportunity op = new Opportunity();
    op.Name = 'Test Opportunity';
    op.CloseDate = Date.today().addDays(7);
    op.StageName = 'Prospecting';
    insert op;    
  }

  @isTest
  public static void postProjectData() {

    Opportunity op = [SELECT Id, Name 
                      FROM Opportunity 
                      WHERE name = 'Test Opportunity'];

    RestRequest request = new RestRequest();
    request.httpMethod = 'POST';
    request.requestURI = '/services/apexrest/project';

    RestContext.request = request;

    Test.startTest();
    String result = ProjectRESTService.postProjectData('gdgfdg54654g', 'Test Ref', 
                  op.Id, Date.today(), Date.today().addDays(7), 30000, 'Running');
    Test.stopTest();
                  
      Opportunity opUpdated = [SELECT Id, Name, DeliveryInstallationStatus__c
                        FROM Opportunity 
                        WHERE Id =: op.Id];
    Assert.areEqual('OK', result);
    Assert.areEqual('In progress', opUpdated.DeliveryInstallationStatus__c);
  }

  @isTest
  public static void postProjectDataFail() {

    Opportunity op = [SELECT Id, Name 
                      FROM Opportunity 
                      WHERE name = 'Test Opportunity'];

    RestRequest request = new RestRequest();
    request.httpMethod = 'POST';
    request.requestURI = '/services/apexrest/project';

    RestContext.request = request;

    Test.startTest();
    String result = ProjectRESTService.postProjectData('gdgfdg54654g', 'Test Ref', 
                  op.Name, Date.today(), Date.today().addDays(7), 30000, 'Running');
    Test.stopTest();
                  
      Opportunity opUpdated = [SELECT Id, Name, DeliveryInstallationStatus__c
                        FROM Opportunity 
                        WHERE Id =: op.Id];
    Assert.areEqual('OK', result);
    Assert.areEqual('In progress', opUpdated.DeliveryInstallationStatus__c);
  }
}