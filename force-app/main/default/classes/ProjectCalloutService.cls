public class ProjectCalloutService {
    //Complete the implementation for business and callout logic
    @InvocableMethod
    public static void PostOpportunityToPMS(List<Id> oppIds){
        if(oppIds.size() > 0){
            System.enqueueJob(new QueueablePMSCall(oppIds));
        }
    }

    public static void sendRequest(List<Id> oppIds){
        ServiceTokens__c projectServiceToken = [SELECT Id, Name, Token__c 
                                                FROM ServiceTokens__c
                                                WHERE Name = 'ProjectServiceToken'];

        String tok = projectServiceToken.Id;
        //ServiceTokens__c.getInstance('ProjectServiceToken').Token__c;

       List<Opportunity> opps = [SELECT Id, Name, Account.Name, CloseDate, Amount 
                                  FROM Opportunity
                                  WHERE Id in :oppIds];
        
        Map<String, Object> opportunity = new Map<String, Object>();
        if (opps.size() > 0) {
            opportunity.put('opportunityId', opps[0].Id);
            opportunity.put('opportunityName', opps[0].Name);
            opportunity.put('accountName', opps[0].Account.Name);
            opportunity.put('closeDate', opps[0].CloseDate);
            opportunity.put('amount', opps[0].Amount);
        }        
        
        // Construir el paquete JSON        
        String jsonBody = JSON.serialize(opportunity);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ProjectService');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('token', '6bb3429e-9321-46cd-8ecc-815d2c915c6b');
        request.setBody(jsonBody);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            System.debug(response);
            System.debug('Todo ok');
        } else {
            System.debug(response.getStatusCode());
            System.debug(response.getBody());
            System.debug('Algo fallo');
        }
        System.debug(response.getBody());
    }

    

    public class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts{
        List<Id> oportunidadesParaProcesar;

        public QueueablePMSCall(List<Id> oppIds){
            this.oportunidadesParaProcesar = oppIds;
        }

        public void execute(System.QueueableContext context){
            sendRequest(oportunidadesParaProcesar);
        }
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