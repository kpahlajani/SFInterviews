import { LightningElement ,api, wire, track} from 'lwc';
import getCandidatesList from '@salesforce/apex/InterviewCandidatesGridHelper.getCandidatesList';
import getAllAvailableInterviewers from '@salesforce/apex/ScheduleAnInterview.getAllAvailableInterviewers';
import getInterviewRounds from '@salesforce/apex/ScheduleAnInterview.getInterviewRoundsForEventCandidate';
import scheduleInterview from '@salesforce/apex/ScheduleAnInterview.scheduleInterview';
import getScheduledRoundForEventCandidate from '@salesforce/apex/ScheduleAnInterview.getScheduledRoundForEventCandidate';
import getInterviewDetailsByInterviewId from '@salesforce/apex/ScheduleAnInterview.getInterviewDetailsByInterviewId';
export default class InterviewCandidatesGrid extends LightningElement {
    @api recordId;

    actions = [
        { label: 'Schedule', name: 'Schedule' },
        { label: 'Reschedule', name: 'Reschedule'},
    ];

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
            type: 'text',
            sortable: true
        },
        {
            type: 'action',
            typeAttributes: { rowActions: this.actions },
        },
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
                candidate.ICName = record.Id;
                candidate.Candidate_Name__c = record.Candidate_Name__c;
                candidate.Candidate_Level__c = record.Candidate_Level__c;
                candidate.Current_Status__c = record.Current_Status__c;
                candidate.Aggregated_Score__c = record.Aggregated_Score__c;
                if(record.Ongoing_Interview__r!=null){
                    candidate.Ongoing_Interview = record.Ongoing_Interview__r.Name;
                }
                if(record.Ongoing_Interview__r!=null && record.Ongoing_Interview__r.Scheduled_Start_Time__c!=null){
                    candidate.Scheduled_Start_Time = record.Ongoing_Interview__r.Scheduled_Start_Time__c.substring(11,16);
                }

                candidates.push(candidate);
            });
            this.candidateList = candidates;
                
        } else if (error) {
            this.error = error;
        }
    }

    selectedCandidates = [];
    selectedCandidate;
    startDateTime;
    endDateTime;
    availableInterviewers = new Map();
    options;
    roundName;
    @track isScheduleCandidatesModalOpen = false;

    opneScheduleCandidatesModal() {
        this.isScheduleCandidatesModalOpen = true;
        this.getInterviewRounds();
    }
    closeScheduleCandidatesModal() {
        this.isScheduleCandidatesModalOpen = false;
        this.selectedCandidates = [];
        this.picklistValue = '';
        this.items = [];
        this.startDateTime = undefined;
        this.endDateTime = undefined;
        this.selectedCandidate = undefined;
    }

    handleStartDateTime(event) {
        this.startDateTime = event.target.value;
        if(this.startDateTime !== undefined && this.endDateTime !== undefined)
        this.getInterviewerList();
    }

    handleEndDateTime(event) {
        this.endDateTime = event.target.value;
        if(this.startDateTime !== undefined && this.endDateTime !== undefined)
        this.getInterviewerList();
    }

    async getInterviewerList() {
        if(this.startDateTime !== undefined && this.endDateTime !== undefined) {
            this.availableInterviewers = await getAllAvailableInterviewers({availabilityCheckFrom : this.startDateTime, availabilityCheckTo : this.endDateTime, eventId : this.recordId});
            this.getValues();
        }
    }

    @track items = []; //this will hold key, value pair
    picklistValue = ''; //initialize combo box value
    @track options = [];
    @track chosenValue = '';

    getValues() {
        if (this.availableInterviewers) {
            let temp = [];
            let i=0;
            for (const [key, value] of Object.entries(this.availableInterviewers)) {
                const option = {
                    label: value,
                    value: key
                };
                temp[i++] = option;
            } 
            this.items = temp;              
        } 
    }

    handleValueChange(event) {
        this.picklistValue = event.detail.value;
    }

    submitDetails() {
        scheduleInterview({interviewId : this.roundName, availabilityCheckFrom : this.startDateTime, availabilityCheckTo : this.endDateTime, hiringPanelMembers : this.picklistValue})
        this.closeScheduleCandidatesModal();
    }
   
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedCandidate = row.ICName;
        switch (actionName) {
            case 'Schedule':
                this.opneScheduleCandidatesModal();
                break;
            case 'Reschedule':
                this.opneReScheduleCandidatesModal();
            default:
        }
    }
    

    async getInterviewRounds() {
        let temp = await getInterviewRoundsForEventCandidate({interviewEventCandidate : this.selectedCandidate});
        let temp1 = [];
        for(let i=0; i<temp.length; i++)  {
            const option = {
                label: temp[i].Questionaire__r.Name,
                value: temp[i].Id
            };
            temp1[i] = option;                                  
        }  
        this.options = temp1;     
    }

    handleRoundName(event) {
        this.roundName = event.target.value;
    }

    isReScheduleCandidatesModalOpen;
    startDateTimeValue;
    endDateTimeValue;
    resheduledInterviewId;
    @track rescheduleRoundOptions = [];

    opneReScheduleCandidatesModal() {
        this.isReScheduleCandidatesModalOpen = true;
        this.getScheduledRoundForEventCandidate();
    }

    async getScheduledRoundForEventCandidate() {
        let temp = await getScheduledRoundForEventCandidate({interviewEventCandidate : this.selectedCandidate});
        let temp1 = [];
        for(let i=0; i<temp.length; i++)  {
            const option = {
                label: temp[i].Questionaire__r.Name,
                value: temp[i].Id
            };
            temp1[i] = option;                                  
        }  
        this.rescheduleRoundOptions = temp1;
    }

    async getRoundDetails(event) {
        let temp = await getInterviewDetailsByInterviewId({interviewId : event.target.value});
        this.startDateTimeValue = temp.StartDateTime;
        this.endDateTimeValue = temp.EndDateTime;
        this.resheduledInterviewId = temp.Id;
        this.availableInterviewers = await getAllAvailableInterviewers({availabilityCheckFrom : this.startDateTimeValue, availabilityCheckTo : this.endDateTimeValue, eventId : this.recordId});
        this.getValues();
    }

    
    submitRescheduleDetails() {
        scheduleInterview({interviewId : this.resheduledInterviewId, availabilityCheckFrom : this.startDateTimeValue, availabilityCheckTo : this.endDateTimeValue, hiringPanelMembers : this.picklistValue});
        this.closeRe
    }

    handleStartDateTimeValue(event) {
        this.startDateTimeValue = event.target.value;
        if(this.startDateTimeValue !== undefined && this.endDateTimeValue !== undefined)
        this.getInterviewerList();
    }

    handleEndDateTimeValue(event) {
        this.endDateTime = event.target.value;
        if(this.startDateTimeValue !== undefined && this.endDateTimeValue !== undefined)
        this.getRescheduledInterviewerList();
    }

    closeReScheduleCandidatesModal() {
        this.isReScheduleCandidatesModalOpen = false;
        this.selectedCandidates = [];
        this.picklistValue = '';
        this.rescheduleRoundOptions = [];
        this.startDateTimeValue = undefined;
        this.endDateTimeValue = undefined;
        this.selectedCandidate = undefined;
    }
}