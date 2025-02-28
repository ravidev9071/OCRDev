public with sharing class HCSAccountDB {
    private final Account account;
    public HCSAccountDB() {

        Id recordid = ApexPages.currentPage().getParameters().get('Id');

        account = [SELECT Id, US_WSREMS__REMS_ID__c,US_WSREMS__Address_Line_1__c,Name,US_WSREMS__City__c,US_WSREMS__State__c,US_WSREMS__Zip__c FROM Account WHERE id =: recordId];
    }

    public Account getAccount() {
        return account;
    }
}