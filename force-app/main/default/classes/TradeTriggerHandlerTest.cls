@isTest
public class TradeTriggerHandlerTest {
    
    @isTest
    static void execute_shouldSkip() {
        new TradeTriggerHandler(false, false).execute(new Trade__c[]{});

        System.assertEquals(0, [SELECT Count() FROM FeedItem]);
    }

    @isTest
    static void execute_shouldCauseException() {
        insert new Trade__c(
            Buy_Currency__c = 'EUR',
            Sell_Currency__c = 'USD',
            Rate__c = 1.1,
            Sell_Amount__c = 100000
        );
        Trade__c trade = [SELECT Id, Name, Sell_Currency__c, Sell_Amount__c, Buy_Currency__c, Buy_Amount__c, Rate__c, Date_Booked__c, OwnerId FROM Trade__c LIMIT 1];
        new TradeTriggerHandler(true, true).execute(new Trade__c[]{trade});

        System.assertEquals(0, [SELECT Count() FROM FeedItem]);
    }

    @isTest(SeeAllData=true)
    static void execute_shouldPost() {
        insert new Trade__c(
            Buy_Currency__c = 'EUR',
            Sell_Currency__c = 'USD',
            Rate__c = 1.1,
            Sell_Amount__c = 100000
        );
        Trade__c trade = [SELECT Id, Name, Sell_Currency__c, Sell_Amount__c, Buy_Currency__c, Buy_Amount__c, Rate__c, Date_Booked__c, OwnerId FROM Trade__c LIMIT 1];
        new TradeTriggerHandler(true, true).execute(new Trade__c[]{trade});

        System.assertNotEquals(0, [SELECT Count() FROM FeedItem]);
    }
}
