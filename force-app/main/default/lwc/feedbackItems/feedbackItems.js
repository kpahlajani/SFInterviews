import { LightningElement, wire, api, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import  getFeedbackItems  from '@salesforce/apex/FeedbackItemsController.getFeedbackItems';
import updateFeedbackItems  from '@salesforce/apex/FeedbackItemsController.updateFeedbackItems';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FEEDBACK_ITEM_OBJECT from '@salesforce/schema/FeedbackItem__c';
import NAME_FIELD from '@salesforce/schema/FeedbackItem__c.Name';
import COMMENT_FIELD from '@salesforce/schema/FeedbackItem__c.Comments__c';
import PROFICIENCY_LEVEL_FIELD from '@salesforce/schema/FeedbackItem__c.Proficiency_Level__c';
import INTERVIEW_ID_FIELD from '@salesforce/schema/FeedbackItem__c.Interview__c';
import QUESTIONAIRE_ID_FIELD from '@salesforce/schema/FeedbackItem__c.Questionaire__c';
const columns = [
    { label: 'Feedback Item Name', fieldName: 'Name', type: 'text' },
    { label: 'Comments', fieldName: 'Comments__c', type: 'text', wrapText: true, editable: true },
    { label: 'Proficiency Level', fieldName: 'Proficiency_Level__c', type: 'text', editable: true }
    
];
export default class FeedbackItems extends LightningElement {
    error;
    columns = columns;
    draftValues = [];

    @api recordId;

    @track feedbackItemsData;

    @track isModalOpen = false;

    feedbackItemFields = [NAME_FIELD, COMMENT_FIELD, PROFICIENCY_LEVEL_FIELD];

    feedbackItemId;
    
    commentValue;
    feedbackNameValue;
    value;

    @wire(getFeedbackItems, {recordId: '$recordId'})
    feedbackItemsData;

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        // Prepare the record IDs for getRecordNotifyChange()
        updatedFields.map(row => { return { "recordId": row.Id } });
        try {
            // Pass edited fields to the updateFeedbackItems Apex controller
            const result = await updateFeedbackItems({data: updatedFields});
           this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Feedback Items updated',
                    variant: 'success'
                })
            );
    
            // Display fresh data in the datatable
            refreshApex(this.feedbackItemsData).then(() => {
                // Clear all draft values in the datatable
                this.draftValues = [];
            });
       } catch(error) {
        };
    }

    
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        this.isModalOpen = false;
        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.feedbackNameValue;
        fields[COMMENT_FIELD.fieldApiName] = this.commentValue;
        fields[PROFICIENCY_LEVEL_FIELD.fieldApiName] = this.value;
        fields[INTERVIEW_ID_FIELD.fieldApiName] = this.recordId;
        fields[QUESTIONAIRE_ID_FIELD.fieldApiName] = this.questionaireId;
        const recordInput = { apiName: FEEDBACK_ITEM_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(feedbackItem => {
                this.feedbackItemId = feedbackItem.id;
                refreshApex(this.feedbackItemsData).then(() => {
                    // Clear all draft values in the datatable
                    this.draftValues = [];
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

    handleCommentblur(event) {
        this.commentValue = event.target.value;
    }

    handleFeedbackNameValueblur(event) {
        this.feedbackNameValue = event.target.value;
    }

    handleProficiencyLevelblur(event) {
        this.value = event.detail.value;
    }

    get options() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
        ];
    }
}
