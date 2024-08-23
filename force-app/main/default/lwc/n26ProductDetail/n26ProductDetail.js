import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getProductDetails from '@salesforce/apex/N26ProductDetailController.getProductDetails';
import CONTACT_FIELD from '@salesforce/schema/Case.ContactId';

const columns = [
    { label: 'Label', fieldName: 'label' },
    { label: 'Value', fieldName: 'value' }
];

export default class N26ProductDetail extends LightningElement {
    @api recordId;
    contactId;
    productDetails;
    columns = columns;
    data = [];
    error;

    @wire(getRecord, {recordId: '$recordId', fields: [CONTACT_FIELD]})
    getContactId({ error, data }) {
        if(data) {
            this.contactId = data.fields.ContactId.value;
            this.fetchProductDetails();
        } else if (error) {
            this.error = error;
        }
    }

    fetchProductDetails() {
        getProductDetails({ contactId: this.contactId })
            .then(result => {
                this.productDetails = result;
                this.error = undefined;
                this.populateData();
            })
            .catch(error => {
                this.error = error.body?.message;
                this.productDetails = undefined;
            });
    }

    populateData() {
        if(this.productDetails) {
            this.data = [
                { label: 'Cost per calendar month', value: this.formatValue(this.productDetails.Monthly_Cost__c, false) },
                { label: 'ATM Fee in other currencies', value: this.formatValue(this.productDetails.ATM_Fee__c, true) },
                { label: 'Card Replacement Cost', value: this.formatValue(this.productDetails.Replacement_Cost__c, false) }
            ];
        }
    }

    formatValue(value, isPercentage) {
        if (value === null || value === undefined) {
            return 'N/A';
        } else if (value === 0) {
            return 'FREE';
        } else {
            if(isPercentage) {
                return `${value.toFixed(2)}%`;
            } else {
                return `${this.productDetails.Currency__c} ${value.toFixed(2)}`;
            }
        }
    }

    get formattedMonthlyCost() {
        return this.formatValue(this.productDetails?.Monthly_Cost__c, false);
    }

    get formattedAtmFee() {
        return this.formatValue(this.productDetails?.ATM_Fee__c, true);
    }

    get formattedReplacementCost() {
        return this.formatValue(this.productDetails?.Replacement_Cost__c, false);
    }

    get productNameStyle() {
        switch (this.productDetails?.Product__c) {
            case 'Standard':
                return 'color: black; background-color: #CCE3DA;';
            case 'Black':
                return 'color: white; background-color: black;';
            case 'Metal':
                return 'color: white; background-color: #7B899B;';
            default:
                return 'color: black; background-color: white;';
        }
    }
}