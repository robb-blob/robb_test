public with sharing class NewTradeController {

    static final String API_KEY = 'fdd04ab87e325b19ae36c2eaa989abe0';

    public class FixerResponse {
        public Boolean success;
        public Datetime timestamp;
        public String base;
        public Date rateDate;
        public Map<String, Decimal> rates;
    }

    @AuraEnabled
    public static Id insertTrade(String buyCurrency, String sellCurrency, Decimal rate, Decimal sellAmount) { 
        Trade__c trade = new Trade__c(
            Buy_Currency__c = buyCurrency,
            Sell_Currency__c = sellCurrency,
            Rate__c = rate,
            Sell_Amount__c = sellAmount
        );
        insert trade;
        return trade.Id;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getRates() {
        FixerResponse fixerResponse = new FixerResponse();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://data.fixer.io/api/latest?access_key='+API_KEY);
        req.setMethod('GET');

        HTTPResponse response = new Http().send(req);
        if (response.getStatus() != 'OK')
            throw new AuraHandledException('Could not connect to Fixer.io exchange rate service, please try again later.');
        
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                switch on parser.getText() {
                    when 'success' {
                        parser.nextToken();
                        fixerResponse.success = parser.getBooleanValue();
                    }
                    when 'timestamp' {
                        parser.nextToken();
                        fixerResponse.timestamp = Datetime.newInstance(parser.getLongValue());
                    }
                    when 'base' {
                        parser.nextToken();
                        fixerResponse.base = parser.getText();
                    }
                    when 'rates' {
                        parser.nextToken();
                        fixerResponse.rates = new Map<String, Decimal>();
                        while (parser.nextToken() != JSONToken.END_OBJECT) {
                            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                                String curr = parser.getText();
                                parser.nextToken();
                                fixerResponse.rates.put(curr, parser.getDecimalValue());
                            }
                        }
                        parser.nextToken();
                    }
                }
            }
        }

        if (!fixerResponse.success || fixerResponse.rates == null)
            throw new AuraHandledException('Could not pull exchange rate from Fixer.io, please try again later.');

        return fixerResponse.rates;
    }
}
