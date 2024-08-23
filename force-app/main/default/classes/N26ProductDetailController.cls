public class N26ProductDetailController {

    @AuraEnabled(cacheable=true)
    public static N26_Product__c getProductDetails(String contactId) {
        try {
            List<Contact> cList = [SELECT Product__c, Home_Country__c FROM Contact WHERE Id = :contactId];
            if(cList.isEmpty()) {
                throw new HandledException('No contact with Id ' + contactId + ' was found');
            }
            Contact c = cList.get(0);
            List<N26_Product__c> productsList = [SELECT Id, Product__c, Monthly_Cost__c, ATM_Fee__c, Replacement_Cost__c, Currency__c FROM N26_Product__c WHERE Product__c = :c.Product__c AND Country__c = :c.Home_Country__c];
            if(productsList.isEmpty()) {
                throw new HandledException('No ' + c.Product__c + ' product available for ' + c.Home_Country__c);
            }
            return productsList.get(0);
        } catch (HandledException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }
}