public with sharing class TradeTriggerHandler {

    private Boolean shouldExecute;
    private String chatterGroupName = 'Trade reviewers';

    public TradeTriggerHandler(Boolean isAfter, Boolean isInsert) {
        this.shouldExecute = isAfter && isInsert;
    }

    public void execute(Trade__c[] trades) {
        if (!shouldExecute) return;

        Id collaborationGroupId;
        try {
            collaborationGroupId = [SELECT Id FROM CollaborationGroup WHERE Name =: chatterGroupName LIMIT 1].Id;
        } catch(exception e) {
            collaborationGroupId = setupCollaborationGroup();
            if (collaborationGroupId == null) return;
        }

        FeedItem[] posts = new FeedItem[]{};
        for (Trade__c trade : trades) {
            posts.add(new FeedItem(
                ParentId = collaborationGroupId,
                CreatedById = trade.OwnerId,
                Type = 'TextPost',
                IsRichText = true,
                Body = '<p>A new trade has been created with the following data:</p>'+
                    '<ul>'+
                    '<li>Sell Currency: '+trade.Sell_Currency__c+'</li>'+
                    '<li>Sell Amount: '+trade.Sell_Amount__c+'</li>'+
                    '<li>Buy Currency: '+trade.Buy_Currency__c+'</li>'+
                    '<li>Buy Amount: '+trade.Buy_Amount__c+'</li>'+
                    '<li>Rate: '+trade.Rate__c+'</li>'+
                    '<li>Booked Date: '+trade.Date_Booked__c+'</li>'+
                    '<li>Link to the trade: <a href="'+URL.getOrgDomainUrl().toExternalForm()+'/'+trade.Id+'">'+trade.Name+'</a></li>'+
                    '</ul>'
            ));
        }

        // No need to check for empty list since it will always contain at least 1 record.
        insert posts;
    }

    // This assumes an admin will keep the group updated after it's created.
    public Id setupCollaborationGroup() {
        Id r;
        try {
            CollaborationGroup collaborationGroup = new CollaborationGroup(Name = chatterGroupName, CollaborationType = 'Private');
            insert collaborationGroup;
            r = collaborationGroup.Id;
        } catch (exception e) {}
        return r;
    }
}
