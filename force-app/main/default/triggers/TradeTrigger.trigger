trigger TradeTrigger on Trade__c (after insert) {
    new TradeTriggerHandler(Trigger.isAfter, Trigger.isInsert)
        .execute(Trigger.new);
}