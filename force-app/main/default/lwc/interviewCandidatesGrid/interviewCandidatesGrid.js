import { LightningElement ,api, wire, track} from 'lwc';
import getCandidatesList from '@salesforce/apex/InterviewCandidatesGridHelper.getCandidatesList';

const actions = [
    { label: 'Show Candidate Info', name: 'show_candidate_info' },
    { label: 'Show Recent Interviews', name: 'show_recent_interviews' },
];

export default class InterviewCandidatesGrid extends LightningElement {
    @api recordId;
    @track columns = [
        {
            label: 'Candidate Name',
            fieldName: 'ICName',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Candidate_Name__c' }, target: '_blank'},
            sortable: true
        },
        {
            label: 'Level',
            fieldName: 'Candidate_Level__c',
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
            label: 'start time',
            fieldName: 'Scheduled_Start_Time',
            type: 'text',
            sortable: true
        },
        {
            label: 'Aggregated Score',
            fieldName: 'Aggregated_Score__c',
            type: 'number',
            sortable: true
        },
        { 
            type: 'action', 
            typeAttributes: { 
                rowActions: actions 
            } 
        }
    ];
 
    @track error;
    @track candidateList ;
    
    @track candidateInfoRow={};
    @track recentInterviewRow={};

    @track candidateInfoModal = false;
    @track recentInterviewModal = false;
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
                candidate.Current_Candidate_Level__c = record.Candidate_Level__c;
                candidate.Scheduled_Start_Time = record.Ongoing_Interview__r.Scheduled_Start_Time__c;
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

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'show_candidate_info':
                this.showCandidateInfoModal(row);
                break;
            case 'show_recent_interviews':
                this.showRecentInterviewsModal(row);
                break;
            default:
        }
    }

    showCandidateInfoModal(row) {
        this.candidateInfoModal=true;
        this.candidateInfoRow=row;
    }

    showRecentInterviewsModal(row){
        this.recentInterviewModal=true;
        this.recentInterviewRow=row;
    }

    closeCandidateInfoModal(){
        this.candidateInfoModal=false;
    }

    closeRecentInterviewModal() {
        this.recentInterviewModal=false;
    }
   
}