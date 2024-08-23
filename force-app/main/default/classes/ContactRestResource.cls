@RestResource(urlMapping='/contactproduct/*')
global class ContactRestResource {

    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //Get the uuid from the request URI
        String uuid = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        try {
            List<Contact> cList = [SELECT FirstName, LastName, Product__c, Home_Country__c FROM Contact WHERE External_UUID__c = :uuid];
            if(cList.isEmpty()) {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('{"error": "Contact not found"}');
                return;
            }
            Contact c = cList.get(0);
            List<N26_Product__c> productsList = [SELECT Id, Product__c, Monthly_Cost__c, ATM_Fee__c, Replacement_Cost__c, Currency__c FROM N26_Product__c WHERE Product__c = :c.Product__c AND Country__c = :c.Home_Country__c];
            if(productsList.isEmpty()) {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('{"error": "Product not found"}');
                return;
            }
            N26_Product__c cp = productsList.get(0);
            ContactProductDetails cpd = new ContactProductDetails(c.firstName, c.lastName, c.Home_Country__c, new ProductDetails(cp.Product__c, cp.Currency__c, cp.Monthly_Cost__c, cp.ATM_Fee__c, cp.Replacement_Cost__c));
            res.responseBody = Blob.valueOf(JSON.serializePretty(cpd));
            res.statusCode = 200;
        } catch(Exception e) {
            System.debug('GET Request error for URI ' + req.requestURI + ': ' + e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "Internal server error"}');
        }
    }

    //Wrapper classes for contact and product details
    global class ContactProductDetails {
        public String firstName;
        public String lastName;
        public String countryCode;
        public ProductDetails product;
        public ContactProductDetails(String firstName, String lastName, String countryCode, ProductDetails product) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.countryCode = countryCode;
            this.product = product;
        }
    }

    global class ProductDetails {
        public String productName;
        public String currencyCode;
        public Decimal monthlyCost;
        public Decimal atmFeePercent;
        public Decimal replacementCost;
        public ProductDetails(String productName, String currencyCode, Decimal monthlyCost, Decimal atmFeePercent, Decimal replacementCost) {
            this.productName = productName;
            this.currencyCode = currencyCode;
            this.monthlyCost = monthlyCost;
            this.atmFeePercent = atmFeePercent;
            this.replacementCost = replacementCost;
        }
    }
}
