import { LightningElement, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import  getPreviousProblemsDiscussed   from '@salesforce/apex/ProblemsDiscussedController.getPreviousProblemsDiscussed';
import PROBLEMS_DISCUSSED_FIELD from '@salesforce/schema/Interview__c.Problems_Discussed__c';
import ID_FIELD from '@salesforce/schema/Interview__c.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProblemsDiscussed extends LightningElement {

    @api recordId;

    @wire(getPreviousProblemsDiscussed, {recordId: '$recordId'})
    problemDiscussed;

    get previousProblemsDiscussedValue() {
        if(this.problemDiscussed.data !== undefined)
        return this.problemDiscussed.data.PreviousProblemDiscussed;
    }
    get currentProblemsDiscussedValue() {
        if(this.problemDiscussed.data !== undefined)
        return this.problemDiscussed.data.ProblemDiscussed;
    }

    saveCurrentProblemsDiscussed() {
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
    }
}