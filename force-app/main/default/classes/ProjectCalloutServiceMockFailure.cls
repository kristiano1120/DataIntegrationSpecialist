global class ProjectCalloutServiceMockFailure implements HttpCalloutMock{
   global HttpResponse respond(HttpRequest request){
      HttpResponse res = new HttpResponse();
      res.setHeader('Content.-Type', 'application/json');
      res.setStatusCode(500);
      res.setStatus('Se ha producido un errror');
      return res;
   }
}