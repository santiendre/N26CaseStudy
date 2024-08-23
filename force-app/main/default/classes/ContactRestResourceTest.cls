@isTest
public class ContactRestResourceTest {
    private static String REQUEST_URI = 'services/apexrest/contactproduct';

    @TestSetup
    static void makeData() {
        List<SObject> recordsToInsert = new List<SObject>();
        Contact testContact = new Contact(FirstName = 'firstName', LastName = 'lastName', Home_Country__c = 'DE', Product__c = 'Standard', External_UUID__c = 'test-uuid');
        recordsToInsert.add(testContact);
        Contact testContactFail = new Contact(FirstName = 'firstNameFail', LastName = 'lastNameFail', Home_Country__c = 'FR', Product__c = 'Standard', External_UUID__c = 'test-uuid-fail');
        recordsToInsert.add(testContactFail);
        N26_Product__c testProduct = new N26_Product__c(Product__c = 'Standard', Country__c = 'DE', Currency__c = 'EUR', Monthly_Cost__c = 0, ATM_Fee__c = 1.7, Replacement_Cost__c = 6);
        recordsToInsert.add(testProduct);
        insert recordsToInsert;
    }

    @isTest
    static void doGetTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI + '/test-uuid';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        ContactRestResource.doGet();
        Test.stopTest();
        System.assertEquals(200, res.statusCode);
        System.assert(res.responseBody.toString().contains('Standard'));
    }

    @isTest
    static void doGetFailNoContactTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI + '/invalid-uuid';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        ContactRestResource.doGet();
        Test.stopTest();
        System.assertEquals(404, res.statusCode);
        System.assert(res.responseBody.toString().contains('Contact not found'));
    }

    @isTest
    static void doGetFailNoProductTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI + '/test-uuid-fail';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        ContactRestResource.doGet();
        Test.stopTest();
        System.assertEquals(404, res.statusCode);
        System.assert(res.responseBody.toString().contains('Product not found'));
    }
}