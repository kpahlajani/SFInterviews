import { LightningElement, api } from 'lwc';
import endInterviewEvent from '@salesforce/apex/ScheduleAnInterview.endInterviewEvent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class EndInterviewEvent extends LightningElement {

    @api recordId;

    closeEndEventModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    async endInterviewEvent() {
        let state = await endInterviewEvent({recordId : this.recordId});
        this.dispatchEvent(new CloseActionScreenEvent());
        if(state == false) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Atleast one interview is in progress',
                    message: 'Atleast one interview is in progress',
                    variant: 'error'
                })
            );
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Interview event closed',
                    message: 'Interview event closed',
                    variant: 'success'
                })
            );
        }
    }
}
