@isTest
public with sharing class N26ProductDetailControllerTest {
    @TestSetup
    static void makeData() {
        List<SObject> recordsToInsert = new List<SObject>();
        Contact testContact = new Contact(FirstName = 'firstName', LastName = 'lastName', Home_Country__c = 'DE', Product__c = 'Standard', External_UUID__c = 'test-uuid');
        recordsToInsert.add(testContact);
        N26_Product__c testProduct = new N26_Product__c(Product__c = 'Standard', Country__c = 'DE', Currency__c = 'EUR', Monthly_Cost__c = 0, ATM_Fee__c = 1.7, Replacement_Cost__c = 6);
        recordsToInsert.add(testProduct);
        insert recordsToInsert;  
    }

    @isTest
    static void getProductDetailsTest() {
        Id contactId = [SELECT Id FROM Contact WHERE External_UUID__c = 'test-uuid' LIMIT 1].Id;
        N26_Product__c p = N26ProductDetailController.getProductDetails(contactId);
        System.assertEquals('Standard', p.Product__c);
    }

    @isTest
    static void getProductDetailsNoContactTest() {
        try {
            N26_Product__c p =  N26ProductDetailController.getProductDetails('0030000000000000AA');
        } catch(AuraHandledException e) {
            System.assert(e != null);
        }
    }

    @isTest
    static void getProductDetailsNoProductTest() {
        Contact c = [SELECT Id, Product__c FROM Contact WHERE External_UUID__c = 'test-uuid' LIMIT 1];
        c.Product__c = 'Metal';
        update c;
        try {
            N26_Product__c p =  N26ProductDetailController.getProductDetails(c.Id);
        } catch(AuraHandledException e) {
            System.assert(e != null);
        }
    }
}