import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import insertTrade from '@salesforce/apex/NewTradeController.insertTrade';
import getRates from '@salesforce/apex/NewTradeController.getRates';
import TRADE_OBJECT from '@salesforce/schema/Trade__c';
import CURRENCY_FIELD from '@salesforce/schema/Trade__c.Buy_Currency__c';

export default class NewTrade extends NavigationMixin(LightningElement) {

    @api recordId;
    @track defaultRecordTypeId;
    @track buyCurrency;
    @track sellCurrency;
    @track buyAmount;

    loading = true;
    rate;
    sellAmount;
    currencies = {};
    rates = new Map(); 

    @wire(getObjectInfo, { objectApiName: TRADE_OBJECT })
    getDefaultRecordTypeId({error,data}){
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.showNotification('Error!', 'Could not pull Trade object data!', 'error');
        }
     };

    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: CURRENCY_FIELD })
    getCurrencies({error, data}){
        if (data){
            this.currencies = data.values;
            this.loading = false;
            this.pullRates();
        } else if (error) {
            this.showNotification('Error!', 'Could not pull Currencies\' data!', 'error');
        }
    };

    pullRates() {
        getRates()
        .then(result => {
            this.rates = result;
        })
        .catch(error => {
            this.showNotification('Error!', error, 'error');
        });
    }

    cancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Trade__c',
                actionName: 'home',
            }
        });
    }

    save() {
        if (this.buyCurrency && this.sellCurrency && this.rate && this.sellAmount){
            insertTrade({
                buyCurrency : this.buyCurrency,
                sellCurrency : this.sellCurrency,
                rate : this.rate,
                sellAmount : this.sellAmount
            })
            .then(result => {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Trade__c',
                        actionName: 'view'
                    }
                });
            })
            .catch(error => {
                this.showNotification('Error!', error.message, 'error');
            });
        } else
            this.showNotification('Warning!', 'You must fill all the fields!', 'warning');
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleSellCurrencyChange(event) {
        this.sellCurrency = event.detail.value;
        this.updateRate();
        this.updateBuyAmount();
    }

    handleBuyCurrencyChange(event) {
        this.buyCurrency = event.detail.value;
        this.updateRate();
        this.updateBuyAmount();
    }

    handleAmountChange(event) {
        this.sellAmount = event.detail.value;
        this.updateBuyAmount();
    }

    updateRate() {
        if (this.sellCurrency && this.buyCurrency)
            this.rate = this.rates[this.buyCurrency] / this.rates[this.sellCurrency];
        else
            this.rate = undefined;
    }

    updateBuyAmount() {
        if (this.rate && this.sellAmount)
            this.buyAmount = this.rate * this.sellAmount;
        else
            this.buyAmount = undefined;
    }
}
