import { LightningElement ,api, wire, track} from 'lwc';
import getCandidatesList from '@salesforce/apex/InterviewCandidatesGridHelper.getCandidatesList';
//import getAllAvailableInterviewers from '@salesforce/apex/ScheduleAnInterview.getAllAvailableInterviewers';
export default class InterviewCandidatesGrid extends LightningElement {
    @api recordId;
    @track columns = [
        {
            label: 'Id',
            fieldName: 'ICName',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'},
            sortable: true
        },
        {
            label: 'Candidate Name',
            fieldName: 'Candidate_Name__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Current Status',
            fieldName: 'Current_Status__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'On Going Interview',
            fieldName: 'Ongoing_Interview',
            type: 'text',
            sortable: true
        },
        {
            label: 'Aggregated Score',
            fieldName: 'Aggregated_Score__c',
            type: 'number',
            sortable: true
        }
    ];
 
    @track error;
    @track candidateList ;
    @wire(getCandidatesList,{recordId: '$recordId'})
    wiredAccounts({
        error,
        data
    }) {
        if (data) {
                let candidates = [];
                data.forEach(record => {
                let candidate = {};
                candidate.ICName = '/'+record.Id;
                candidate.Candidate_Name__c = record.Candidate_Name__c;
                candidate.Current_Status__c = record.Current_Status__c;
                candidate.Aggregated_Score__c = record.Aggregated_Score__c;
                if(record.Ongoing_Interview__r!=null){
                candidate.Ongoing_Interview = record.Ongoing_Interview__r.Name;
                }

                candidates.push(candidate);
            });
            this.candidateList = candidates;
                
        } else if (error) {
            this.error = error;
        }
    }

    selectedCandidates = [];
    startDateTime;
    endDateTime;
    availableInterviewers;
    getSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;

        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedCandidates[i] = selectedRows[i].Id;
        }
    }

    @track isScheduleCandidatesModalOpen = false;

    opneScheduleCandidatesModal() {
        this.isScheduleCandidatesModalOpen = true;
    }
    closeScheduleCandidatesModal() {
        this.isScheduleCandidatesModalOpen = false;
        this.selectedCandidates = [];
        this.picklistValue = '';
        this.items = [];
        this.startDateTime = '';
        this.endDateTime = '';
    }

    handleStartDateTime(event) {
        //let a = event.target.value;
        this.startDateTime = event.target.value;
        this.getInterviewerList();
    }

    handleEndDateTime(event) {
        //let b = event.target.value;
        this.endDateTime = event.target.value;
        this.getInterviewerList();
    }

    getInterviewerList() {
        if(this.startDateTime !== undefined && this.endDateTime !== undefined) {
           this.availableInterviewers ;//= getAllAvailableInterviewers({availabilityCheckFrom : this.startDateTime, availabilityCheckTo : this.endDateTime, eventId : this.recordId});
            this.getValues();
        }
    }

    @track items = []; //this will hold key, value pair
    picklistValue = ''; //initialize combo box value

    @track chosenValue = '';

    getValues() {
        if (this.availableInterviewers) {
            let temp = [];
            for(let i=0; i<this.availableInterviewers.length; i++)  {
                const option = {
                    label: this.availableInterviewers[i],
                    value: this.availableInterviewers[i]
                };
                temp[i] = option;                                  
            }  
            this.items = temp;              
        } 
    }

    handleValueChange(event) {
        this.picklistValue = event.detail.value;
    }
   
}