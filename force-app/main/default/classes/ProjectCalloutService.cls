public class ProjectCalloutService {
    public static final String PROJECT_SERVICE_TOKEN_NAME = 'ProjectServiceToken';

    @InvocableMethod
    public static void PostOpportunityToPMS(List<Id> oppIds){
        if(oppIds.size() > 0){
            System.enqueueJob(new QueueablePMSCall(oppIds));
        }
    }

    public class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts{
        List<Id> oppsToProccess;

        public QueueablePMSCall(List<Id> oppIds){
            this.oppsToProccess = oppIds;
        }

        public void execute(System.QueueableContext context){
            collectDataForCallOut(oppsToProccess);
        }
    }

    static void collectDataForCallOut(List<Id> oppIds){
        List<Opportunity> oppsToProcess = [SELECT ID, Name, Account.Name, CloseDate, Amount
                                                    FROM Opportunity
                                                    WHERE Id In :oppIds];
        if(oppsToProcess.size() > 0){           
            makeCallout(oppsToProcess[0], ServiceTokens__c.getInstance(PROJECT_SERVICE_TOKEN_NAME).Token__c);
        }
    }

    static void makeCallout(Opportunity opp, String projectServiceToken){
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod('POST');
        request.setEndpoint('callout:ProjectService');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('token', projectServiceToken);
        request.setBody(JSON.serialize(new JsonWrapper(opp)));
        
        HttpResponse response = http.send(request);


        if (response.getStatusCode() == 201 && response.getStatus() == 'OK') {
            System.debug(response);
            System.debug('Todo ok');
            opp.StageName = 'Submitted Project';
        } else {
            System.debug(response.getStatusCode());
            System.debug(response.getBody());
            System.debug(response.getStatus());
            System.debug('Algo fallo');
            
            opp.StageName = 'Resubmit Project';
        }
        update opp;
    }      
    
    public class JsonWrapper{
        String opportunityId;
        String opportunityName;
        String accountName;
        String closeDate;
        Decimal amount;
        
        public JsonWrapper(Opportunity opp){
            this.opportunityId = opp.Id;
            this.opportunityName = opp.Name;
            this.accountName = opp.Account.Name;
            this.closeDate = String.valueOf(opp.CloseDate); 
            this.amount = opp.Amount;
        }
    }
}