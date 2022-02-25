import { LightningElement, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import  getPreviousProblemsDiscussed   from '@salesforce/apex/ProblemsDiscussedController.getPreviousProblemsDiscussed';
import PROBLEMS_DISCUSSED_FIELD from '@salesforce/schema/Interview__c.Problems_Discussed__c';
import ID_FIELD from '@salesforce/schema/Interview__c.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Interview__c.Status__c';
export default class ProblemsDiscussed extends LightningElement {

    @api recordId;

    @wire(getPreviousProblemsDiscussed, {recordId: '$recordId'})
    problemDiscussed;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    record;

    get previousProblemsDiscussedValue() {
        if(this.problemDiscussed.data !== undefined)
        return this.problemDiscussed.data.PreviousProblemDiscussed;
    }
    get currentProblemsDiscussedValue() {
        if(this.problemDiscussed.data !== undefined)
        return this.problemDiscussed.data.ProblemDiscussed;
    }

    saveCurrentProblemsDiscussed() {
        if(this.record.data.fields.Status__c.value == 'InProgress' || this.record.data.fields.Status__c.value == 'Completed') {
            const fields = {};
            fields[PROBLEMS_DISCUSSED_FIELD.fieldApiName] = this.template.querySelector('lightning-input-rich-text').value;
            fields[ID_FIELD.fieldApiName] = this.recordId;

            const recordInput = { fields };
            updateRecord(recordInput)
                    .then(() => {
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error creating record',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Can not update handshake information',
                    message: 'Can not update handshake information',
                    variant: 'error'
                })
            );
        }
    }
}