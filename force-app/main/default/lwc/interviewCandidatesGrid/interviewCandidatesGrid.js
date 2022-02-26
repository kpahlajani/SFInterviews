import { LightningElement ,api, wire, track} from 'lwc';
import getCandidatesList from '@salesforce/apex/InterviewCandidatesGridHelper.getCandidatesList';
import getUpdatedCandidatesList from '@salesforce/apex/InterviewCandidatesGridHelper.getUpdatedCandidatesList';
import getAllAvailableInterviewers from '@salesforce/apex/ScheduleAnInterview.getAllAvailableInterviewers';
import getInterviewRoundsForEventCandidate from '@salesforce/apex/ScheduleAnInterview.getInterviewRoundsForEventCandidate';
import getCandidateListWithFilter from '@salesforce/apex/InterviewCandidatesGridHelper.getCandidateListWithFilter';
import scheduleInterview from '@salesforce/apex/ScheduleAnInterview.scheduleInterview';
import getScheduledRoundForEventCandidate from '@salesforce/apex/ScheduleAnInterview.getScheduledRoundForEventCandidate';
import getInterviewDetailsByInterviewId from '@salesforce/apex/ScheduleAnInterview.getInterviewDetailsByInterviewId';
import { updateRecord } from 'lightning/uiRecordApi';
import CURRENT_STATUS_FIELD from '@salesforce/schema/InterviewEventCandidate__c.Current_Status__c';
import ID_FIELD from '@salesforce/schema/InterviewEventCandidate__c.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InterviewCandidatesGrid extends LightningElement {
    @api recordId;

    actions = [
        { label: 'Schedule', name: 'Schedule' },
        //{ label: 'Reschedule', name: 'Reschedule'},
        { label: 'Update Status', name: 'UpdateStatus'},
    ];

    searchKey='';
    columnName='';
    get columnOptions() {
        return [
            { label: 'Candidate Name', value: 'Candidate_Name__c' },
            { label: 'Level', value: 'Candidate_Level__c' },
            { label: 'Current Status', value: 'Current_Status__c' },
            { label: 'Planned Interactions', value: 'Total_Interactions__c' },
            { label: 'Completed Interactions', value: 'Completed_Intractions__c' },
            { label: 'Interview Round', value: 'Ongoing_Interview' },
            { label: 'Interviewers', value: 'Current_Interviewers__c' },
        ];
    }

    handleKeyChange(event) {
        this.searchKey  = event.target.value;
        this.columnName = this.template.querySelector("[data-name='columnsToSearch']").value;
        if (this.columnName==='Candidate_Level__c') {
            this.columnName = 'toLabel(Candidate_Level__c)';
        }
        this.refreshCandidateList();
    }

    connectedCallback() {  
        this._interval = setInterval(() => {  
            this.refreshCandidateList();
        }, 2000); 
    }
    
    @track columns = [
        {
            label: 'Candidate Name',
            fieldName: 'ICName',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Candidate_Name__c' }},
            sortable: true,
            wrapText: true
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
            sortable: true,
            wrapText: true
        },
        {
            label: 'Planned Interactions',
            fieldName: 'Total_Interactions__c',
            type: 'text',
            sortable: true,
            wrapText: true
        },
        {
            label: 'Completed Interactions',
            fieldName: 'Completed_Interactions__c',
            type: 'text',
            sortable: true,
            wrapText: true
        },
        {
            label: 'Start time',
            fieldName: 'Scheduled_Start_Time',
            type: 'date',
            typeAttributes:{
                hour: "2-digit",
                minute: "2-digit"
            },
            sortable: true,
            wrapText: true
        },
        {
            label: 'Interview Round',
            fieldName: 'Ongoing_Interview',
            type: 'text',
            sortable: true,
            wrapText: true,
            wrapText: true
        },
        {
            label: 'Aggregated Score',
            fieldName: 'Aggregated_Score__c',
            type: 'text',
            sortable: true,
            wrapText: true
        },
        {
            label: 'Interviewers',
            fieldName: 'Current_Interviewers__c',
            type: 'text',
            sortable: true,
            wrapText: true
        },
        {
            type: 'action',
            typeAttributes: { rowActions: this.actions },
        },
    ];
 
    @track error;
    @track candidateList ;
    @wire(getCandidateListWithFilter,{recordId:'$recordId', searchKey:'$searchKey', columnName:'$columnName'})
    wiredAccounts({
        error,
        data
    }) {
        if (data) {
            this.prepareCandidateList(data);    
        } else if (error) {
            this.error = error;
        }
    }

    async refreshCandidateList() {   
        let temp = await getUpdatedCandidatesList({recordId: this.recordId, searchKey:this.searchKey, columnName:this.columnName});
        this.prepareCandidateList(temp);
    }

    prepareCandidateList(data) {
        let candidates = [];
                data.forEach(record => {
                let candidate = {};
                candidate.ICName = '/'+record.Id;
                candidate.Candidate_Name__c = record.Candidate_Name__c;
                candidate.Candidate_Level__c = record.Candidate_Level__c;
                candidate.Current_Status__c = record.Current_Status__c;
                candidate.Aggregated_Score__c = record.Aggregated_Score__c;
                if(record.Ongoing_Interview__r!=null){
                    candidate.Ongoing_Interview = record.Ongoing_Interview__r.Name;
                }
                if((record.Current_Status__c == 'In Progress' || record.Current_Status__c == 'Completed') && record.Ongoing_Interview__r!=null && record.Ongoing_Interview__r.Actual_Start_Time__c!=null){
                    candidate.Scheduled_Start_Time = record.Ongoing_Interview__r.Actual_Start_Time__c;
                } else if(record.Ongoing_Interview__r!=null && record.Ongoing_Interview__r.Scheduled_Start_Time__c!=null){
                    candidate.Scheduled_Start_Time = record.Ongoing_Interview__r.Scheduled_Start_Time__c;
                } 
                candidate.Current_Interviewers__c = record.Current_Interviewers__c;
                candidates.push(candidate);
            });
            this.candidateList = candidates;
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
            this.availableInterviewers = await getAllAvailableInterviewers({availabilityCheckFrom : this.startDateTime, availabilityCheckTo : this.endDateTime, eventId : this.recordId,interviewId : null,interviewEventCandidate:this.selectedCandidate});
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

    async submitDetails() {
        await scheduleInterview({interviewId : this.roundName, availabilityCheckFrom : this.startDateTime, availabilityCheckTo : this.endDateTime, hiringPanelMembers : this.picklistValue})
        this.closeScheduleCandidatesModal();
        this.refreshCandidateList();
    }
   
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedCandidate = row.ICName.split('/')[1];
        switch (actionName) {
            case 'Schedule':
                this.opneScheduleCandidatesModal();
                break;
            case 'Reschedule':
                this.opneReScheduleCandidatesModal();
            case 'UpdateStatus':
                this.updateInterviewEventCandidateStatus();
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
        this.startDateTime = new Date().toISOString();
        this.endDateTime = new Date(new Date().getTime() + 90*60000).toISOString();  
        this.getInterviewerList();
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
        this.availableInterviewers = await getAllAvailableInterviewers({availabilityCheckFrom : this.startDateTimeValue, availabilityCheckTo : this.endDateTimeValue, eventId : this.recordId,interviewId : temp.Id,interviewEventCandidate:this.selectedCandidate});
        this.getValues();
    }

    
    async submitRescheduleDetails() {
        await scheduleInterview({interviewId : this.resheduledInterviewId, availabilityCheckFrom : this.startDateTimeValue, availabilityCheckTo : this.endDateTimeValue, hiringPanelMembers : this.picklistValue});
        this.closeReScheduleCandidatesModal();
        this.refreshCandidateList();
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

    get statusOptions() {
        return [
            { label: 'Loop Cut', value: 'Loop Cut' },
            { label: 'No Show	', value: 'No Show' }
        ];
    }

    isChangeStatusModalOpened = false;
    currentStatus;
    updateStatus(event) {
        this.currentStatus = event.target.value;
    }

    closeStatusChangeModal() {
        this.isChangeStatusModalOpened = false;
    }

    submitStatusChangeModal(){
        this.isChangeStatusModalOpened = false;
        this.updateCurrentStatus();
    }    
    
    updateInterviewEventCandidateStatus() {
        this.isChangeStatusModalOpened = true;
    }

    updateCurrentStatus() {
        const fields = {};
        fields[CURRENT_STATUS_FIELD.fieldApiName] = this.currentStatus;
        fields[ID_FIELD.fieldApiName] = this.selectedCandidate;

        const recordInput = { fields };
        updateRecord(recordInput)
                .then(() => {
                    this.refreshCandidateList();
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