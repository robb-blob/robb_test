@isTest
public class NewTradeControllerTest {

    private class SuccessfulMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{'+
                '"success": true,'+
                '"timestamp": 1519296206,'+
                '"base": "EUR",'+
                '"date": "2021-07-17",'+
                '"rates": {'+
                    '"AUD": 1.566015,'+
                    '"CAD": 1.560132,'+
                    '"CHF": 1.154727,'+
                    '"CNY": 7.827874,'+
                    '"GBP": 0.882047,'+
                    '"JPY": 132.360679,'+
                    '"USD": 1.23396'+
                '}'+
            '}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    private class SuccessfulEmptyMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{'+
                '"success": false,'+
                '"timestamp": 1519296206,'+
                '"base": "EUR",'+
                '"date": "2021-07-17"'+
            '}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    private class FailMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(404);
            res.setStatus('KO');
            return res;
        }
    }

    @isTest
    static void nsertTrade_shouldInsert() {
        NewTradeController.insertTrade('EUR', 'USD', 1.1, 100);
        System.assertEquals(1, [SELECT Count() FROM Trade__c]);
    }

    @isTest
    static void getRates_shouldReturnTrades() {
        Test.setMock(HttpCalloutMock.class, new SuccessfulMock());

        Test.startTest();
        Map<String, Decimal> rates = NewTradeController.getRates();
        Test.stopTest();

        System.assertNotEquals(null, rates);
    }

    @isTest
    static void getRates_shouldReturnNothing() {
        Test.setMock(HttpCalloutMock.class, new SuccessfulEmptyMock());

        Test.startTest();
        try {
            Map<String, Decimal> rates = NewTradeController.getRates();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void getRates_shouldBreak() {
        Test.setMock(HttpCalloutMock.class, new FailMock());
        
        Test.startTest();
        try {
            Map<String, Decimal> rates = NewTradeController.getRates();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}
