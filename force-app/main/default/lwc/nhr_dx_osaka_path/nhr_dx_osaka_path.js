// Import LightningElement and api classes from lwc module
import { LightningElement, api, wire, track } from 'lwc';
// import getPicklistValues method from lightning/uiObjectInfoApi
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// import getObjectInfo method from lightning/uiObjectInfoApi
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// Import Account object APi from schema
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
// import Account status field from schema
import PICKLIST_FIELD from '@salesforce/schema/Account.AccountStage_Osaka__c';
// import record ui service to use crud services
import { getRecord } from 'lightning/uiRecordApi';
// import show toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import update record api
import { updateRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Account.Id',
    'Account.AccountStage_Osaka__c'
];

export default class CustomAccountPath extends LightningElement {

    @track selectedValue;
    @api recordId;
    @track showSpinner = false;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PICKLIST_FIELD })
    picklistFieldValues;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record;


    get picklistValues() {
        let itemsList = [];

        if (this.record.data) {
            if (!this.selectedValue && this.record.data.fields.AccountStage_Osaka__c.value) {
                this.selectedValue = this.record.data.fields.AccountStage_Osaka__c.value + '';
            }
            if (this.picklistFieldValues && this.picklistFieldValues.data && this.picklistFieldValues.data.values) {
                let valueList = [];
                let selectedUpTo = 0;
                for (let item in this.picklistFieldValues.data.values) {

                    if (Object.prototype.hasOwnProperty.call(this.picklistFieldValues.data.values, item)) {
                        valueList.push(this.picklistFieldValues.data.values[item].value);
                        let classList;
                        if (this.picklistFieldValues.data.values[item].value === this.selectedValue) {
                            classList = 'slds-path__item slds-is-current slds-is-active';
                        } else {
                            classList = 'slds-path__item slds-is-incomplete';
                        }

                        itemsList.push({
                            pItem: this.picklistFieldValues.data.values[item],
                            classList: classList
                        })
                    }
                }

                selectedUpTo = valueList.indexOf(this.selectedValue);

                if (selectedUpTo > 0) {
                    for (let item = 0; item < selectedUpTo; item++) {
                        itemsList[item].classList = 'slds-path__item slds-is-complete';
                    }
                }
                console.log(itemsList);
                return itemsList;
            }
        }
        return null;
    }

    handleSelect(event) {
        this.selectedValue = event.currentTarget.dataset.value;
    }

    handleMarkAsSelected() {
        this.showSpinner = true;
        const fields = {};
        fields.Id = this.recordId;
        fields.AccountStage_Osaka__c = this.selectedValue;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '成功',
                        message: 'ステータス更新しました。',
                        variant: 'success'
                    })
                );
            })
            .catch(
                error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '失敗',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                }
            );
        this.showSpinner = false;
    }
}