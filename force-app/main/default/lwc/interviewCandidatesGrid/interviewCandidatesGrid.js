import { LightningElement ,api, wire, track} from 'lwc';
import getCandidatesList from '@salesforce/apex/InterviewCandidatesGridHelper.getCandidatesList';
export default class InterviewCandidatesGrid extends LightningElement {
    @api recordId;
    @track columns = [{
            label: 'Id',
            fieldName: 'Id',
            type: 'text',
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
                candidate.Id = record.Id;
                candidate.Candidate_Name__c = record.Candidate_Name__c;
                candidate.Current_Status__c = record.Current_Status__c;
                candidate.Ongoing_Interview = record.Ongoing_Interview__r.Name;

                candidates.push(candidate);
            });
            this.candidateList = candidates;
                
        } else if (error) {
            this.error = error;
        }
    }

   
}