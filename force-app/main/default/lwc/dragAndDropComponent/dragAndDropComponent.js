import { LightningElement, track, wire } from 'lwc';
import taskData from '@salesforce/apex/DragAndDropComponentHandler.getAllTask';
import updateTask from '@salesforce/apex/DragAndDropComponentHandler.updateTask';

export default class DragAndDropComponent extends LightningElement {
    @track codingList = [];
    @track designList = [];
    @track taskCompletedList = [];
    @track dropTaskId;

    connectedCallback(){
        this.getTaskData();
    }

    getTaskData(){
        taskData().then(result =>{
            let codingCandidatesData = [];
            let designCandidatesData = [];
            for(let i = 0; i < result.length; i++){
                let task = new Object();
                task.Id = result[i].Id;
                task.Name = result[i].Name;
                task.CandidateName = result[i].Candidate_Name__c;
                task.Candidate_Level__c = result[i].Candidate_Level__c;
                task.InterviewName = result[i].Interview__r.Name;
                if(task.InterviewName === 'Coding'){
                    codingCandidatesData.push(task);
                }else if(task.InterviewName == 'System Design'){
                    designCandidatesData.push(task);
                }
            }
            this.codingList = codingCandidatesData;
            this.designList = designCandidatesData;
        }).catch(error => {
            window.alert('$$$Test1:'+ error);
        })
    }

    taskDragStart(event){
        const taskId = event.target.id.substr(0,18);
        //window.alert(taskId);
        this.dropTaskId = taskId;
        let draggableElement = this.template.querySelector('[data-id="' + taskId + '"]');
        draggableElement.classList.add('drag');
        this.handleTaskDrag(taskId);
    }

    taskDragEnd(event){
        const taskId = event.target.id.substr(0,18);
        //window.alert(taskId);
        let draggableElement = this.template.querySelector('[data-id="' + taskId + '"]');
        draggableElement.classList.remove('drag');
    }

    handleDrop(event){
        this.cancel(event);
        const columnUsed = event.target.id;
        let taskNewStatus;
        if(columnUsed.includes('InProgress')){
            taskNewStatus = 'System Design';
        }else if(columnUsed.includes('newTask')){
            taskNewStatus = 'Coding';
        }
        //window.alert(columnUsed + ' & '+ taskNewStatus);
        this.updateTaskStatus(this.dropTaskId, taskNewStatus);
        let draggableElement = this.template.querySelector('[data-role="drop-target"]');
        draggableElement.classList.remove('over');
    }

    handleDragEnter(event){
        this.cancel(event);
    }

    handleDragOver(event){
        this.cancel(event);
        let draggableElement = this.template.querySelector('[data-role="drop-target"]');
        draggableElement.classList.add('over');
    }

    handleDragLeave(event){
        this.cancel(event);
        let draggableElement = this.template.querySelector('[data-role="drop-target"]');
        draggableElement.classList.remove('over');
    }

    handleTaskDrag(taskId){
        console.log('$$$TEst: '+ taskId);
    }

    updateTaskStatus(taskId, taskNewStatus){
        updateTask({interviewCanidateId: taskId, newInterview: taskNewStatus}).then(result =>{
            this.getTaskData();
        }).catch(error =>{
            window.alert('$$$Test2:'+ JSON.stringify(error));
        })
    }

    cancel(event) {
        if (event.stopPropagation) event.stopPropagation();
        if (event.preventDefault) event.preventDefault();
        return false;
    };

}