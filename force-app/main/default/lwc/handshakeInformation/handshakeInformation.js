import { LightningElement, api, wire } from 'lwc';
import  getPrviousHandshakeInformation   from '@salesforce/apex/HandshakeInformationController.getPrviousHandshakeInformation';
import { updateRecord } from 'lightning/uiRecordApi';
import HANDSHAKE_INFORMATION_FIELD from '@salesforce/schema/Interview__c.Handshake_Information__c';
import ID_FIELD from '@salesforce/schema/Interview__c.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Interview__c.Status__c';
export default class HandshakeInformation extends LightningElement {

    @api recordId;

    @wire(getPrviousHandshakeInformation, {recordId: '$recordId'})
    handshakeInformation;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    record;

    get previousHandshakeInformationValue() {
        if(this.handshakeInformation.data !== undefined)
        return this.handshakeInformation.data.PreviousHandshakeInformation;
    }
    get currentHandshakeInformationValue() {
        if(this.handshakeInformation.data !== undefined)
        return this.handshakeInformation.data.HandshakeInformation;
    }

    saveCurrentHandshakeInformation() {
        if(this.record.data.fields.Status__c.value == 'InProgress' || this.record.data.fields.Status__c.value == 'Completed') {
            const fields = {};
            fields[HANDSHAKE_INFORMATION_FIELD.fieldApiName] = this.template.querySelector('lightning-input-rich-text').value;
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