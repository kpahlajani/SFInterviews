import { LightningElement, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import HANDSHAKE_INFORMATION_FIELD from '@salesforce/schema/Interview__c.Handshake_Information__c';
import ID_FIELD from '@salesforce/schema/Interview__c.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class HandshakeInformation extends LightningElement {

    @api recordId;

   // @wire(getPrviousHandshakeInformation, {recordId: '$recordId'})
    handshakeInformation;

    get previousHandshakeInformationValue() {
        if(this.handshakeInformation.data !== undefined)
        return this.handshakeInformation.data.PreviousHandshakeInformation;
    }
    get currentHandshakeInformationValue() {
        if(this.handshakeInformation.data !== undefined)
        return this.handshakeInformation.data.HandshakeInformation;
    }

    saveCurrentHandshakeInformation() {
        
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
    }
}