import { LightningElement, api, wire } from 'lwc';
import { getPicklistValues,getObjectInfo } from 'lightning/uiObjectInfoApi';
import CURR_STATUS_FIELD from '@salesforce/schema/InterviewEventCandidate__c.Current_Status__c';
import IEC_OBJECT from '@salesforce/schema/InterviewEventCandidate__c';
import ID_FIELD from '@salesforce/schema/InterviewEvent__c.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';


export default class HandshakeInformation extends LightningElement {

    @api recordId;

    @wire(getObjectInfo, { objectApiName: IEC_OBJECT })
    interviewMetadata;

    @wire(getPicklistValues,{ recordTypeId: '$interviewMetadata.data.defaultRecordTypeId', fieldApiName: CURR_STATUS_FIELD})
    statusPicklist;    

    error;
    statuses;

    @wire(getRelatedListRecords, {parentRecordId: '$recordId',relatedListId:'InterviewEventCandidate',fields:['InterviewEventCandidate__r.Current_Status__c']})
    listInfo({ error, data }) {
        if (data) {
            this.statuses = data.records;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.statuses = undefined;
        }
    }

}