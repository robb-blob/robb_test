@isTest
public class TradeTriggerTest {

    @isTest
    static void test_insert() {
        insert new Trade__c(
            Buy_Currency__c = 'EUR',
            Sell_Currency__c = 'USD',
            Rate__c = 1.1,
            Sell_Amount__c = 100000
        );
    }
}
